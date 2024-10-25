import 'dart:io';
import 'package:bookmart/main.dart';
import 'package:bookmart/screens/home/myprofile/manageblockedusers.dart';
import 'package:bookmart/screens/home/myprofile/viewmyads.dart';
import 'package:bookmart/screens/home/myprofile/viewmypublicwishlist.dart';
import 'package:bookmart/screens/home/myprofile/viewmywatchlist.dart';
import 'package:bookmart/services/database.dart';
import 'package:bookmart/shared/change_theme.dart';
import 'package:bookmart/shared/loading.dart';
import 'package:bookmart/shared/view_privacy_policy.dart';
import 'package:bookmart/shared/view_terms_of_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:bookmart/services/auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:provider/provider.dart';
import 'package:bookmart/models/user.dart';
import 'package:prompt_dialog/prompt_dialog.dart';

final AuthService _auth = AuthService();

class MyProfile extends StatefulWidget {
  @override
  _MyProfileState createState() => _MyProfileState();
  String currentTheme;

  MyProfile({this.currentTheme});
}

class _MyProfileState extends State<MyProfile> {

  int numOfTimesPressed = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool loading = false;
  final successSnackBar =
      SnackBar(content: Text('A password reset email has been sent to you.', style: TextStyle(color: Colors.white, fontFamily: 'Poppins Regular'),));
  final failedSnackBar = SnackBar(content: Text('Something went wrong.', style: TextStyle(color: Colors.white, fontFamily: 'Poppins Regular')));
  final googleSnackBar = SnackBar(
      content: Text(
          'You are signed in with Google. Reset your password on Google.', style: TextStyle(color: Colors.white, fontFamily: 'Poppins Regular')));
  final signOut = SnackBar(
      content: Text(
          'Press the sign out button again to sign out of your account.', style: TextStyle(color: Colors.white, fontFamily: 'Poppins Regular')));

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);

    Future<String> getWatchlist() async {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      String watchlist = doc.data()['watchlist'];
      return watchlist;
    }

    Future<String> _showThemePanel() async {
      String theme = await showModalBottomSheet(
          context: context,
          builder: (context) {
            return ChangeTheme(
              currentTheme: widget.currentTheme,
            );
          });
      return theme;
    }

    Color primaryColor;
    Color secondaryColor;

    String imagePath;
    Gradient currentGradient;
    if (widget.currentTheme == 'Light') {
      primaryColor = Colors.teal;
      secondaryColor = Colors.white;
      imagePath = 'images/book-blueAccent.png';
      currentGradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.teal, Colors.white]);
    }

    if (widget.currentTheme == 'Blue') {
      primaryColor = Colors.blueAccent;
      secondaryColor = Colors.white;
      imagePath = 'images/book-white.png';
      currentGradient = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.lightBlue[600], Colors.blueAccent]);
    }

    if (widget.currentTheme == 'Dark') {
      primaryColor = Colors.black;
      secondaryColor = Colors.grey[350];
      imagePath = 'images/book-blueAccent.png';
      currentGradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, Colors.grey[850]]);
    }

    Future getUserLocation() async {
      Position position;
      try {
        LocationPermission permission = await Geolocator.requestPermission();
        position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);

        //position = widget.currentUserLocation;

        return position;
      } catch (e) {
        position = null;
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Center(
                    child: Text(
                  'Attention',
                  style: TextStyle(
                      fontFamily: 'Poppins Bold', color: secondaryColor),
                )),
                content: Text(
                    'Please grant Bookmart location permissions through your settings.',
                    style: TextStyle(
                        fontFamily: 'Poppins Regular', color: secondaryColor)),
                actions: [
                  FlatButton(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      child: Text(
                        'Ok',
                        style: TextStyle(
                            color: secondaryColor,
                            fontFamily: 'Poppins Regular'),
                      ))
                ],
                elevation: 24,
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20))),
              );
            },
            barrierDismissible: false);
        return null;
      }
    }

    String username = '';

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
              username = snapshot.data.data() != null ? snapshot.data.data()['username'] : '';
              return FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('ads')
                      .where('uid', isEqualTo: user.uid)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<DocumentSnapshot> adList = snapshot.data.docs;
                      return Scaffold(
                        key: _scaffoldKey,
                        body: Container(
                          // decoration: BoxDecoration(
                          //     gradient: LinearGradient(
                          //         begin: Alignment.topRight,
                          //         end: Alignment.bottomLeft,
                          //         colors: [Colors.lightBlue[300], Colors.deepPurpleAccent]
                          //     )
                          // ),
                          decoration: BoxDecoration(
                              color: primaryColor, gradient: currentGradient),
                          child: Flex(
                            direction: Axis.vertical,
                            children: [
                              Expanded(
                                child:
                                    //SizedBox(height: 500,),
                                    ListView(
                                  shrinkWrap: true,
                                  children: [
                                    Center(
                                        child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(

                                          // decoration: BoxDecoration(
                                          //     color: Colors.transparent,
                                          //     border: Border.all(
                                          //       color: Colors.blueAccent,
                                          //       width: 1,
                                          //     ),
                                          //     borderRadius: BorderRadius.circular(12)
                                          // ),
                                          child: Column(
                                        children: [
                                          Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      8, 12, 8, 8),
                                              child: Text(
                                                'Current Display Name:',
                                                style: TextStyle(
                                                    color: secondaryColor,
                                                    fontSize: 20,
                                                    fontFamily: 'Poppins Bold'),
                                              ),
                                            ),
                                          ),
                                          Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                username,
                                                style: TextStyle(
                                                    color: secondaryColor,
                                                    fontSize: 18,
                                                    fontFamily: 'Poppins Regular'),
                                              ),
                                            ),
                                          ),
                                          Center(
                                            child: Padding(
                                              padding:
                                              const EdgeInsets.all(8.0),
                                              child: Text(
                                                'General',
                                                style: TextStyle(
                                                    color: secondaryColor,
                                                    fontSize: 16,
                                                    fontFamily: 'Poppins Bold'),
                                              ),
                                            ),
                                          ),
                                          // ignore: deprecated_member_use
                                          SizedBox(
                                            width: double.infinity,
                                            child: RaisedButton.icon(
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          18.0),
                                                  side: BorderSide(
                                                      color: secondaryColor)),
                                              color: secondaryColor,
                                              icon: Icon(
                                                Icons.edit_outlined,
                                                color: primaryColor,
                                              ),
                                              label: Padding(
                                                padding:
                                                    const EdgeInsets.all((8)),
                                                child: Text(
                                                  'Change Display Name',
                                                  style: TextStyle(
                                                      color: primaryColor,
                                                      fontFamily:
                                                          'Poppins Regular',
                                                      fontSize: 15),
                                                ),
                                              ),
                                              onPressed: () async {
                                                String entry = await prompt(
                                                    context,
                                                  title: Text('Enter a new display name:', style: TextStyle(color: primaryColor, fontSize: 17, fontFamily: 'Poppins Bold'),),
                                                  initialValue: '',
                                                  textOK: Text('Ok', style: TextStyle(color: primaryColor, fontSize: 17, fontFamily: 'Poppins Regular')),
                                                  textCancel: Text('Cancel', style: TextStyle(color: primaryColor, fontSize: 17, fontFamily: 'Poppins Regular')),
                                                  hintText: '',
                                                  minLines: 1,
                                                  maxLines: 1,
                                                  autoFocus: false,
                                                  obscureText: false,
                                                  obscuringCharacter: '•',
                                                  textCapitalization: TextCapitalization.words,
                                                );
                                                print(entry);
                                                final filter = ProfanityFilter();
                                                final validCharacters = RegExp('[A-Za-z]+');
                                                bool validQuery = validCharacters.hasMatch(entry);
                                                bool hasProfanity = filter.hasProfanity(entry ?? '');
                                                if (!hasProfanity) {
                                                  if (entry != null && validQuery) {
                                                    if (entry.length > 20) {
                                                      showDialog(
                                                          context: context,
                                                          builder: (_) {
                                                            return AlertDialog(
                                                              title: Center(
                                                                  child: Text(
                                                                    'Attention',
                                                                    style: TextStyle(
                                                                        fontFamily: 'Poppins Bold',
                                                                        color: secondaryColor),
                                                                  )),
                                                              content: Text(
                                                                  'Please enter a name that is less than 20 characters.',
                                                                  style: TextStyle(
                                                                      fontFamily: 'Poppins Regular',
                                                                      color: secondaryColor)),
                                                              actions: [
                                                                FlatButton(
                                                                    onPressed: () {
                                                                      Navigator
                                                                          .of(
                                                                          context,
                                                                          rootNavigator: true)
                                                                          .pop();
                                                                    },
                                                                    child: Text(
                                                                      'Ok',
                                                                      style: TextStyle(
                                                                          color: secondaryColor,
                                                                          fontFamily: 'Poppins Regular'),
                                                                    ))
                                                              ],
                                                              elevation: 24,
                                                              backgroundColor: primaryColor,
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius
                                                                      .all(
                                                                      Radius
                                                                          .circular(
                                                                          20))),
                                                            );
                                                          },
                                                          barrierDismissible: false);
                                                    } else {
                                                      setState(() {
                                                        loading = true;
                                                      });
                                                      bool result = await DatabaseService(
                                                          uid: user.uid)
                                                          .changeDisplayName(
                                                          entry);
                                                      setState(() {
                                                        loading = false;
                                                      });
                                                      if (result) {
                                                        showDialog(
                                                            context: context,
                                                            builder: (_) {
                                                              return AlertDialog(
                                                                title: Center(
                                                                    child: Text(
                                                                      'Attention',
                                                                      style: TextStyle(
                                                                          fontFamily: 'Poppins Bold',
                                                                          color: secondaryColor),
                                                                    )),
                                                                content: Text(
                                                                    'Display name has been updated.',
                                                                    style: TextStyle(
                                                                        fontFamily: 'Poppins Regular',
                                                                        color: secondaryColor)),
                                                                actions: [
                                                                  FlatButton(
                                                                      onPressed: () {
                                                                        Navigator
                                                                            .of(
                                                                            context,
                                                                            rootNavigator: true)
                                                                            .pop();
                                                                      },
                                                                      child: Text(
                                                                        'Ok',
                                                                        style: TextStyle(
                                                                            color: secondaryColor,
                                                                            fontFamily: 'Poppins Regular'),
                                                                      ))
                                                                ],
                                                                elevation: 24,
                                                                backgroundColor: primaryColor,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius
                                                                        .all(
                                                                        Radius
                                                                            .circular(
                                                                            20))),
                                                              );
                                                            },
                                                            barrierDismissible: false);
                                                      } else {
                                                        showDialog(
                                                            context: context,
                                                            builder: (_) {
                                                              return AlertDialog(
                                                                title: Center(
                                                                    child: Text(
                                                                      'Attention',
                                                                      style: TextStyle(
                                                                          fontFamily: 'Poppins Bold',
                                                                          color: secondaryColor),
                                                                    )),
                                                                content: Text(
                                                                    'Something went wrong. Make sure your internet connection is stable.',
                                                                    style: TextStyle(
                                                                        fontFamily: 'Poppins Regular',
                                                                        color: secondaryColor)),
                                                                actions: [
                                                                  FlatButton(
                                                                      onPressed: () {
                                                                        Navigator
                                                                            .of(
                                                                            context,
                                                                            rootNavigator: true)
                                                                            .pop();
                                                                      },
                                                                      child: Text(
                                                                        'Ok',
                                                                        style: TextStyle(
                                                                            color: secondaryColor,
                                                                            fontFamily: 'Poppins Regular'),
                                                                      ))
                                                                ],
                                                                elevation: 24,
                                                                backgroundColor: primaryColor,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius
                                                                        .all(
                                                                        Radius
                                                                            .circular(
                                                                            20))),
                                                              );
                                                            },
                                                            barrierDismissible: false);
                                                      }
                                                    }
                                                  } else {

                                                    showDialog(
                                                        context: context,
                                                        builder: (_) {
                                                          return AlertDialog(
                                                            title: Center(
                                                                child: Text(
                                                                  'Attention',
                                                                  style: TextStyle(
                                                                      fontFamily: 'Poppins Bold',
                                                                      color: secondaryColor),
                                                                )),
                                                            content: Text(
                                                                'Please provide a valid display name.',
                                                                style: TextStyle(
                                                                    fontFamily: 'Poppins Regular',
                                                                    color: secondaryColor)),
                                                            actions: [
                                                              FlatButton(
                                                                  onPressed: () {
                                                                    Navigator
                                                                        .of(
                                                                        context,
                                                                        rootNavigator: true)
                                                                        .pop();
                                                                  },
                                                                  child: Text(
                                                                    'Ok',
                                                                    style: TextStyle(
                                                                        color: secondaryColor,
                                                                        fontFamily: 'Poppins Regular'),
                                                                  ))
                                                            ],
                                                            elevation: 24,
                                                            backgroundColor: primaryColor,
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius
                                                                    .all(
                                                                    Radius
                                                                        .circular(
                                                                        20))),
                                                          );
                                                        },
                                                        barrierDismissible: false);

                                                  }
                                                } else {
                                                  showDialog(
                                                      context: context,
                                                      builder: (_) {
                                                        return AlertDialog(
                                                          title: Center(
                                                              child: Text(
                                                                'Attention',
                                                                style: TextStyle(
                                                                    fontFamily: 'Poppins Bold',
                                                                    color: secondaryColor),
                                                              )),
                                                          content: Text(
                                                              'Please remove any profanity.',
                                                              style: TextStyle(
                                                                  fontFamily: 'Poppins Regular',
                                                                  color: secondaryColor)),
                                                          actions: [
                                                            FlatButton(
                                                                onPressed: () {
                                                                  Navigator
                                                                      .of(
                                                                      context,
                                                                      rootNavigator: true)
                                                                      .pop();
                                                                },
                                                                child: Text(
                                                                  'Ok',
                                                                  style: TextStyle(
                                                                      color: secondaryColor,
                                                                      fontFamily: 'Poppins Regular'),
                                                                ))
                                                          ],
                                                          elevation: 24,
                                                          backgroundColor: primaryColor,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius
                                                                  .all(
                                                                  Radius
                                                                      .circular(
                                                                      20))),
                                                        );
                                                      },
                                                      barrierDismissible: false);
                                                }
                                              },
                                            ),
                                          ),
                                          SizedBox(
                                            width: double.infinity,
                                            child: RaisedButton.icon(
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          18.0),
                                                  side: BorderSide(
                                                      color: secondaryColor)),
                                              color: secondaryColor,
                                              icon: Icon(
                                                Icons.book_outlined,
                                                color: primaryColor,
                                              ),
                                              label: Padding(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                child: Text(
                                                  'View my Ads',
                                                  style: TextStyle(
                                                      color: primaryColor,
                                                      fontFamily:
                                                          'Poppins Regular',
                                                      fontSize: 15),
                                                ),
                                              ),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ViewMyAds(
                                                            currentTheme: widget
                                                                .currentTheme,
                                                          )),
                                                );
                                              },
                                            ),
                                          ),
                                          SizedBox(
                                            width: double.infinity,
                                            child: RaisedButton.icon(
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          18.0),
                                                  side: BorderSide(
                                                      color: secondaryColor)),
                                              color: secondaryColor,
                                              icon: Icon(
                                                Icons.remove_red_eye_outlined,
                                                color: primaryColor,
                                              ),
                                              label: Padding(
                                                padding: const EdgeInsets.all(
                                                    8),
                                                child: Text(
                                                  'View my Watchlist',
                                                  style: TextStyle(
                                                      color: primaryColor,
                                                      fontFamily:
                                                          'Poppins Regular',
                                                      fontSize: 15),
                                                ),
                                              ),
                                              onPressed: () async {
                                                setState(() {
                                                  loading = true;
                                                });
                                                //String watchlist = await getWatchlist();
                                                Position position1 =
                                                    await getUserLocation();

                                                if (position1 != null) {
                                                  setState(() {
                                                    loading = false;
                                                  });
                                                  Navigator.push(
                                                    this.context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ViewMyWatchlist(
                                                              currentTheme: widget
                                                                  .currentTheme,
                                                              currentUserLocation:
                                                                  position1,
                                                            )),
                                                  );
                                                } else {
                                                  setState(() {
                                                    loading = false;
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                          SizedBox(
                                            width: double.infinity,
                                            child: RaisedButton.icon(
                                              icon: Icon(Icons.list_outlined, color: primaryColor,),
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      18.0),
                                                  side: BorderSide(
                                                      color: secondaryColor)),
                                              color: secondaryColor,
                                              label: Padding(
                                                padding: const EdgeInsets.all(
                                                    8),
                                                child: Text(
                                                  'View my public wishlist',
                                                  style: TextStyle(
                                                      color: primaryColor,
                                                      fontFamily:
                                                      'Poppins Regular',
                                                      fontSize: 15),
                                                ),
                                              ),
                                              onPressed: () async {
                                                Navigator.push(
                                                  this.context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ViewMyPublicWishlist(
                                                            currentTheme: widget
                                                                .currentTheme,
                                                          )),
                                                );
                                              },
                                            ),
                                          ),
                                          //
                                          // !(Platform.isIOS) ? SizedBox(
                                          //   width: double.infinity,
                                          //   child: RaisedButton.icon(
                                          //     icon: Icon(
                                          //       Icons.color_lens_outlined,
                                          //       color: primaryColor,
                                          //     ),
                                          //     //padding: const EdgeInsets.all(12.0),
                                          //     label: Text(
                                          //       'Change Theme',
                                          //       style: TextStyle(
                                          //           color: primaryColor,
                                          //           fontFamily:
                                          //           'Poppins Regular',
                                          //           fontSize: 15),
                                          //     ),
                                          //     elevation: 0,
                                          //     shape: RoundedRectangleBorder(
                                          //         borderRadius:
                                          //         BorderRadius.circular(
                                          //             18.0),
                                          //         side: BorderSide(
                                          //             color: secondaryColor)),
                                          //     color: secondaryColor,
                                          //     onPressed: () async {
                                          //       String theme =
                                          //       await _showThemePanel();
                                          //       if (theme != null) {
                                          //         setState(() {
                                          //           widget.currentTheme =
                                          //               theme;
                                          //         });
                                          //       }
                                          //     },
                                          //   ),
                                          // ): SizedBox(height: 0,),
                                          SizedBox(
                                            width: double.infinity,
                                            child: RaisedButton.icon(
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      18.0),
                                                  side: BorderSide(
                                                      color: secondaryColor)),
                                              color: secondaryColor,
                                              icon: Icon(
                                                Icons.bug_report_outlined,
                                                color: primaryColor,
                                              ),
                                              label: Padding(
                                                padding:
                                                const EdgeInsets.all(8),
                                                child: Text(
                                                  'Report a bug',
                                                  style: TextStyle(
                                                      color: primaryColor,
                                                      fontFamily:
                                                      'Poppins Regular',
                                                      fontSize: 15),
                                                ),
                                              ),
                                              onPressed: () async {
                                                String entry = await prompt(
                                                  this.context,
                                                  title: Text("Please describe how the bug occurred in detail.", style: TextStyle(color: primaryColor, fontSize: 17, fontFamily: 'Poppins Bold'),),
                                                  initialValue: '',
                                                  textOK: Text('Ok', style: TextStyle(color: primaryColor, fontSize: 17, fontFamily: 'Poppins Regular')),
                                                  textCancel: Text('Cancel', style: TextStyle(color: primaryColor, fontSize: 17, fontFamily: 'Poppins Regular')),
                                                  hintText: '',
                                                  minLines: 1,
                                                  maxLines: 1,
                                                  autoFocus: false,
                                                  obscureText: false,
                                                  obscuringCharacter: '•',
                                                  textCapitalization: TextCapitalization.words,
                                                );
                                                print(entry);
                                                if (entry != null) {
                                                  try {
                                                    await FirebaseFirestore.instance.collection('bugreport').add({
                                                      'uid' : user.uid,
                                                      'report' : entry.trim()
                                                    });
                                                    showDialog(
                                                        context: this.context,
                                                        builder: (_) {
                                                          return AlertDialog(
                                                            title: Center(
                                                                child: Text(
                                                                  'Attention',
                                                                  style: TextStyle(
                                                                      fontFamily: 'Poppins Bold',
                                                                      color: secondaryColor),
                                                                )),
                                                            content: Text(
                                                                'Thank you for your feedback.',
                                                                style: TextStyle(
                                                                    fontFamily: 'Poppins Regular',
                                                                    color: secondaryColor)),
                                                            actions: [
                                                              FlatButton(
                                                                  onPressed: () {
                                                                    Navigator
                                                                        .of(
                                                                        context,
                                                                        rootNavigator: true)
                                                                        .pop();
                                                                  },
                                                                  child: Text(
                                                                    'Ok',
                                                                    style: TextStyle(
                                                                        color: secondaryColor,
                                                                        fontFamily: 'Poppins Regular'),
                                                                  ))
                                                            ],
                                                            elevation: 24,
                                                            backgroundColor: primaryColor,
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius
                                                                    .all(
                                                                    Radius
                                                                        .circular(
                                                                        20))),
                                                          );
                                                        },
                                                        barrierDismissible: false);
                                                  } catch(e) {
                                                    print(e.toString());
                                                    showDialog(
                                                        context: this.context,
                                                        builder: (_) {
                                                          return AlertDialog(
                                                            title: Center(
                                                                child: Text(
                                                                  'Attention',
                                                                  style: TextStyle(
                                                                      fontFamily: 'Poppins Bold',
                                                                      color: secondaryColor),
                                                                )),
                                                            content: Text(
                                                                'Something went wrong. Make sure that you have a stable internet connection.',
                                                                style: TextStyle(
                                                                    fontFamily: 'Poppins Regular',
                                                                    color: secondaryColor)),
                                                            actions: [
                                                              FlatButton(
                                                                  onPressed: () {
                                                                    Navigator
                                                                        .of(
                                                                        context,
                                                                        rootNavigator: true)
                                                                        .pop();
                                                                  },
                                                                  child: Text(
                                                                    'Ok',
                                                                    style: TextStyle(
                                                                        color: secondaryColor,
                                                                        fontFamily: 'Poppins Regular'),
                                                                  ))
                                                            ],
                                                            elevation: 24,
                                                            backgroundColor: primaryColor,
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius
                                                                    .all(
                                                                    Radius
                                                                        .circular(
                                                                        20))),
                                                          );
                                                        },
                                                        barrierDismissible: false);
                                                  }
                                                }
                                              },
                                            ),
                                          ),
                                          Center(
                                            child: Padding(
                                              padding:
                                              const EdgeInsets.all(8.0),
                                              child: Text(
                                                'Account Settings',
                                                style: TextStyle(
                                                    color: secondaryColor,
                                                    fontSize: 16,
                                                    fontFamily: 'Poppins Bold'),
                                              ),
                                            ),
                                          ),
                                          // ignore: deprecated_member_use
                                          SizedBox(
                                            width: double.infinity,
                                            child: RaisedButton.icon(
                                              icon: Icon(Icons.lock_outlined, color: primaryColor),
                                              elevation: 0,
                                              onPressed: () async {
                                                DocumentSnapshot
                                                    userSnapshot =
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('users')
                                                        .doc(user.uid)
                                                        .get();
                                                bool googleUser = userSnapshot
                                                    .data()['isGoogleUser'];
                                                // if (googleUser) {
                                                  print(
                                                      'User is a google user.');
                                                  //Scaffold.of(context)
                                                   //   .showSnackBar(
                                                    //      googleSnackBar);
                                                  // showDialog(
                                                  //     context: context,
                                                  //     builder: (_) {
                                                  //       return AlertDialog(
                                                  //         title: Center(child: Text(
                                                  //           'Attention', style: TextStyle(
                                                  //             fontFamily: 'Poppins Bold',
                                                  //             color: secondaryColor),)),
                                                  //         content: Text(
                                                  //             'You cannot do this when you are signed in with Google.',
                                                  //             style: TextStyle(
                                                  //                 fontFamily: 'Poppins Regular',
                                                  //                 color: secondaryColor)),
                                                  //         actions: [
                                                  //           FlatButton(onPressed: () {
                                                  //             Navigator.of(context,
                                                  //                 rootNavigator: true)
                                                  //                 .pop();
                                                  //           },
                                                  //               child: Text('Ok',
                                                  //                 style: TextStyle(
                                                  //                     color: secondaryColor,
                                                  //                     fontFamily: 'Poppins Regular'),))
                                                  //         ],
                                                  //         elevation: 24,
                                                  //         backgroundColor: primaryColor,
                                                  //         shape: RoundedRectangleBorder(
                                                  //             borderRadius: BorderRadius
                                                  //                 .all(
                                                  //                 Radius.circular(20)
                                                  //             )
                                                  //         ),
                                                  //       );;
                                                  //     },
                                                  //     barrierDismissible: false
                                                  // );


                                                  print(
                                                      'User is not a google user.');
                                                  DocumentSnapshot userSnap = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
                                                  Timestamp timestamp = userSnap.data()['lastEmailSent'] ?? null;
                                                  bool emailAllowed = true;

                                                  if (timestamp != null) {
                                                    DateTime date = timestamp.toDate();
                                                    if (DateTime.now().difference(date).inMinutes < 30) {
                                                      emailAllowed = false;
                                                    }
                                                  } else {
                                                    emailAllowed = true;
                                                  }
                                                  if (emailAllowed) {
                                                    await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
                                                      {
                                                        'lastEmailSent' : DateTime.now(),
                                                      }
                                                    );
                                                    bool result = await _auth
                                                        .resetPassword();

                                                    if (result == true) {
                                                      Scaffold.of(context)
                                                          .showSnackBar(
                                                          successSnackBar);
                                                      // showDialog(
                                                      //     context: context,
                                                      //     builder: (_) {
                                                      //       return AlertDialog(
                                                      //         title: Center(child: Text(
                                                      //           'Attention', style: TextStyle(
                                                      //             fontFamily: 'Poppins Bold',
                                                      //             color: secondaryColor),)),
                                                      //         content: Text(
                                                      //             'A password reset email has been sent to you.',
                                                      //             style: TextStyle(
                                                      //                 fontFamily: 'Poppins Regular',
                                                      //                 color: secondaryColor)),
                                                      //         actions: [
                                                      //           FlatButton(onPressed: () {
                                                      //             Navigator.of(context,
                                                      //                 rootNavigator: true)
                                                      //                 .pop();
                                                      //           },
                                                      //               child: Text('Ok',
                                                      //                 style: TextStyle(
                                                      //                     color: secondaryColor,
                                                      //                     fontFamily: 'Poppins Regular'),))
                                                      //         ],
                                                      //         elevation: 24,
                                                      //         backgroundColor: primaryColor,
                                                      //         shape: RoundedRectangleBorder(
                                                      //             borderRadius: BorderRadius
                                                      //                 .all(
                                                      //                 Radius.circular(20)
                                                      //             )
                                                      //         ),
                                                      //       );
                                                      //     },
                                                      //     barrierDismissible: false
                                                      // );
                                                    } else {
                                                      Scaffold.of(context)
                                                          .showSnackBar(
                                                          failedSnackBar);
                                                      // showDialog(
                                                      //     context: context,
                                                      //     builder: (_) {
                                                      //       return AlertDialog(
                                                      //         title: Center(child: Text(
                                                      //           'Attention', style: TextStyle(
                                                      //             fontFamily: 'Poppins Bold',
                                                      //             color: secondaryColor),)),
                                                      //         content: Text(
                                                      //             'Something went wrong. Check your connection.',
                                                      //             style: TextStyle(
                                                      //                 fontFamily: 'Poppins Regular',
                                                      //                 color: primaryColor)),
                                                      //         actions: [
                                                      //           FlatButton(onPressed: () {
                                                      //             Navigator.of(context,
                                                      //                 rootNavigator: true)
                                                      //                 .pop();
                                                      //           },
                                                      //               child: Text('Ok',
                                                      //                 style: TextStyle(
                                                      //                     color: secondaryColor,
                                                      //                     fontFamily: 'Poppins Regular'),))
                                                      //         ],
                                                      //         elevation: 24,
                                                      //         backgroundColor: primaryColor,
                                                      //         shape: RoundedRectangleBorder(
                                                      //             borderRadius: BorderRadius
                                                      //                 .all(
                                                      //                 Radius.circular(20)
                                                      //             )
                                                      //         ),
                                                      //       );
                                                      //     },
                                                      //     barrierDismissible: false
                                                      // );
                                                    }
                                                  } else {

                                                    showDialog(
                                                        context: context,
                                                        builder: (_) {
                                                          return AlertDialog(
                                                            title: Center(
                                                                child: Text(
                                                                  'Attention',
                                                                  style: TextStyle(
                                                                      fontFamily: 'Poppins Bold', color: secondaryColor),
                                                                )),
                                                            content: Text(
                                                                'Please refrain from sending too many emails. Make sure to check your inbox as well as your spam folder.',
                                                                style: TextStyle(
                                                                    fontFamily: 'Poppins Regular', color: secondaryColor)),
                                                            actions: [
                                                              FlatButton(
                                                                  onPressed: () {
                                                                    Navigator.of(context, rootNavigator: true).pop();
                                                                  },
                                                                  child: Text(
                                                                    'Ok',
                                                                    style: TextStyle(
                                                                        color: secondaryColor,
                                                                        fontFamily: 'Poppins Regular'),
                                                                  ))
                                                            ],
                                                            elevation: 24,
                                                            backgroundColor: primaryColor,
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.all(Radius.circular(20))),
                                                          );
                                                        },
                                                        barrierDismissible: false);

                                                  }


                                              },
                                              label: Text(
                                                'Change my Password',
                                                style: TextStyle(
                                                    color: primaryColor,
                                                    fontFamily:
                                                        'Poppins Regular',
                                                    fontSize: 15),
                                              ),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          18.0),
                                                  side: BorderSide(
                                                      color: secondaryColor)),
                                              color: secondaryColor,
                                            ),
                                          ),
                                          SizedBox(
                                            width: double.infinity,
                                            child: RaisedButton.icon(
                                              icon:  Icon(
                                                Icons.block_outlined,
                                                color: primaryColor,
                                              ),
                                              //padding: const EdgeInsets.all(12.0),
                                              label: Text(
                                                'Manage Blocked Users',
                                                style: TextStyle(
                                                    color: primaryColor,
                                                    fontFamily:
                                                    'Poppins Regular',
                                                    fontSize: 15),
                                              ),
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      18.0),
                                                  side: BorderSide(
                                                      color: secondaryColor)),
                                              color: secondaryColor,
                                              onPressed: () async {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ViewBlockedUsers(
                                                            currentTheme: widget
                                                                .currentTheme,
                                                          )),
                                                );
                                              },
                                            ),
                                          ),
                                          SizedBox(
                                            width: double.infinity,
                                            child: RaisedButton.icon(
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          18.0),
                                                  side: BorderSide(
                                                      color: secondaryColor)),
                                              color: secondaryColor,
                                              icon: Icon(
                                                Icons.person_outlined,
                                                color: primaryColor,
                                              ),
                                              label: Text(
                                                'Sign Out',
                                                style: TextStyle(
                                                    color: primaryColor,
                                                    fontFamily:
                                                        'Poppins Regular',
                                                    fontSize: 15),
                                              ),
                                              onPressed: () async {
                                                if (numOfTimesPressed == 0) {
                                                  numOfTimesPressed++;
                                                  Scaffold.of(context)
                                                      .showSnackBar(
                                                      signOut);
                                                } else {
                                                  await _auth.signOut();
                                                }

                                              },
                                            ),
                                          ),
                                          SizedBox(
                                            width: double.infinity,
                                            child: RaisedButton.icon(
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      18.0),
                                                  side: BorderSide(
                                                      color: secondaryColor)),
                                              color: secondaryColor,
                                              icon: Icon(
                                                Icons.delete_forever_outlined,
                                                color: primaryColor,
                                              ),
                                              label: Text(
                                                'Delete my Account',
                                                style: TextStyle(
                                                    color: primaryColor,
                                                    fontFamily:
                                                    'Poppins Regular',
                                                    fontSize: 15),
                                              ),
                                              onPressed: () async {
                                                String entry = await prompt(
                                                  context,
                                                    title: Text('To confirm your request, type "delete" and press ok.', style: TextStyle(color: primaryColor, fontSize: 17, fontFamily: 'Poppins Bold'),),
                                                  initialValue: '',
                                                  textOK: Text('Ok', style: TextStyle(color: primaryColor, fontSize: 17, fontFamily: 'Poppins Regular')),
                                                  textCancel: Text('Cancel', style: TextStyle(color: primaryColor, fontSize: 17, fontFamily: 'Poppins Regular')),
                                                  hintText: '',
                                                  minLines: 1,
                                                  maxLines: 1,
                                                  autoFocus: false,
                                                  obscureText: false,
                                                  obscuringCharacter: '•',
                                                  textCapitalization: TextCapitalization.words,
                                                );
                                                print(entry);
                                                if (entry.toLowerCase() == 'delete') {
                                                  // setState(() {
                                                  //   loading = true;
                                                  // });
                                                  // Navigator.push(
                                                  //   this.context,
                                                  //   MaterialPageRoute(
                                                  //       builder: (context) =>
                                                  //           Loading(
                                                  //             currentTheme: widget
                                                  //                 .currentTheme,
                                                  //           )
                                                  //   ),
                                                  // );
                                                  print('Deleting user account.');
                                                  try {

                                                    DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
                                                    QuerySnapshot blockedSnaps = await FirebaseFirestore.instance.collection('users').where('blockedUsers', arrayContains: userRef).get();
                                                    for (int index = 0; index <= blockedSnaps.docs.length - 1; index++) {
                                                      List<dynamic> indexBlocked = blockedSnaps.docs[index].data()['blockedUsers'];
                                                      indexBlocked.removeWhere((element) => element == userRef);
                                                      await blockedSnaps.docs[index].reference.update(
                                                          {
                                                            'blockedUsers' : indexBlocked
                                                          });
                                                    }
                                                    User firebaseUser = FirebaseAuth.instance.currentUser;
                                                    QuerySnapshot allUserAds = await FirebaseFirestore.instance.collection('ads').where('uid', isEqualTo: user.uid).get();
                                                    QuerySnapshot allUserChats = await FirebaseFirestore.instance.collection('chatrooms').where('visibleTo', arrayContains: userRef).get();
                                                    for (int index = 0; index <= allUserAds.docs.length - 1; index ++) {
                                                      await allUserAds.docs[index].reference.delete();
                                                    }
                                                    for (int index = 0; index <= allUserChats.docs.length - 1; index ++) {
                                                      // List<dynamic> visibleTo = allUserChats.docs[index].data()['visibleTo'];
                                                      // if (visibleTo[0] == userRef) {
                                                      //   visibleTo[0] = null;
                                                      // } else {
                                                      //   visibleTo[1] = null;
                                                      // }
                                                      // await allUserChats.docs[index].reference.update(
                                                      //     {
                                                      //       'visibleTo' : visibleTo
                                                      //     });
                                                      await allUserChats.docs[index].reference.delete();
                                                    }
                                                    await userRef.delete();
                                                    await firebaseUser.delete();
                                                    // await AuthService().signOut();
                                                    print('Deletion of user successful.');
                                                  } catch (e) {
                                                    print(e.toString());
                                                    // do something...
                                                  }
                                                }
                                              },
                                            ),
                                          ),
                                          Center(
                                            child: Padding(
                                              padding:
                                              const EdgeInsets.all(8.0),
                                              child: Text(
                                                'Legal',
                                                style: TextStyle(
                                                    color: secondaryColor,
                                                    fontSize: 16,
                                                    fontFamily: 'Poppins Bold'),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: double.infinity,
                                            child: RaisedButton(
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      18.0),
                                                  side: BorderSide(
                                                      color: secondaryColor)),
                                              color: secondaryColor,
                                              child: Padding(
                                                padding:
                                                const EdgeInsets.all(8),
                                                child: Text(
                                                  'Terms of Service',
                                                  style: TextStyle(
                                                      color: primaryColor,
                                                      fontFamily:
                                                      'Poppins Regular',
                                                      fontSize: 15),
                                                ),
                                              ),
                                              onPressed: () {
                                                Navigator.push(
                                                  this.context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ViewTermsOfService(
                                                            currentTheme: widget
                                                                .currentTheme,
                                                          )),
                                                );
                                              },
                                            ),
                                          ),
                                          SizedBox(
                                            width: double.infinity,
                                            child: RaisedButton(
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      18.0),
                                                  side: BorderSide(
                                                      color: secondaryColor)),
                                              color: secondaryColor,
                                              child: Padding(
                                                padding:
                                                const EdgeInsets.all(8),
                                                child: Text(
                                                  'Privacy Policy',
                                                  style: TextStyle(
                                                      color: primaryColor,
                                                      fontFamily:
                                                      'Poppins Regular',
                                                      fontSize: 15),
                                                ),
                                              ),
                                              onPressed: () {
                                                Navigator.push(
                                                  this.context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ViewPrivacyPolicy(
                                                            currentTheme: widget
                                                                .currentTheme,
                                                          )),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      )),
                                    )),
                                  ],
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
            } else {
              return Loading(
                currentTheme: widget.currentTheme,
              );
            }
          });
    }
  }
}
