import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CareRecipientService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Adds a dependent and generates a unique code
  Future<String> addDependent({
    required String name,
    required int age,
    required String gender,
    required String allergic,
    required String disease,
    required String guardianId,
  }) async {
    final User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      // Generate a unique code
      final String code = _generateUniqueCode(guardianId);

      // Add dependent to Firestore
      final DocumentReference docRef = await _firestore.collection('care_recipients').add({
        'name': name.trim(),
        'age': age,
        'gender': gender.trim(),
        'allergic': allergic.trim(),
        'disease': disease.trim(),
        'guardianId': currentUser.uid,
        'code': code, // Save the generated code
      });

      // Save the code to the guardian's user document
      await _firestore.collection('users').doc(currentUser.uid).update({
        'dependentCode': code,
      });

      // Return the generated code
      return code;
    } else {
      throw Exception('No user is logged in');
    }
  }

  /// Generates a unique code for the dependent
  String _generateUniqueCode(String guardianId) {
    final String randomString = DateTime.now().millisecondsSinceEpoch.toString();
    return '${guardianId.substring(0, 5)}-${randomString.substring(randomString.length - 5)}';
  }


  


}
