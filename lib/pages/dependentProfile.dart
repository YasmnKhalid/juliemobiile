import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_symbols_icons/symbols.dart';

class DependentProfilePage extends StatefulWidget {
  const DependentProfilePage({super.key});

  @override
  _DependentProfilePageState createState() => _DependentProfilePageState();
}

class _DependentProfilePageState extends State<DependentProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? dependentData; // Stores the care recipient's data
  String? caretakerName; // Stores the caretaker's name
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
        title: const Text('Dependent Profile'),
        backgroundColor: const Color(0xFF624E88),
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
              leading: const Icon(Icons.local_hospital),
              title: const Text('Disease'),
              subtitle: Text(dependentData!['disease'] ?? 'N/A'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Symbols.allergy),
              title: const Text('Allergies'),
              subtitle: Text(dependentData!['allergic'] ?? 'N/A'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.female),
              title: const Text('Gender'),
              subtitle: Text(dependentData!['gender'] ?? 'N/A'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Code'),
              subtitle: Text(dependentData!['code'] ?? 'N/A'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Caretaker'),
              subtitle: Text(caretakerName ?? 'N/A'),
            ),
          ],
        ),
      ),
    );
  }
}
