import 'package:bookmart/models/user.dart';
import 'package:bookmart/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewBlockedUsers extends StatefulWidget {
  @override
  _ViewBlockedUsersState createState() => _ViewBlockedUsersState();

  final String currentTheme;

  ViewBlockedUsers({this.currentTheme});
}

class _ViewBlockedUsersState extends State<ViewBlockedUsers> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);

    Color primaryColor;
    Color secondaryColor;
    Gradient currentGradient;
    if (widget.currentTheme == 'Light') {
      primaryColor = Colors.white;
      secondaryColor = Colors.blueAccent;
      //imagePath = 'images/book-blueAccent.png';
      currentGradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.grey[200]]);
    }

    if (widget.currentTheme == 'Blue') {
      primaryColor = Colors.blueAccent;
      secondaryColor = Colors.white;
      //imagePath = 'images/book-white.png';
      currentGradient = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.lightBlue[600], Colors.blueAccent]);
    }

    if (widget.currentTheme == 'Dark') {
      primaryColor = Colors.black;
      secondaryColor = Colors.grey[350];
      //imagePath = 'images/book-blueAccent.png';
      currentGradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, Colors.grey[800]]);
    }

    Future<bool> _askedToLead(String otherUserUID) async {
      switch (await showDialog<String>(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              elevation: 24,
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: secondaryColor, width: 1),
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              title: Text(
                'Manage',
                style: TextStyle(
                    color: secondaryColor, fontFamily: 'Poppins Bold'),
              ),
              children: <Widget>[
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, 'Unblock');
                  },
                  child: Text(
                    'Unblock user',
                    style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Poppins Regular',
                        color: secondaryColor),
                  ),
                ),
              ],
            );
          })) {
        case 'Unblock':
          {
            setState(() {
              loading = true;
            });
            try {
              print('Attemping to unblock: ${otherUserUID}');
              DocumentSnapshot snap = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .get();
              List<dynamic> blockedUsers = snap.data()['blockedUsers'] ??
                  List.generate(0, (index) => null);
              blockedUsers.removeWhere((element) => element.id == otherUserUID);
              await snap.reference.update({'blockedUsers': blockedUsers});
              DocumentSnapshot otherUserSnap = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(otherUserUID)
                  .get();
              dynamic timesReported =
                  otherUserSnap.data()['timesReported'] ?? '0';
              timesReported = timesReported - 1;
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(otherUserUID)
                  .update({'timesReported': timesReported});
              setState(() {
                loading = false;
              });
              return true;
            } catch (e) {
              print(e.toString());
              setState(() {
                loading = false;
              });
              return false;
            }
          }
          break;
      }
    }

    if (loading) {
      return Loading(
        currentTheme: widget.currentTheme,
      );
    } else {
      return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<dynamic> blockedUsers =
                  snapshot.data.data()['blockedUsers'] ??
                      List.generate(0, (index) => null);
              List<dynamic> blockedUsersUIDs = List.generate(
                  blockedUsers.length, (index) => blockedUsers[index].id);
              if (blockedUsers.length == 0) {
                print('No blocked Users');
              } else {
                print(blockedUsersUIDs[0]);
              }
              // List<String> blockedUsersNames = List.generate(blockedUsers.length, (index) => blockedUsers[index].);
              // print(blockedUsersNames[0] ?? 'value is null');
              return blockedUsersUIDs.isNotEmpty
                  ? FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .where(FieldPath.documentId,
                              whereIn: blockedUsersUIDs)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          print('docs length: ${snapshot.data.docs.length}');
                          List<dynamic> currentUsersBlocked =
                              snapshot.data.docs;
                          if (currentUsersBlocked.length == 0) {
                            print('Future docs empty.');
                          } else {
                            print(currentUsersBlocked[0]['username']);
                          }
                          List<dynamic> currentUsersBlockedNames =
                              List.generate(0, (index) => null);
                          if (currentUsersBlocked != null) {
                            //currentUsersBlockedNames = List.generate(currentUsersBlocked.length, (index) => currentUsersBlocked[index]['username']) ?? List.generate(0, (index) => null);
                            currentUsersBlocked.forEach((element) {
                              currentUsersBlockedNames.add(element['username']);
                              print(element['username']);
                            });
                            print('FIRST USER: ${currentUsersBlockedNames[0]}');
                          } else {
                            print('NO USERS BLOCKED.');
                          }

                          return Scaffold(
                            appBar: AppBar(
                              elevation: 0,
                              backgroundColor: primaryColor,
                            ),
                            backgroundColor: primaryColor,
                            body: Container(
                              decoration: BoxDecoration(
                                color: primaryColor,
                                gradient: currentGradient,
                              ),
                              child: Flex(
                                direction: Axis.vertical,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          border: Border.all(
                                            color: secondaryColor, //                   <--- border color
                                          ),
                                          borderRadius: BorderRadius.circular(25)
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(15),
                                        child: Center(
                                          child: Text(
                                            'Blocked Users:',
                                            style: TextStyle(
                                                color: secondaryColor,
                                                fontSize: 25,
                                                fontFamily: 'Poppins Bold'),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(5),
                                    child: Center(
                                      child: currentUsersBlockedNames == null
                                          ? Text(
                                              'You have not blocked anyone.',
                                              style: TextStyle(
                                                  color: secondaryColor,
                                                  fontSize: 13,
                                                  fontFamily:
                                                      'Poppins Regular'),
                                            )
                                          : null,
                                    ),
                                  ),
                                  Expanded(
                                      child: ListView.builder(
                                          itemCount: currentUsersBlocked.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return Padding(
                                              padding: EdgeInsets.all(8),
                                              child: Card(
                                                shape: RoundedRectangleBorder(
                                                    side: BorderSide(
                                                        color: secondaryColor,
                                                        width: 1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                color: secondaryColor,
                                                elevation: 0,
                                                child: InkWell(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  onTap: () async {
                                                    bool result =
                                                        await _askedToLead(
                                                            blockedUsersUIDs[
                                                                index]);
                                                    if (!result) {
                                                      showDialog(
                                                          context: context,
                                                          builder: (_) {
                                                            return AlertDialog(
                                                              title: Center(
                                                                  child: Text(
                                                                'Attention',
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Poppins Bold',
                                                                    color:
                                                                        secondaryColor),
                                                              )),
                                                              content: Text(
                                                                  'User could not be unblocked. Check your internet connection.',
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Poppins Regular',
                                                                      color:
                                                                          secondaryColor)),
                                                              actions: [
                                                                FlatButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context,
                                                                              rootNavigator: true)
                                                                          .pop();
                                                                    },
                                                                    child: Text(
                                                                      'Ok',
                                                                      style: TextStyle(
                                                                          color:
                                                                              secondaryColor,
                                                                          fontFamily:
                                                                              'Poppins Regular'),
                                                                    ))
                                                              ],
                                                              elevation: 24,
                                                              backgroundColor:
                                                                  primaryColor,
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              20))),
                                                            );
                                                          },
                                                          barrierDismissible:
                                                              false);
                                                    } else {
                                                      Navigator.pop(context);
                                                    }
                                                  },
                                                  child: ListTile(
                                                    title: Text(
                                                      currentUsersBlockedNames[
                                                          index],
                                                      style: TextStyle(
                                                          color: primaryColor,
                                                          fontFamily:
                                                              'Poppins Bold',
                                                          fontSize: 15),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }))
                                ],
                              ),
                            ),
                          );
                        } else {
                          return Loading(
                            currentTheme: widget.currentTheme,
                          );
                        }
                      })
                  : Scaffold(
                      appBar: AppBar(
                        elevation: 0,
                        backgroundColor: primaryColor,
                      ),
                      backgroundColor: primaryColor,
                      body: Container(
                        decoration: BoxDecoration(
                          color: primaryColor,
                          gradient: currentGradient,
                        ),
                        child: Flex(
                          direction: Axis.vertical,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(15),
                              child: Center(
                                child: Text(
                                  'Blocked Users:',
                                  style: TextStyle(
                                      color: secondaryColor,
                                      fontSize: 25,
                                      fontFamily: 'Poppins Bold'),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(5),
                              child: Center(
                                child: Text(
                                  'You have not blocked anyone.',
                                  style: TextStyle(
                                      color: secondaryColor,
                                      fontSize: 13,
                                      fontFamily: 'Poppins Bold'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
            } else {
              return Loading(
                currentTheme: widget.currentTheme,
              );
            }
          });
    }
  }
}
