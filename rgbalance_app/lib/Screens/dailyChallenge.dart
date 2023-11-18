

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rgbalance/Screens/home.dart';
import 'package:rgbalance/reusable_widgets/reusable_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'NavBar.dart';

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  Future<void> fetchCompleted() async {

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          completedDailyChallenge = userDoc.data()?['completed_daily_challenge'] ?? false;
          last_login_timestamp = userDoc.data()?['last_login_timestamp'] ?? "";
          daily_streak = userDoc.data()?['daily_streak'] ?? 0;
          daily_last_completed = userDoc.data()?['daily_last_completed'] ?? "";
          daily_total = userDoc.data()?['daily_total'] ?? 0;
          lost_game = userDoc.data()?['daily_lost'] ?? false;
          total_accuracy = userDoc.data()?['total_accuracy'] ?? 0.0;
        });
        if (daily_last_completed == "" || DateTime.now().difference(DateTime.parse(daily_last_completed)).inDays >= 2) {
          daily_streak = 0;
        }
        if (last_login_timestamp == "" || DateTime.parse(last_login_timestamp).isBefore(DateTime(now.year, now.month, now.day))) {
          completedDailyChallenge = false;
        }
        if (completedDailyChallenge) {
          daily_streak -=1;
          daily_total -=1;
        }
        if (lost_game && completedDailyChallenge) {
        }
      }
    }

  }

  //this contains the list of RGB values for each day. Element zero is
  // for October 19, 2023 and right now there are __ different colors for the next month
  List<List<double>> dailyChallengeValues = [
    [161, 171, 102], [74, 245, 7], [142, 137, 251], [181, 172, 230],
    [215, 148, 175], [46, 223, 62], [244, 113, 163], [71, 28, 254],
    [222, 141, 206], [209, 85, 164], [184, 228, 70], [176, 208, 101],
    [230, 118, 69], [227, 150, 41], [12, 205, 248], [127, 219, 148],
    [136, 140, 78], [197, 240, 180], [6, 83, 51], [128, 80, 107],
    [41, 219, 70], [156, 61, 216], [83, 143, 125], [193, 173, 141],
    [205, 206, 63], [113, 167, 28], [251, 38, 247], [172, 29, 179],
    [42, 229, 249], [192, 162, 131], [199, 247, 75], [32, 190, 104],
    [189, 186, 189], [85, 225, 134], [146, 33, 89], [177, 129, 136],
    [115, 168, 84], [70, 131, 211], [27, 136, 187], [200, 191, 239],
    [217, 88, 91], [101, 122, 76], [101, 253, 3], [212, 209, 67],
    [170, 211, 61], [19, 222, 162], [110, 42, 162], [62, 155, 168],
    [201, 117, 154], [23, 211, 25], [194, 214, 68], [3, 227, 85],
    [154, 205, 16], [159, 49, 53], [49, 216, 66], [251, 193, 5],
    [43, 100, 107], [84, 119, 138], [105, 167, 156], [171, 149, 94],
    [0, 36, 2], [36, 15, 195], [175, 20, 223], [81, 192, 136],
    [49, 162, 166], [170, 133, 76], [188, 124, 143], [253, 33, 188],
    [61, 234, 230], [129, 176, 208], [254, 135, 23], [242, 170, 171],
    [165, 118, 88], [99, 105, 175], [75, 163, 220], [87, 209, 127],
    [241, 205, 255], [98, 87, 147], [73, 188, 87], [241, 201, 75],
    [200, 238, 190], [81, 208, 69], [119, 54, 251], [100, 42, 103],
    [207, 22, 109], [12, 208, 11], [213, 222, 73], [194, 26, 248],
    [103, 92, 136], [201, 14, 170], [3, 134, 12], [121, 117, 199],
    [95, 223, 130], [148, 34, 236], [79, 175, 53], [7, 98, 37],
    [181, 85, 97], [253, 103, 159], [152, 129, 229], [136, 210, 255],
    [182, 201, 176], [254, 243, 85], [6, 48, 201], [127, 225, 229],
    [93, 94, 18], [224, 187, 101], [42, 44, 187], [167, 10, 34],
    [132, 105, 98], [72, 108, 204], [124, 52, 141], [238, 65, 2],
    [173, 124, 74], [26, 104, 87], [55, 136, 251], [97, 33, 57],
    [99, 12, 159], [168, 239, 35], [168, 80, 208], [96, 99, 0],
    [2, 158, 107], [19, 109, 178], [253, 8, 213], [236, 53, 165],
    [142, 220, 248], [64, 219, 145], [67, 165, 227], [37, 166, 239],
    [47, 212, 1], [23, 214, 152], [189, 128, 224], [251, 115, 30],
    [148, 170, 234], [17, 172, 213], [95, 99, 158], [70, 144, 129],
    [5, 92, 104], [13, 251, 15], [146, 73, 189], [73, 167, 240],
    [171, 16, 29], [254, 1, 133], [212, 49, 174], [155, 80, 7],
    [144, 55, 202], [185, 136, 73], [136, 48, 255], [134, 105, 245],
    [95, 209, 160], [133, 249, 62], [184, 246, 25], [189, 23, 39],
    [215, 185, 242], [191, 63, 242], [20, 113, 251], [158, 146, 218],
    [97, 139, 47], [192, 20, 61], [172, 107, 131], [79, 1, 164],
    [23, 212, 104], [149, 22, 170], [216, 52, 238], [250, 46, 206],
    [103, 224, 103], [62, 14, 27], [22, 26, 160], [87, 13, 36],
    [218, 170, 81], [213, 79, 52], [208, 23, 44], [121, 28, 219],
    [217, 163, 10], [18, 81, 77], [100, 98, 128], [249, 229, 123],
    [220, 213, 19], [151, 212, 35], [55, 213, 147], [80, 243, 242],
    [133, 47, 142], [232, 63, 6], [164, 49, 128], [148, 233, 244],
    [119, 103, 55], [84, 176, 67], [15, 98, 98], [59, 82, 78],
    [241, 166, 220], [203, 244, 88], [242, 13, 147], [43, 128, 135],
    [32, 29, 71], [192, 168, 1], [128, 141, 73], [181, 126, 176],
    [141, 162, 20], [232, 192, 134], [215, 129, 66], [94, 140, 107],
    [208, 131, 176], [58, 135, 43], [201, 242, 219], [64, 59, 153],
    [189, 163, 147], [46, 29, 52], [122, 62, 3], [45, 216, 247],
    [155, 160, 55], [177, 4, 122], [124, 235, 252], [54, 106, 125],
    [234, 37, 244], [11, 39, 65], [172, 135, 65], [240, 223, 17],
    [68, 155, 161], [116, 12, 228], [178, 255, 6], [164, 185, 127],
    [195, 121, 127], [169, 205, 177], [22, 176, 151], [106, 18, 183],
    [233, 138, 44], [163, 175, 135], [184, 117, 133], [167, 114, 159],
    [244, 128, 242], [144, 239, 203], [225, 229, 177], [143, 191, 92],
    [15, 61, 237], [108, 180, 105], [252, 5, 41], [197, 188, 196],
    [224, 3, 27], [95, 105, 124], [0, 121, 20], [8, 0, 143],
    [46, 63, 42], [136, 156, 19], [47, 63, 3], [151, 154, 66],
    [244, 182, 75], [167, 97, 137], [193, 87, 105], [45, 246, 5],
    [140, 228, 171], [77, 56, 125], [25, 140, 52], [49, 156, 24],
    [63, 42, 45], [186, 90, 165], [196, 201, 166], [132, 125, 70],
    [36, 178, 16], [244, 106, 255], [62, 27, 124], [228, 166, 171],
    [8, 204, 113], [185, 26, 115], [212, 56, 105], [118, 178, 23],
    [105, 157, 107], [19, 127, 64], [63, 215, 163], [67, 160, 155],
    [89, 95, 170], [58, 250, 108], [26, 137, 246], [143, 93, 80],
    [7, 128, 38], [79, 185, 87], [75, 251, 234], [81, 161, 123],
    [54, 60, 116], [181, 216, 54], [145, 176, 116], [69, 101, 220],
    [234, 75, 250], [205, 15, 3], [24, 136, 45], [180, 222, 189],
    [180, 64, 137], [197, 97, 37], [173, 158, 86], [203, 43, 253],
    [84, 248, 140], [190, 106, 61], [44, 54, 224], [22, 198, 220],
    [216, 205, 130], [112, 127, 28], [243, 71, 110], [0, 173, 182],
    [65, 198, 80], [28, 146, 190], [1, 201, 56], [206, 185, 251],
    [121, 203, 67], [170, 106, 56], [206, 236, 24], [91, 244, 154],
    [159, 29, 159], [145, 161, 191], [120, 191, 171], [172, 89, 93],
    [81, 85, 236], [160, 255, 244], [51, 226, 154], [151, 126, 63],
    [91, 163, 89], [127, 21, 34], [241, 233, 31], [140, 57, 136],
    [247, 50, 237], [31, 55, 232], [47, 118, 208], [18, 25, 102],
    [19, 125, 34], [132, 66, 40], [40, 209, 254], [72, 213, 212],
    [47, 190, 66], [33, 113, 230], [205, 69, 16], [0, 149, 23],
    [33, 162, 19], [78, 80, 216], [175, 28, 106], [59, 232, 185],
    [59, 142, 250], [188, 110, 236], [69, 88, 217], [224, 213, 229],
    [135, 4, 73], [60, 98, 41], [19, 168, 203], [31, 133, 104],
    [77, 199, 172], [170, 186, 183], [254, 30, 121], [86, 152, 172],
    [180, 11, 166], [20, 75, 115], [14, 105, 161], [133, 12, 119],
    [165, 188, 162], [110, 164, 195], [70, 215, 45], [150, 176, 40],
    [91, 69, 126], [59, 11, 124], [184, 30, 54], [106, 169, 98],
    [255, 27, 192], [95, 216, 97], [57, 141, 82], [167, 12, 182],
    [207, 177, 237], [119, 150, 199], [234, 153, 122], [253, 119, 165],
    [171, 131, 71]
  ];
  List result = [];
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
  int daily_total = 0;
  int daily_streak = 0;
  String daily_last_completed = "";
  String last_login_timestamp = "";
  DateTime now = DateTime.now();
  bool completedDailyChallenge = false;
  bool lost_game = false;
  double total_accuracy = 0.0;
  void initState() {
    super.initState();
    // Call your function here when the screen is opened
    performTasks();


  }
  Future<void> performTasks() async {
    await fetchCompleted();
    await checkNewDay();
    await checkCompleted(context, attempts, [redAnswer, greenAnswer, blueAnswer], lost_game);
  }

  @override
  checkNewDay() async {
    DateTime first = DateTime(DateTime.now().year, 1, 1, 0, 0);
    int dayOfYear = (DateTime.now()).difference(first).inDays;
    redAnswer = dailyChallengeValues[dayOfYear][0];
    greenAnswer = dailyChallengeValues[dayOfYear][1];
    blueAnswer = dailyChallengeValues[dayOfYear][2];

    fetchCompleted();
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
      String res = "";
      res += '🟥';
      if (redValue.toInt() - redAnswer <= 5 && redValue.toInt() - redAnswer >= -5) {
        res += '✅';
      } else if (redValue.toInt() < redAnswer) {
        res += '⬆️';
      } else {
        res += '⬇️';
      }
      res += '🟩';
      if (greenValue.toInt() - greenAnswer <= 5 && greenValue.toInt() - greenAnswer >= -5) {
        res += '✅';
      } else if (greenValue.toInt() < greenAnswer) {
        res += '⬆️';
      } else {
        res += '⬇️';
      }
      res += '🟦';
      if (blueValue.toInt() - blueAnswer <= 5 && blueValue.toInt() - blueAnswer >= -5) {
        res += '✅';
      } else if (blueAnswer.toInt() < blueAnswer) {
        res += '⬆️';
      } else {
        res += '⬇️';
      }
      result.add(res);
      if (bestRed.toInt() - redAnswer <= 5 && bestRed.toInt() - redAnswer >= -5 &&
          bestGreen.toInt() - greenAnswer <= 5 && bestGreen.toInt() - greenAnswer >= -5 &&
          bestBlue.toInt() - blueAnswer <= 5 && bestBlue.toInt() - blueAnswer >= -5) {
        completedDailyChallenge = true;
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'daily_last_completed': DateTime(now.year, now.month, now.day).toIso8601String(),
          }).catchError((error) {
            print('Error storing user data: $error');
          });
          FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'daily_challenge_guesses': result,
          }).catchError((error) {
            print('Error storing user data: $error');
          });
          FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'daily_challenge_attempts': attempts,
          }).catchError((error) {
            print('Error storing user data: $error');
          });
        }
        bestAccuracy = 100.0;
        lastAccuracy = 100.0;
        lost_game = false;
        total_accuracy = (total_accuracy*(daily_total)+1)/(daily_total+1);
      }
      else if (attempts == 6) {
        lost_game = true;
        total_accuracy = (total_accuracy*(daily_total))/(daily_total+1);
        daily_streak = -1;
        completedDailyChallenge = true;
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'daily_last_completed': DateTime(now.year, now.month, now.day)
                .toIso8601String(),
          }).catchError((error) {
            print('Error storing user data: $error');
          });
          FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'daily_challenge_guesses': result

          }).catchError((error) {
            print('Error storing user data: $error');
          });
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
  checkCompleted(BuildContext context, int numAttempts, List<double> dailyAnswer, bool lost_game) {

    if (completedDailyChallenge) {
      buildPopUp(context, numAttempts, dailyAnswer, lost_game, result);
      setState(() {
        buildPopUp(context, numAttempts, dailyAnswer, lost_game, result);
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'completed_daily_challenge': completedDailyChallenge,
          }).catchError((error) {
            print('Error storing user data: $error');
          });
          FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'last_login_timestamp': DateTime.now().toIso8601String(),
          }).catchError((error) {
            print('Error storing user data: $error');
          });
          FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'daily_streak': daily_streak+1,
          }).catchError((error) {
            print('Error storing user data: $error');
          });
          FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'daily_total': daily_total+1,
          }).catchError((error) {
            print('Error storing user data: $error');
          });
          FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'daily_lost': lost_game,
          }).catchError((error) {
            print('Error storing user data: $error');
          });
          FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'total_accuracy': total_accuracy,
          }).catchError((error) {
            print('Error storing user data: $error');
          });
        }
      });
    }
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
                Padding(padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.05),),
                logoWidget2("assets/images/RGBLogo.png", MediaQuery.of(context).size.width*0.9, MediaQuery.of(context).size.height*0.11,),

                Text( '${now.month}-${now.day}-${now.year} Daily Challenge', textAlign: TextAlign.center,  style: GoogleFonts.spaceMono(textStyle:  TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25))),
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
                    checkCompleted(context, attempts, [redAnswer, greenAnswer, blueAnswer], lost_game);
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
                Text('Attempts Remaining: ' + ((6-attempts).toString()), style: GoogleFonts.spaceMono(textStyle:  TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25))),
              ]
          ),
        ),
      ),
    );
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


