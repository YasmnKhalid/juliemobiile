import 'package:cloud_firestore/cloud_firestore.dart';

String? globalRole;

Future<void> initializeUserRole(String currentUserId) async {
  try {
    globalRole = await determineUserRole(currentUserId); // Update globalRole
    print('Global role set to: $globalRole');
  } catch (e) {
    print('Error initializing user role: $e');
    globalRole = 'unknown'; // Set a fallback role if initialization fails
  }
}




Future<String> determineUserRole(String userId) async {
  try {
    var userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      return userDoc.data()?['role'] ?? 'unknown'; // Default to 'unknown' if role is missing
    } else {
      throw Exception('User document does not exist!');
    }
  } catch (e) {
    print('Error determining user role: $e');
    return 'unknown'; // Return default role on error
  }
}
