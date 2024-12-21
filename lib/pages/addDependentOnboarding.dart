import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../services/add_dependant.dart';
import '../component/text_logo.dart'; // Ensure the TextLogo component is correctly imported
import '../pages/EnterCode.dart'; // Import the caretaker "Enter Code" page

class RegisterCareRecipientPage extends StatefulWidget {
  const RegisterCareRecipientPage({super.key});

  @override
  _RegisterCareRecipientPageState createState() =>
      _RegisterCareRecipientPageState();
}

class _RegisterCareRecipientPageState extends State<RegisterCareRecipientPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _allergicController = TextEditingController();
  final TextEditingController _diseaseController = TextEditingController();
  final CareRecipientService _careRecipientService = CareRecipientService();
  String? _generatedCode;

  Future<void> _addDependent() async {
    if (_formKey.currentState!.validate()) {
      try {
        final User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          final String code = await _careRecipientService.addDependent(
            name: _nameController.text,
            age: int.parse(_ageController.text),
            gender: _genderController.text,
            allergic: _allergicController.text,
            disease: _diseaseController.text,
            guardianId: currentUser.uid,
          );
          setState(() {
            _generatedCode = code;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dependent added successfully!')),
          );

          // Clear the form
          _nameController.clear();
          _ageController.clear();
          _genderController.clear();
          _allergicController.clear();
          _diseaseController.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No user is logged in')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add dependent: $e')),
        );
      }
    }
  }

  void _shareCode() {
    if (_generatedCode != null) {
      final String shareText =
          'Here is the code to join as a caretaker: $_generatedCode';
      Share.share(shareText, subject: 'Join as Caretaker');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No code available to share')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),

            // Add the TextLogo at the top
            const TextLogo(
              text: 'Julie',
              fontSize: 80.0,
              color: Color(0xFF624E88), // Purple text color
              borderColor: Color(0xFF624E88), // Purple border
              borderWidth: 2.0, // Thinner border
            ),
            const SizedBox(height: 24),

            // Show Generated Code or Form
            if (_generatedCode != null)
              _buildSuccessSection()
            else
              _buildFormSection(),

            // Add "Not a Guardian? Click Here" button at the bottom
            const SizedBox(height: 32),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EnterCodePage(), // Navigate to the caretaker page
                  ),
                );
              },
              child: const Text(
                'Not a guardian? Click here',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF624E88), // Purple text
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Name',
                hint: 'Enter dependent\'s name',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _ageController,
                label: 'Age',
                hint: 'Enter dependent\'s age',
                icon: Icons.calendar_today_outlined,
                inputType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _genderController,
                label: 'Gender',
                hint: 'Enter dependent\'s gender',
                icon: Icons.transgender_outlined,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _allergicController,
                label: 'Allergic',
                hint: 'Enter any allergies',
                icon: Icons.warning_amber_outlined,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _diseaseController,
                label: 'Disease',
                hint: 'Enter any known diseases',
                icon: Icons.health_and_safety_outlined,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _addDependent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF624E88),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'Add Dependent',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Dependent added successfully!',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Share this code with your caretaker:',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF624E88)),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            _generatedCode!,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF624E88),
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _shareCode,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF624E88),
          ),
          child: const Text('Share Code'),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
          ),
          child: const Text('Back to Dashboard'),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF624E88)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
