import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GuardianHomePage extends StatelessWidget {
  final User? user;

  const GuardianHomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guardian Home'),
      ),
      body: Center(
        child: Text(
          'Welcome back, ${user?.email ?? 'Guardian'}!',
          style: const TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
