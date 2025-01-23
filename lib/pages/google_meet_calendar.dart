// google_meet_calendar.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/auth_io.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class GoogleMeetCalendarPage extends StatefulWidget {
  const GoogleMeetCalendarPage({super.key});

  @override
  _GoogleMeetCalendarPageState createState() => _GoogleMeetCalendarPageState();
}

class _GoogleMeetCalendarPageState extends State<GoogleMeetCalendarPage> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _gMeetLink;
  String? _meetingTopic;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/calendar',
    ],
  );

Future<void> _signInAndCreateEvent() async {
  try {
    final account = await _googleSignIn.signIn();
    if (account != null) {
      final auth = await account.authentication;
      final accessToken = auth.accessToken;
      if (accessToken != null) {
        DateTime startTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );
        DateTime endTime = startTime.add(Duration(hours: 1));

        // Generate Google Meet Link
        _gMeetLink =
            await createGoogleMeetEvent(accessToken, startTime, endTime);

        // Save Details to Firestore
        await saveMeetingDetailsToFirestore(
          account.id, // Current user ID
          "careRecipientUID123", // Replace with actual care recipient UID
          _meetingTopic!,
          startTime,
          endTime,
          _gMeetLink!,
        );

        setState(() {});
      }
    }
  } catch (e) {
    print("Error signing in or creating event: $e");
  }
}

Future<void> saveMeetingDetailsToFirestore(
  String userId,
  String careRecipientId,
  String topic,
  DateTime startTime,
  DateTime endTime,
  String meetLink,
) async {
  try {
    final firestore = FirebaseFirestore.instance;

    await firestore.collection("vidcon").add({
      "userId": userId,
      "careRecipientId": careRecipientId,
      "topic": topic,
      "startTime": startTime.toIso8601String(),
      "endTime": endTime.toIso8601String(),
      "meetLink": meetLink,
      "createdAt": FieldValue.serverTimestamp(),
    });

    print("Meeting details saved successfully!");
  } catch (e) {
    print("Error saving meeting details to Firestore: $e");
  }
}

Future<String?> createGoogleMeetEvent(
    String accessToken, DateTime startTime, DateTime endTime) async {
  // Ensure the start and end times are converted to UTC
  final startUtc = startTime.toUtc();
  final endUtc = endTime.toUtc();

  final client = authenticatedClient(
    http.Client(),
    AccessCredentials(
      AccessToken(
          "Bearer", accessToken, DateTime.now().toUtc().add(Duration(hours: 1))), // Convert expiry to UTC
      null,
      ["https://www.googleapis.com/auth/calendar"],
    ),
  );

  var calendarApi = calendar.CalendarApi(client);

  var event = calendar.Event(
    summary: "Meeting",
    description: "Google Meet Meeting",
    start: calendar.EventDateTime(
      dateTime: startUtc, // Use UTC
      timeZone: "UTC",
    ),
    end: calendar.EventDateTime(
      dateTime: endUtc, // Use UTC
      timeZone: "UTC",
    ),
    conferenceData: calendar.ConferenceData(
      createRequest: calendar.CreateConferenceRequest(
        requestId: "unique-request-id",
      ),
    ),
  );

  var createdEvent = await calendarApi.events.insert(
    event,
    "primary",
    conferenceDataVersion: 1,
  );

  return createdEvent.hangoutLink;
}


  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  @override
  @override
 // Variable to store the meeting topic

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        "Google Meet Calendar",
        style: TextStyle(color: Color(0xFF624E88)), // Dark purple color
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Color(0xFF624E88)), // Adjust icon color
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meeting Topic Textbox
          TextField(
            onChanged: (value) {
              setState(() {
                _meetingTopic = value;
              });
            },
            decoration: InputDecoration(
              labelText: "Meeting Topic",
              labelStyle: TextStyle(color: Color(0xFF624E88)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF624E88)),
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: Icon(Icons.topic, color: Color(0xFF624E88)),
            ),
          ),
          const SizedBox(height: 20),
          // Date Selector
          GestureDetector(
            onTap: _selectDate,
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate == null
                          ? "Select Date"
                          : "Selected Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Time Selector
          GestureDetector(
            onTap: _selectTime,
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedTime == null
                          ? "Select Time"
                          : "Selected Time: ${_selectedTime!.format(context)}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.access_time),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Generate Meeting Button
          ElevatedButton.icon(
            onPressed: (_selectedDate != null &&
                    _selectedTime != null &&
                    _meetingTopic != null &&
                    _meetingTopic!.isNotEmpty)
                ? _signInAndCreateEvent
                : null,
            icon: const Icon(Icons.link),
            label: const Text(
              "Generate Google Meet Link",
              style: TextStyle(color: Colors.white), // White text
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF624E88),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Meeting Details Card
          if (_gMeetLink != null)
            Expanded(
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Meeting Topic: ${_meetingTopic ?? "N/A"}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        "Time: ${_selectedTime!.format(context)}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (await canLaunchUrl(Uri.parse(_gMeetLink!))) {
                            await launchUrl(Uri.parse(_gMeetLink!));
                          }
                        },
                        icon: const Icon(Icons.videocam, color: Colors.white,),
                        label: const Text(
                          "Join Meeting",
                          style: TextStyle(color: Colors.white), // White text
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF624E88),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: _gMeetLink!),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Link copied to clipboard"),
                                ),
                              );
                            },
                            icon: const Icon(Icons.copy, color: Colors.white,),
                            label: const Text(
                              "Copy Link",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF624E88),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Share.share(_gMeetLink!);
                            },
                            icon: const Icon(Icons.share, color: Colors.white,),
                            label: const Text(
                              "Share Link",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF624E88),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

}
