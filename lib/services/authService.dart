import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:juliemobiile/pages/EnterCode.dart';
import '../pages/caretakerHomepage.dart';
import '../pages/guardianHomepage.dart';
import '../pages/addDependentOnboarding.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the sign-in
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google Sign-In cancelled')),
        );
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);

      // Navigate based on user role (Guardian or Caretaker)
      _navigateUser(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In failed: $error')),
      );
    }
  }

  Future<void> signInWithEmailAndPassword(
      BuildContext context, String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password.trim());
      // Navigate based on user role (Guardian or Caretaker)
      _navigateUser(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    }
  }

  Future<void> registerWithEmailAndPassword(BuildContext context, String email,
      String password, String role, String name) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final User? user = userCredential.user;

      // Optionally update the display name in FirebaseAuth
      await user?.updateDisplayName(name);

      // Save user details in Firestore
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'email': user.email ?? 'unknown',
          'role': role,
          'name': name.trim(), // Save the provided name
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User registered: ${user?.email ?? 'unknown'}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    }
  }

 void _navigateUser(BuildContext context) async {
  final User? user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    // Handle case where no user is signed in
    print('No user is signed in');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No user is signed in.')),
    );
    return;
  }

  print('User ID: ${user.uid}');

  try {
    // Fetch the user's document from Firestore
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!userDoc.exists || userDoc.data() == null) {
      // Handle case where user document does not exist
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User document not found. Please contact support.'),
        ),
      );
      return;
    }

    // Retrieve the role from the Firestore document
    final String? role = userDoc['role'];
    if (role == null) {
      // Handle missing role field
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User role not found in Firestore.')),
      );
      return;
    }

    if (role == 'guardian') {
      await _handleGuardianNavigation(context, user);
    } else if (role == 'caretaker') {
      await _handleCaretakerNavigation(context, user);
    } else {
      // Handle unknown roles
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unknown user role. Please contact support.'),
        ),
      );
    }
  } catch (e) {
    // Handle any exceptions during Firestore query
    print('Error fetching user data: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error fetching user data: $e')),
    );
  }
}

Future<void> _handleGuardianNavigation(BuildContext context, User user) async {
  try {
    // Check if the guardian has any dependents in Firestore
    final QuerySnapshot dependentsSnapshot = await FirebaseFirestore.instance
        .collection('care_recipients')
        .where('guardianId', isEqualTo: user.uid)
        .get();

    if (dependentsSnapshot.docs.isEmpty) {
      // No dependents found; navigate to onboarding page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RegisterCareRecipientPage(),
        ),
      );
    } else {
      // Dependents exist; navigate to GuardianHomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GuardianHomePage(user: user),
        ),
      );
    }
  } catch (e) {
    print('Error during guardian navigation: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error during guardian navigation: $e')),
    );
  }
}

Future<void> _handleCaretakerNavigation(BuildContext context, User user) async {
  try {
    // Check if the caretaker is linked to any dependents in Firestore
    final QuerySnapshot dependentsSnapshot = await FirebaseFirestore.instance
        .collection('care_recipients')
        .where('caretakerId', isEqualTo: user.uid)
        .get();

    if (dependentsSnapshot.docs.isEmpty) {
      // No dependents found; navigate to code entry page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EnterCodePage(),
        ),
      );
    } else {
      // Dependents exist; navigate to CaretakerHomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CaretakerHomePage(user: user),
        ),
      );
    }
  } catch (e) {
    print('Error during caretaker navigation: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error during caretaker navigation: $e')),
    );
  }
}


  Future<void> otpSignIn(BuildContext context) async {
    // Implement OTP sign-in method here
  }
}
