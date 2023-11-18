import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rgbalance/reusable_widgets/reusable_widget.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'dart:math';
import 'package:rgbalance/Screens/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class TimedPlayScreen extends StatefulWidget {
  const TimedPlayScreen({super.key});

  @override
  State<TimedPlayScreen> createState() => _TimedPlayScreenState();
}

class _TimedPlayScreenState extends State<TimedPlayScreen> {
  double redValue = 0;
  double greenValue = 0;
  double blueValue = 0;
  double lastRed = 0;
  double lastGreen = 0;
  double lastBlue = 0;
  bool update = false;
  double redAnswer = (new Random()).nextInt(256).toDouble();
  double greenAnswer = (new Random()).nextInt(256).toDouble();
  double blueAnswer = (new Random()).nextInt(256).toDouble();
  double bestRed = 0;
  double bestGreen = 0;
  double bestBlue = 0;
  double lastAccuracy = 0;
  double bestAccuracy = 0;
  // int attempts = 0;
  int score = 0;
  int highScore = 0;
  final stopwatch = Stopwatch();
  final _stopwatchTimer = StopWatchTimer(mode: StopWatchMode.countDown,
    presetMillisecond: StopWatchTimer.getMilliSecFromMinute(2),);
  final _isHours = true;
  var timeDisplay = '';

