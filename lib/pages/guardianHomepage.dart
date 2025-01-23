import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:juliemobiile/component/navbar.dart';
import 'package:juliemobiile/pages/dependentProfile.dart';
import 'package:juliemobiile/pages/forum.dart';
import 'package:juliemobiile/pages/health_diary.dart';
import 'package:juliemobiile/pages/medication_page.dart';
import 'package:juliemobiile/pages/task_page.dart';
import 'package:syncfusion_flutter_charts/charts.dart';


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
              'Care Recipient: Juliah',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sertralin 50mg',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(7, (index) {
                        return Icon(
                          Icons.check_circle,
                          color: index == 6 ? Colors.orange : Colors.green,
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    _buildGraphCard(
                        'Weight', [80.5, 80.4, 80.3, 80.2, 80.5, 80.6, 80.5]),
                    const SizedBox(height: 20),
                    _buildGraphCard(
                        'Blood Pressure', [108, 110, 112, 107, 108, 109, 108],
                        diastolic: [75, 76, 74, 73, 75, 74, 75]),
                    const SizedBox(height: 20),
                    _buildGraphCard('Fatigue', [5, 7, 3, 6, 4, 8, 5]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

 Widget _buildGraphCard(String title, List<double> data, {List<double>? diastolic}) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: Colors.lightBlue[50],
    ),
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: SfCartesianChart(
            primaryXAxis: NumericAxis(
              title: AxisTitle(text: 'Index'),
              edgeLabelPlacement: EdgeLabelPlacement.shift,
            ),
            primaryYAxis: NumericAxis(
              title: AxisTitle(text: 'Value'),
              labelFormat: '{value}',
            ),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <LineSeries<double, int>>[
              LineSeries<double, int>(
                dataSource: List.generate(data.length, (index) => index.toDouble()),
                xValueMapper: (index, _) => index.toInt(),
                yValueMapper: (index, _) => data[index.toInt()],
                name: title,
                color: Colors.blue,
                dataLabelSettings: const DataLabelSettings(isVisible: true),
              ),
              if (diastolic != null)
                LineSeries<double, int>(
                  dataSource: List.generate(diastolic.length, (index) => index.toDouble()),
                  xValueMapper: (index, _) => index.toInt(),
                  yValueMapper: (index, _) => diastolic[index.toInt()],
                  name: '$title (Diastolic)',
                  color: Colors.red,
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

}
