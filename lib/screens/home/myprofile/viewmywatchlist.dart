import 'package:bookmart/models/post_ad_data_model.dart';
import 'package:bookmart/models/user.dart';
import 'package:bookmart/services/database.dart';
import 'package:bookmart/shared/loading.dart';
import 'package:bookmart/shared/view_specific_ad.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'dart:math' show cos, sqrt, asin;

class ViewMyWatchlist extends StatefulWidget {
  @override
  _ViewMyWatchlistState createState() => _ViewMyWatchlistState();

  String currentTheme;
  Position currentUserLocation;

  ViewMyWatchlist({this.currentTheme, this.currentUserLocation});
}

class _ViewMyWatchlistState extends State<ViewMyWatchlist> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    double calculateDistance(lat1, lon1, lat2, lon2) {
      var p = 0.017453292519943295;
      var c = cos;
      var a = 0.5 -
          c((lat2 - lat1) * p) / 2 +
          c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
      return 12742 * asin(sqrt(a));
    }

    int distance;

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
    Position position;
    final user = Provider.of<CustomUser>(context);

    void _askedToLead(PostAdModel model) async {
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
                    'View',
                    style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Poppins Regular',
                        color: secondaryColor),
                  ),
                ),
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, 'Delete');
                  },
                  child: Text(
                    'Delete from Watchlist',
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
            //Position userLocation = await getUserLocation();
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ViewSpecificAd(
                        currentTheme: widget.currentTheme,
                        postAdModel: model,
                        currentUserLocation: widget.currentUserLocation,
                      )),
            );
          }
          break;

        case 'Delete':
          {
            print('Deleting from Watchlist: ${model.uniqueName}');
            try {
              String uniqueName = model.uniqueName;
              bool result = await DatabaseService(uid: user.uid)
                  .deleteFromWatchlist(uniqueName);
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
                            'Item has been deleted from your watchlist.',
                            style: TextStyle(
                                fontFamily: 'Poppins Regular',
                                color: secondaryColor)),
                        actions: [
                          FlatButton(
                              onPressed: () {
                                Navigator.of(context, rootNavigator: true)
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
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
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
                            'Item could not be deleted at this time. Check your internet connection and try again.',
                            style: TextStyle(
                                fontFamily: 'Poppins Regular',
                                color: secondaryColor)),
                        actions: [
                          FlatButton(
                              onPressed: () {
                                Navigator.of(context, rootNavigator: true)
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
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                      );
                    },
                    barrierDismissible: false);
              }
            } catch (e) {
              print(e);
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
                          'Item could not be deleted at this time. Check your internet connection and try again.',
                          style: TextStyle(
                              fontFamily: 'Poppins Regular',
                              color: secondaryColor)),
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
          }
          // ...
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
              String completeWatchlist = snapshot.data.data()['watchlist'];
              if (completeWatchlist == null) {
                completeWatchlist = '';
              }
              List<String> watchListItems = completeWatchlist.split('#');
              //print(watchListItems[0]);
              //print(watchListItems[1]);
              // print(completeWatchlist);
              return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('ads')
                      .where('uniqueName', whereIn: watchListItems)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<QueryDocumentSnapshot> documents =
                          snapshot.data.docs;

                      print(documents.length);

                      List<PostAdModel> watchlistModels;
                      List<int> distances;
                      if (documents != null) {
                        watchlistModels = documents.map((e) {
                          return PostAdModel(
                            uniqueName: e.data()['uniqueName'],
                            adPosted: true,
                            mainCategory: e.data()['mainCat'],
                            subCategory: e.data()['subCat'],
                            dateOfPost: e.data()['postDate'].toDate(),
                            bookTitle: e.data()['title'],
                            cover: NetworkImage(e.data()['coverImage']),
                            author: e.data()['author'],
                            postDate: e.data()['postDate'].toDate(),
                            condition: e.data()['condition'],
                            description: e.data()['description'],
                            adGeoPoint: e.data()['location'],
                            generalLocation: e.data()['generalLocation'],
                            price: e.data()['price'],
                            adLocation: Position(
                                longitude: e.data()['location'].longitude,
                                latitude: e.data()['location'].latitude),
                            imageLink: e.data()['coverImage'],
                            uid: e.data()['uid'],
                          );
                        }).toList();
                        //print('Model : ${watchlistModels[0].uniqueName}');
                        distances =
                            List.generate(watchlistModels.length, (index) => 0);
                        for (int i = 0; i <= watchlistModels.length - 1; i++) {
                          distances[i] = calculateDistance(
                                  widget.currentUserLocation.latitude,
                                  widget.currentUserLocation.longitude,
                                  watchlistModels[i].adGeoPoint.latitude,
                                  watchlistModels[i].adGeoPoint.longitude)
                              .round();
                        }
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
                                        'Current Watchlist:',
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
                                  child: watchlistModels.length == 0
                                      ? Text(
                                          'You have no items on your watchlist.',
                                          style: TextStyle(
                                              color: secondaryColor,
                                              fontSize: 13,
                                              fontFamily: 'Poppins Regular'),
                                        )
                                      : null,
                                ),
                              ),
                              Expanded(
                                  child: ListView.builder(
                                      itemCount: watchlistModels.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                    color: secondaryColor,
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            //margin: EdgeInsets.fromLTRB(20, 6 , 20, 0),
                                            color: secondaryColor,
                                            elevation: 0,
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              onTap: () async {
                                                _askedToLead(
                                                    watchlistModels[index]);
                                              },
                                              child: Column(
                                                children: [
                                                  ListTile(
                                                    leading: CircleAvatar(
                                                      radius: 30,
                                                      backgroundImage:
                                                          watchlistModels[index]
                                                              .cover,
                                                    ),
                                                    title: Text(
                                                      watchlistModels[index]
                                                          .bookTitle,
                                                      style: TextStyle(
                                                          color: primaryColor,
                                                          fontFamily:
                                                              'Poppins Bold',
                                                          fontSize: 15),
                                                    ),
                                                    subtitle: Text(
                                                      'Author: ${watchlistModels[index].author}',
                                                      style: TextStyle(
                                                          color: primaryColor,
                                                          fontFamily:
                                                              'Poppins Regular'),
                                                      textAlign: TextAlign.left,
                                                    ),
                                                    trailing: Text(
                                                      watchlistModels[index]
                                                          .price,
                                                      style: TextStyle(
                                                          color: primaryColor,
                                                          fontFamily:
                                                              'Poppins Regular'),
                                                    ),
                                                  ),
                                                  ListTile(
                                                    selectedTileColor:
                                                        Colors.transparent,
                                                    trailing: Text(
                                                      distances[index]
                                                              .toString() +
                                                          ' km away',
                                                      style: TextStyle(
                                                          color: primaryColor,
                                                          fontFamily:
                                                              'Poppins Regular'),
                                                    ),
                                                    title: Text(
                                                      'Condition: ${watchlistModels[index].condition}',
                                                      style: TextStyle(
                                                          color: primaryColor,
                                                          fontFamily:
                                                              'Poppins Bold',
                                                          fontSize: 13),
                                                    ),
                                                    subtitle: Text(
                                                      '${watchlistModels[index].generalLocation}',
                                                      style: TextStyle(
                                                          color: primaryColor,
                                                          fontFamily:
                                                              'Poppins Regular',
                                                          fontSize: 13),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      })),
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
