import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:juliemobiile/pages/calendar_page.dart';
// import 'package:juliemobiile/component/navbar.dart';
import 'package:juliemobiile/pages/caretakerHomepage.dart';
import 'package:juliemobiile/pages/dependentProfile.dart';
import 'package:juliemobiile/pages/health_diary.dart';
import 'package:juliemobiile/pages/settingPage.dart';
import 'package:juliemobiile/pages/account.dart';
import 'package:juliemobiile/services/globalVariable.dart';
import 'pages/loginPage.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print("Starting Firebase initialization...");
  try {
    // Initialize Firebase
    await Firebase.initializeApp();
    print("Firebase initialized successfully!");

    // Check if the user is logged in and initialize their role
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (currentUserId.isNotEmpty) {
      await initializeUserRole(currentUserId); // Initialize the global role
      print("User role initialized: $globalRole");
    } else {
      print("No current user logged in.");
    }

    // Start the app
    runApp(const MyApp());
  } catch (e) {
    print("Error initializing Firebase or user role: $e");
    runApp(const MyApp()); // Still run the app to handle errors gracefully
  }
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Create a global dark mode notifier
  static final ValueNotifier<bool> isDarkMode = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode, // Listen to changes in dark mode
      builder: (context, isDark, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false, // Disable the debug banner
          title: 'Firebase Test',
          theme: isDark ? ThemeData.dark() : ThemeData.light(), // Switch themes
          initialRoute: '/', // Define the initial route
          routes: {
            '/login': (context) => const AuthenticationPage(), // Login Page
            '/caretakerHome': (context) => const CaretakerHomePage(user: null),
            '/account': (context) => const ProfilePage(),
            '/setting': (context) => const SettingsPage(),
            '/calendar': (context) => const CalendarPage(),
            '/healthdiary': (context) => const HealthDiary(),
            '/dependent': (context) => DependentProfilePage(),

            '/': (context) => const AuthenticationPage(), // Authentication Page
          },
        );
      },
    );
  }
}