Future<void> buildPopUp(BuildContext context, int numAttempts, List<double> dailyAnswer, bool lost_game, List result ) async {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            backgroundColor: Color.fromRGBO(dailyAnswer[0].toInt(), dailyAnswer[1].toInt(), dailyAnswer[2].toInt(), 1),
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
                            child: (numAttempts <= 0 && lost_game == false) ? new Text("Congratulations! You completed today's daily challenge.",  textAlign: TextAlign.center, style: GoogleFonts.spaceMono(textStyle: TextStyle(fontSize: 25.0,color: Colors.white))) : (lost_game == false ? new Text("Congratulations! You completed today's daily challenge in ${numAttempts} guesses.",  textAlign: TextAlign.center, style: GoogleFonts.spaceMono(textStyle: TextStyle(fontSize: 25.0,color: Colors.white))) : new Text("You lost today's daily challenge. Try again tomorrow!", textAlign: TextAlign.center,  style: GoogleFonts.spaceMono(textStyle: TextStyle(fontSize: 25.0,color: Colors.white)))),
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
                            "OK", textAlign: TextAlign.center,
                            style: GoogleFonts.spaceMono(textStyle:  TextStyle(color: Colors.blue,fontSize: 25.0)),
                          ),
                        ),
                        onTap:(){
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => NavBarScreen()));
                        },
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
                            "Copy Results", textAlign: TextAlign.center,
                            style: GoogleFonts.spaceMono(textStyle:  TextStyle(color: Colors.blue,fontSize: 25.0)),
                          ),
                        ),
                        onTap:() async {
                          final user = FirebaseAuth.instance.currentUser;
                          List guessList = [];
                          int numberAttempts = 0;
                          if (user != null) {
                            final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
                            if (userDoc.exists) {
                              guessList = userDoc.data()?['daily_challenge_guesses'] ?? [];
                              numberAttempts = userDoc.data()?['daily_challenge_attempts'] ?? 0;
                            }
                          }

                          if (guessList.length == 0) {
                            guessList = result;
                          }
                          if (numberAttempts == 0) {
                            numberAttempts = numAttempts;
                          }
                          DateTime currentDate = DateTime.now();
                          String text = '${currentDate.month}/${currentDate.day}/${currentDate.year} Daily Challenge: ';
                          if (lost_game) {
                            text += '❌\n';
                          } else {
                            text += '$numberAttempts/6\n';
                          }

                          for (int i = 0; i < guessList.length; i++) {
                            text += '\n';
                            text += guessList[i];
                          }
                          Clipboard.setData(ClipboardData(text: text));
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content:  Text('Succesffully copied to clipboard', style: TextStyle(fontSize: 8),),));
                        },
                      ),
                    ],
                  ),
                ),
                // Positioned(
                //   top: 0.0,
                //   right: 0.0,
                //   child: FloatingActionButton(
                //     child: Image.asset("assets/red_cross.png"),
                //     onPressed: (){
                //       Navigator.pop(context);
                //     },
                //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80)),
                //     backgroundColor: Colors.white,
                //     mini: true,
                //     elevation: 5.0,
                //   ),
                // ),
              ],
            )
        );
      });
}


