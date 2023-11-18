import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rgbalance/Screens/MultiplayerChallenge.dart';
import 'package:rgbalance/Screens/home.dart';
import 'package:rgbalance/Screens/photoChallenge.dart';
import 'package:rgbalance/reusable_widgets/reusable_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'NavBar.dart';
class MultiplayerScreen extends StatefulWidget {
  const MultiplayerScreen({super.key});

  @override
  State<MultiplayerScreen> createState() => _MultiplayerScreenState();
}

class _MultiplayerScreenState extends State<MultiplayerScreen> {
  Future<QuerySnapshot>? friendDocs;
  List<dynamic> friendList = [];
  Future<QuerySnapshot>? currentGameDocs;
  List<dynamic> currentGameList = [];


  Future<void> fetchFriendList() async {

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          friendList = userDoc.data()?['friends'] ?? [];
          Future<QuerySnapshot> friendUserDocs = FirebaseFirestore.instance
              .collection('users')
              .where(FieldPath.documentId, whereIn: friendList)
              .get();
          friendDocs = friendUserDocs;
        });

      }
    }

  }
  Future<void> fetchGameList() async {

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          currentGameList = userDoc.data()?['current_games'] ?? [];
          if (currentGameList.isNotEmpty) {
            Future<QuerySnapshot> gameDocs = FirebaseFirestore.instance
                .collection('games')
                .where(FieldPath.documentId, whereIn: currentGameList)
                .get();
            currentGameDocs = gameDocs;
          }


        });

      }
    }

  }
  void initState() {
    super.initState();
    // Call your function here when the screen is opened
    performTasks();


  }
  Future<void> performTasks() async {
    await fetchGameList();
    await fetchFriendList();
  }
  buildFriendList() {
    return FutureBuilder(
      future: friendDocs,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        List<UserResult> searchResults = [];
        snapshot.data?.docs.forEach((doc) {

          // Check if 'friend_records' is present and of the correct type
          try {
            if (doc.get('friend_records') is Map<String, dynamic>) {
              Map<String, List<int>> friend_records = (doc.get('friend_records') as Map<String, dynamic>).map(
                    (key, value) => MapEntry(key, List<int>.from(value)),
              );


              // Check if the specific user's record exists
              List<int>? record = friend_records[FirebaseAuth.instance.currentUser!.uid]?.reversed.toList() ?? [0, 0];

              UserResult searchResult = UserResult(doc.get('username'), doc.get('user_color'), searchResults.length, doc.id, true, false, false, doc.get('user_color'), false, "", 0, record!);
              searchResults.add(searchResult);

            }
          } catch(e) {
          }



      });
            return ListView(children: searchResults);
            },
    );
  }
  buildGameList() {
    return FutureBuilder(
        future: currentGameDocs, builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(
          child: CircularProgressIndicator(),);
      }
      List<UserResult> gameResults = [];
      int count  = 0;
      snapshot.data?.docs.forEach((doc) async {
        count += 1;
        String other_player = "";
        if (doc.get('player1') != FirebaseAuth.instance.currentUser!.uid) {
          other_player = doc.get('player1');
        } else {
          other_player = doc.get('player2');
        }
        bool current_turn;
        if (doc.get('current_player') == FirebaseAuth.instance.currentUser!.uid) {
          current_turn = true;
        } else {
          current_turn = false;
        }
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(
            other_player).get();
        final currentUserDoc = await FirebaseFirestore.instance.collection('users').doc(
            FirebaseAuth.instance.currentUser!.uid).get();

        bool hasWinner = doc.get('winner') != 'TBD';
        String winner = doc.get('winner');
        int winner_attempts = (doc.get('player1_score') <= doc.get('player2_score')) ? doc.get('player1_score') : doc.get('player2_score');

        int status = 0;
        List<String> gameList = [];


          UserResult searchResult = UserResult(userDoc.get('username'), userDoc.get('user_color'), gameResults.length, doc.id, false, true, current_turn, doc.get('current_color'), hasWinner, winner, winner_attempts, [0, 0]);
          gameResults.add(searchResult);

      });
      return ListView(children: gameResults);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> body_list = [];
    return Scaffold(
        backgroundColor: Color.fromRGBO(27, 32, 33, 1),
        body: Column(
            children: <Widget>[
              Padding(padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1)),
              Text("Multiplayer", style: GoogleFonts.spaceMono(textStyle: TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize: 40))),
              Padding(padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.05)),
              Text("Current Games", style: GoogleFonts.spaceMono(textStyle: TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize: 30))),
              Expanded(child: buildGameList(), flex: 1),
              Text("Start Game", style: GoogleFonts.spaceMono(textStyle: TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize: 30))),
              Expanded(child: buildFriendList(), flex: 2),
              Padding(padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.05)),

            ])
    );
  }
}
class UserResult extends StatelessWidget {
  String username = "";
  Map<String, dynamic> userColorData = {};
  int index = -1;
  String uid = "";
  String setStatus = "";
  bool new_game;
  bool current_game;
  bool current_turn;
  Map<String, dynamic> game_color;
  bool has_winner = false;
  String winner;
  int winner_attempts = 0;
  List<int> record;
  UserResult(this.username, this.userColorData, this.index, this.uid, this.new_game, this.current_game, this.current_turn, this.game_color, this.has_winner, this.winner, this.winner_attempts, this.record);



