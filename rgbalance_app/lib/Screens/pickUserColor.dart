import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rgbalance/Screens/NavBar.dart';
import 'package:rgbalance/Screens/home.dart';

class PickUserColorScreen extends StatefulWidget {
  const PickUserColorScreen({super.key});

  @override
  State<PickUserColorScreen> createState() => _PickUserColorState();
}

class _PickUserColorState extends State<PickUserColorScreen> {
  String username = ''; // Initialize the username variable.
  double redValue = 0;
  double greenValue = 0;
  double blueValue = 0;
  Color containerColor = Color.fromRGBO(0, 0, 0, 1);

  Future<void> fetchUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          username = userDoc.data()?['username'] ?? 'User';
        });
      }
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
      body: Container(width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            color: Color.fromRGBO(27, 32, 33, 1)),
      child: Column(
        children: <Widget>[
        Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1)
        ),
      Container(
          width: MediaQuery.of(context).size.height * 0.25,
            height: MediaQuery.of(context).size.height * 0.25,
            decoration: BoxDecoration(
              color: containerColor,
              shape: BoxShape.circle,
            ),
          ),
          Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.05)
          ),
          Text('Welcome $username', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25)),
          Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.01)
          ),
          Text('Choose a color for your profile.', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.white, fontSize: 18)),
          Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.02)
          ),
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
                containerColor = Color.fromRGBO(redValue.toInt(), greenValue.toInt(), blueValue.toInt(), 1);
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
                containerColor = Color.fromRGBO(redValue.toInt(), greenValue.toInt(), blueValue.toInt(), 1);
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
                containerColor = Color.fromRGBO(redValue.toInt(), greenValue.toInt(), blueValue.toInt(), 1);
              });
            },
          ),
          Container(
            width: double.infinity,
            height: 50,
            margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width * 0.5,
                ),
                child: ElevatedButton(
                  onPressed: () {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                        'user_color': {
                          'red': redValue.toInt(),
                          'green': greenValue.toInt(),
                          'blue': blueValue.toInt(),
                        },
                      }).then((_) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => NavBarScreen()));
                      }).catchError((error) {
                        print('Error storing user data: $error');
                      });
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.pressed)) {
                        return containerColor;
                      }
                      return Colors.white;
                    }),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        side: const BorderSide(
                          color: Color.fromRGBO(35, 116, 171, 1),
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  child: const Text('Submit User Color',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
    )
    ));
  }
}
