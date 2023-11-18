import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController emailController = TextEditingController();
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
              SizedBox(height: MediaQuery.of(context).size.height * .1,),
           Text('Receive an email to reset your password',
             style: GoogleFonts.spaceMono(textStyle:
             TextStyle(fontSize: 26,
                 color: Colors.white,
                 fontWeight: FontWeight.bold)),
             textAlign: TextAlign.center,
           ),
           const SizedBox(height: 20,),
           TextField( controller: emailController,
            obscureText: false ,
            autocorrect: false,
            cursorColor: Colors.white,
            style: GoogleFonts.spaceMono(textStyle:TextStyle(color: Colors.white)),
            decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.email,
                  color: Colors.white70,
                ),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50.0),
                    borderSide: BorderSide(width: 3, color:
                    Color.fromRGBO(200, 29, 37, 1))),

                labelText: 'Email',
                labelStyle: GoogleFonts.spaceMono(textStyle:TextStyle(color: Colors.white.withOpacity(.9))),
                filled: true,
                floatingLabelBehavior: FloatingLabelBehavior.never,
                fillColor: Colors.white.withOpacity(0.3),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50.0),

                    borderSide: const BorderSide(width: 3, style: BorderStyle.none))
            ),),
              const SizedBox(height: 10,),
          Container(width: MediaQuery.of(context).size.width,
            height: 50,
            margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
            child: ElevatedButton(
              onPressed: () {
                resetPassword(context);
              },
              child: Text('RESET PASSWORD',
                style: GoogleFonts.spaceMono(textStyle:TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)) ,
              ),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.pressed)) {
                      return Colors.black26;
                    }
                    return Colors.white;
                  }),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(side: BorderSide(
                          color: Color.fromRGBO(35, 116, 171, 1),
                          width: 3),
                          borderRadius: BorderRadius.circular(30)))),
            ),
          )

            ],
          ),
        ),
        ),
      ),
    );
  }
  Future resetPassword(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(snackBar(false, emailController.text.trim()));
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(snackBar(true, e.toString()));
      Navigator.of(context).pop();
    }

  }

  SnackBar snackBar(bool error, String message) {
    return SnackBar(
        content:  Text(error ? 'Error: $message' : 'Password Reset Email Sent to $message'),
        action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
        // Some code to undo the change.
      },
    ),);
  }
}
