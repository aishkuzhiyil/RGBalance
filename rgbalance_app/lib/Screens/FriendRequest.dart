
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rgbalance/Screens/home.dart';
import 'package:rgbalance/reusable_widgets/reusable_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'NavBar.dart';

class FriendRequestScreen extends StatefulWidget {
  const FriendRequestScreen({super.key});

  @override
  State<FriendRequestScreen> createState() => _FriendRequestScreenState();
}

class _FriendRequestScreenState extends State<FriendRequestScreen> {
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot>? searchResultsFuture;
  Future<QuerySnapshot>? friendRequestsFuture;

  Future<QuerySnapshot>? friendDocs;
  List<dynamic> friendList = [];
  Future<void> fetchFriendList() async {

    print('in fetch completed');
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          friendList = userDoc.data()?['friends'] ?? [];

          if (friendList.isNotEmpty) {
            Future<QuerySnapshot> friendUserDocs = FirebaseFirestore.instance
                .collection('users')
                .where(FieldPath.documentId, whereIn: friendList)
                .get();
            friendDocs = friendUserDocs;
          }

        });

      }
    }

  }
  void initState() {
    super.initState();
    // Call your function here when the screen is opened
    Future<QuerySnapshot> friendRequests = FirebaseFirestore.instance.collection('friendRequests').get();

    friendRequestsFuture = friendRequests;
    performTasks();

  }
  Future<void> performTasks() async {
    await fetchFriendList();
  }
  handleSearch(String query) {
    print('In Handle Search With query ${query}');
    Future<QuerySnapshot> users = FirebaseFirestore.instance.collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThan: query + 'z')
        .get();

    setState(()
    {
      searchResultsFuture = users;
    });
  }

  //buildSearchResults();
  AppBar buildSearchField() {
    return AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {

            Navigator.of(context).pop();
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => NavBarScreen()));
          },
        ),
        backgroundColor: Colors.white,
        title: TextFormField(autocorrect: false, controller: searchController,
          decoration: InputDecoration(hintText: "Search for a user...",
              filled: true,
              prefixIcon: Icon(Icons.account_box, size: 28.0),
              suffixIcon: IconButton(icon: Icon(Icons.clear),
                  onPressed: () => searchController.clear())
          ),
          onFieldSubmitted: handleSearch,
        )
    );
  }

  buildSearchResults() {
    return FutureBuilder(
        future: searchResultsFuture, builder: (context, snapshot) {
      print('In Build Search Results');
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(
          child: CircularProgressIndicator(),);
      }
      List<UserResult> searchResults = [];
      snapshot.data?.docs.forEach((doc) {
        print('Assigning to searchResults username: ${doc.get('username')}' );
        print('Assigning to searchResults red Color: ${doc.get('user_color')['red']}' );
        int status = 0;
        List<String> friendList = [];
        try {
          List<String> friendList = doc.get('friends') ?? [];
        } catch(error) {

        }


        if (friendList.contains(FirebaseAuth.instance.currentUser?.uid)) {
          status = 1; //they are friends
        }
        UserResult searchResult = UserResult(doc.get('username'), doc.get('user_color'), searchResults.length, doc.id, true, false, status, "");
        searchResults.add(searchResult);
      });
      return ListView(children: searchResults,);
    });
  }


  buildFriendRequests()  {

    return FutureBuilder(
        future: friendRequestsFuture, builder: (context, snapshot) {
      print('In Build Friend Requests');
      if (snapshot.connectionState == ConnectionState.waiting) {

        return Center(
          child: CircularProgressIndicator(),);
      }
      List<UserResult> friendResults = [];
      return ListView.builder(
        itemCount: snapshot.data?.docs.length ?? 0,
        itemBuilder: (context, index) {
          final doc = snapshot.data?.docs[index];
          String recipientUid = doc?['recipientUid'] as String;
          String currentUserUid = FirebaseAuth.instance.currentUser?.uid ?? '';

          if (recipientUid == currentUserUid && doc?['status'] == 'pending') {
            final userRef = FirebaseFirestore.instance.collection('users').doc(doc?['senderUid']);
            return FutureBuilder(
              future: userRef.get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // Show a loading indicator while waiting for user data.
                } else if (userSnapshot.hasError) {
                  return Text('Error: ${userSnapshot.error}');
                } else if (userSnapshot.hasData) {
                  final userData = userSnapshot.data?.data() as Map<String, dynamic>;
                  final username = userData['username'] as String;
                  final user_color = userData['user_color'];
                  UserResult searchResult = UserResult(username, user_color, friendResults.length, doc!.id, false, true, 0, doc?['senderUid']);
                  friendResults.add(searchResult);
                  return searchResult;
                  return SizedBox.shrink(); // This will not display anything in the list item, as we are adding it to the friendResults list.
                } else {
                  return Text('User document not found.');
                }
              },
            );
          } else {
            return SizedBox.shrink(); // Return an empty SizedBox for non-matching items.
          }
        },
      );

    });


    // while (friendResults.length == 0) {
    //
    // }
    //print('Returning Column With Length ${friendResults}');
    //return ListView(children: friendResults,);

  }
  buildFriendList() {
    return FutureBuilder(
        future: friendDocs, builder: (context, snapshot) {
      print('In Build Friend List');
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(
          child: CircularProgressIndicator(),);
      }
      List<UserResult> searchResults = [];
      snapshot.data?.docs.forEach((doc) {
        int status = 0;
        List<String> friendList = [];

        UserResult searchResult = UserResult(doc.get('username'), doc.get('user_color'), searchResults.length, doc.id, false, false, 1, "");
        searchResults.add(searchResult);
      });
      return ListView(children: searchResults,);
    });
  }
  @override
  Widget build(BuildContext context) {
    List<Widget> body_list = [];
    print('Building');
    return Scaffold(
        backgroundColor: Color.fromRGBO(27, 32, 33, 1),
        appBar: buildSearchField(),

        body: Column(
            children: <Widget>[
              Expanded(child: buildSearchResults(), flex: 1),
              Padding(padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.02)),
              Text("Friend Requests",  style: GoogleFonts.spaceMono(textStyle: TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25))),

              Padding(padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.02)),
              Expanded(child: buildFriendRequests(), flex: 1),
              Padding(padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.02)),
              Text("Friends", style: GoogleFonts.spaceMono(textStyle: TextStyle(height: 0, fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25))),
              Padding(padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.02)),
              Expanded(child: buildFriendList(), flex: 2),


            ])
    );
  }
}
class UserResult extends StatelessWidget {
  String username = "";
  Map<String, dynamic> userColorData = {};
  int index = -1;
  String uid = "";
  String setStatus = "";
  bool searchBool;
  bool requestBool;
  int status;
  String senderUid = "";
  UserResult(this.username, this.userColorData, this.index, this.uid, this.searchBool, this.requestBool, this.status, this.senderUid);



