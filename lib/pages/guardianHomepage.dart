import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:juliemobiile/component/navbar.dart';
import 'package:juliemobiile/pages/dependentProfile.dart';
import 'package:juliemobiile/pages/forum.dart';
import 'package:juliemobiile/pages/health_diary.dart';
import 'package:juliemobiile/pages/medication_page.dart';
import 'package:juliemobiile/pages/task_page.dart';

class GuardianHomePage extends StatelessWidget {
  final User? user;

  const GuardianHomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return GoogleBottomBar(
      pages: [
        BloodPressureDashboard(),
        MedicationPage(),
        TaskPage(),
        HealthDiary(),
        ForumPage(),
      ],
    );
  }
}

class BloodPressureDashboard extends StatelessWidget {
  const BloodPressureDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Guardian',
          style: TextStyle(
            color: Color(0xFF624E88),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.elderly, color: Color(0xFF624E88)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DependentProfilePage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Blood Pressure Trends',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.lightBlue[50],
                ),
                child: Center(
                  child: const Text(
                    'Graph Placeholder',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Weekly Readings',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: List.generate(7, (index) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.favorite, color: Colors.red),
                      title: Text(
                          'Day ${index + 1}: Systolic: 120, Diastolic: 80'),
                      subtitle: Text('Pulse: 72 bpm'),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