  @override
  void toggleBooleanValue() {
    setState(() {
      update = true;
      lastRed = redValue;
      lastGreen = greenValue;
      lastBlue = blueValue;
      // attempts +=1;
      double redAccuracy = 0;
      if (redValue > redAnswer)
        redAccuracy = 1-((redValue-redAnswer)/256);
      else
        redAccuracy = 1-((redAnswer-redValue)/256);
      double greenAccuracy = 0;
      if (greenValue > greenAnswer)
        greenAccuracy = 1-((greenValue-greenAnswer)/256);
      else
        greenAccuracy = 1-((greenAnswer-greenValue)/256);
      double blueAccuracy = 0;
      if (blueValue > blueAnswer)
        blueAccuracy = 1-((blueValue-blueAnswer)/256);
      else
        blueAccuracy = 1-((blueAnswer-blueValue)/256);
      lastAccuracy = 100*(redAccuracy+greenAccuracy+blueAccuracy)/3;
      if (lastAccuracy > bestAccuracy) {
        bestRed = redValue;
        bestGreen = greenValue;
        bestBlue = blueValue;
        bestAccuracy = lastAccuracy;
      }
      if (bestRed - redAnswer <= 5 && bestRed - redAnswer >= -5 &&
          bestGreen - greenAnswer <= 5 && bestGreen - greenAnswer >= -5 &&
          bestBlue - blueAnswer <= 5 && bestBlue - blueAnswer >= -5) {
        bestAccuracy = 100.0;
        lastAccuracy = 100.0;
      }
      if (lastAccuracy == 100) {
        redValue = 0;
        greenValue = 0;
        blueValue = 0;
        lastRed = 0;
        lastGreen = 0;
        lastBlue = 0;
        update = false;
        redAnswer = (new Random()).nextInt(256).toDouble();
        greenAnswer = (new Random()).nextInt(256).toDouble();
        blueAnswer = (new Random()).nextInt(256).toDouble();
        bestRed = 0;
        bestGreen = 0;
        bestBlue = 0;
        lastAccuracy = 0;
        bestAccuracy = 0;
        score += 1;
      }
    });

    // Delay changing the boolean back to false by 1 second
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        update = false;
      });
    });
  }

  void initState() {
    // TODO: implement initState
    performTasks();
    _stopwatchTimer.onExecute.add(StopWatchExecute.start);
    stopwatch.start();
    super.initState();
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (stopwatch.elapsed.inSeconds >= 120) {
        // Elapsed time is 120 seconds, call the results() function
        updateHighScore();
        results();
        // Cancel the timer as we have achieved our goal
        timer.cancel();
      }
    });
  }

  Future<void> updateHighScore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && score > highScore) {
      FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'high_score': score,
      }).catchError((error) {
        print('Error storing user data: $error');
      });
      setState(() {
        highScore = score;
      });
    }
    //fetchTimedScore();
  }

  Future<void> performTasks() async {
    await fetchTimedScore();
    // await checkNewDay();
  }

  Future<void> fetchTimedScore() async {
    print('in fetch completed');
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          highScore = userDoc.data()?['high_score'] ?? 0;
          print('Setting highScore to ${highScore}');
        });
      }
    }
  }

  results() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              backgroundColor: Color.fromRGBO(255, 255, 255, 1),
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
                              child: new Text("Score: $score \nHigh Score: $highScore", style:TextStyle(fontSize: 25.0,color: Colors.black),textAlign: TextAlign.center),
                            )//
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
                              "OK",
                              style: TextStyle(color: Colors.blue,fontSize: 25.0),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          onTap:(){
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => HomeScreen()));
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

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container (
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            color: Color.fromRGBO(27, 32, 33, 1)),
        child: SingleChildScrollView(
          child: Column(
              children: <Widget>[
                logoWidget("assets/images/RGBLogo.png"),
                Text('Timed Play', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25)),
                Padding(
                    padding: EdgeInsets.fromLTRB(
                        10, MediaQuery.of(context).size.height*0.05, 20, 0)),
                Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      buildContainer(color: Color.fromRGBO(redAnswer.toInt(), greenAnswer.toInt(), blueAnswer.toInt(), 1)),
                      Padding(
                          padding: EdgeInsets.fromLTRB(
                              55, MediaQuery.of(context).size.height*0.05, 20, 0)),
                      update
                          ? buildContainer(color: Color.fromRGBO(redValue.toInt(), greenValue.toInt(), blueValue.toInt(), 1))
                          : buildContainer(color: Color.fromRGBO(lastRed.toInt(), lastGreen.toInt(), lastBlue.toInt(), 1)),

                    ]
                ),
                StreamBuilder<int>(
                  stream: _stopwatchTimer.rawTime,
                  initialData: _stopwatchTimer.rawTime.value,
                  builder: (context, snapshot) {
                    final value = snapshot.data;
                    final displayTime =
                    StopWatchTimer.getDisplayTime(value!, hours: _isHours);
                    timeDisplay = displayTime;
                    return Text(
                      'Time: ' + displayTime.substring(3),
                      style: const TextStyle(
                          fontSize: 20,
                          color: Color.fromRGBO(237,211,196,1.00)
                      ),
                    );
                  },
                ),
                Padding(
                    padding: EdgeInsets.fromLTRB(
                        20, MediaQuery.of(context).size.height*0.05, 20, 0)),
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
                    height: 60,
                    width: 340,
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
                Text('Best Guess', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25)),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                  Text('R', style: const TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(200, 29, 37, 1), fontSize: 40)),
                  (bestRed-redAnswer <= 5 && bestRed-redAnswer >= -5) ? answerImage("assets/images/Green Check.png") : ((bestRed < redAnswer) ? answerImage("assets/images/White Up Arrow.png") : answerImage("assets/images/White Down Arrow.png")),
                  Padding(padding: EdgeInsets.fromLTRB(10, MediaQuery.of(context).size.height*0.05, 20, 0)),
                  Text('G', style: const TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(97, 231, 134, 1), fontSize: 40)),
                  (bestGreen-greenAnswer <= 5 && bestGreen-greenAnswer >= -5) ? answerImage("assets/images/Green Check.png") : ((bestGreen < greenAnswer) ? answerImage("assets/images/White Up Arrow.png") : answerImage("assets/images/White Down Arrow.png")),
                  Padding(padding: EdgeInsets.fromLTRB(10, MediaQuery.of(context).size.height*0.05, 20, 0)),
                  Text('B', style: const TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(35, 116, 171, 1), fontSize: 40)),
                  (bestBlue-blueAnswer <= 5 && bestBlue-blueAnswer >= -5) ? answerImage("assets/images/Green Check.png") : ((bestBlue < blueAnswer) ? answerImage("assets/images/White Up Arrow.png") : answerImage("assets/images/White Down Arrow.png")),
                  Padding(padding: EdgeInsets.fromLTRB(10, MediaQuery.of(context).size.height*0.05, 20, 0)),
                  Text(bestAccuracy.round().toString() + '%', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25)),
                ]),
                Text('Last Guess', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25)),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                  Text('R', style: const TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(200, 29, 37, 1), fontSize: 40)),
                  (lastRed-redAnswer <= 5 && lastRed-redAnswer >= -5) ? answerImage("assets/images/Green Check.png") : ((lastRed < redAnswer) ? answerImage("assets/images/White Up Arrow.png") : answerImage("assets/images/White Down Arrow.png")),
                  Padding(padding: EdgeInsets.fromLTRB(10, MediaQuery.of(context).size.height*0.05, 20, 0)),
                  Text('G', style: const TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(97, 231, 134, 1), fontSize: 40)),
                  (lastGreen-greenAnswer <= 5 && lastGreen-greenAnswer >= -5) ? answerImage("assets/images/Green Check.png") : ((lastGreen < greenAnswer) ? answerImage("assets/images/White Up Arrow.png") : answerImage("assets/images/White Down Arrow.png")),
                  Padding(padding: EdgeInsets.fromLTRB(10, MediaQuery.of(context).size.height*0.05, 20, 0)),
                  Text('B', style: const TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(35, 116, 171, 1), fontSize: 40)),
                  (lastBlue-blueAnswer <= 5 && lastBlue-blueAnswer >= -5) ? answerImage("assets/images/Green Check.png") : ((lastBlue < blueAnswer) ? answerImage("assets/images/White Up Arrow.png") : answerImage("assets/images/White Down Arrow.png")),
                  Padding(padding: EdgeInsets.fromLTRB(10, MediaQuery.of(context).size.height*0.05, 20, 0)),
                  Text(lastAccuracy.round().toString() + '%', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25)),
                ]),
                Text('Score: ' + score.toString() + '\nHigh Score: ' + ((score>highScore) ? score.toString() : highScore.toString()), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25)),
              ]
          ),
        ),
      ),
    );
  }
}

Container buildContainer({required Color color}) {
  return Container(
    color: color,
    width:  100.0,
    height: 100.0,
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
