 import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:juliemobiile/pages/calendar_page.dart';
import 'package:juliemobiile/pages/forum.dart';
import 'package:juliemobiile/pages/medication_page.dart';
import 'package:juliemobiile/pages/task_page.dart';
import '../component/navbar.dart';

class CaretakerHomePage extends StatelessWidget {
  final User? user;

  const CaretakerHomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return GoogleBottomBar(
      pages: [
        Center(
          child: Text(
            'Welcome back, Caretaker!',
            style: const TextStyle(fontSize: 24),
            textAlign: TextAlign.center,
          ),
        ),
        MedicationPage(),
        TaskPage(),
        CalendarPage(),
        ForumPage(),
      ],
    );
  }
}

// class CaretakerHomePage extends StatelessWidget {
//   const CaretakerHomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Center(child: Text("Home Page"));
//   }
// }