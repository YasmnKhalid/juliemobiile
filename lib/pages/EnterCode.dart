import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'caretakerHomepage.dart';

class EnterCodePage extends StatefulWidget {
  const EnterCodePage({super.key});

  @override
  _EnterCodePageState createState() => _EnterCodePageState();
}

class _EnterCodePageState extends State<EnterCodePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();

  Future<bool> validateCaretakerCode(String enteredCode) async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    return false; // User not authenticated
  }

  final userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(currentUser.uid)
      .get();

  if (!userDoc.exists || userDoc['role'] != 'caretaker') {
    return false; // User not a caretaker
  }

  try {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('care_recipients')
        .where('code', isEqualTo: enteredCode)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final DocumentSnapshot careRecipientDoc = querySnapshot.docs.first;
      final String careRecipientId = careRecipientDoc.id;

      // Update caretaker document with careRecipientId
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({'careRecipientId': careRecipientId});

      // Update care recipient document with caretakerId
      await FirebaseFirestore.instance
          .collection('care_recipients')
          .doc(careRecipientId)
          .update({'caretakerId': currentUser.uid});

      return true;
    }

    return false; // Code not found
  } catch (e) {
    print('Error validating code: $e');
    return false;
  }
}


 Future<void> _submitCode() async {
  if (_formKey.currentState!.validate()) {
    final code = _codeController.text.trim();

    try {
      // Debugging log
      print('Querying care_recipients with code: $code');

      final isValidCode = await validateCaretakerCode(code);

      if (isValidCode) {
        // Navigate to CaretakerHomePage
        final currentUser = FirebaseAuth.instance.currentUser;

        if (currentUser != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CaretakerHomePage(user: currentUser),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not authenticated.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid code. Please try again.')),
        );
      }
    } catch (e) {
      print('Error validating code: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error validating code: $e')),
      );
    } finally {
      _codeController.clear();
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      appBar: AppBar(
        title: const Text('Enter Code'),
        backgroundColor: const Color(0xFF624E88),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),

              // Title or Instruction
              const Text(
                'Enter the code provided by the guardian',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF624E88),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Form
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _codeController,
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a code';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Enter Code',
                    hintText: 'e.g., ABC123',
                    prefixIcon:
                        const Icon(Icons.vpn_key, color: Color(0xFF624E88)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF624E88),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'Submit Code',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Back Button
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Navigate back to the previous page
                },
                child: const Text(
                  'Back to Home',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF624E88),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
