import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rgbalance/Screens/NavBar.dart';
import 'package:rgbalance/Screens/dailyChallenge.dart';
import 'package:rgbalance/Screens/freePlay.dart';
import 'package:rgbalance/Screens/photoPlay.dart';
import 'package:rgbalance/Screens/timedPlay.dart';
import 'package:rgbalance/reusable_widgets/reusable_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Multiplayer.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String username = ''; // Initialize the username variable.
  int daily_streak = 0;
  int daily_total = 0;
  double daily_accuracy = 0.0;
  int timed_high_score = 0;
  int numWinsToday = 0;
  int numWinsTotal = 0;
  int playAccuracy = 0;
  List<dynamic> friends = [];
  List<dynamic> current_games = [];
  List daily_challenge_guesses = [];
  int daily_challenge_attempts = 0;
  Map<String, List<int>> friend_records = {};
  Future<void> fetchUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          username = userDoc.data()?['username'] ?? 'User';
          daily_streak = userDoc.data()?['daily_streak'] ?? 0;
          daily_total = userDoc.data()?['daily_total'] ?? 0;
          daily_accuracy = userDoc.data()?['total_accuracy'] ?? 0.0;
          timed_high_score = userDoc.data()?['high_score'] ?? 0;
          numWinsToday = userDoc.data()?['numWinsToday'] ?? 0;
          numWinsTotal = userDoc.data()?['numWinsTotal'] ?? 0;
          playAccuracy = userDoc.data()?['playAccuracy'] ?? 0;
          friends = userDoc.data()?['friends'] ?? [];
          current_games = userDoc.data()?['current_games'] ?? [];
          daily_challenge_guesses = userDoc.data()?['daily_challenge_guesses'] ?? [];
          daily_challenge_attempts = userDoc.data()?['daily_challenge_attempts'] ?? 0;
          friend_records =  friend_records = userDoc.data()?['friend_records'] != null
              ? (userDoc.data()?['friend_records'] as Map<String, dynamic>).map(
                (key, value) => MapEntry(key, List<int>.from(value)),
          )
              : {};
        });
      }
      if (friend_records.isEmpty) {
        print("In if statement!");
        for (int i = 0; i < friends.length; i++) {
          List<int> record = [0, 0];
          friend_records[friends[i]] = record;
        }

      }
      FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'high_score': timed_high_score,
      }).catchError((error) {
        print('Error storing user data: $error');
      });
      FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'daily_streak': daily_streak,
      }).catchError((error) {
        print('Error storing user data: $error');
      });
      FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'daily_total': daily_total,
      }).catchError((error) {
        print('Error storing user data: $error');
      });
      FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'daily_accuracy': daily_accuracy,
      }).catchError((error) {
        print('Error storing user data: $error');
      });
      FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'numWinsTotal': numWinsTotal,
      }).catchError((error) {
        print('Error storing user data: $error');
      });
      FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'numWinsToday': numWinsToday,
      }).catchError((error) {
        print('Error storing user data: $error');
      });
      FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'friends': friends,
      }).catchError((error) {
        print('Error storing user data: $error');
      });
      FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'current_games': current_games,
      }).catchError((error) {
        print('Error storing user data: $error');
      });
      FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'playAccuracy': playAccuracy,
      }).catchError((error) {
        print('Error storing user data: $error');
      });
      FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'daily_challenge_guesses': daily_challenge_guesses,
      }).catchError((error) {
        print('Error storing user data: $error');
      });
      FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'daily_challenge_attempts': daily_challenge_attempts,
      }).catchError((error) {
        print('Error storing user data: $error');
      });
      FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'friend_records': friend_records,
      }).catchError((error) {
        print('Error storing user data: $error');
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUsername(); // Fetch the username when the widget is initialized.
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container (
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              color: Color.fromRGBO(27, 32, 33, 1)),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height*0.1, 20, 0),
            child: Column(
              children: <Widget>[
                logoWidget("assets/images/RGBLogo.png"),
                SizedBox(
                    height: 30),
                SizedBox(
                  height: 20,
                ),
                homeButton(context, true, false, false, false, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => DailyChallengeScreen()));
                }),
                SizedBox(
                  height: 20,
                ),
                homeButton(context, false, true, false,false,  () {
                  //Navigator.push(context,
                      //MaterialPageRoute(builder: (context) => NavBarScreen(initialIndex: 0,)));
                  //return FreePlayScreen();
                  Navigator.push(context,
                    MaterialPageRoute(builder: (context) => FreePlayScreen()));
                }),
                SizedBox(
                  height: 20,
                ),
                homeButton(context, false, false, true, false, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => TimedPlayScreen()));
                }),
                SizedBox(
                  height: 20,
                ),
                homeButton(context, false, false, false, true, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => PhotoPlayScreen()));
                }),
                SizedBox(
                  height: 20,
                ),
                homeButton(context, false, false, false, false, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MultiplayerScreen()));
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Container homeButton(
    BuildContext context, bool daily, bool free, bool timed, bool settings, Function onTap) {
  return Container(width: MediaQuery.of(context).size.width,
    height: 50,
    margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
    child: ElevatedButton(
      onPressed: () {
        onTap();
      },
      child: Text(
        daily ? 'DAILY CHALLENGE' : (free ? 'FREE PLAY' : (timed ?'TIMED PLAY' : (settings ? 'PHOTO PLAY' : 'MULTIPLAYER'))),
        style: GoogleFonts.spaceMono(textStyle: TextStyle(
            color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (daily) {
              return Color.fromRGBO(200, 29, 37, 1); //Red
            } else if (free) {
              return Color.fromRGBO(97, 231, 134, 1); //Green
            } else if (timed) {
              return Color.fromRGBO(35, 116, 171, 1); //Blue
            } else {
              return Color.fromRGBO(38, 40, 180, 1);
            }}),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(side: BorderSide(
                  width: 3),
                  borderRadius: BorderRadius.circular(30)))),
    ),
  );
}
