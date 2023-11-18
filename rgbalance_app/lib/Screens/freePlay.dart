import 'package:flutter/material.dart';
import 'package:rgbalance/reusable_widgets/reusable_widget.dart';

class FreePlayScreen extends StatefulWidget {
  const FreePlayScreen({super.key});

  @override
  State<FreePlayScreen> createState() => _FreePlayScreenState();
}

class _FreePlayScreenState extends State<FreePlayScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container (
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              color: Color.fromRGBO(27, 32, 33, 1)),
          child: SingleChildScrollView(child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height*0.2, 20, 0),
            child: Column(
              children: <Widget>[
                logoWidget("assets/images/RGBLogo.png"),
                Text('Free Play', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                colorImage("assets/images/DailyChallenge.png"),
              ],
            ),
          ),
          ),
        )
    );
  }
}

