// firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:typed_data';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  // Authentication Methods
  Future<UserCredential?> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      print('Error signing in anonymously: $e');
      return null;
    }
  }

  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error signing in with email: $e');
      return null;
    }
  }

  Future<UserCredential?> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error creating user: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // User Profile Methods
  Future<void> saveUserProfile({
    required String name,
    String? email,
    String? profileImageBase64,
    Map<String, dynamic>? additionalData,
  }) async {
    if (!isAuthenticated) return;

    try {
      final userData = {
        'name': name,
        'email': email ?? currentUser?.email,
        'profileImageBase64': profileImageBase64,
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        ...?additionalData,
      };

      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .set(userData, SetOptions(merge: true));
    } catch (e) {
      print('Error saving user profile: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    if (!isAuthenticated) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Custom Scenario Methods
  Future<void> saveCustomScenarioData(Map<String, dynamic> data) async {
    if (_auth.currentUser == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('settings')
          .doc('customScenario')
          .set(data, SetOptions(merge: true));

      print('Custom scenario data saved to Firebase');
    } catch (e) {
      print('Error saving custom scenario to Firebase: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getCustomScenarioData() async {
    if (_auth.currentUser == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('settings')
          .doc('customScenario')
          .get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error loading custom scenario from Firebase: $e');
      return null;
    }
  }

  // ========== NEW METHODS (INSIDE THE CLASS) ==========

  // Save water usage history
  Future<void> saveWaterUsageHistory(List<Map<String, dynamic>> history) async {
    if (!isAuthenticated) return;

    try {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('settings')
          .doc('waterUsageHistory')
          .set({'history': history, 'updatedAt': FieldValue.serverTimestamp()});
      print('Water usage history saved to Firebase');
    } catch (e) {
      print('Error saving water usage history: $e');
      rethrow;
    }
  }

  // Get water usage history
  Future<List<Map<String, dynamic>>?> getWaterUsageHistory() async {
    if (!isAuthenticated) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('settings')
          .doc('waterUsageHistory')
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data['history'] != null) {
          return List<Map<String, dynamic>>.from(data['history']);
        }
      }
      return null;
    } catch (e) {
      print('Error loading water usage history: $e');
      return null;
    }
  }

  // Save flow rate
  Future<void> saveFlowRate(double flowRate) async {
    if (!isAuthenticated) return;

    try {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('settings')
          .doc('preferences')
          .set({
            'flow_rate': flowRate,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      print('Flow rate saved to Firebase');
    } catch (e) {
      print('Error saving flow rate: $e');
      rethrow;
    }
  }

  // Get flow rate
  Future<double?> getFlowRate() async {
    if (!isAuthenticated) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('settings')
          .doc('preferences')
          .get();

      if (doc.exists && doc.data() != null) {
        return doc.data()!['flow_rate']?.toDouble();
      }
      return null;
    } catch (e) {
      print('Error loading flow rate: $e');
      return null;
    }
  }

  // Save selected scenario
  Future<void> saveSelectedScenario(String scenario) async {
    if (!isAuthenticated) return;

    try {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('settings')
          .doc('preferences')
          .set({
            'water_scenario': scenario,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      print('Selected scenario saved to Firebase');
    } catch (e) {
      print('Error saving selected scenario: $e');
      rethrow;
    }
  }

  // Get selected scenario
  Future<String?> getSelectedScenario() async {
    if (!isAuthenticated) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('settings')
          .doc('preferences')
          .get();

      if (doc.exists && doc.data() != null) {
        return doc.data()!['water_scenario'];
      }
      return null;
    } catch (e) {
      print('Error loading selected scenario: $e');
      return null;
    }
  }
}
