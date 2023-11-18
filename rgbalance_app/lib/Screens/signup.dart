import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rgbalance/Screens/login.dart';
import 'package:rgbalance/Screens/home.dart';
import 'package:rgbalance/Screens/pickUserColor.dart';
import '../reusable_widgets/reusable_widget.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String message = ''; // Store error message here

  void changeMessage(String newMessage) {
    setState(() {
      message = newMessage;
    });
  }

  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _passwordTextController2 = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _userNameTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title:  Text(
          "Sign Up",
          style: GoogleFonts.spaceMono(textStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        )),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          color: Color.fromRGBO(27, 32, 33, 1),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 120, 20, 0),
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 20,
                ),
                reusableTextField(
                  "Enter Username",
                  Icons.person_outline,
                  false,
                  _userNameTextController,
                ),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField("Enter Email", Icons.person_outline, false, _emailTextController),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField(
                  "Enter Password",
                  Icons.lock_outlined,
                  true,
                  _passwordTextController,
                ),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField("Renter Password", Icons.lock_outlined, true, _passwordTextController2),
                const SizedBox(
                  height: 20,
                ),
                Visibility(
                  visible: message.isNotEmpty, // Show the error message only when it's not empty
                  child: Text(
                    message,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                signInSignUpButton(context, false, () {
                  final RegExp specialCharRegExp = RegExp(r'[!@#\$%^&*()?{}|<>]');
                  if (_passwordTextController.text != _passwordTextController2.text) {
                    changeMessage('Passwords do not match');
                  } else if (_passwordTextController.text.length < 8) {
                    changeMessage('Password is too short');
                  } else if (!specialCharRegExp.hasMatch(_passwordTextController.text)) {
                    changeMessage('Password must contain a special character: !@#\$%^&*()?{}|<>');
                  } else {
                    FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: _emailTextController.text,
                      password: _passwordTextController.text,
                    ).then((authResult) {
                      // User registered successfully. Now store additional user data in Firestore.
                      FirebaseFirestore.instance.collection('users').doc(authResult.user?.uid).set({
                        'username': _userNameTextController.text,
                      }).then((_) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => PickUserColorScreen()));
                      }).catchError((error) {
                        if (error is FirebaseAuthException) {
                          final authError = error as FirebaseAuthException;
                          switch (authError.code) {
                            case 'email-already-in-use':
                              changeMessage('Email is already in use with another account');
                              break;
                            case 'weak-password':
                              changeMessage('The password is too weak.');
                              break;
                            case 'operation-not-allowed':
                              changeMessage('Operation not allowed.');
                              break;
                            default:
                              changeMessage('Error: ${authError.message}');
                          }
                        } else {
                          changeMessage('An unexpected error occurred: $error');
                        }
                        print("Error during registration: $error");
                      });
                    }).catchError((error) {
                      // Handle authentication errors
                      if (error is FirebaseAuthException) {
                        final authError = error as FirebaseAuthException;
                        changeMessage('Authentication Error: ${authError.message}');
                      } else {
                        changeMessage('An unexpected error occurred: $error');
                      }
                      print('Error during registration: $error');
                    });
                  }
                }),
              LogInOption()
              ],
            ),
          ),
        ),
      ),
    );

  }
  Row LogInOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
         Text("Already Have An Account?",
            style:  GoogleFonts.spaceMono(textStyle:TextStyle(
                color: Colors.white))),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => LogInScreen()));
          },
          child:  Text(
            " Log in",
            style:  GoogleFonts.spaceMono(textStyle:TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        )
      ],
    );
}
}
