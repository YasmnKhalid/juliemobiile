import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter/services.dart'; // For Clipboard functionality
import 'package:share_plus/share_plus.dart';

class DependentProfilePage extends StatefulWidget {
  const DependentProfilePage({super.key});

  @override
  _DependentProfilePageState createState() => _DependentProfilePageState();
}

class _DependentProfilePageState extends State<DependentProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? dependentData; // Stores the care recipient's data
  String? caretakerName; // Stores the caretaker's name
  String mortalityStatus = 'alive'; // Default mortality status
  TextEditingController diseaseController = TextEditingController();
  TextEditingController allergicController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDependentData();
  }

  Future<void> _loadDependentData() async {
    try {
      // Get the current user's ID
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Fetch the care recipient data where guardianId matches the current user
        final querySnapshot = await _firestore
            .collection('care_recipients')
            .where('guardianId', isEqualTo: user.uid)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          dependentData = querySnapshot.docs.first.data();

          // Initialize controllers and mortality status
          diseaseController.text = dependentData!['disease'] ?? '';
          allergicController.text = dependentData!['allergic'] ?? '';
          mortalityStatus = dependentData!['mortalityStatus'] ?? 'alive';

          // Fetch caretaker's name if caretakerId exists
          if (dependentData?['caretakerId'] != null) {
            final caretakerDoc = await _firestore
                .collection('users')
                .doc(dependentData!['caretakerId'])
                .get();

            if (caretakerDoc.exists) {
              caretakerName = caretakerDoc['name'] ?? 'Unknown Caretaker';
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching dependent data: $e');
    }

    setState(() {
      isLoading = false; // Stop loading once the data is fetched
    });
  }

  Future<void> _updateDependentData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null && dependentData != null) {
        // Update the care recipient document
        final docId = (await _firestore
                .collection('care_recipients')
                .where('guardianId', isEqualTo: user.uid)
                .get())
            .docs
            .first
            .id;

        await _firestore.collection('care_recipients').doc(docId).update({
          'disease': diseaseController.text,
          'allergic': allergicController.text,
          'mortalityStatus': mortalityStatus,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dependent data updated successfully!')),
        );
      }
    } catch (e) {
      print('Error updating dependent data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update dependent data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (dependentData == null) {
      return const Scaffold(
        body: Center(
          child: Text('No dependent data found.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dependent Profile',
          style: TextStyle(
            color: Color(0xFF624E88),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display care recipient information
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Name'),
              subtitle: Text(dependentData!['name'] ?? 'N/A'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.cake),
              title: const Text('Age'),
              subtitle: Text(dependentData!['age'].toString()),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Code'),
              subtitle: Text(dependentData!['code'] ?? 'N/A'),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'copy') {
                    Clipboard.setData(
                        ClipboardData(text: dependentData!['code']));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Code copied to clipboard')),
                    );
                  } else if (value == 'share') {
                    Share.share('Dependent Code: ${dependentData!['code']}');
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'copy',
                    child: Text('Copy Code'),
                  ),
                  const PopupMenuItem(
                    value: 'share',
                    child: Text('Share Code'),
                  ),
                ],
              ),
            ),

            // Editable Disease Field
            TextField(
              controller: diseaseController,
              decoration: const InputDecoration(
                labelText: 'Disease',
                prefixIcon: Icon(Icons.local_hospital),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Editable Allergic Field
            TextField(
              controller: allergicController,
              decoration: const InputDecoration(
                labelText: 'Allergies',
                prefixIcon: Icon(Symbols.allergy),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Mortality Status Dropdown
            DropdownButtonFormField<String>(
              value: mortalityStatus,
              decoration: const InputDecoration(
                labelText: 'Mortality Status',
                prefixIcon: Icon(Icons.heart_broken),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'alive',
                  child: Text('Alive'),
                ),
                DropdownMenuItem(
                  value: 'deceased',
                  child: Text('Deceased'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  mortalityStatus = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Save Button
            ElevatedButton(
              onPressed: _updateDependentData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF624E88),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text(
                'Save Changes',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    diseaseController.dispose();
    allergicController.dispose();
    super.dispose();
  }
}
