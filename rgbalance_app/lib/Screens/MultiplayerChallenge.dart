import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:rgbalance/Screens/Multiplayer.dart';
import 'package:rgbalance/Screens/photoPlay.dart';
import '../reusable_widgets/reusable_widget.dart';
import 'NavBar.dart';

class MultiplayerChallengeScreen extends StatefulWidget {
  //const MultiplayerChallengeScreen({super.key});
  final String uid;
  // final double redAnswer;
  // final double greenAnswer;
  // final double blueAnswer;
  final Color currentColor;
  MultiplayerChallengeScreen({Key? key, required this.uid, required this.currentColor});// Constructor with initial color

  @override
  _MultiplayerChallengeScreenState createState() => _MultiplayerChallengeScreenState(uid, currentColor);
}

class _MultiplayerChallengeScreenState extends State<MultiplayerChallengeScreen> {

  double redValue = 0;

  double greenValue = 0;
  double blueValue = 0;
  double lastRed = 0;
  double lastGreen = 0;
  double lastBlue = 0;
  bool update = false;
  double redAnswer = 0;
  double greenAnswer = 0;
  double blueAnswer = 0;
  double bestRed = 0;
  double bestGreen = 0;
  double bestBlue = 0;
  double lastAccuracy = 0;
  double bestAccuracy = 0;
  int attempts = 0;
  String uid = "";
  Color currentColor;
  String other_player = "";
  String other_username = "";
  String current_name = "";
  int player1Score = 0;
  String current_username = "";
  String player1 = "";
  _MultiplayerChallengeScreenState(String gameuid, Color initialColor) : uid = gameuid, currentColor = initialColor;
  Future<QuerySnapshot>? gameDocFuture;
  void initState() {

    super.initState();
    performTasks();
    final gameDoc = FirebaseFirestore.instance.collection('games').doc(uid).get();




    // Call your function here when the screen is opened
  }
  Future<void> performTasks() async {
    uid = widget.uid;
    //await fetchColor();
    Future<QuerySnapshot> gameDoc = FirebaseFirestore.instance.collection('games').where(FieldPath.documentId, isEqualTo: uid).get();

    gameDocFuture = gameDoc;


  }


  @override

