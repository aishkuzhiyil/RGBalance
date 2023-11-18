import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserColorProvider with ChangeNotifier {
  Color _userColor = Colors.white;

  Color get userColor => _userColor;

  // Firestore reference
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Constructor
  UserColorProvider() {
    // Fetch the user color when the app starts
    fetchUserColorFromFirestore();

    // Set up a Firestore listener for user color changes
    setUpFirestoreListener();
  }
  void setUserColor(Color color) {
    print('in setUserColor');
    _userColor = color;
    notifyListeners();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'user_color': {
          'red': color.red,
          'green': color.green,
          'blue': color.blue
        },
      }).then((_) {

      }).catchError((error) {
        print('Error storing user data: $error');
      });
    }

  }

  Future<void> fetchUserColorFromFirestore() async {
    try {
      // Use Firebase Firestore to retrieve the user's color
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final colorData = userDoc.data()?['user_color'];
          final color = Color.fromRGBO(
            colorData['red'] as int,
            colorData['green'] as int,
            colorData['blue'] as int,
            1,
          );

          // Update _userColor with the retrieved color
          _userColor = color;
          notifyListeners();
        }
      }
    } catch (error) {
      print('Error fetching user color: $error');
    }
  }

  void setUpFirestoreListener() {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      _firestore.collection('users').doc(user.uid).snapshots().listen((docSnapshot) {
        if (docSnapshot.exists) {
          final colorData = docSnapshot.data()?['user_color'];
          final color = Color.fromRGBO(
            colorData['red'] as int,
            colorData['green'] as int,
            colorData['blue'] as int,
            1,
          );

          // Update _userColor with the updated color from Firestore
          _userColor = color;
          notifyListeners();
        }
      });
    }
  }
}