  @override
  Widget build(BuildContext context) {
    int redUserColor = 0;
    int greenUserColor = 0;
    int blueUserColor = 0;
    print('Red: ${username}');
    if (userColorData.keys.length >= 3) {
      redUserColor = userColorData['red'].toInt();
      print('Setting Red To be ${redUserColor}');
      greenUserColor = userColorData['green'].toInt();
      blueUserColor = userColorData['blue'].toInt();
      print('UID: ${uid}');
      if (status == 1)
        setStatus = "Friends";

    }

    print('SetStatus: ${setStatus}' );
    return Container(
        color: Color.fromRGBO(100, 105, 106, 1),
        //color: (index  % 3 == 0 ? Color.fromRGBO(200, 29, 37, 1) : (index%3==1 ? Color.fromRGBO(97, 231, 134, 1) : Color.fromRGBO(35, 116, 171, 1))),
        child: Column(children: <Widget>[
          GestureDetector(onTap: () => !searchBool && !requestBool ? Placeholder(): buildPopUp(context, userColorData, username, uid, searchBool, senderUid),
              child: ListTile(leading: CircleAvatar(
                backgroundColor: Color.fromRGBO(redUserColor as int, greenUserColor as int, blueUserColor as int, 1),
              ),
                  title: Text(username, style: GoogleFonts.spaceMono(textStyle: TextStyle(fontSize: 25, color: Colors.black, fontWeight: FontWeight.bold)))
                  , trailing: Text(setStatus, style: GoogleFonts.spaceMono(textStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15))))
          ),
          Divider(
              height: 4.0, color: Colors.white54
          )
        ]

        ));
  }
}

