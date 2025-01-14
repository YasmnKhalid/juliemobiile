import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:juliemobiile/services/globalVariable.dart';

/// Use nullable type to handle initialization

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  _TaskPage createState() => _TaskPage();
}

class _TaskPage extends State<TaskPage> {
  DateTime _selectedDate = DateTime.now();
  String _selectedPriority = "Low";
  int selectedTabIndex = 0;
  final TextEditingController _taskTitleController = TextEditingController();
  final TextEditingController _taskDescriptionController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (globalRole == null) {
      return const Center(
        child: CircularProgressIndicator(),
      ); // Wait until globalRole is initialized
    }

    if (globalRole == 'unknown') {
      return const Center(
        child: Text(
          'Error: User role is not defined or invalid.',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '${_selectedDate.monthName()} ${_selectedDate.year}',
          style: const TextStyle(
            color: Color(0xFF624E88),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.calendar_today),
          //   onPressed: () {
          //     Navigator.pushNamed(context, '/calendar');
          //   },
          // ),
        ],
      ),
      body: Column(
        children: [
          _buildWeekView(),
          const Divider(),
          Expanded(
            child: Builder(
              builder: (context) {
                return FutureBuilder<String>(
                  future: globalRole != null && globalRole != 'unknown'
                      ? getAssignedPatientId(globalRole!, currentUserId)
                      : Future.error(
                          'Global role is not initialized or invalid.'),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                            'Error fetching careRecipientId: ${snapshot.error}'),
                      );
                    }

                    final careRecipientId = snapshot.data;

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('tasks')
                          .where('assignedFor', isEqualTo: careRecipientId)
                          .where('date',
                              isEqualTo:
                                  _selectedDate.toString().substring(0, 10))
                          .snapshots(),
                      builder: (context, taskSnapshot) {
                        if (taskSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (taskSnapshot.hasError) {
                          return const Center(
                              child: Text('Error loading tasks.'));
                        }

                        final tasks = taskSnapshot.data?.docs ?? [];
                        final uncompletedTasks = tasks
                            .where((task) => !(task['isCompleted'] ?? false))
                            .toList();
                        final completedTasks = tasks
                            .where((task) => task['isCompleted'] ?? false)
                            .toList();

                        return ListView(
                          children: [
                            ...uncompletedTasks
                                .map((task) => _buildTaskItem(task, false)),
                            ...completedTasks
                                .map((task) => _buildTaskItem(task, true)),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF624E88),
        onPressed: () => _showCreateTaskDialog(context, currentUserId),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildWeekView() {
    final DateTime today = DateTime.now();
    final int currentWeekDay = today.weekday; // 1 = Monday, 7 = Sunday
    final DateTime startOfWeek =
        today.subtract(Duration(days: currentWeekDay - 1));
    final List<DateTime> weekDays = List.generate(7, (index) {
      return startOfWeek.add(Duration(days: index));
    });

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: weekDays.length,
        itemBuilder: (context, index) {
          final DateTime date = weekDays[index];
          final bool isSelected = _selectedDate.isSameDate(date);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
            },
            child: Container(
              width: 50,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color:
                    isSelected ? const Color(0xFF624E88) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    date.weekdayName(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getPriorityColor(String? priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.blue;
      default:
        return Colors.grey; // Default color
    }
  }

  Widget _buildTaskItem(QueryDocumentSnapshot task, bool isCompleted) {
    final String priority =
        task['priority'] ?? 'Low'; // Default to 'Low' if missing

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      elevation: 2,
      child: ListTile(
        leading: Checkbox(
          value: isCompleted,
          activeColor: const Color(0xFF624E88),
          onChanged: (value) async {
            await FirebaseFirestore.instance
                .collection('tasks')
                .doc(task.id)
                .update({'isCompleted': value});
          },
        ),
        title: Text(
          task['title'] ?? 'No Title',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isCompleted ? Colors.grey : Colors.black,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task['description'] ?? 'No Description',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              'Due: ${task['date']}',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        trailing: Icon(
          Icons.circle,
          color: _getPriorityColor(priority),
          size: 16,
        ),
      ),
    );
  }

  Widget _buildCompletedSection(int completedCount, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 175, 163, 198),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'COMPLETED',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Text(
                  '$completedCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsTab(
      BuildContext context, StateSetter setState, TabController tabController) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _taskTitleController,
            decoration: InputDecoration(
              labelText: "Task Title",
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF624E88)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _taskDescriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: "Task Description",
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF624E88)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Priority:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ChoiceChip(
                label: Text("High"),
                selected: _selectedPriority == "High",
                onSelected: (selected) {
                  setState(() {
                    _selectedPriority = selected ? "High" : _selectedPriority;
                  });
                },
                selectedColor: Colors.red,
              ),
              ChoiceChip(
                label: Text("Medium"),
                selected: _selectedPriority == "Medium",
                onSelected: (selected) {
                  setState(() {
                    _selectedPriority = selected ? "Medium" : _selectedPriority;
                  });
                },
                selectedColor: Colors.orange,
              ),
              ChoiceChip(
                label: Text("Low"),
                selected: _selectedPriority == "Low",
                onSelected: (selected) {
                  setState(() {
                    _selectedPriority = selected ? "Low" : _selectedPriority;
                  });
                },
                selectedColor: Colors.blue,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() {
              // Switch to the Date tab
              tabController.animateTo(1);
            }),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF624E88),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              "Set Date",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  } //builddetails

  Widget _buildDateTab(BuildContext context, String currentUserId) {
    return Column(
      children: [
        Expanded(
          child: CalendarDatePicker(
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            onDateChanged: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
          ),
        ),
        const Divider(),
        ElevatedButton(
          onPressed: () async {
            final title = _taskTitleController.text.trim();
            final description = _taskDescriptionController.text.trim();

            if (title.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Task title cannot be empty.')),
              );
              return;
            }

            try {
              // Determine role of currentUserId (e.g., from your Firestore user collection or state)
              String role = await determineUserRole(currentUserId);

              // Prepare the assignedFor field (this could come from the UI or logic)
              String assignedFor =
                  await getAssignedPatientId(role, currentUserId);

              // Add task to Firestore
              await FirebaseFirestore.instance.collection('tasks').add({
                'title': title,
                'description': description,
                'priority': _selectedPriority,
                'isCompleted': false,
                'date': _selectedDate.toString().substring(0, 10),
                'assignedBy':
                    role, // Dynamically assign 'Caretaker' or 'Guardian'
                'createdBy': currentUserId,
                'assignedFor':
                    assignedFor, // PatientId associated with the caretaker or guardian
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Task created successfully.')),
              );
              Navigator.pop(context);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error creating task: $e')),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF624E88),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text(
            "Create Task",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Future<String> getAssignedPatientId(String role, String userId) async {
    try {
      // Fetch user document based on role
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        String? careRecipientId = userDoc.data()?['careRecipientId'];

        if (careRecipientId != null && careRecipientId.isNotEmpty) {
          return careRecipientId;
        } else {
          throw Exception('No careRecipientId found for this user.');
        }
      } else {
        throw Exception('User document does not exist.');
      }
    } catch (e) {
      print('Error fetching careRecipientId: $e');
      rethrow;
    }
  }

  // Future<String> getCareRecipientId() async {
  //   try {
  //     String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  //     // Fetch the user document from the Firestore 'users' collection
  //     var userDoc = await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(currentUserId)
  //         .get();

  //     if (userDoc.exists) {
  //       // Return the careRecipientId field from the document
  //       return userDoc.data()?['careRecipientId'] ??
  //           ''; // Default to an empty string if the field is null
  //     } else {
  //       throw Exception('User document does not exist!');
  //     }
  //   } catch (error) {
  //     print('Error fetching careRecipientId: $error');
  //     throw Exception('Failed to fetch careRecipientId');
  //   }
  // }

  Future<void> _showCreateTaskDialog(
      BuildContext context, String currentUserId) async {
    _taskTitleController.clear();
    _taskDescriptionController.clear();

    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return DefaultTabController(
              length: 2,
              child: Builder(
                builder: (BuildContext innerContext) {
                  final TabController tabController =
                      DefaultTabController.of(innerContext);

                  return Container(
                    height: MediaQuery.of(context).size.height * 0.75,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Tab Bar
                        TabBar(
                          controller: tabController,
                          indicatorColor: const Color(0xFF624E88),
                          labelColor: const Color(0xFF624E88),
                          unselectedLabelColor: Colors.grey,
                          tabs: const [
                            Tab(text: "Details"),
                            Tab(text: "Date"),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: tabController,
                            children: [
                              _buildDetailsTab(
                                  innerContext, setState, tabController),
                              _buildDateTab(innerContext, currentUserId),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

extension DateTimeExtension on DateTime {
  String monthName() {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  String weekdayName() {
    const weekdays = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];
    return weekdays[weekday - 1];
  }

  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
