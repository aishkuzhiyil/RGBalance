import 'dart:io';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cyclop/cyclop.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rgbalance/Screens/NavBar.dart';
import 'package:rgbalance/Screens/photoChallenge.dart';

class PhotoPlayScreen extends StatefulWidget {
  const PhotoPlayScreen({super.key});

  @override
  State<PhotoPlayScreen> createState() => _PhotoPlayScreenState();
}

class _PhotoPlayScreenState extends State<PhotoPlayScreen> {

  String username = ''; // Initialize the username variable.
  double redValue = 0;
  double greenValue = 0;
  double blueValue = 0;
  Color containerColor = Color.fromRGBO(0, 0, 0, 1);
  final ValueNotifier<Color?> hoveredColor = ValueNotifier<Color?>(null);
  Color userColor = Colors.white;

  Future<void> fetchUserColor() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final colorData = userDoc.data()?['user_color'];
        setState(() {
          userColor =
              Color.fromRGBO(colorData['red'] as int, colorData['green'] as int, colorData['blue'] as int, 1);
          containerColor = userColor;
        });
      }
    }
  }
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
    fetchUserColor();
    fetchUsername(); // Fetch the username when the widget is initialized.
  }
  XFile? pickedImage;
  Widget buildImage() {
    if (pickedImage != null) {
      return SizedBox(
        height: 150,
        width: 150,
        child: Image.file(File(pickedImage!.path),fit: BoxFit.cover,),
      );
    } else {
      return SizedBox(
        height: 150,
        width: 150,
        child: DecoratedBox(
          decoration: BoxDecoration(color: userColor),
        ),
        );
      // Display a message if no image is selected
    }
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
                Text('Welcome $username', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25)),
                Padding(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.01)
                ),
                Text('Choose a picture from your gallery.', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.white, fontSize: 18)),
                Padding(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.01)
                ),
                Text('Then select a color', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.white, fontSize: 18)),
                Padding(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.02)
                ),
                buildImage(),
                Padding(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.02)
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
                        onPressed: () async {

                          final ImagePicker picker = ImagePicker();
                          pickedImage = await picker.pickImage(source: ImageSource.gallery);
                          setState(() {
                            containerColor = userColor;
                          });
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
                        child: const Text('Choose Picture from Gallery',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),

                    ),
                  ),
                ),
                EyedropperButton( // Add this EyedropperButton
                  onColor: (value) {
                    setState(() {
                      containerColor = value; // Update the containerColor with the selected color
                    });
                  },
                  onColorChanged: (value) => hoveredColor.value = value,
                ),
                Padding(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.01)
                ),
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: containerColor,
                    shape: BoxShape.circle,
                  ),
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
                        onPressed: () async {

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PhotoChallengeScreen(initialColor: containerColor),
                            ),
                          );

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
                        child: const Text('Submit',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),

                    ),
                  ),
                ),
                // Padding(
                //     padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.01)
                // ),
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
                        onPressed: () async {

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NavBarScreen(),
                            ),
                          );

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
                        child: const Text('Home',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),

                    ),
                  ),
                ),
              ],
            )
        ));
  }
}

