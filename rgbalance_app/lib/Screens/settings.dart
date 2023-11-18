import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rgbalance/Screens/home.dart';

import '../reusable_widgets/reusable_widget.dart';
import '../userColor.dart';
import 'login.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  Color userColor = Colors.white;
  String email = '';
  String username = '';

  Future<void> fetchUserColor() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      print(userDoc);
      if (userDoc.exists) {
        final colorData = userDoc.data()?['user_color'];
        setState(() {
          userColor =
              Color.fromRGBO(colorData['red'] as int, colorData['green'] as int, colorData['blue'] as int, 1);
        });
      }
    }
  }

  Future<void> fetchEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        email = user.email ?? 'empty email';
      });
    }
  }

  Future<void> updateUserSettings() async {
    await fetchUsername();
    await fetchUserColor();
    setState(() {});
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
    fetchEmail();
    fetchUsername();
  }

  @override
  Widget build(BuildContext context) {
    UserColorProvider userColorProvider = Provider.of<UserColorProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.spaceMono(textStyle: TextStyle(
            color: isColorCloserToWhite(userColor) ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          )),
        ),
        backgroundColor: userColor,
        titleTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        shadowColor: Color.fromRGBO(userColor.red, userColor.blue, userColor.green, userColor.opacity * 0.25),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(color: Color.fromRGBO(27, 32, 33, 1)),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            Card(
              elevation: 2,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
                side: BorderSide(
                  color: Colors.black,
                  width: 2,
                ),
              ),
              child: Container(
                color: const Color.fromARGB(255, 60, 60, 60),
                child: ListTile(
                  title: Text(
                    'Email Address',
                    style: GoogleFonts.spaceMono(textStyle: const TextStyle(color: Colors.white)),
                  ),
                  subtitle: Text(
                    email,
                    style:  GoogleFonts.spaceMono(textStyle: TextStyle(color: Colors.white)),
                  ),
                  leading: const Icon(
                    Icons.email,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Card(
              elevation: 2,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
                side: BorderSide(
                  color: Colors.black,
                  width: 2,
                ),
              ),
              child: Container(
                color: const Color.fromARGB(255, 60, 60, 60),
                child: ListTile(
                  title: Text(
                    'Username',
                    style: GoogleFonts.spaceMono(textStyle: TextStyle(color: Colors.white)),
                  ),
                  subtitle: Text(
                    username,
                    style: GoogleFonts.spaceMono(textStyle:  TextStyle(color: Colors.white)),
                  ),
                  leading: const Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, elevation: 0),
                    onPressed: () {
                      showChangeUsernameDialog(context);
                      updateUserSettings();
                    },
                    child: Text(
                      'Change',
                      style: GoogleFonts.spaceMono(textStyle: TextStyle(color: Colors.red)),
                    ),
                  ),
                ),
              ),
            ),
            Card(
              elevation: 2,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
                side: BorderSide(
                  color: Colors.black,
                  width: 2,
                ),
              ),
              child: Container(
                color: const Color.fromARGB(255, 60, 60, 60),
                child: ListTile(
                  title:  Text(
                    'User Color',
                    style: GoogleFonts.spaceMono(textStyle: TextStyle(color: Colors.white)),
                  ),
                  leading: UserColorCircle(color: userColor),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, elevation: 0),
                    onPressed: () {
                      showChangeUserColorDialog(context, userColorProvider);
                    },
                    child: Text(
                      'Change',
                      style: GoogleFonts.spaceMono(textStyle: TextStyle(color: Colors.red)),
                    ),
                  ),
                ),
              ),
            ),
            Card(
              elevation: 2,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
                side: BorderSide(
                  color: Colors.black,
                  width: 2,
                ),
              ),
              child: Container(
                color: const Color.fromARGB(255, 60, 60, 60),
                child: ListTile(
                  onTap: () {
                    showLogoutDialog(context);
                  },
                  title: Text(
                    'Logout',
                    style: GoogleFonts.spaceMono(textStyle:TextStyle(color: Colors.white)),
                  ),
                  leading: const Icon(
                    Icons.exit_to_app,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Card(
              elevation: 2,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
                side: BorderSide(
                  color: Colors.black,
                  width: 2,
                ),
              ),
              child: Container(
                color: const Color.fromARGB(255, 60, 60, 60),
                child: ListTile(
                  onTap: () {
                    showChangePasswordDialog(context);
                  },
                  title: Text(
                    'Change Password',
                    style: GoogleFonts.spaceMono(textStyle:TextStyle(color: Colors.white)),
                  ),
                  leading: const Icon(
                    Icons.lock_outline,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Card(
              elevation: 2,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
                side: BorderSide(
                  color: Colors.black,
                  width: 2,
                ),
              ),
              child: Container(
                color: const Color.fromARGB(255, 60, 60, 60),
                child: ListTile(
                  onTap: () {
                    showDeleteDialog(context);
                  },
                  title: Text(
                    'Delete Account',
                    style: GoogleFonts.spaceMono(textStyle:TextStyle(color: Colors.red)),
                  ),
                  leading: const Icon(
                    Icons.cancel,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showChangePasswordDialog(BuildContext context) {
    TextEditingController passwordController = TextEditingController();
    TextEditingController repasswordController = TextEditingController();
    String message = ''; // Store error message here

    showDialog(

      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            void changeMessage(String newMessage) {
              setState(() {
                message = newMessage;
              });
            }

            return AlertDialog(
              title: Text('Change Password', style: GoogleFonts.spaceMono()),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: passwordController,
                    autocorrect: false,
                    obscureText: true,
                    decoration: InputDecoration(labelText: 'Enter Password', labelStyle: GoogleFonts.spaceMono(),),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: repasswordController,
                    autocorrect: false,
                    obscureText: true,
                    decoration: InputDecoration(labelText: 'Reenter Password', labelStyle: GoogleFonts.spaceMono(),),
                  ),
                  SizedBox(height: 10),
                  Visibility(
                    visible: message.isNotEmpty, // Show the error message only when it's not empty
                    child: Text(
                      message,
                      style: GoogleFonts.spaceMono(textStyle:TextStyle(color: Colors.red)),
                    ),
                  ),
                ],
              ),
              backgroundColor: Color.lerp(Colors.white, userColor, .2) ?? Colors.white,
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel', style: GoogleFonts.spaceMono(textStyle:TextStyle(color: Colors.red))),
                ),
                TextButton(
                  onPressed: () {
                    final RegExp specialCharRegExp = RegExp(r'[!@#\$%^&*()?{}|<>]');
                    if (passwordController.text != repasswordController.text) {
                      changeMessage('Passwords do not match');
                    } else if (passwordController.text.length < 8) {
                      changeMessage('Password must be at least 8 characters.');
                    } else if (!specialCharRegExp.hasMatch(passwordController.text)) {
                      changeMessage('Password must contain a special character: !@#\$%^&*()?{}|<>');
                    } else {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        user.updatePassword(passwordController.text).then((_) {
                          Navigator.pop(context);
                        }).catchError((error) {
                          changeMessage("Error updating password: $error");
                        });
                      }
                    }
                  },
                  child: Text('Save', style: TextStyle(color: Colors.black)),
                ),
              ],
            );
          },
        );
      },
    );
  }


  void showChangeUsernameDialog(BuildContext context) {
    TextEditingController usernameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Change Username', style: GoogleFonts.spaceMono()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                autocorrect: false,
                decoration: InputDecoration(labelText: 'New Username', labelStyle: GoogleFonts.spaceMono()),
              ),
              SizedBox(height: 10),
            ],
          ),
          backgroundColor: Color.lerp(Colors.white, userColor, .2) ?? Colors.white,
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel', style: GoogleFonts.spaceMono(textStyle:TextStyle(color: Colors.black))),
            ),
            TextButton(
              onPressed: () {
                final newUsername = usernameController.text;
                if (newUsername.isNotEmpty) {
                  setState(() {
                    username = newUsername;
                  });

                  final user = FirebaseAuth.instance.currentUser;
                  print(user?.uid);
                  if (user != null) {
                    FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                      'username': newUsername,
                    }).then((_) {
                      Navigator.pop(context);
                    }).catchError((error) {
                      print('Error storing user data: $error');
                    });
                  }
                }
              },
              child: Text('Save', style: GoogleFonts.spaceMono(textStyle:TextStyle(color: Colors.black))),
            ),
          ],
        );
      },
    );
  }

  void showChangeUserColorDialog(BuildContext context, UserColorProvider userColorProvider) {
    double redValue = userColor.red.toDouble();
    double greenValue = userColor.green.toDouble();
    double blueValue = userColor.blue.toDouble();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('Change User Color', style: GoogleFonts.spaceMono()),
            content: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.height * 0.25,
                  height: MediaQuery.of(context).size.height * 0.25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromRGBO(redValue.toInt(), greenValue.toInt(), blueValue.toInt(), 1),
                  ),
                ),
                Slider(
                  min: 0,
                  max: 255,
                  divisions: 255,
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
                  divisions: 255,
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
                  divisions: 255,
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
              ],
            ),
            backgroundColor: Color.lerp(Colors.white, userColor, .2) ?? Colors.white,

            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel', style: GoogleFonts.spaceMono(textStyle:TextStyle(color: Colors.red))),
              ),
              TextButton(
                onPressed: () {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    final userColor = Color.fromRGBO(redValue.toInt(), greenValue.toInt(), blueValue.toInt(), 1);
                    print("before userColor call");
                    userColorProvider.setUserColor(userColor);
                    print("after userColor call");
                    FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                      'user_color': {
                        'red': redValue.toInt(),
                        'green': greenValue.toInt(),
                        'blue': blueValue.toInt(),
                      },
                    }).then((_) {
                      Navigator.pop(context);
                      updateUserSettings();
                    }).catchError((error) {
                      print('Error storing user data: $error');
                    });
                  }
                },
                child: Text('Save', style: GoogleFonts.spaceMono(textStyle:TextStyle(color: Colors.black))),
              ),
            ],
          );
        });
      },
    );
  }
  void showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Are you sure you want to delete your account?', style: GoogleFonts.spaceMono()),
          backgroundColor: Color.lerp(Colors.white, userColor, .2) ?? Colors.white,
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                User? user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  try {
                    await user.delete();
                    print('complete');

                  } catch (e) {
                    print('Error deleting account: $e');
                  }
                }
                //Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => LogInScreen()));
              },
              child: Text('Yes, delete my account', style: GoogleFonts.spaceMono(textStyle:TextStyle(color: Colors.red))),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('No', style: GoogleFonts.spaceMono(textStyle:TextStyle(color: Colors.black))),
            ),
          ],
        );
      },
    );
  }

  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Are you sure you want to log out?', style: GoogleFonts.spaceMono()),
          backgroundColor: Color.lerp(Colors.white, userColor, .2) ?? Colors.white,
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => LogInScreen()));
              },
              child: Text('Yes, log me out', style: GoogleFonts.spaceMono(textStyle:TextStyle(color: Colors.red))),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('No', style: GoogleFonts.spaceMono(textStyle:TextStyle(color: Colors.black)),),
            ),
          ],
        );

      },
    );
  }
}



bool isColorCloserToWhite(Color color) {
  final brightness = (color.red * 299 + color.green * 587 + color.blue * 114) / 1000;
  return brightness > 128;
}

class UserColorCircle extends StatelessWidget {
  final Color color;
  final double radius;

  UserColorCircle({
    required this.color,
    this.radius = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