  @override
  Widget build(BuildContext context) {
    int redUserColor = 0;
    int greenUserColor = 0;
    int blueUserColor = 0;
    if (userColorData.keys.length >= 3) {
      redUserColor = userColorData['red'].toInt();
      greenUserColor = userColorData['green'].toInt();
      blueUserColor = userColorData['blue'].toInt();

    }

    return Container(
        color: Color.fromRGBO(100, 105, 106, 1),
        //color: (index  % 3 == 0 ? Color.fromRGBO(200, 29, 37, 1) : (index%3==1 ? Color.fromRGBO(97, 231, 134, 1) : Color.fromRGBO(35, 116, 171, 1))),
        child: Column(children: <Widget>[
          GestureDetector(onTap: () => (new_game ? buildStartGamePopUp(context, userColorData, username, uid, game_color) : (!current_turn ? buildCurrentGamePopUp(context, userColorData, username, uid, has_winner, winner, winner_attempts) : Navigator.push(context, MaterialPageRoute(builder: (context) => MultiplayerChallengeScreen(uid: uid, currentColor: Color.fromRGBO(game_color['red'], game_color['green'], game_color['blue'], 1)))))),
              child: ListTile(leading: CircleAvatar(
                backgroundColor: Color.fromRGBO(redUserColor as int, greenUserColor as int, blueUserColor as int, 1),
              ),
                  title: Text(username, style: GoogleFonts.spaceMono(textStyle: TextStyle(fontSize: 25, color: Colors.black, fontWeight: FontWeight.bold)))
                  , trailing: (has_winner ? Text("Game Complete",style: GoogleFonts.spaceMono(textStyle:  TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15))) : (new_game ? Text('${record[0]}-${record[1]}',style: GoogleFonts.spaceMono(textStyle:  TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 25))) : (current_turn ? Text("Your Turn",style: GoogleFonts.spaceMono(textStyle:  TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15))) :  Text("Opponent's Turn",style: GoogleFonts.spaceMono(textStyle:  TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)))))))
          ),
          Divider(
              height: 8.0, color: Colors.white54, thickness: 2,
          )
        ]

        ));
  }
}
Future<String> startGame(String current_uid, String friend_uid) async {
  final gamesCollection = FirebaseFirestore.instance.collection('games');

  // Create a new document to represent the friend request
  final newGameRef = await gamesCollection.add({
    'player1': current_uid,
    'player2': friend_uid,
    'current_player': current_uid,
    'winner': 'TBD',
    'player1_score': 0,
    'player2_score': 0,
    'current_color': {'red': new Random().nextInt(256), 'green':new Random().nextInt(256), 'blue': new Random().nextInt(256)},
  });
  String game_uid = newGameRef.id;
  final userDoc = FirebaseFirestore.instance.collection('users').doc(
      current_uid);
  try {
    await userDoc.update({
      'current_games': FieldValue.arrayUnion([game_uid])
    });
  } catch (e) {
    print('ERROR');
  }



  final otherDoc = FirebaseFirestore.instance.collection('users').doc(friend_uid);
  try {
    await otherDoc.update({
      'current_games': FieldValue.arrayUnion([game_uid])
    });
  } catch(e) {
    print('ERROR');
  }
  return game_uid;
}
Future<void> removeGameFromList(String game_uid, int winner, bool incrementScore) async {
  final currentUserDoc = await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get();
  final currentGameDoc = await FirebaseFirestore.instance.collection('games').doc(game_uid).get();
  if (currentUserDoc.exists && currentGameDoc.exists) {
    String other_uid = "";
    if (FirebaseAuth.instance.currentUser!.uid == currentGameDoc.get('player1')) {
      other_uid = currentGameDoc.get('player2');
    } else {
      other_uid = currentGameDoc.get('player1');
    }
    final otherUserDoc = await FirebaseFirestore.instance.collection('users').doc(other_uid).get();
    List<dynamic> current_games =currentUserDoc.data()?['current_games'] ?? [];
    Map<String, List<int>> friend_records =  (currentUserDoc.data()?['friend_records'] as Map<String, dynamic>)?.map(
          (key, value) => MapEntry(key, List<int>.from(value)),
    ) ??
        {};
    if (winner != -1) {
      if (incrementScore) {
        friend_records[other_uid]?[winner] = otherUserDoc.get('friend_records')[FirebaseAuth.instance.currentUser!.uid][winner == 0 ? 1 : 0] + 1;
      } else {
        friend_records[other_uid]?[winner] = otherUserDoc.get('friend_records')[FirebaseAuth.instance.currentUser!.uid][winner == 0 ? 1 : 0];
      }

      FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update({
        'friend_records': friend_records,
      }).catchError((error) {
        print('Error storing user data: $error');
      });
    }
    current_games.remove(game_uid);
    FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update({
      'current_games': current_games,
    }).catchError((error) {
      print('Error storing user data: $error');
    });

  }




}
Future<void> buildStartGamePopUp(BuildContext context, Map<String, dynamic> userColorData, String username, String uid, Map<String, dynamic> game_color) async {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            backgroundColor: Color.fromRGBO(userColorData['red'].toInt(), userColorData['green'].toInt(), userColorData['blue'].toInt(), 1),
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
                            child: new Text('Do you want to start a game with ${username}?',  textAlign: TextAlign.center, style: GoogleFonts.spaceMono(textStyle: TextStyle(fontSize: 25.0,color: Colors.white))),
                          )//
                      ),
                      SizedBox(
                        height: 20.0,
                        width: 5.0,
                      ),

                      Row(children: <Widget>[Container(
                          width: 175, // Set the desired width
                          height: 80, // Set the desired height
                          child: InkWell(
                            child: Container(
                                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                                decoration: BoxDecoration(
                                  color:Colors.white,
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(32.0),
                                      bottomRight: Radius.circular(0.0)),
                                ),
                                child: Row(mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text("Yes", textAlign: TextAlign.center,
                                        style: GoogleFonts.spaceMono(textStyle:  TextStyle(color: Colors.blue,fontSize: 25.0)),
                                      ),
                                    ])),
                            onTap:() async {
                              String game_uid = await startGame(FirebaseAuth.instance.currentUser!.uid, uid);
                              Navigator.of(context).pop();
                              Navigator.push(context, MaterialPageRoute(builder: (context) => MultiplayerChallengeScreen(uid: game_uid, currentColor: Color.fromRGBO(game_color['red'], game_color['green'], game_color['blue'], 1)))); //edit!!
                            },
                          )),
                        Container(
                          width: 175, // Set the desired width
                          height: 80, // Set the desired height
                          child: InkWell(
                            child: Container(
                                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                                decoration: BoxDecoration(
                                  color:Colors.white,
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(0.0),
                                      bottomRight: Radius.circular(32.0)),
                                ),
                                child: Row(mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text("No", textAlign: TextAlign.center,
                                        style: GoogleFonts.spaceMono(textStyle:  TextStyle(color: Colors.blue,fontSize: 25.0)),
                                      ),
                                    ])),
                            onTap:(){
                              Navigator.of(context).pop();
                            },
                          ),
                        )]),


                    ],
                  ),
                ),
              ],
            )
        );
      });
}
Future<void> buildCurrentGamePopUp(BuildContext context, Map<String, dynamic> userColorData, String username, String uid, bool has_winner, String winner, int winner_attempts) async {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            backgroundColor: Color.fromRGBO(userColorData['red'].toInt(), userColorData['green'].toInt(), userColorData['blue'].toInt(), 1),
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
                            child: (!has_winner ? new Text('It is currently ${username}\'s turn.',  textAlign: TextAlign.center, style: GoogleFonts.spaceMono(textStyle: TextStyle(fontSize: 25.0,color: Colors.white))) : (winner != "Tie" ? new Text('$winner has won the game with $winner_attempts guesses.',  textAlign: TextAlign.center, style: GoogleFonts.spaceMono(textStyle: TextStyle(fontSize: 25.0,color: Colors.white))) : new Text('You and $username have tied with $winner_attempts guesses.',  textAlign: TextAlign.center, style: GoogleFonts.spaceMono(textStyle: TextStyle(fontSize: 25.0,color: Colors.white))))),
                          )//
                      ),
                      SizedBox(
                        height: 20.0,
                        width: 5.0,
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
                            "OK", textAlign: TextAlign.center,
                            style: GoogleFonts.spaceMono(textStyle:  TextStyle(color: Colors.blue,fontSize: 25.0)),
                          ),
                        ),
                        onTap:(){
                          if (has_winner) {
                            int winner_num;
                            if (winner == username) {
                              winner_num = 1;
                            } else if (winner == 'Tie') {
                              winner_num = -1;
                            } else {
                                winner_num = 0;
                            }
                            removeGameFromList(uid, winner_num, false);
                          }
                          Navigator.of(context).pop();
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
