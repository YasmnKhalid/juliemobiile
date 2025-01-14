import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/NotificationService.dart';

class MedicationHelper {
  final NotificationService _notificationService = NotificationService();

  void addMedication(BuildContext context) {
    TextEditingController medNameController = TextEditingController();
    TextEditingController brandNameController = TextEditingController();
    TextEditingController formController = TextEditingController();
    TextEditingController purposeController = TextEditingController();
    TextEditingController frequencyController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Medication'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: medNameController,
                  decoration: InputDecoration(
                    labelText: 'Medication Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: brandNameController,
                  decoration: InputDecoration(
                    labelText: 'Brand Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: formController,
                  decoration: InputDecoration(
                    labelText: 'Form (e.g., tablet)',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: purposeController,
                  decoration: InputDecoration(
                    labelText: 'Purpose',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: frequencyController,
                  decoration: InputDecoration(
                    labelText: 'How Often',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextButton(
                  child: Text(
                      'Set Reminder Time: ${selectedTime.format(context)}'),
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      selectedTime = time;
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                final medicationData = {
                  'medicationName': medNameController.text,
                  'brandName': brandNameController.text,
                  'form': formController.text,
                  'purpose': purposeController.text,
                  'frequency': frequencyController.text,
                  'reminderTime': '${selectedTime.hour}:${selectedTime.minute}',
                };

                // Save to Firestore
                FirebaseFirestore.instance
                    .collection('medication')
                    .add(medicationData);

                // Schedule notification
                _notificationService.scheduleNotification(
                  medNameController.text,
                  'Time to take your medication!',
                  selectedTime,
                );

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
