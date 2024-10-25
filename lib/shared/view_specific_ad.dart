import 'package:algolia/algolia.dart';
import 'package:bookmart/models/post_ad_data_model.dart';
import 'package:bookmart/models/user.dart';
import 'package:bookmart/screens/home/chat/specific_chat.dart';
import 'package:bookmart/services/database.dart';
import 'package:bookmart/shared/loading.dart';
import 'package:bookmart/shared/view_ads_by_specific_user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math' show cos, sqrt, asin;
import 'package:bookmart/models/selected_chatroom.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share/share.dart';

class ViewSpecificAd extends StatefulWidget {
  @override
  _ViewSpecificAdState createState() => _ViewSpecificAdState();
  var currentUserLocation;
  final String currentTheme;
  final AlgoliaObjectSnapshot model;
  PostAdModel postAdModel;

  ViewSpecificAd(
      {this.currentTheme,
      this.model,
      this.currentUserLocation,
      this.postAdModel});
}

class _ViewSpecificAdState extends State<ViewSpecificAd> {
  bool loading = false;

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  Future<SelectedChatroom> startChatroomForUsers(List<CustomUser> users) async {
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(users[1].uid);
    QuerySnapshot queryResults = await FirebaseFirestore.instance
        .collection('chatrooms')
        .where("participants", arrayContains: userRef)
        .get();

    DocumentReference otherUserRef =
        FirebaseFirestore.instance.collection('users').doc(users[0].uid);
    DocumentSnapshot roomSnapshot = queryResults.docs.firstWhere((room) {
      return room.data()["participants"].contains(otherUserRef);
    }, orElse: () => null);
    if (roomSnapshot != null) {
      if (roomSnapshot.data()['visibleTo'].contains(userRef)) {
        if (widget.model == null && widget.postAdModel != null) {
          return SelectedChatroom(
              roomID: roomSnapshot.id,
              displayName: widget.postAdModel.bookTitle);
        } else {
          return SelectedChatroom(
              roomID: roomSnapshot.id, displayName: widget.model.data['title']);
        }
      } else {
        List<dynamic> visibleTo = roomSnapshot.data()['visibleTo'];
        visibleTo[1] = userRef;
        await FirebaseFirestore.instance
            .collection('chatrooms')
            .doc(roomSnapshot.id)
            .update({'visibleTo': visibleTo});
        if (widget.model == null && widget.postAdModel != null) {
          return SelectedChatroom(
              roomID: roomSnapshot.id,
              displayName: widget.postAdModel.bookTitle);
        } else {
          return SelectedChatroom(
              roomID: roomSnapshot.id, displayName: widget.model.data['title']);
        }
      }
    } else {
      Map<String, dynamic> chatroomMap = Map<String, dynamic>();
      chatroomMap["messages"] = List<Map<String, dynamic>>(0);
      // Map<String, dynamic> tempChat = {
      //   'content' : null,
      //   'sender' : null,
      //   'timestamp' : null
      // };
      // chatroomMap['messages'][0] = null;

      List<DocumentReference> participants = List<DocumentReference>(2);
      participants[0] = otherUserRef;
      participants[1] = userRef;
      chatroomMap["participants"] = participants;

      List<DocumentReference> visibleTo = List<DocumentReference>(2);
      visibleTo[0] = otherUserRef;
      visibleTo[1] = userRef;
      chatroomMap["visibleTo"] = visibleTo;

      if (widget.model != null && widget.postAdModel == null) {
        chatroomMap['initialProduct'] = widget.model.data['title'];
        chatroomMap['initialProductID'] = widget.model.data['uniqueName'];
      }
      if (widget.model == null && widget.postAdModel != null) {
        chatroomMap['initialProduct'] = widget.postAdModel.bookTitle;
        chatroomMap['initialProductID'] = widget.postAdModel.uniqueName;
      }

      DocumentReference reference = await FirebaseFirestore.instance
          .collection('chatrooms')
          .add(chatroomMap);
      DocumentSnapshot chatroomSnapshot = await reference.get();
      if (widget.model == null && widget.postAdModel != null) {
        return SelectedChatroom(
            roomID: chatroomSnapshot.id,
            displayName: widget.postAdModel.bookTitle);
      } else {
        return SelectedChatroom(
            roomID: chatroomSnapshot.id,
            displayName: widget.model.data['title']);
      }
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    var distance;
    var date;
    var dateDifference;
    String whenWasAdPosted;
    String title;
    String imageLink;
    String author;
    String price;
    String condition;
    String generalLocation;
    String description;

    if (widget.model != null && widget.postAdModel == null) {
      title = widget.model.data['title'];
      imageLink = widget.model.data['coverImage'];
      author = widget.model.data['author'];
      price = widget.model.data['price'];
      condition = widget.model.data['condition'];
      generalLocation = widget.model.data['generalLocation'];
      description = widget.model.data['description'];

      if (widget.currentUserLocation != null) {
        distance = calculateDistance(
                widget.currentUserLocation.latitude,
                widget.currentUserLocation.longitude,
                widget.model.data['location']['_latitude'],
                widget.model.data['location']['_longitude'])
            .round();
        print('$distance  km');
      }

      date = DateTime.fromMillisecondsSinceEpoch(
          widget.model.data['postDate']['_seconds'] * 1000);
      DateTime now = DateTime.now();
      dateDifference = now.difference(date);
      if (dateDifference.inDays == 0) {
        whenWasAdPosted = '${dateDifference.inHours}h ago';
      } else {
        whenWasAdPosted = '${dateDifference.inDays}d ago';
      }
      print(whenWasAdPosted);
      print(date.toString());
    }

    if (widget.postAdModel != null && widget.model == null) {
      title = widget.postAdModel.bookTitle;
      imageLink = widget.postAdModel.imageLink;
      author = widget.postAdModel.author;
      price = widget.postAdModel.price;
      condition = widget.postAdModel.condition;
      generalLocation = widget.postAdModel.generalLocation;
      description = widget.postAdModel.description;

      if (widget.currentUserLocation != null) {
        distance = calculateDistance(
                widget.currentUserLocation.latitude,
                widget.currentUserLocation.longitude,
                widget.postAdModel.adLocation.latitude,
                widget.postAdModel.adLocation.longitude)
            .round();
        print('$distance  km');
      }
      // date = widget.postAdModel.postDate;
      // print(date);
      // DateTime now = DateTime.now();
      // dateDifference = now.difference(date);
      // if (dateDifference.inDays == 0) {
      //   whenWasAdPosted = '${dateDifference.inHours}h ago';
      // } else {
      //   whenWasAdPosted =
      //   '${dateDifference.inHours}h ${dateDifference.inDays}d ago';
      // }
      date = widget.postAdModel.dateOfPost;
      DateTime now = DateTime.now();
      dateDifference = now.difference(date);
      //print(dateDifference.inMonths);
      if (dateDifference.inDays == 0) {
        whenWasAdPosted = '${dateDifference.inHours}h ago';
      } else {
        whenWasAdPosted = '${dateDifference.inDays}d ago';
      }
      print(whenWasAdPosted);
      print(date.toString());
    }

    Color primaryColor;
    Color secondaryColor;

    String imagePath;
    Gradient currentGradient;
    if (widget.currentTheme == 'Light') {
      primaryColor = Colors.white;
      secondaryColor = Colors.blueAccent;
      imagePath = 'images/Bookmart Icon-64x64.png';
      currentGradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.grey[200]]);
    }

