import 'dart:math';

import 'package:bookmart/models/selected_chatroom.dart';
import 'package:bookmart/models/user.dart';
import 'package:bookmart/screens/home/chat/specific_chat.dart';
import 'package:bookmart/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:books_finder/books_finder.dart';


class BuyersByISBN extends StatefulWidget {
  @override
  _BuyersByISBNState createState() => _BuyersByISBNState();

  String currentTheme;
  String userCountry;
  final userPosition;
  String ISBN;


  BuyersByISBN(
      {this.currentTheme, this.ISBN, this.userCountry, this.userPosition});
}

class _BuyersByISBNState extends State<BuyersByISBN> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    dynamic user = Provider.of<CustomUser>(context);

    Future<SelectedChatroom> startChatroomForUsers(
        List<CustomUser> users) async {
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
          return SelectedChatroom(
              roomID: roomSnapshot.id, displayName: widget.ISBN);
        } else {
          List<dynamic> visibleTo = roomSnapshot.data()['visibleTo'];
          visibleTo[1] = userRef;
          await FirebaseFirestore.instance
              .collection('chatrooms')
              .doc(roomSnapshot.id)
              .update({'visibleTo': visibleTo});
          return SelectedChatroom(
              roomID: roomSnapshot.id, displayName: widget.ISBN);
        }
      } else {
        Map<String, dynamic> chatroomMap = Map<String, dynamic>();
        chatroomMap["messages"] = List<Map<String, dynamic>>(0);

        List<DocumentReference> participants = List<DocumentReference>(2);
        participants[0] = otherUserRef;
        participants[1] = userRef;
        chatroomMap["participants"] = participants;

        List<DocumentReference> visibleTo = List<DocumentReference>(2);
        visibleTo[0] = otherUserRef;
        visibleTo[1] = userRef;
        chatroomMap["visibleTo"] = visibleTo;

        List<Book> books = await queryBooks(
          "isbn:" + widget.ISBN,
          maxResults: 1,
          printType: PrintType.all,
          orderBy: OrderBy.relevance,
          reschemeImageLinks: true,
        );

        String title = books.first.info.title;

        chatroomMap['initialProduct'] = title;

        DocumentReference reference = await FirebaseFirestore.instance
            .collection('chatrooms')
            .add(chatroomMap);
        DocumentSnapshot chatroomSnapshot = await reference.get();
        return SelectedChatroom(
            roomID: chatroomSnapshot.id, displayName: title);
      }
    }

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

    double calculateDistance(lat1, lon1, lat2, lon2) {
      var p = 0.017453292519943295;
      var c = cos;
      var a = 0.5 -
          c((lat2 - lat1) * p) / 2 +
          c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
      return 12742 * asin(sqrt(a));
    }

    Future<bool> _askedToLead(String userUID) async {
      print(userUID);
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
                'Options',
                style: TextStyle(
                    color: secondaryColor, fontFamily: 'Poppins Bold'),
              ),
              children: <Widget>[
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, 'View');
                  },
                  child: Text(
                    'Send a message',
                    style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Poppins Regular',
                        color: secondaryColor),
                  ),
                ),
              ],
            );
          })) {
        case 'View':
          {
            //Position userLocation = await getUserLocation()
            setState(() {
              loading = true;
            });

            try {
              List<CustomUser> users = List.generate(2, (index) => null);

              users[0] = CustomUser(uid: user.uid);
              users[1] = CustomUser(uid: userUID);

              SelectedChatroom chatroom = await startChatroomForUsers(users);

              DocumentSnapshot doc = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(users[1].uid)
                  .get();
              String talkingTo = doc.data()['username'];
              setState(() {
                loading = false;
              });
              Navigator.push(
                this.context,
                MaterialPageRoute(
                    builder: (context) => SpecificChat(
                          currentTheme: widget.currentTheme,
                          chatroomID: chatroom.roomID,
                          chattingTo: talkingTo,
                        )),
              );

              return true;

              setState(() {
                loading = false;
              });
            } catch (e) {
              print(e.toString());
              return false;
            }

            // return result;
          }
          break;
      }
    }



    if (loading) {
      return Loading(
        currentTheme: widget.currentTheme,
      );
    } else {
      return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('publicWishlist', arrayContains: widget.ISBN)
              .where('lastCountry', isEqualTo: widget.userCountry)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {

              List<QueryDocumentSnapshot> docs = snapshot.data.docs;

              docs.removeWhere((element) => element.id == user.uid);

              // docs.sort()
              
              List resultDistances =
                  List.generate(docs.length, (i) => i);

              for (int index = 0; index < docs.length; index++) {
                var adPosition =
                docs[index].data()['lastKnownLocation'];
                var distance = calculateDistance(
                    adPosition.latitude,
                    adPosition.longitude,
                    widget.userPosition.latitude,
                    widget.userPosition.longitude);
                resultDistances[index] = distance;
              }
              for (int i = 0; i < docs.length - 1; i++) {            // -1
                for (int j = 0; j < docs.length - i - 1; j++) {           // - i - 1
                  if (resultDistances[j] > resultDistances[j + 1]) {
                    // Swapping using temporary variable
                    var temp = resultDistances[j];
                    var temp2 = docs[j];
                    //var temp3 = newSearchDocuments[j];
                    resultDistances[j] = resultDistances[j + 1];
                    docs[j] = docs[j + 1];
                    //newSearchDocuments[j] = newSearchDocuments[j + 1];
                    resultDistances[j + 1] = temp;
                    //newSearchDocuments[j + 1] = temp3;
                    docs[j + 1] = temp2;
                  }
                }
              }




              return Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  elevation: 0,
                  backgroundColor: primaryColor,
                  title: Text(
                    "Search Results",
                    style: TextStyle(
                        fontFamily: 'Poppins Bold',
                        fontSize: 18,
                        color: secondaryColor),
                  ),
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
                            'Looking for this ISBN:',
                            style: TextStyle(
                                color: secondaryColor,
                                fontSize: 26,
                                fontFamily: 'Poppins Bold'),
                          ),
                        ),
                      ),
                      Text(
                        widget.ISBN,
                        style: TextStyle(
                            fontFamily: "Poppins Regular",
                            fontSize: 20,
                            color: secondaryColor),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: docs.isEmpty
                            ? Text(
                                'No users currently have this ISBN number on their wish list.',
                                style: TextStyle(
                                    color: secondaryColor,
                                    fontSize: 13,
                                    fontFamily: 'Poppins Bold'),
                          textAlign: TextAlign.center,
                              )
                            : null,
                      ),
                      Expanded(
                          child: ListView.builder(
                              itemCount: docs.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: secondaryColor, width: 1),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    color: secondaryColor,
                                    elevation: 0,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(10),
                                      onTap: () async {
                                        bool result = await _askedToLead(
                                            docs[index].id);
                                        if (result == null || result) {
                                          return;
                                        }
                                        if (!result) {
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
                                                      'Something went wrong. Try again later.',
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
                                        }
                                      },
                                      child: ListTile(
                                        title: Text(
                                          docs[index]
                                              .data()['username'],
                                          style: TextStyle(
                                              color: primaryColor,
                                              fontFamily: 'Poppins Regular',
                                              fontSize: 15),
                                        ),
                                        trailing: Text(
                                          // calculateDistance(
                                          //             widget.userPosition
                                          //                 .latitude,
                                          //             widget.userPosition
                                          //                 .longitude,
                                          //             snapshot.data.docs[index]
                                          //                 .data()[
                                          //                     'lastKnownLocation']
                                          //                 .latitude,
                                          //             snapshot.data.docs[index]
                                          //                 .data()[
                                          //                     'lastKnownLocation']
                                          //                 .longitude)
                                          resultDistances[index]
                                                  .truncate()
                                                  .toString() +
                                              " km away",
                                          style: TextStyle(
                                              color: primaryColor,
                                              fontFamily: 'Poppins Regular',
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
          });
    }
  }
}
