import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rgbalance/reusable_widgets/reusable_widget.dart';
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int daily_streak = 0;
  int daily_total = 0;
  double daily_accuracy = 0.0;
  int timed_high_score = 0;
  int numWinsToday = 0;
  int numWinsTotal = 0;
  double playAccuracy = 0.0;

  int daily_streak_3rd = 0;
  String sdaily_streak_3rd = "";
  int daily_total_3rd = 0;
  String sdaily_total_3rd = "";
  double daily_accuracy_3rd = 0.0;
  String sdaily_accuracy_3rd = "";
  int timed_high_score_3rd = 0;
  String stimed_high_score_3rd = "";
  int daily_streak_2nd = 0;
  String sdaily_streak_2nd = "";
  int daily_total_2nd = 0;
  String sdaily_total_2nd = "";
  double daily_accuracy_2nd = 0.0;
  String sdaily_accuracy_2nd = "";
  int timed_high_score_2nd = 0;
  String stimed_high_score_2nd = "";
  int daily_streak_1st = 0;
  String sdaily_streak_1st = "";
  int daily_total_1st = 0;
  String sdaily_total_1st = "";
  double daily_accuracy_1st = 0.0;
  String sdaily_accuracy_1st = "";
  int timed_high_score_1st = 0;
  String stimed_high_score_1st = "";

  void initState() {
    super.initState();
    // Call your function here when the screen is opened
    fetchFirebaseStats();
    fetchFirebaseAllTime();
  }
  Future<void> fetchFirebaseStats() async {

    print('in fetch completed');
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          daily_streak = userDoc.data()?['daily_streak'] ?? 0;
          daily_total = userDoc.data()?['daily_total'] ?? 0;
          daily_accuracy = userDoc.data()?['total_accuracy'] ?? 0;
          timed_high_score = userDoc.data()?['high_score'] ?? 0;
          numWinsToday = userDoc.data()?['numWinsToday'] ?? 0;
          numWinsTotal = userDoc.data()?['numWinsTotal'] ?? 0;
          playAccuracy = userDoc.data()?['playAccuracy'] ?? 0;
        });
        //print('Day difference since last completed: ${DateTime.now().difference(DateTime.parse(daily_last_completed)).inDays}');
      }
    }
  }

  Future<void> fetchFirebaseAllTime() async {

    print('in fetch completed');
    //final ListUsersResult listUsersResult = await FirebaseAuth.instance.listUsers();
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').get();
    for (QueryDocumentSnapshot userDoc in querySnapshot.docs) {
      print("here");
      print(userDoc.data());
      if (userDoc != null) {
        // final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          if ((userDoc?['daily_streak'] ?? 0) >= daily_streak_1st) {
            setState(() {
              print("first");
              if (daily_streak_2nd != 0) {
                daily_streak_3rd = daily_streak_2nd;
              }
              if (daily_streak_1st != 0) {
                daily_streak_2nd = daily_streak_1st;
              }
              daily_streak_1st = userDoc['daily_streak'];
              sdaily_streak_1st = userDoc['username'];
            });
          } else if ((userDoc?['daily_streak'] ?? 0) >= daily_streak_2nd) {
            setState(() {
              print("second");
              if (daily_streak_2nd != 0) {
                daily_streak_3rd = daily_streak_2nd;
              }
              daily_streak_2nd = userDoc['daily_streak'];
              sdaily_streak_2nd = userDoc['username'];
            });
          } else if ((userDoc?['daily_streak'] ?? 0) >= daily_streak_3rd) {
            setState(() {
              print("third");
              daily_streak_3rd = userDoc['daily_streak'];
              sdaily_streak_3rd = userDoc['username'];
            });
          }
          if ((userDoc?['daily_total'] ?? 0) >= daily_total_1st) {
            setState(() {
              print("first t");
              if (daily_total_2nd != 0) {
                daily_total_3rd = daily_total_2nd;
              }
              if (daily_total_1st != 0) {
                daily_total_2nd = daily_total_1st;
              }
              daily_total_1st = userDoc['daily_total'];
              sdaily_total_1st = userDoc['username'];
            });
          } else if ((userDoc?['daily_total'] ?? 0) >= daily_total_2nd) {
            setState(() {
              print("second t");
              if (daily_total_2nd != 0) {
                daily_total_3rd = daily_total_2nd;
              }
              daily_total_2nd = userDoc['daily_total'];
              sdaily_total_2nd = userDoc['username'];
            });
          } else if ((userDoc?['daily_total'] ?? 0) >= daily_total_3rd) {
            setState(() {
              print("third t");
              daily_total_3rd = userDoc['daily_total'];
              sdaily_total_3rd = userDoc['username'];
            });
          }
          if ((userDoc?['daily_accuracy'] ?? 0) >= daily_accuracy_1st) {
            setState(() {
              print("first a");
              if (daily_accuracy_2nd != 0) {
                daily_accuracy_3rd = daily_accuracy_2nd;
              }
              if (daily_accuracy_1st != 0) {
                daily_accuracy_2nd = daily_accuracy_1st;
              }
              daily_accuracy_1st = userDoc['daily_accuracy'].toDouble();
              sdaily_accuracy_1st = userDoc['username'];
            });
          } else if ((userDoc?['daily_accuracy'] ?? 0) >= daily_accuracy_2nd) {
            setState(() {
              print("second a");
              if (daily_accuracy_2nd != 0) {
                daily_accuracy_3rd = daily_accuracy_2nd;
              }
              daily_accuracy_2nd = userDoc['daily_accuracy'].toDouble();
              sdaily_accuracy_2nd = userDoc['username'];
            });
          } else if ((userDoc?['daily_accuracy'] ?? 0) >= daily_accuracy_3rd) {
            setState(() {
              print("third a");
              daily_accuracy_3rd = userDoc['daily_accuracy'].toDouble();
              sdaily_accuracy_3rd = userDoc['username'];
            });
          }
          if ((userDoc?['high_score'] ?? 0) >= timed_high_score_1st) {
            setState(() {
              print("first h");
              if (timed_high_score_2nd != 0) {
                timed_high_score_3rd = timed_high_score_2nd;
              }
              if (timed_high_score_1st != 0) {
                timed_high_score_2nd = timed_high_score_1st;
              }
              timed_high_score_1st = userDoc['high_score'];
              stimed_high_score_1st = userDoc['username'];
            });
          } else if ((userDoc?['high_score'] ?? 0) >= timed_high_score_2nd) {
            setState(() {
              print("second h");
              if (timed_high_score_2nd != 0) {
                timed_high_score_3rd = timed_high_score_2nd;
              }
              timed_high_score_2nd = userDoc['high_score'];
              stimed_high_score_2nd = userDoc['username'];
            });
          } else if ((userDoc?['high_score'] ?? 0) >= timed_high_score_3rd) {
            setState(() {
              print("third h");
              timed_high_score_3rd = userDoc['high_score'];
              stimed_high_score_3rd = userDoc['username'];
            });
          }
          print("here");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(backgroundColor: Color.fromRGBO(27, 32, 33, 1), foregroundColor: Color.fromRGBO(27, 32, 33, 1),),
        body: Container (
        width: MediaQuery.of(context).size.width,
    height: MediaQuery.of(context).size.height,
    decoration: BoxDecoration(
    color: Color.fromRGBO(27, 32, 33, 1)),
    child: SingleChildScrollView(
    child: Column(
    children: <Widget>[
      Padding(padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.05),),
      logoWidget2("assets/images/RGBLogo.png", MediaQuery.of(context).size.width*0.9, MediaQuery.of(context).size.height*0.11,),
      
      Text('Statistics', textAlign: TextAlign.center, style: GoogleFonts.spaceMono(textStyle: TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize: 40))),
      Padding(padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.03),),
      Text('Daily Challenge: ', textAlign: TextAlign.left, style: GoogleFonts.spaceMono(textStyle: TextStyle(height: 0, fontWeight: FontWeight.bold, color: Color.fromRGBO(200, 29, 37, 1), fontSize: 30))),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[

          Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            Text('${daily_total}', textAlign: TextAlign.center,style: GoogleFonts.spaceMono(textStyle: TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize: 35))),
            Text('Played', textAlign: TextAlign.center, style: GoogleFonts.spaceMono(textStyle: TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize:15))),
          ]),
          Padding(padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.1),),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            Text('${daily_streak}', textAlign: TextAlign.center, style: GoogleFonts.spaceMono(textStyle:  TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize: 35))),
            Text('Streak', textAlign: TextAlign.center, style: GoogleFonts.spaceMono(textStyle:  TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15))),
          ]),
          Padding(padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.1),),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            Text('${(daily_accuracy*100).toInt()}%', textAlign: TextAlign.center, style: GoogleFonts.spaceMono(textStyle:  TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize: 35))),
            Text('Accuracy', textAlign: TextAlign.center,style: GoogleFonts.spaceMono(textStyle:  TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15))),
          ]
          )
        ],
        ),
      Padding(padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.03),),
      Text('Timed Play: ', textAlign: TextAlign.center, style: GoogleFonts.spaceMono(textStyle: TextStyle(height: 0, fontWeight: FontWeight.bold, color: Color.fromRGBO(97, 231, 134, 1), fontSize: 30))),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        Column(children: <Widget>[
          Text('${timed_high_score}', textAlign: TextAlign.center, style: GoogleFonts.spaceMono(textStyle:  TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize: 35))),
          Text('High Score', textAlign: TextAlign.center, style: GoogleFonts.spaceMono(textStyle:  TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize:15))),
        ]),
      ],
      ),
      Padding(padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.03),),
      Text('Free Play: ', textAlign: TextAlign.center, style: GoogleFonts.spaceMono(textStyle: TextStyle(height: 0, fontWeight: FontWeight.bold, color: Color.fromRGBO(35, 116, 171, 1), fontSize: 30))),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        Column(children: <Widget>[
          Text('${numWinsToday}', textAlign: TextAlign.center, style: GoogleFonts.spaceMono(textStyle:  TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize: 35))),
          Text('Wins Today', textAlign: TextAlign.center, style: GoogleFonts.spaceMono(textStyle:  TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize:15))),
        ]),
        Padding(padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.1),),
        Column(children: <Widget>[
          Text('${numWinsTotal}', textAlign: TextAlign.center, style: GoogleFonts.spaceMono(textStyle:  TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize: 35))),
          Text('Total Wins', textAlign: TextAlign.center, style: GoogleFonts.spaceMono(textStyle:  TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15))),
        ]),
        Padding(padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.1),),
        Column(children: <Widget>[
            Text('${(playAccuracy*100).toInt()}%', textAlign: TextAlign.center,style: GoogleFonts.spaceMono(textStyle:  TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize: 35))),
            Text('Accuracy', textAlign: TextAlign.center, style: GoogleFonts.spaceMono(textStyle:  TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15))),
        ])
      ],
      ),
      Padding(padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.03),),
      Text('All-Time Leaderboard', textAlign: TextAlign.center, style: GoogleFonts.spaceMono(textStyle: TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize: 40))),
      Padding(padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.03),),
      Text('Daily Challenge: ', textAlign: TextAlign.left, style: GoogleFonts.spaceMono(textStyle: TextStyle(height: 0, fontWeight: FontWeight.bold, color: Color.fromRGBO(200, 29, 37, 1), fontSize: 30))),
      Text('Games Played: ', textAlign: TextAlign.left, style: GoogleFonts.spaceMono(textStyle: TextStyle(height: 0, fontWeight: FontWeight.bold, color: Color.fromRGBO(200, 29, 37, 1), fontSize: 25))),
      Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Text('1st Place: ${daily_total_1st}', textAlign: TextAlign.center,style: GoogleFonts.spaceMono(textStyle: TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25))),
          Text('@${sdaily_total_1st}', textAlign: TextAlign.center, style: GoogleFonts.spaceMono(textStyle: TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize:15))),
        ]),
        Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Text('2nd Place: ${daily_total_2nd}', textAlign: TextAlign.center,style: GoogleFonts.spaceMono(textStyle: TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25))),
          Text('@${sdaily_total_2nd}', textAlign: TextAlign.center, style: GoogleFonts.spaceMono(textStyle: TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize:15))),
        ]),
        Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Text('3rd Place: ${daily_total_3rd}', textAlign: TextAlign.center,style: GoogleFonts.spaceMono(textStyle: TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25))),
          Text('@${sdaily_total_3rd}', textAlign: TextAlign.center, style: GoogleFonts.spaceMono(textStyle: TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize:15))),
        ]),
      ]),
      Text('Daily Streak: ', textAlign: TextAlign.left, style: GoogleFonts.spaceMono(textStyle: TextStyle(height: 0, fontWeight: FontWeight.bold, color: Color.fromRGBO(200, 29, 37, 1), fontSize: 25))),
      Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Text('1st Place: ${daily_streak_1st}', textAlign: TextAlign.center,style: GoogleFonts.spaceMono(textStyle: TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25))),
          Text('@${sdaily_streak_1st}', textAlign: TextAlign.center, style: GoogleFonts.spaceMono(textStyle: TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize:15))),
        ]),
        Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Text('2nd Place: ${daily_streak_2nd}', textAlign: TextAlign.center,style: GoogleFonts.spaceMono(textStyle: TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25))),
          Text('@${sdaily_streak_2nd}', textAlign: TextAlign.center, style: GoogleFonts.spaceMono(textStyle: TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize:15))),
        ]),
        Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Text('3rd Place: ${daily_streak_3rd}', textAlign: TextAlign.center,style: GoogleFonts.spaceMono(textStyle: TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25))),
          Text('@${sdaily_streak_3rd}', textAlign: TextAlign.center, style: GoogleFonts.spaceMono(textStyle: TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize:15))),
        ]),
      ]),
      Text('Accuracy: ', textAlign: TextAlign.left, style: GoogleFonts.spaceMono(textStyle: TextStyle(height: 0, fontWeight: FontWeight.bold, color: Color.fromRGBO(200, 29, 37, 1), fontSize: 25))),
      Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Text('1st Place: ${(daily_accuracy_1st * 100).toInt()}%', textAlign: TextAlign.center,style: GoogleFonts.spaceMono(textStyle: TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25))),
          Text('@${sdaily_accuracy_1st}', textAlign: TextAlign.center, style: GoogleFonts.spaceMono(textStyle: TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize:15))),
        ]),
        Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Text('2nd Place: ${(daily_accuracy_2nd * 100).toInt()}%', textAlign: TextAlign.center,style: GoogleFonts.spaceMono(textStyle: TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25))),
          Text('@${sdaily_accuracy_2nd}', textAlign: TextAlign.center, style: GoogleFonts.spaceMono(textStyle: TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize:15))),
        ]),
        Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Text('3rd Place: ${(daily_accuracy_3rd * 100).toInt()}%', textAlign: TextAlign.center,style: GoogleFonts.spaceMono(textStyle: TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25))),
          Text('@${sdaily_accuracy_3rd}', textAlign: TextAlign.center, style: GoogleFonts.spaceMono(textStyle: TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize:15))),
        ]),
      ]),
      Padding(padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.03),),
      Text('Timed Play: ', textAlign: TextAlign.left, style: GoogleFonts.spaceMono(textStyle: TextStyle(height: 0, fontWeight: FontWeight.bold, color: Color.fromRGBO(97, 231, 134, 1), fontSize: 30))),
      Text('High Score: ', textAlign: TextAlign.left, style: GoogleFonts.spaceMono(textStyle: TextStyle(height: 0, fontWeight: FontWeight.bold, color: Color.fromRGBO(97, 231, 134, 1), fontSize: 25))),
      Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Text('1st Place: ${timed_high_score_1st}', textAlign: TextAlign.center,style: GoogleFonts.spaceMono(textStyle: TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25))),
          Text('@${stimed_high_score_1st}', textAlign: TextAlign.center, style: GoogleFonts.spaceMono(textStyle: TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize:15))),
        ]),
        Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Text('2nd Place: ${timed_high_score_2nd}', textAlign: TextAlign.center,style: GoogleFonts.spaceMono(textStyle: TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25))),
          Text('@${stimed_high_score_2nd}', textAlign: TextAlign.center, style: GoogleFonts.spaceMono(textStyle: TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize:15))),
        ]),
        Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Text('3rd Place: ${timed_high_score_3rd}', textAlign: TextAlign.center,style: GoogleFonts.spaceMono(textStyle: TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25))),
          Text('@${stimed_high_score_3rd}', textAlign: TextAlign.center, style: GoogleFonts.spaceMono(textStyle: TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize:15))),
        ]),
      ]),
    ]
    )
    )
    )
    );
  }

}