  void toggleBooleanValue() {
    setState(() {

      update = true;
      lastRed = redValue;
      lastGreen = greenValue;
      lastBlue = blueValue;
      attempts += 1;
      double redAccuracy = 0;
      if (redValue > redAnswer)
        redAccuracy = 1 - ((redValue - redAnswer) / 256);
      else
        redAccuracy = 1 - ((redAnswer - redValue) / 256);
      double greenAccuracy = 0;
      if (greenValue > greenAnswer)
        greenAccuracy = 1 - ((greenValue - greenAnswer) / 256);
      else
        greenAccuracy = 1 - ((greenAnswer - greenValue) / 256);
      double blueAccuracy = 0;
      if (blueValue > blueAnswer)
        blueAccuracy = 1 - ((blueValue - blueAnswer) / 256);
      else
        blueAccuracy = 1 - ((blueAnswer - blueValue) / 256);
      lastAccuracy = 100 * (redAccuracy + greenAccuracy + blueAccuracy) / 3;
      if (lastAccuracy > bestAccuracy) {
        bestRed = redValue;
        bestGreen = greenValue;
        bestBlue = blueValue;
        bestAccuracy = lastAccuracy;
      }
      if (bestRed.toInt() - redAnswer <= 5 && bestRed.toInt() - redAnswer >= -5 &&
          bestGreen.toInt() - greenAnswer <= 5 && bestGreen.toInt() - greenAnswer >= -5 &&
          bestBlue.toInt() - blueAnswer <= 5 && bestBlue.toInt() - blueAnswer >= -5) {

        bestAccuracy = 100.0;
        lastAccuracy = 100.0;
        if (other_player != player1) {
          FirebaseFirestore.instance.collection('games').doc(uid).update({
            'current_player': other_player,
          }).catchError((error) {
            print('Error storing user data: $error');
          });
        }

          FirebaseFirestore.instance.collection('games').doc(uid).update({
            (current_name == 'player1_score' ? 'player1_score' : 'player2_score') : attempts,
          }).catchError((error) {
            print('Error storing user data: $error');
          });
        if (current_name == 'player1_score') {
          buildPlayer1PopUp(context, attempts, Color.fromRGBO(redAnswer.toInt(), greenAnswer.toInt(), blueAnswer.toInt(), 1), other_username);
        } else {
          bool hasWinner = true;
          int winnerAttempts = 0;
          String winnerUsername = "";
          if (player1Score == attempts) {
            hasWinner = false;
            winnerAttempts = player1Score;
            winnerUsername = other_username;
            FirebaseFirestore.instance.collection('games').doc(uid).update({
              'winner': "Tie",
            }).catchError((error) {
              print('Error storing user data: $error');
            });
          } else if (player1Score < attempts) {
            winnerAttempts = player1Score;
            winnerUsername = other_username;
            FirebaseFirestore.instance.collection('games').doc(uid).update({
              'winner': winnerUsername,
            }).catchError((error) {
              print('Error storing user data: $error');
            });
          } else {
            winnerAttempts = attempts;
            winnerUsername = current_username;
            FirebaseFirestore.instance.collection('games').doc(uid).update({
              'winner': winnerUsername,
            }).catchError((error) {
              print('Error storing user data: $error');
            });
          }
          //ADD STATUS!!! AND figure out best thing to store for winner


          buildPlayer2PopUp(context, attempts, Color.fromRGBO(redAnswer.toInt(), greenAnswer.toInt(), blueAnswer.toInt(), 1), other_username, hasWinner, winnerAttempts, winnerUsername, uid);

        }
      }
    });


    // Delay changing the boolean back to false by 1 second
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        update = false;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: gameDocFuture, builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(
          child: CircularProgressIndicator(),);
      }
      snapshot.data?.docs.forEach((doc) async {
        redAnswer = doc.get('current_color')['red'].toDouble();
        greenAnswer = doc.get('current_color')['green'].toDouble();
        blueAnswer = doc.get('current_color')['blue'].toDouble();
        if (doc.get('current_player') != doc.get('player1')) {
          other_player = doc.get('player1');
          current_name = 'player2_score';
          player1Score = doc.get('player1_score');
        } else {
          other_player = doc.get('player2');
          current_name = 'player1_score';
        }
        player1 = doc.get('player1');
        final other_doc = await FirebaseFirestore.instance.collection('users').doc(
            other_player).get();
        final current_doc = await FirebaseFirestore.instance.collection('users').doc(
            doc.get('current_player')).get();

        other_username = other_doc.get('username');
        current_username = current_doc.get('username');
      });
      return Scaffold(
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
                  Text('Multiplayer', textAlign: TextAlign.center,  style: GoogleFonts.spaceMono(textStyle:  TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25))),
                  Padding(padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.03),),
                  Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        buildContainer(context, color: Color.fromRGBO(redAnswer.toInt(), greenAnswer.toInt(), blueAnswer.toInt(), 1)),
                        Padding(padding: EdgeInsets.only(left: MediaQuery.of(context).size.height * 0.1),),
                        update
                            ? buildContainer(context, color: Color.fromRGBO(redValue.toInt(), greenValue.toInt(), blueValue.toInt(), 1))
                            : buildContainer(context, color: Color.fromRGBO(lastRed.toInt(), lastGreen.toInt(), lastBlue.toInt(), 1)),

                      ]
                  ),

                  Padding(padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.03),),
                  Slider(
                    min: 0,
                    max: 255,
                    divisions: 256,
                    label: redValue.round().toString(),
                    activeColor: Color.fromRGBO(255, 29, 37, 1),
                    thumbColor: Color.fromRGBO(200, 29, 37, 1),
                    inactiveColor: Color.fromRGBO(150, 29, 37, 1),
                    value: redValue,
                    onChanged: (value) {
                      setState(() {
                        redValue = value;
                      });
                    },
                  ),
                  Slider(
                    min: 0,
                    max: 255,
                    divisions: 256,
                    label: greenValue.round().toString(),
                    activeColor: Color.fromRGBO(97, 255, 134, 1),
                    thumbColor: Color.fromRGBO(97, 231, 134, 1),
                    inactiveColor: Color.fromRGBO(97, 190, 134, 1),
                    value: greenValue,
                    onChanged: (value) {
                      setState(() {
                        greenValue = value;
                      });
                    },
                  ),
                  Slider(
                    min: 0,
                    max: 255,
                    divisions: 256,
                    label: blueValue.round().toString(),
                    activeColor: Color.fromRGBO(35, 116, 255, 1),
                    thumbColor: Color.fromRGBO(35, 116, 171, 1),
                    inactiveColor: Color.fromRGBO(35, 116, 150, 1),
                    value: blueValue,
                    onChanged: (value) {
                      setState(() {
                        blueValue = value;
                      });
                    },
                  ),
                  TextButton(onPressed: () {
                    setState((){
                      toggleBooleanValue();
                    });}
                    , child: Container(
                      margin: const EdgeInsets.all(8),
                      height: MediaQuery.of(context).size.height*0.07,
                      width: MediaQuery.of(context).size.width*0.9,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'SUBMIT',
                        style: TextStyle(color: Colors.black, fontSize: 35),
                      ),
                    ),),
                  Text('Last Guess', textAlign: TextAlign.center, style: GoogleFonts.spaceMono(textStyle:  TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25))),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                    Text('R', style: GoogleFonts.spaceMono(textStyle:  TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(200, 29, 37, 1), fontSize: 40))),
                    (lastRed.toInt()-redAnswer <= 5 && lastRed-redAnswer >= -5) ? answerImage("assets/images/Green Check.png") : ((lastRed < redAnswer) ? answerImage("assets/images/White Up Arrow.png") : answerImage("assets/images/White Down Arrow.png")),
                    Padding(padding: EdgeInsets.only(right: MediaQuery.of(context).size.height * 0.02),),
                    Text('G', style: GoogleFonts.spaceMono(textStyle:  TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(97, 231, 134, 1), fontSize: 40))),
                    (lastGreen.toInt()-greenAnswer <= 5 && lastGreen-greenAnswer >= -5) ? answerImage("assets/images/Green Check.png") : ((lastGreen < greenAnswer) ? answerImage("assets/images/White Up Arrow.png") : answerImage("assets/images/White Down Arrow.png")),
                    Padding(padding: EdgeInsets.only(right: MediaQuery.of(context).size.height * 0.02),),
                    Text('B', style: GoogleFonts.spaceMono(textStyle:  TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(35, 116, 171, 1), fontSize: 40))),
                    (lastBlue.toInt()-blueAnswer <= 5 && lastBlue-blueAnswer >= -5) ? answerImage("assets/images/Green Check.png") : ((lastBlue < blueAnswer) ? answerImage("assets/images/White Up Arrow.png") : answerImage("assets/images/White Down Arrow.png")),
                    Padding(padding: EdgeInsets.only(right: MediaQuery.of(context).size.height * 0.02),),
                    Text(lastAccuracy.round().toString() + '%', style: GoogleFonts.spaceMono(textStyle:  TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25))),
                  ]),
                  Text('Best Guess', textAlign: TextAlign.center, style: GoogleFonts.spaceMono(textStyle:  TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25))),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                    Text('R', style: GoogleFonts.spaceMono(textStyle:  TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(200, 29, 37, 1), fontSize: 40))),
                    (bestRed.toInt()-redAnswer <= 5 && bestRed-redAnswer >= -5) ? answerImage("assets/images/Green Check.png") : ((bestRed < redAnswer) ? answerImage("assets/images/White Up Arrow.png") : answerImage("assets/images/White Down Arrow.png")),
                    Padding(padding: EdgeInsets.only(right: MediaQuery.of(context).size.height * 0.02),),
                    Text('G', style: GoogleFonts.spaceMono(textStyle:  TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(97, 231, 134, 1), fontSize: 40))),
                    (bestGreen.toInt()-greenAnswer <= 5 && bestGreen-greenAnswer >= -5) ? answerImage("assets/images/Green Check.png") : ((bestGreen < greenAnswer) ? answerImage("assets/images/White Up Arrow.png") : answerImage("assets/images/White Down Arrow.png")),
                    Padding(padding: EdgeInsets.only(right: MediaQuery.of(context).size.height * 0.02),),
                    Text('B', style: GoogleFonts.spaceMono(textStyle:  TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(35, 116, 171, 1), fontSize: 40))),
                    (bestBlue.toInt()-blueAnswer <= 5 && bestBlue-blueAnswer >= -5) ? answerImage("assets/images/Green Check.png") : ((bestBlue < blueAnswer) ? answerImage("assets/images/White Up Arrow.png") : answerImage("assets/images/White Down Arrow.png")),
                    Padding(padding: EdgeInsets.only(right: MediaQuery.of(context).size.height * 0.02),),
                    Text(bestAccuracy.round().toString() + '%', style: GoogleFonts.spaceMono(textStyle:  TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25))),
                  ]),
                  Padding(padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.01),),
                  Text('Number of Attempts: ' + ((attempts).toString()), style: GoogleFonts.spaceMono(textStyle:  TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25))),
                ]
            ),
          ),
        ),
      );

    });
  }
}




