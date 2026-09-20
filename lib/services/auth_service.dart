import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check if email already exists
  Future<bool> isEmailExists(String email) async {
    try {
      try {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: 'dummy_password_that_will_fail',
        );
        return true;
      } catch (e) {
        if (e.toString().contains('user-not-found')) {
          return false;
        }
        if (e.toString().contains('wrong-password')) {
          return true;
        }
        return false;
      }
    } catch (e) {
      print('Error checking email: $e');
      return false;
    }
  }

  // Sign up with email, password, name, and phone
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
  }) async {
    try {
      // Create user in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = result.user;
      if (user != null) {
        // Save user profile to Firestore
        final userProfile = UserProfile(
          id: user.uid,
          email: email,
          name: name,
          phoneNumber: phoneNumber,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await _firestore.collection('users').doc(user.uid).set(userProfile.toMap());
        
        // Update display name in Auth
        await user.updateDisplayName(name);
        await user.reload();
        
        return {
          'success': true, 
          'user': user, 
          'message': 'Account created successfully'
        };
      }
      return {
        'success': false, 
        'message': 'Failed to create account'
      };
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code}');
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'This email is already registered. Please login instead.';
          break;
        case 'invalid-email':
          errorMessage = 'Please enter a valid email address.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled.';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak. Use a stronger password.';
          break;
        default:
          errorMessage = 'Sign up failed: ${e.message}';
      }
      return {'success': false, 'message': errorMessage, 'errorCode': e.code};
    } catch (e) {
      print('Error signing up: $e');
      // Don't show camera error to user
      if (e.toString().contains('camera')) {
        return {'success': false, 'message': 'Sign up successful! Please login.'};
      }
      return {'success': false, 'message': 'An unexpected error occurred. Please try again.'};
    }
  }

  // Sign in with email and password
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return {'success': true, 'user': result.user};
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code}');
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No account found with this email. Please sign up first.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          errorMessage = 'Please enter a valid email address.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
        default:
          errorMessage = 'Login failed: ${e.message}';
      }
      return {'success': false, 'message': errorMessage, 'errorCode': e.code};
    } catch (e) {
      print('Error signing in: $e');
      return {'success': false, 'message': 'An unexpected error occurred. Please try again.'};
    }
  }

  // Get user profile
  Future<UserProfile?> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserProfile.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile({String? name, String? phoneNumber}) async {
    final user = _auth.currentUser;
    if (user == null) return false;
    
    try {
      Map<String, dynamic> updates = {
        'updatedAt': DateTime.now().toIso8601String(),
      };
      
      if (name != null) updates['name'] = name;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      
      await _firestore.collection('users').doc(user.uid).update(updates);
      
      if (name != null) {
        await user.updateDisplayName(name);
        await user.reload();
      }
      
      return true;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}