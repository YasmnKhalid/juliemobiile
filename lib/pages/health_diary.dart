import 'package:flutter/material.dart';

class HealthDiary extends StatelessWidget {
  const HealthDiary({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Health Diary',
          style: TextStyle(
            color: Color(0xFF624E88),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent, // Purple theme
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: 100, // Adjust the width as needed
            height: 100, // Adjust the height as needed
            decoration: BoxDecoration(
              shape: BoxShape.circle, // Make the container circular
              border: Border.all(
                color: const Color(0xFF624E88), // Border color (purple theme)
                width: 1.0, // Border thickness
              ),
              image: DecorationImage(
                image: NetworkImage(
                    'https://picsum.photos/200'), // Random image from Lorem Picsum
                fit: BoxFit.cover, // Ensure the image fits within the circle
              ),
            ),
          ),

          const SizedBox(height: 16),
          SizedBox(
            height: 300, // Adjust this height as needed for the grid size
            child: GridView.count(
              padding:
                  const EdgeInsets.all(24.0), // Adjust padding for larger space
              crossAxisCount: 2,
              crossAxisSpacing: 20.0, // Adjust horizontal spacing between items
              mainAxisSpacing: 20.0, // Adjust vertical spacing between items
              childAspectRatio:
                  4 / 3, // Adjust the aspect ratio of each grid item
              physics:
                  const NeverScrollableScrollPhysics(), // Disable scrolling
              children: [
                _buildDetailCard('Age', '75 yrs', Icons.cake_outlined),
                _buildDetailCard('Blood Type', 'O+', Icons.bloodtype_outlined),
                _buildDetailCard(
                    'Allergies', 'None', Icons.warning_amber_outlined),
                _buildDetailCard('BMI', '22.5', Icons.fitness_center),
              ],
            ),
          ),

          const SizedBox(height: 16),
          // Additional Sections
          Expanded(
            child: ListView(
              children: [
                _buildListTile(context, 'Medical History',
                    Icons.medical_services_outlined),
                // _buildListTile(
                //     context, 'Family History', Icons.family_restroom_outlined),
                _buildListTile(
                    context, 'Lab Test Reports', Icons.biotech_outlined),
                // _buildListTile(
                //     context, 'Vaccination Records', Icons.vaccines_outlined),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to create a card for the details grid
  Widget _buildDetailCard(String title, String value, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 32, color: const Color(0xFF624E88)), // Purple theme color
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to create list tiles for the additional sections
  Widget _buildListTile(BuildContext context, String title, IconData icon) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      leading: Icon(icon, color: const Color(0xFF624E88)), // Purple theme color
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        // Navigate to the corresponding page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: Text(title),
              ),
              body: Center(child: Text('$title Page')),
            ),
          ),
        );
      },
    );
  }
}