    if (widget.currentTheme == 'Blue') {
      primaryColor = Colors.blueAccent;
      secondaryColor = Colors.white;
      imagePath = 'images/Bookmart Icon-64x64.png';
      currentGradient = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.lightBlue[600], Colors.blueAccent]);
    }

    if (widget.currentTheme == 'Dark') {
      primaryColor = Colors.black;
      secondaryColor = Colors.grey[350];
      imagePath = 'images/Bookmart Icon-64x64.png';
      currentGradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, Colors.grey[800]]);
    }

    final user = Provider.of<CustomUser>(context);

    if (loading) {
      return Loading(
        currentTheme: widget.currentTheme,
      );
    } else {
      return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.postAdModel == null
                  ? widget.model.data['uid']
                  : widget.postAdModel.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              String posterName = snapshot.data.data()['username'];
              print('posterName = $posterName');
              return Scaffold(
                key: _scaffoldKey,
                backgroundColor: primaryColor,
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: primaryColor,
                ),
                body: Container(
                    decoration: BoxDecoration(
                      color: primaryColor,
                      gradient: currentGradient,
                    ),
                    child: Flex(
                      direction: Axis.vertical,
                      children: [
                        Expanded(
                            child: ListView(
                          children: [
                            Center(
                              child: Container(
                                  width: double.infinity,
                                  child: CachedNetworkImage(
                                    imageUrl: imageLink,
                                    placeholder: (context, url) {
                                      return Loading(
                                        currentTheme: widget.currentTheme,
                                      );
                                    },
                                  )),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(color: secondaryColor)),
                                //margin: EdgeInsets.fromLTRB(20, 6 , 20, 0),
                                color: secondaryColor,
                                elevation: 0,
                                child: Column(
                                  children: [
                                    ListTile(
                                      // leading: Column(
                                      //   children: [
                                      //     Padding(
                                      //       padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                                      //       child: Text(widget.currentModel.bookTitle, style: TextStyle(color: secondaryColor, fontFamily: 'Open Sans Bold'),),
                                      //     ),
                                      //     Padding(
                                      //       padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                                      //       child: Text(widget.currentModel.condition, style: TextStyle(color: secondaryColor, fontFamily: 'Open Sans Semi Bold'),),
                                      //     ),
                                      //   ],
                                      // ),
                                      // leading: Row(
                                      //   children: [
                                      //     CircleAvatar(
                                      //       radius: 45,
                                      //       backgroundImage: FileImage(widget.currentModel.providedCover),
                                      //     ),
                                      //     Text(widget.currentModel.bookTitle, style: TextStyle(color: secondaryColor, fontFamily: 'Open Sans Bold'),),
                                      //     SizedBox(width: 10,),
                                      //     Text(widget.currentModel.condition, style: TextStyle(color: secondaryColor, fontFamily: 'Open Sans Semi Bold'),),
                                      //   ],
                                      // ),
                                      title: Text(
                                        title,
                                        style: TextStyle(
                                            color: primaryColor,
                                            fontFamily: 'Poppins Bold',
                                            fontSize: 22),
                                      ),
                                      subtitle: Text(
                                        'Author: ${author}',
                                        style: TextStyle(
                                            color: primaryColor,
                                            fontFamily: 'Poppins Bold',
                                            fontSize: 16),
                                      ),
                                    ),
                                    ListTile(
                                      leading: Text(
                                        'Price: ${price}',
                                        style: TextStyle(
                                            color: primaryColor,
                                            fontFamily: 'Poppins Bold',
                                            fontSize: 16),
                                      ),
                                      title: Text(
                                        'Condition: ${condition}',
                                        style: TextStyle(
                                            color: primaryColor,
                                            fontFamily: 'Poppins Bold',
                                            fontSize: 16),
                                      ),
                                    ),
                                    ListTile(
                                      title: Text(
                                        distance == null
                                            ? 'Seller Location:'
                                            : 'Seller Location: ${distance} km away',
                                        style: TextStyle(
                                            color: primaryColor,
                                            fontFamily: 'Poppins Bold',
                                            fontSize: 16),
                                      ),
                                      subtitle: Text(
                                        generalLocation,
                                        style: TextStyle(
                                            color: primaryColor,
                                            fontFamily: 'Poppins Regular',
                                            fontSize: 16),
                                      ),
                                    ),
                                    ListTile(
                                      title: Text(
                                        'Posted:',
                                        style: TextStyle(
                                            color: primaryColor,
                                            fontFamily: 'Poppins Bold',
                                            fontSize: 16),
                                      ),
                                      subtitle: Text(
                                        whenWasAdPosted,
                                        style: TextStyle(
                                            color: primaryColor,
                                            fontFamily: 'Poppins Regular',
                                            fontSize: 16),
                                      ),
                                    ),
                                    ListTile(
                                      title: Text(
                                        'Poster:',
                                        style: TextStyle(
                                            color: primaryColor,
                                            fontFamily: 'Poppins Bold',
                                            fontSize: 16),
                                      ),
                                      subtitle: Text(
                                        posterName,
                                        style: TextStyle(
                                            color: primaryColor,
                                            fontFamily: 'Poppins Regular',
                                            fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: RaisedButton(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        side: BorderSide(color: secondaryColor)),
                                    color: secondaryColor,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Contact Seller',
                                        style: TextStyle(
                                            color: primaryColor,
                                            fontFamily: 'Poppins Regular',
                                            fontSize: 18),
                                      ),
                                    ),
                                    onPressed: () async {
                                      setState(() {
                                        loading = true;
                                      });
                                      String adUID;
                                      String userUID;
                                      String sellerUID;
                                      if (widget.model != null &&
                                          widget.postAdModel == null) {
                                        adUID = widget.model.data['uniqueName'];
                                        userUID = user.uid;
                                        sellerUID = widget.model.data['uid'];
                                      }
                                      if (widget.model == null &&
                                          widget.postAdModel != null) {
                                        adUID = widget.postAdModel.uniqueName;
                                        //widget.postAdModel.
                                        userUID = user.uid;
                                        sellerUID = widget.postAdModel.uid;
                                      }

                                      bool match = adUID.contains(userUID);
                                      if (match) {
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
                                                      color: secondaryColor),
                                                )),
                                                content: Text(
                                                    'You cannot contact yourself.',
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Poppins Regular',
                                                        color: secondaryColor)),
                                                actions: [
                                                  FlatButton(
                                                      onPressed: () {
                                                        Navigator.of(context,
                                                                rootNavigator:
                                                                    true)
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
                                                backgroundColor: primaryColor,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                20))),
                                              );
                                            },
                                            barrierDismissible: false);
                                        setState(() {
                                          loading = false;
                                        });
                                      } else {
                                        DocumentSnapshot currentUserSnap =
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(user.uid)
                                                .get();
                                        List<dynamic> blockedUsers =
                                            currentUserSnap
                                                    .data()['blockedUsers'] ??
                                                List.generate(
                                                    0, (index) => null);
                                        DocumentReference sellerRef =
                                            FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(sellerUID);
                                        bool isUserBlocked =
                                            blockedUsers.contains(sellerRef);
                                        if (isUserBlocked) {
                                          setState(() {
                                            loading = false;
                                          });
                                          showDialog(
                                              context: this.context,
                                              builder: (_) {
                                                return AlertDialog(
                                                  title: Center(
                                                      child: Text(
                                                    'Attention',
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Poppins Bold',
                                                        color: secondaryColor),
                                                  )),
                                                  content: Text(
                                                      'You have blocked this user. If you wish to contact them, unblock them in your profile settings.',
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Poppins Regular',
                                                          color:
                                                              secondaryColor)),
                                                  actions: [
                                                    FlatButton(
                                                        onPressed: () {
                                                          Navigator.of(
                                                                  this.context,
                                                                  rootNavigator:
                                                                      true)
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
                                                  backgroundColor: primaryColor,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  20))),
                                                );
                                              },
                                              barrierDismissible: false);
                                        } else {
                                          DocumentSnapshot otherUserSnap =
                                              await FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(sellerUID)
                                                  .get();
                                          List<dynamic> blockedUsers =
                                              otherUserSnap
                                                      .data()['blockedUsers'] ??
                                                  List.generate(
                                                      0, (index) => null);
                                          DocumentReference currentUserRef =
                                              FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(user.uid);
                                          bool isCurrentUserBlocked =
                                              blockedUsers
                                                  .contains(currentUserRef);
                                          if (isCurrentUserBlocked) {
                                            setState(() {
                                              loading = false;
                                            });
                                            showDialog(
                                                context: this.context,
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
                                                        'You are unable to contact this user.',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Poppins Regular',
                                                            color:
                                                                secondaryColor)),
                                                    actions: [
                                                      FlatButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    this
                                                                        .context,
                                                                    rootNavigator:
                                                                        true)
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
                                                barrierDismissible: false);
                                          } else {
                                            List<CustomUser> users =
                                                List.generate(
                                                    2, (index) => null);
                                            if (widget.postAdModel != null &&
                                                widget.model == null) {
                                              users[0] = CustomUser(
                                                  uid: widget.postAdModel.uid);
                                              users[1] =
                                                  CustomUser(uid: user.uid);
                                            }
                                            if (widget.postAdModel == null &&
                                                widget.model != null) {
                                              users[0] = CustomUser(
                                                  uid:
                                                      widget.model.data['uid']);
                                              users[1] =
                                                  CustomUser(uid: user.uid);
                                            }
                                            SelectedChatroom chatroom =
                                                await startChatroomForUsers(
                                                    users);
                                            DocumentSnapshot doc =
                                                await FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(users[0].uid)
                                                    .get();
                                            String talkingTo =
                                                doc.data()['username'];
                                            setState(() {
                                              loading = false;
                                            });
                                            Navigator.push(
                                              this.context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      SpecificChat(
                                                        currentTheme:
                                                            widget.currentTheme,
                                                        chatroomID:
                                                            chatroom.roomID,
                                                        chattingTo: talkingTo,
                                                      )),
                                            );
                                          }
                                        }
                                      }
                                    }),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: SizedBox(
                                width: double.infinity,
                                child: RaisedButton(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        side: BorderSide(color: secondaryColor)),
                                    color: secondaryColor,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Add to Watchlist',
                                        style: TextStyle(
                                            color: primaryColor,
                                            fontFamily: 'Poppins Regular',
                                            fontSize: 18),
                                      ),
                                    ),
                                    onPressed: () async {
                                      setState(() {
                                        loading = true;
                                      });
                                      String adUID;
                                      String userUID;
                                      if (widget.model != null &&
                                          widget.postAdModel == null) {
                                        adUID = widget.model.data['uniqueName'];
                                        userUID = user.uid;
                                      }
                                      if (widget.model == null &&
                                          widget.postAdModel != null) {
                                        adUID = widget.postAdModel.uniqueName;
                                        //widget.postAdModel.
                                        userUID = user.uid;
                                      }

                                      bool match = adUID.contains(userUID);
                                      if (match) {
                                        print('This is your ad.');

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
                                                      color: secondaryColor),
                                                )),
                                                content: Text(
                                                    'You cannot add your own ads to your watchlist.',
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Poppins Regular',
                                                        color: secondaryColor)),
                                                actions: [
                                                  FlatButton(
                                                      onPressed: () {
                                                        Navigator.of(context,
                                                                rootNavigator:
                                                                    true)
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
                                                backgroundColor: primaryColor,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                20))),
                                              );
                                            },
                                            barrierDismissible: false);
                                        setState(() {
                                          loading = false;
                                        });
                                      } else {
                                        print('Not your ad.');
                                        bool result =
                                            await DatabaseService(uid: user.uid)
                                                .addToWatchlist(adUID);
                                        if (result) {
                                          showDialog(
                                              context: this.context,
                                              builder: (_) {
                                                return AlertDialog(
                                                  title: Center(
                                                      child: Text(
                                                    'Attention',
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Poppins Bold',
                                                        color: secondaryColor),
                                                  )),
                                                  content: Text(
                                                      'Watchlist has been updated.',
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Poppins Regular',
                                                          color:
                                                              secondaryColor)),
                                                  actions: [
                                                    FlatButton(
                                                        onPressed: () {
                                                          Navigator.of(
                                                                  this.context,
                                                                  rootNavigator:
                                                                      true)
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
                                                  backgroundColor: primaryColor,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  20))),
                                                );
                                                ;
                                              },
                                              barrierDismissible: false);
                                          setState(() {
                                            loading = false;
                                          });
                                        } else {
                                          showDialog(
                                              context: this.context,
                                              builder: (_) {
                                                return AlertDialog(
                                                  title: Center(
                                                      child: Text(
                                                    'Attention',
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Poppins Bold',
                                                        color: secondaryColor),
                                                  )),
                                                  content: Text(
                                                      'Either you have an unstable internet connection or the item is already on your watchlist.',
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Poppins Regular',
                                                          color:
                                                              secondaryColor)),
                                                  actions: [
                                                    FlatButton(
                                                        onPressed: () {
                                                          Navigator.of(
                                                                  this.context,
                                                                  rootNavigator:
                                                                      true)
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
                                                  backgroundColor: primaryColor,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  20))),
                                                );
                                                ;
                                              },
                                              barrierDismissible: false);
                                          setState(() {
                                            loading = false;
                                          });
                                        }
                                      }
                                      print('Ad ID: $adUID');
                                    }),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: SizedBox(
                                width: double.infinity,
                                child: RaisedButton(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        side: BorderSide(color: secondaryColor)),
                                    color: secondaryColor,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'View all ads by user',
                                        style: TextStyle(
                                            color: primaryColor,
                                            fontFamily: 'Poppins Regular',
                                            fontSize: 18),
                                      ),
                                    ),
                                    onPressed: () async {
                                      String userUID;
                                      if (widget.model == null &&
                                          widget.postAdModel != null) {
                                        userUID = widget.postAdModel.uid;
                                      } else {
                                        userUID = widget.model.data['uid'];
                                      }
                                      print('Viewing ads by $userUID');
                                      Navigator.push(
                                        this.context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SpecificUserAds(
                                                  currentTheme:
                                                  widget.currentTheme,
                                                  posterName: posterName,
                                                  userUID: userUID,
                                                )),
                                      );
                                    }),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: SizedBox(
                                width: double.infinity,
                                child: RaisedButton(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(20.0),
                                        side: BorderSide(color: secondaryColor)),
                                    color: secondaryColor,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Share ad',
                                        style: TextStyle(
                                            color: primaryColor,
                                            fontFamily: 'Poppins Regular',
                                            fontSize: 18),
                                      ),
                                    ),
                                    onPressed: () async {
                                      // String adTitle;
                                      // String price;
                                      // String author;
                                      String shareText;

                                      if (widget.model == null && widget.postAdModel != null) {
                                        shareText = 'This item is being sold on Bookmart:\n${widget.postAdModel.bookTitle}\nPrice: ${widget.postAdModel.price}\nBookmart is available on iOS and Android.\nApp Store: https://apps.apple.com/us/app/bookmart/id1576758337\nGoogle Play Store: https://play.google.com/store/apps/details?id=com.alekduplessis.bookmart';

                                      }
                                      if (widget.model != null && widget.postAdModel == null) {
                                        shareText = 'This item is being sold on Bookmart:\n${widget.model.data['title']}\nPrice: ${widget.model.data['price']}\nBookmart is available on iOS and Android.\nApp Store: https://apps.apple.com/us/app/bookmart/id1576758337\nGoogle Play Store: https://play.google.com/store/apps/details?id=com.alekduplessis.bookmart';

                                      }

                                      Share.share(shareText);

                                    }),
                              )
                            ),
                            // Padding(
                            //   padding: EdgeInsets.all(12),
                            //   child: Text(
                            //     'Description',
                            //       style:
                            //       TextStyle(
                            //       color: primaryColor,
                            //       fontFamily: 'Poppins Regular',
                            //       fontSize: 18)
                            //   ),
                            //

                            Padding(
                              padding: const EdgeInsets.fromLTRB(15, 12, 15, 5),
                              child: Center(
                                  child: Text(
                                'Description:',
                                style: TextStyle(
                                    color: secondaryColor,
                                    fontFamily: 'Poppins Bold',
                                    fontSize: 18),
                              )),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(15, 6, 15, 45),
                              child: Center(
                                  child: Text(
                                description ?? 'No Description Given',
                                style: TextStyle(
                                    color: secondaryColor,
                                    fontFamily: 'Poppins Regular',
                                    fontSize: 15),
                              )),
                            ),
                          ],
                        ))
                      ],
                    )),
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
