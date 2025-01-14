import 'package:flutter/material.dart';
import 'package:juliemobiile/utils/MedicationHelper.dart';

class MedicationPage extends StatefulWidget {
  const MedicationPage({super.key});

  @override
  _MedicationPageState createState() => _MedicationPageState();
}

class _MedicationPageState extends State<MedicationPage> {
  bool _showFABs = false; // State to toggle visibility of FABs

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage('https://picsum.photos/200'),
            ),
            const SizedBox(width: 8),
            const Text(
              'Yasmin',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.white),
          ],
        ),
        backgroundColor: const Color(0xFF624E88),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Calendar View
          Container(
            color: const Color(0xFF624E88),
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              children: [
                const Text(
                  'Today, 27 Dec',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(7, (index) {
                    return Column(
                      children: [
                        Text(
                          ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index],
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        CircleAvatar(
                          backgroundColor: index == 4 ? Colors.teal : Colors.transparent,
                          radius: 12,
                          child: Text(
                            (23 + index).toString(),
                            style: TextStyle(
                              color: index == 4 ? Colors.white : Colors.grey[300],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
          // Medication List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildMedicationCard('Sertraline', '50 mg, Take 1 Pill(s)', '22:00'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFABs(),
    );
  }

  // Helper method to build the medication card
  Widget _buildMedicationCard(String title, String description, String time) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: const CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage('https://picsum.photos/200'),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          description,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        trailing: Text(
          time,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  // Helper method to build FABs
  Widget _buildFABs() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_showFABs) ...[
          _buildActionButton(Icons.add, 'Add Medication', Colors.pink, () {
            MedicationHelper().addMedication(context);// Handle Add Medication
          }),
          const SizedBox(height: 8),
          _buildActionButton(Icons.add_task, 'Add Tracker Entry', Colors.blue, () {
            // Handle Add Tracker Entry
          }),
          const SizedBox(height: 8),
          _buildActionButton(Icons.check_circle_outline, 'Add Dose', Colors.purple, () {
            // Handle Add Dose
          }),
          const SizedBox(height: 16),
        ],
        FloatingActionButton(
          onPressed: () {
            setState(() {
              _showFABs = !_showFABs; // Toggle visibility of FABs
            });
          },
          backgroundColor: const Color(0xFF624E88),
          child: Icon(_showFABs ? Icons.close : Icons.add, color: Colors.white),
        ),
      ],
    );
  }

  // Helper method to build each action button
  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onPressed) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: label,
          onPressed: onPressed,
          backgroundColor: color,
          mini: true,
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }
}
