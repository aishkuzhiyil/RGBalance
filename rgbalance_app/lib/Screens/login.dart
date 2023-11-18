import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rgbalance/Screens/home.dart';
import 'package:rgbalance/Screens/signup.dart';
import 'package:rgbalance/reusable_widgets/reusable_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'NavBar.dart';
import 'forgotPassword.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({Key? key}) : super(key: key);

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  void changeMessage(String newMessage) {
    setState(() {
      message = newMessage;
    });
  }

  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  String message = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            color: Color.fromRGBO(27, 32, 33, 1)),
          child: SingleChildScrollView(child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height*0.2, 20, 0),
            child: Column(
              children: <Widget>[
                logoWidget("assets/images/RGBLogo.png"),
                const SizedBox(
                  height: 30,
                ),
                reusableTextField("Enter Email", Icons.person_outline, false,
                    _emailTextController),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField("Enter Password", Icons.lock_outline, true,
                    _passwordTextController),
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
                const SizedBox(
                  height: 10,
                ),
              signInSignUpButton(context, true, () {
                FirebaseAuth.instance
                    .signInWithEmailAndPassword(
                  email: _emailTextController.text,
                  password: _passwordTextController.text,
                )
                    .then((authResult) {
                  // Sign-in successful, navigate to HomeScreen.
                  Navigator.push(context, MaterialPageRoute(builder: (context) => NavBarScreen(initialIndex: 0,)));
                })
                    .catchError((error) {
                  if (error is FirebaseAuthException) {
                    final authError = error as FirebaseAuthException;
                    switch (authError.code) {
                      case 'user-not-found':
                        changeMessage('User not found.');
                        break;
                      case 'wrong-password':
                        changeMessage('Wrong password.');
                        break;
                      default:
                        changeMessage('Invalid email/password combination');
                    }
                  } else {
                    changeMessage('An unexpected error occurred: $error');
                  }
                  print("Error during sign-in: $error");
                });
              }),
                forgotPasswordOption(),
                const SizedBox(
                  height: 10,
                ),
                signUpOption()
              ],
            ),
          ),
          ),
        ),
    );
  }
  Row forgotPasswordOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
         Text("Forgot Password?",
            style: GoogleFonts.spaceMono(textStyle:TextStyle(color: Colors.white70))),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ForgotPasswordScreen()));
          },
          child:  Text(
            " Reset",
            style: GoogleFonts.spaceMono(textStyle:TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        )
      ],
    );
  }
  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
         Text("Don't Have Account?",
            style: GoogleFonts.spaceMono(textStyle:TextStyle(color: Colors.white70))),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
              MaterialPageRoute(builder: (context) => SignUpScreen()));
          },
          child: Text(
            " Sign Up",
            style: GoogleFonts.spaceMono(textStyle:TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        )
      ],
    );
  }
}



