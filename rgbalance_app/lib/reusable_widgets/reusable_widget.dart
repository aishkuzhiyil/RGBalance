import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Image logoWidget(String imageName) {
  return Image.asset(
    imageName,
    width: 313.6,
    height: 99.2,
  );
}
Image logoWidget2(String imageName, double width, double height) {
  return Image.asset(
    imageName,
    width: width,
    height: height,
  );
}
Image colorImage(String imageName) {
  return Image.asset(
    imageName,
    fit:BoxFit.fitWidth,
  );
}

TextField reusableTextField(String text, IconData icon, bool isPasswordType,
    TextEditingController controller) {
  return TextField( controller: controller,
    obscureText: isPasswordType ,
    enableSuggestions: !isPasswordType,
    autocorrect: false,
    cursorColor: Colors.white,
    style: GoogleFonts.spaceMono(textStyle:TextStyle(
        color: Colors.white.withOpacity(.9))),
    decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          color: Colors.white70,
        ),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50.0),
            borderSide: BorderSide(width: 3, color:
            Color.fromRGBO(200, 29, 37, 1))),

        labelText: text,
        labelStyle: GoogleFonts.spaceMono(textStyle:TextStyle(
            color: Colors.white.withOpacity(.9))),
        filled: true,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        fillColor: Colors.white.withOpacity(0.3),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50.0),

            borderSide: const BorderSide(width: 3, style: BorderStyle.none))
    ),
    keyboardType: isPasswordType
        ? TextInputType.visiblePassword
        : TextInputType.emailAddress,
  );
}

Container signInSignUpButton(
    BuildContext context, bool isLogin, Function onTap) {
  return Container(width: MediaQuery.of(context).size.width,
    height: 50,
    margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
    child: ElevatedButton(
      onPressed: () {
        onTap();
      },
      child: Text(
        isLogin ? 'LOG IN' : 'CREATE ACCOUNT',
        style: GoogleFonts.spaceMono(textStyle:
        TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
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
  );
}





