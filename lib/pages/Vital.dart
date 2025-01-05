import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_symbols_icons/symbols.dart';

class VitalSignsPage extends StatefulWidget {
  const VitalSignsPage({super.key});

  @override
  _VitalSignsPageState createState() => _VitalSignsPageState();
}

class _VitalSignsPageState extends State<VitalSignsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _heartRateController = TextEditingController();
  final TextEditingController _bloodPressureController =
      TextEditingController();
  final TextEditingController _spo2Controller = TextEditingController();
  final TextEditingController _bloodSugarController = TextEditingController();
  bool _isLoading = false;

  Future<void> _saveVitals() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final String caretakerId =
          FirebaseAuth.instance.currentUser?.uid ?? 'unknown';

      // Fetch the careRecipientId from the 'users' collection
      final DocumentSnapshot caretakerDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(caretakerId)
          .get();

      if (!caretakerDoc.exists || caretakerDoc['role'] != 'caretaker') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Caretaker record not found or invalid role.')),
        );
        return;
      }

      final String careRecipientId = caretakerDoc['careRecipientId'];

      if (careRecipientId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No care recipient linked to this caretaker.')),
        );
        return;
      }

      // Save vitals to Firestore
      await FirebaseFirestore.instance.collection('vital_signs').add({
        'careRecipientId': careRecipientId,
        'caretakerId': caretakerId,
        'heartRate': int.parse(_heartRateController.text.trim()),
        'bloodPressure': _bloodPressureController.text.trim(),
        'spo2': int.parse(_spo2Controller.text.trim()),
        'bloodSugar': double.parse(_bloodSugarController.text.trim()),
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vital signs saved successfully!')),
      );

      // Clear input fields
      _heartRateController.clear();
      _bloodPressureController.clear();
      _spo2Controller.clear();
      _bloodSugarController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving vital signs: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Record Vital Signs',
          style: TextStyle(
            color: Color(0xFF624E88),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent, // Purple theme
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _heartRateController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Heart Rate (BPM)',
                      border: OutlineInputBorder(),
                      prefixIcon:
                          Icon(Symbols.pulse_alert, color: Color(0xFF624E88))),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter heart rate';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bloodPressureController,
                  decoration: const InputDecoration(
                      labelText: 'Blood Pressure (e.g., 120/80)',
                      border: OutlineInputBorder(),
                      prefixIcon:
                          Icon(Symbols.cardiology, color: Color(0xFF624E88))),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter blood pressure';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _spo2Controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'SPO₂ Level (%)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Symbols.spo2, color: Color(0xFF624E88))),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter SPO₂ level';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bloodSugarController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Blood Sugar Level (mg/dL)',
                      border: OutlineInputBorder(),
                      prefixIcon:
                          Icon(Symbols.glucose, color: Color(0xFF624E88))),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter blood sugar level';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveVitals,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF624E88), // Purple theme
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            'Save Vitals',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
