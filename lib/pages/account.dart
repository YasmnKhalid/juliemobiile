import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  String displayName = '';
  String email = '';
  String profilePicUrl = '';
  String initialPhone = '';
  String initialAddress = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
  final user = _auth.currentUser;

  if (user != null) {
    final userData = await _firestore.collection('users').doc(user.uid).get();

    if (userData.exists) {
      print("Fetched data: ${userData.data()}"); // Debugging
      setState(() {
        displayName = userData['displayName'] ?? '';
        email = userData['email'] ?? '';
        phoneController.text = initialPhone = userData['phone'] ?? '';
        addressController.text = initialAddress = userData['address'] ?? '';
      });
    } else {
      print("No document found for UID: ${user.uid}");
    }
  } else {
    print("No user is signed in.");
  }
}

  Future<void> _updateUserData() async {
    final user = _auth.currentUser;

    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'phone': phoneController.text,
        'address': addressController.text,
      });

      setState(() {
        initialPhone = phoneController.text;
        initialAddress = addressController.text;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void _navigateToHomePage(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/caretakerHome'); 
  }
   

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // ignore: deprecated_member_use
      onPopInvoked: (popDisposition) async {
        if (phoneController.text != initialPhone ||
            addressController.text != initialAddress) {
          final result = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Unsaved Changes"),
              content: const Text("You have unsaved changes. Do you want to discard them?"),
              actions: <Widget>[
                TextButton(
                  child: const Text("No"),
                  onPressed: () {
                    Navigator.pop(context, false); // Stay on the page
                  },
                ),
                TextButton(
                  child: const Text("Yes", style: TextStyle(color: Colors.red)),
                  onPressed: () {
                    Navigator.pop(context, true); // Leave the page
                  },
                ),
              ],
            ),
          );
          if (result == true) {
            _navigateToHomePage(context);
          }
        } else {
          _navigateToHomePage(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: Colors.teal,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (phoneController.text != initialPhone ||
                  addressController.text != initialAddress) {
                final result = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Unsaved Changes"),
                    content: const Text(
                        "You have unsaved changes. Do you want to discard them?"),
                    actions: <Widget>[
                      TextButton(
                        child: const Text("No"),
                        onPressed: () {
                          Navigator.pop(context, false); // Stay on the page
                        },
                      ),
                      TextButton(
                        child: const Text("Yes",
                            style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          Navigator.pop(context, true); // Leave the page
                        },
                      ),
                    ],
                  ),
                );
                if (result == true) {
                  _navigateToHomePage(context); // Navigate to homepage
                }
              } else {
                _navigateToHomePage(context); // Navigate to homepage
              }
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Picture
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: profilePicUrl.isNotEmpty
                        ? NetworkImage(profilePicUrl)
                        : null,
                    backgroundColor: Colors.grey.shade200,
                    child: profilePicUrl.isEmpty
                        ? const Icon(Icons.person, size: 50, color: Colors.grey)
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.teal),
                    onPressed: () {
                      // Implement profile picture upload
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Non-editable display name
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Display Name'),
                subtitle: Text(displayName),
              ),
              const Divider(),

              // Non-editable email
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Email'),
                subtitle: Text(email),
              ),
              const Divider(),

              // Editable phone number
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Editable address
              TextField(
                controller: addressController,
                keyboardType: TextInputType.streetAddress,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),

              // Save Button
              ElevatedButton(
                onPressed: _updateUserData,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  iconColor: Colors.teal,
                ),
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}