import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:juliemobiile/pages/forum.dart';
import 'package:juliemobiile/pages/health_diary.dart';
import 'package:juliemobiile/pages/medication_page.dart';
import 'package:juliemobiile/pages/task_page.dart';
import '../component/navbar.dart';

class CaretakerHomePage extends StatelessWidget {
  final User? user;

  const CaretakerHomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return GoogleBottomBar(
      pages: [
        _buildDashboardPage(context),
        MedicationPage(),
        TaskPage(),
        HealthDiary(),
        ForumPage(),
      ],
    );
  }

  Widget _buildDashboardPage(BuildContext context) {
    final String caretakerId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Caretaker',
          style: TextStyle(
            color: Color(0xFF624E88),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Color(0xFF624E88)),
            onPressed: () {
              // Handle notification icon click
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(caretakerId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No caretaker data found.'));
          }

          final caretakerData = snapshot.data!.data() as Map<String, dynamic>;
          final careRecipientId = caretakerData['careRecipientId'] ?? '';

          if (careRecipientId.isEmpty) {
            return const Center(child: Text('No care recipient associated.'));
          }

          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('care_recipients')
                .doc(careRecipientId)
                .snapshots(),
            builder: (context, recipientSnapshot) {
              if (recipientSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!recipientSnapshot.hasData ||
                  recipientSnapshot.data == null) {
                return const Center(
                    child: Text('No care recipient data found.'));
              }

              final careRecipientData =
                  recipientSnapshot.data!.data() as Map<String, dynamic>;
              final patientName =
                  careRecipientData['name'] ?? 'Unknown Patient';
              final guardianId = careRecipientData['guardianId'];

              if (guardianId == null) {
                return const Center(child: Text('Guardian not assigned.'));
              }

              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(guardianId)
                    .snapshots(),
                builder: (context, guardianSnapshot) {
                  if (guardianSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!guardianSnapshot.hasData ||
                      guardianSnapshot.data == null) {
                    return const Center(
                        child: Text('Guardian information not found.'));
                  }

                  final guardianData =
                      guardianSnapshot.data!.data() as Map<String, dynamic>;
                  final guardianName =
                      guardianData['name'] ?? 'Unknown Guardian';

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Patient and Guardian Section
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Patient Name: $patientName',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Guardian Name: $guardianName',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    // Handle Emergency
                                  },
                                  icon: const Icon(Icons.warning,
                                      color: Colors.white),
                                  label: const Text('Emergency'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
// Upcoming Tasks Section
                       StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('tasks')
      .where('createdBy', isEqualTo: caretakerId) // Adjust the field here
      .where('isCompleted', isEqualTo: false)
      .snapshots(),
  builder: (context, taskSnapshot) {
    if (taskSnapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!taskSnapshot.hasData || taskSnapshot.data!.docs.isEmpty) {
      return Column(
        children: [
          const SizedBox(height: 8),
          const Text(
            'Upcoming Tasks',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF624E88),
            ),
          ),
          const SizedBox(height: 16),
          Icon(
            Icons.task_alt,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          const Text(
            'No upcoming tasks',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    final tasks = taskSnapshot.data!.docs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Align label and cards
      children: [
        const SizedBox(height: 8),
        const Text(
          'Upcoming Tasks',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF624E88),
          ),
        ),
        const SizedBox(height: 16),
        ...tasks.map((task) {
          final taskData = task.data() as Map<String, dynamic>;
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            child: ListTile(
              title: Text(taskData['title'] ?? 'No Title'),
              subtitle: Text(
                  'Due Date: ${taskData['dueDate'] ?? 'Unknown Date'}'),
              trailing: const Icon(Icons.check_circle_outline,
                  color: Colors.grey),
              onTap: () {
                // Navigate to task details or page
              },
            ),
          );
        }),
      ],
    );
  },
),

                        const SizedBox(height: 16),
// Upcoming Medications Section
                        // const Text(
                        //   'Upcoming Medications',
                        //   style: TextStyle(
                        //     fontWeight: FontWeight.bold,
                        //     fontSize: 18,
                        //     color: Color(0xFF624E88),
                        //   ),
                        // ),
                        // const SizedBox(height: 8),
                        // medications.isEmpty
                        //     ? Column(
                        //         children: [
                        //           Icon(
                        //             Icons.medical_services_outlined,
                        //             size: 48,
                        //             color: Colors.grey[400],
                        //           ),
                        //           const SizedBox(height: 8),
                        //           const Text(
                        //             'No upcoming medications',
                        //             style: TextStyle(
                        //               color: Colors.grey,
                        //               fontSize: 16,
                        //               fontWeight: FontWeight.w500,
                        //             ),
                        //           ),
                        //         ],
                        //       )
                        //     : Card(
                        //         shape: RoundedRectangleBorder(
                        //           borderRadius: BorderRadius.circular(12),
                        //         ),
                        //         elevation: 4,
                        //         child: ListTile(
                        //           title: const Text('Medication Name'),
                        //           subtitle: const Text('Time: 10:00 AM'),
                        //           trailing: const Icon(
                        //               Icons.medical_services_outlined,
                        //               color: Colors.grey),
                        //           onTap: () {
                        //             // Navigate to medication details or page
                        //           },
                        //   // ),
                        // ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTasksSection(String careRecipientId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tasks')
          .where('careRecipientId', isEqualTo: careRecipientId)
          .where('isCompleted', isEqualTo: false)
          .snapshots(),
      builder: (context, taskSnapshot) {
        if (taskSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!taskSnapshot.hasData || taskSnapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No upcoming tasks.'));
        }

        final tasks = taskSnapshot.data!.docs;

        return Column(
          children: tasks.map((task) {
            final taskData = task.data() as Map<String, dynamic>;
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: ListTile(
                title: Text(taskData['title'] ?? 'No Title'),
                subtitle:
                    Text('Due Date: ${taskData['dueDate'] ?? 'Unknown Date'}'),
                trailing:
                    const Icon(Icons.check_circle_outline, color: Colors.grey),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildMedicationsSection(String careRecipientId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('medications')
          .where('careRecipientId', isEqualTo: careRecipientId)
          .where('date',
              isGreaterThanOrEqualTo: DateTime.now().toIso8601String())
          .snapshots(),
      builder: (context, medSnapshot) {
        if (medSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!medSnapshot.hasData || medSnapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No upcoming medications.'));
        }

        final medications = medSnapshot.data!.docs;

        return Column(
          children: medications.map((med) {
            final medData = med.data() as Map<String, dynamic>;
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: ListTile(
                title: Text(medData['name'] ?? 'No Name'),
                subtitle: Text('Time: ${medData['time'] ?? 'Unknown Time'}'),
                trailing: const Icon(Icons.medical_services_outlined,
                    color: Colors.grey),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
