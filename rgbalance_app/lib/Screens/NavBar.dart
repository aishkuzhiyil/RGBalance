import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rgbalance/Screens/FriendRequest.dart';
import 'package:rgbalance/Screens/dailyChallenge.dart';
import 'package:rgbalance/Screens/freePlay.dart';
import 'package:rgbalance/Screens/settings.dart';
import 'package:rgbalance/Screens/stats.dart';
import 'package:rgbalance/Screens/timedPlay.dart';

import '../userColor.dart';
import 'home.dart';
import 'login.dart';

class NavBarScreen extends StatefulWidget {
  final int initialIndex;

  const NavBarScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<NavBarScreen> createState() => _NavBarScreenState(initialIndex);
}

class _NavBarScreenState extends State<NavBarScreen> {
  int _currentPageIndex;
  final UserColorProvider userColorProvider = UserColorProvider();
  _NavBarScreenState(int initialIndex) : _currentPageIndex = initialIndex;

  final List<Widget> _pages = [
    //HomeScreen(),
    HomeScreen(),
    StatsScreen(),
    SettingsScreen(),
    FriendRequestScreen(),

  ];
  Color userColor = Colors.white;
  Color iconColor = Colors.black;

  // Future<void> fetchUserColor() async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   userColor = userColorProvider.userColor;
  //   if (user != null) {
  //     final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  //     if (userDoc.exists) {
  //       final colorData = userDoc.data()?['user_color'];
  //       setState(() {
  //         userColor = userColorProvider.userColor;
  //         iconColor = isColorCloserToWhite(userColor) ? Colors.black : Colors.white;
  //       });
  //     }
  //   }
  // }
  Future<void> fetchUserColor() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final colorData = userDoc.data()?['user_color'];
        final newColor = Color.fromRGBO(
          colorData['red'] as int,
          colorData['green'] as int,
          colorData['blue'] as int,
          1,
        );

        // Update user color using the UserColorProvider
        context.read<UserColorProvider>().setUserColor(newColor);

        setState(() {
          // No need to update userColor here, as the provider should handle it
          iconColor = isColorCloserToWhite(newColor) ? Colors.black : Colors.white;
        });
      }
    }
  }
  @override
  void initState() {
    super.initState();

    fetchUserColor();
    print("initState");
    print(userColor);
    print("initState");
    //userColor = userColorProvider.userColor;
    _currentPageIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    UserColorProvider userColorProvider = Provider.of<UserColorProvider>(context);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Set the status bar color
    ));
    print("index: $_currentPageIndex");
    print("length: ${_pages.length}");
    print(isColorCloserToWhite(userColor));
    return Scaffold(
      //appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0,),
      body: SafeArea(
        child: _pages[_currentPageIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: userColorProvider.userColor,
        currentIndex: _currentPageIndex,
        selectedItemColor: isColorCloserToWhite(userColor) ? Colors.black : Colors.white,
        unselectedItemColor: isColorCloserToWhite(userColor) ? Colors.black : Colors.white,
        onTap: (int index) {
          setState(() {
            fetchUserColor();
            _currentPageIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: isColorCloserToWhite(userColor) ? Colors.black : Colors.white),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: isColorCloserToWhite(userColor) ? Colors.black : Colors.white),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, color: isColorCloserToWhite(userColor) ? Colors.black : Colors.white,),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people, color: isColorCloserToWhite(userColor) ? Colors.black : Colors.white),
            label: 'Friends',

          ),
        ],
        selectedLabelStyle: GoogleFonts.spaceMono(textStyle:
          TextStyle(color: isColorCloserToWhite(userColor) ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
        unselectedLabelStyle: GoogleFonts.spaceMono(textStyle:
        TextStyle(color: isColorCloserToWhite(userColor) ? Colors.black : Colors.white,)),
      ),
    );
  }
}
bool isColorCloserToWhite(Color color) {
  final brightness = (color.red * 299 + color.green * 587 + color.blue * 114) / 1000;
  return brightness > 128;
}