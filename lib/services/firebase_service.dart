import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService extends ChangeNotifier {
  final String projectId = 'kin-care-connect-2'; // Connected Project ID
  
  bool _isLoading = false;
  bool _isLoggedIn = false;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;

  FirebaseService() {
    debugPrint("Firebase UI placeholder mode connected to: $projectId. Needs CLI keys.");
  }

  Future<bool> loginWithEmail(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Mock success for now since CLI options aren't present in Cloud Build
      await Future.delayed(const Duration(seconds: 1));
      _isLoading = false;
      _isLoggedIn = true;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint("Login failed for project $projectId: $e");
      return false;
    }
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    notifyListeners();
  }

  Future<void> updateLastActiveStatus(bool isMoving) async {
    try {
      // In a real app we would use FirebaseAuth.instance.currentUser?.uid
      const userId = 'user_dummy_123';
      
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'lastActive': FieldValue.serverTimestamp(),
        'isMoving': isMoving,
        'status': isMoving ? 'Moving' : 'Still',
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Failed to update last active status: $e");
    }
  }
}
