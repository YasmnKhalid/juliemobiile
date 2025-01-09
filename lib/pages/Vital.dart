import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_symbols_icons/symbols.dart';

class VitalSignsForm extends StatefulWidget {
  const VitalSignsForm({super.key});

  @override
  _VitalSignsFormState createState() => _VitalSignsFormState();
}

class _VitalSignsFormState extends State<VitalSignsForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _heartRateController = TextEditingController();
  final TextEditingController _bloodPressureController = TextEditingController();
  final TextEditingController _spo2Controller = TextEditingController();
  final TextEditingController _bloodSugarController = TextEditingController();
  bool _isLoading = false;

  Future<void> _saveVitals() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final String caretakerId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';

      final DocumentSnapshot caretakerDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(caretakerId)
          .get();

      if (!caretakerDoc.exists || caretakerDoc['role'] != 'caretaker') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Caretaker record not found or invalid role.')),
        );
        return;
      }

      final String careRecipientId = caretakerDoc['careRecipientId'];
      if (careRecipientId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No care recipient linked to this caretaker.')),
        );
        return;
      }

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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(
                controller: _heartRateController,
                label: 'Heart Rate (BPM)',
                icon: Symbols.pulse_alert,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _bloodPressureController,
                label: 'Blood Pressure (e.g., 120/80)',
                icon: Symbols.cardiology,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _spo2Controller,
                label: 'SPO₂ Level (%)',
                icon: Symbols.spo2,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _bloodSugarController,
                label: 'Blood Sugar Level (mg/dL)',
                icon: Symbols.glucose,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveVitals,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF624E88),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Vitals', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon, color: const Color(0xFF624E88)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }
}