Container buildContainer(BuildContext context, {required Color color}) {
  return Container(
    color: color,
    width:  MediaQuery.of(context).size.width*0.3,
    height: MediaQuery.of(context).size.height*0.14,
  );
}

Image answerImage(String imageName) {
  return Image.asset(
    imageName,
    fit:BoxFit.fitWidth,
    width: 45,
    height: 45,
  );
}


Future<void> buildPlayer1PopUp(BuildContext context, int numAttempts, Color container, String other_username) async {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            backgroundColor: container,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            contentPadding: EdgeInsets.only(top: 10.0),
            content: Stack(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        height: 20.0,
                      ),
                      Center(
                        child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: new Text("You correctly guessed the color in $numAttempts guesses! It is now $other_username's turn.",  textAlign: TextAlign.center, style: GoogleFonts.spaceMono(textStyle: TextStyle(fontSize: 25.0,color: Colors.white)))),//
                      ),
                      SizedBox(
                        height: 20.0,
                        width: 5.0,
                      ),
                      Divider(
                        color: Colors.grey,
                        height: 4.0,
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: InkWell(
                              child: Container(
                                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                                decoration: BoxDecoration(
                                  color:Colors.white,
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(32.0),
                                      bottomRight: Radius.circular(0.0)),
                                ),
                                child:  Text(
                                  "BACK", textAlign: TextAlign.center,
                                  style: GoogleFonts.spaceMono(textStyle:  TextStyle(color: Colors.blue,fontSize: 25.0)),
                                ),
                              ),
                              onTap:(){
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) => MultiplayerScreen()));
                              },
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              child: Container(
                                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                                decoration: BoxDecoration(
                                  color:Colors.white,
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(0.0),
                                      bottomRight: Radius.circular(32.0)),
                                ),
                                child:  Text(
                                  "HOME", textAlign: TextAlign.center,
                                  style: GoogleFonts.spaceMono(textStyle:  TextStyle(color: Colors.blue,fontSize: 25.0)),
                                ),
                              ),
                              onTap:(){
                                Navigator.pop(context);
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) => NavBarScreen()));

                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )
        );
      });
}
Future<void> buildPlayer2PopUp(BuildContext context, int numAttempts, Color container, String other_username, bool hasWinner, int winnerAttempts, String winnerUsername, String game_uid) async {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            backgroundColor: container,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            contentPadding: EdgeInsets.only(top: 10.0),
            content: Stack(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        height: 20.0,
                      ),
                      Center(
                        child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: new Text("You correctly guessed the color in $numAttempts guesses! Click below to view the winner.",  textAlign: TextAlign.center, style: GoogleFonts.spaceMono(textStyle: TextStyle(fontSize: 25.0,color: Colors.white)))),//
                      ),
                      SizedBox(
                        height: 20.0,
                        width: 5.0,
                      ),
                      Divider(
                        color: Colors.grey,
                        height: 4.0,
                      ),
                          InkWell(
                              child: Container(
                                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                                decoration: BoxDecoration(
                                  color:Colors.white,
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(32.0),
                                      bottomRight: Radius.circular(32.0)),
                                ),
                                child:  Text(
                                  "VIEW WINNER", textAlign: TextAlign.center,
                                  style: GoogleFonts.spaceMono(textStyle:  TextStyle(color: Colors.blue,fontSize: 25.0)),
                                ),
                              ),
                              onTap:(){
                                Navigator.pop(context);
                                buildWinnerPopUp(context, container, hasWinner, winnerAttempts, winnerUsername);
                                if (hasWinner) {
                                  if (winnerUsername == other_username) {
                                    removeGameFromList(game_uid, 1, true);
                                  } else {
                                    removeGameFromList(game_uid, 0, true);
                                  }
                                } else {
                                  removeGameFromList(game_uid, 0, false);
                                }

                              },
                          ),
                    ],
                  ),
                ),
              ],
            )
        );
      });
}
Future<void> buildWinnerPopUp(BuildContext context, Color container, bool hasWinner, int winnerAttempts,  String winnerUsername) async {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            backgroundColor: container,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            contentPadding: EdgeInsets.only(top: 10.0),
            content: Stack(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        height: 20.0,
                      ),
                      Center(
                        child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: (hasWinner ? new Text("$winnerUsername wins with $winnerAttempts guesses!",  textAlign: TextAlign.center, style: GoogleFonts.spaceMono(textStyle: TextStyle(fontSize: 25.0,color: Colors.white))) : new Text("You and $winnerUsername have tied with $winnerAttempts guesses.",  textAlign: TextAlign.center, style: GoogleFonts.spaceMono(textStyle: TextStyle(fontSize: 25.0,color: Colors.white))))),//
                      ),
                      SizedBox(
                        height: 20.0,
                        width: 5.0,
                      ),
                      Divider(
                        color: Colors.grey,
                        height: 4.0,
                      ),
                    Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: InkWell(
                            child: Container(
                              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                              decoration: BoxDecoration(
                                color:Colors.white,
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(32.0),
                                    bottomRight: Radius.circular(0.0)),
                              ),
                              child:  Text(
                                "BACK", textAlign: TextAlign.center,
                                style: GoogleFonts.spaceMono(textStyle:  TextStyle(color: Colors.blue,fontSize: 25.0)),
                              ),
                            ),
                            onTap:(){
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => MultiplayerScreen()));
                            },
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            child: Container(
                              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                              decoration: const BoxDecoration(
                                color:Colors.white,
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(0.0),
                                    bottomRight: Radius.circular(32.0)),
                              ),
                              child:  Text(
                                "HOME", textAlign: TextAlign.center,
                                style: GoogleFonts.spaceMono(textStyle:  TextStyle(color: Colors.blue,fontSize: 25.0)),
                              ),
                            ),
                            onTap:(){
                              Navigator.pop(context);
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => NavBarScreen()));

                            },
                          ),
                        ),
                      ],
                    )
                    ],
                  ),
                ),
              ],
            )
        );
      });
}