Future<void> sendFriendRequest(String senderUid, String recipientUid) async {
  final friendRequestsCollection = FirebaseFirestore.instance.collection('friendRequests');

  // Create a new document to represent the friend request
  await friendRequestsCollection.add({
    'senderUid': senderUid,
    'recipientUid': recipientUid,
    'status': 'pending'
  });
}
addFriends(String current_uid, String other_uid) async {
  final userDoc = await FirebaseFirestore.instance.collection('users').doc(
      current_uid).get();
  Map<String, List<int>> friend_records =  userDoc.data()?['friend_records'] != null
      ? (userDoc.data()?['friend_records'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, List<int>.from(value)),) : {};
  friend_records[other_uid] = [0, 0];
  try {
    await FirebaseFirestore.instance.collection('users').doc(current_uid).update({
      'friends': FieldValue.arrayUnion([other_uid])
    });
    await FirebaseFirestore.instance.collection('users').doc(current_uid).update({
      'friend_records': friend_records
    });

  } catch (e) {
    print('ERROR');
  }



  final otherDoc = await FirebaseFirestore.instance.collection('users').doc(
      other_uid).get();
  Map<String, List<int>> friend_records_2 =  otherDoc.data()?['friend_records'] != null
      ? (otherDoc.data()?['friend_records'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, List<int>.from(value)),) : {};
  friend_records_2[current_uid] = [0, 0];
  try {
    await FirebaseFirestore.instance.collection('users').doc(other_uid).update({
      'friends': FieldValue.arrayUnion([current_uid])
    });
    await FirebaseFirestore.instance.collection('users').doc(other_uid).update({
      'friend_records': friend_records_2
    });

  } catch (e) {
    print('ERROR');
  }

}

Future<void> editFriendRequest(String request_id, String new_status) async {
  final friendRequestsCollection = FirebaseFirestore.instance.collection('friendRequests');
  friendRequestsCollection.doc(request_id).update({
    'status': new_status,
  }).then((_) {
    print('Friend request status updated successfully.');
  }).catchError((error) {
    print('Error updating friend request status: $error');
  });
}


Future<void> buildPopUp(BuildContext context, Map<String, dynamic> userColorData, String username, String uid, bool searchBool, String senderUid) async {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            backgroundColor: Color.fromRGBO(userColorData['red'].toInt(), userColorData['green'].toInt(), userColorData['blue'].toInt(), 1),
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
                            child: searchBool ? (new Text('Do you want to send a friend request to ${username}?',  textAlign: TextAlign.center, style: GoogleFonts.spaceMono(textStyle: TextStyle(fontSize: 25.0,color: Colors.white)))) : new Text('Do you want to accept ${username}\'s friend request?',  textAlign: TextAlign.center, style: GoogleFonts.spaceMono(textStyle: TextStyle(fontSize: 25.0,color: Colors.white))),
                          )//
                      ),
                      SizedBox(
                        height: 20.0,
                        width: 5.0,
                      ),
                      Row(children: <Widget>[Container(
                          width: 175, // Set the desired width
                          height: 80, // Set the desired height
                          child: InkWell(
                            child: Container(
                                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                                decoration: BoxDecoration(
                                  color:Colors.white,
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(32.0),
                                      bottomRight: Radius.circular(0.0)),
                                ),
                                child: Row(mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text("Yes", textAlign: TextAlign.center,
                                        style: GoogleFonts.spaceMono(textStyle:  TextStyle(color: Colors.blue,fontSize: 25.0)),
                                      ),
                                    ])),
                            onTap:(){
                              if (searchBool) {
                                sendFriendRequest(FirebaseAuth.instance.currentUser!.uid, uid);
                              } else {
                                editFriendRequest(uid, 'accepted');
                                addFriends(FirebaseAuth.instance.currentUser!.uid, senderUid);
                              }
                              Navigator.of(context).pop();
                              buildRequestSentPopUp(context, userColorData, username, searchBool);
                            },
                          )),
                        Container(
                          width: 175, // Set the desired width
                          height: 80, // Set the desired height
                          child: InkWell(
                            child: Container(
                                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                                decoration: BoxDecoration(
                                  color:Colors.white,
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(0.0),
                                      bottomRight: Radius.circular(32.0)),
                                ),
                                child: Row(mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text("No", textAlign: TextAlign.center,
                                        style: GoogleFonts.spaceMono(textStyle:  TextStyle(color: Colors.blue,fontSize: 25.0)),
                                      ),
                                    ])),
                            onTap:(){
                              Navigator.of(context).pop();
                              if (!searchBool)
                                editFriendRequest(uid, 'rejected');
                            },
                          ),
                        )]),


                    ],
                  ),
                ),
              ],
            )
        );
      });
}
Future<void> buildRequestSentPopUp(BuildContext context, Map<String, dynamic> userColorData, String username, bool searchBool) async {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            backgroundColor: Color.fromRGBO(userColorData['red'].toInt(), userColorData['green'].toInt(), userColorData['blue'].toInt(), 1),
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
                            child: new Text(searchBool ? 'Friend request to ${username} sent.' : 'You are now friends with ${username}.',  textAlign: TextAlign.center, style: GoogleFonts.spaceMono(textStyle: TextStyle(fontSize: 25.0,color: Colors.white))),
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
                          Navigator.of(context).pop();
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
