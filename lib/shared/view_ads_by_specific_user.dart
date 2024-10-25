import 'package:bookmart/models/post_ad_data_model.dart';
import 'package:bookmart/services/database.dart';
import 'package:bookmart/shared/loading.dart';
import 'package:bookmart/shared/view_specific_ad.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';

class SpecificUserAds extends StatefulWidget {
  @override
  _SpecificUserAdsState createState() => _SpecificUserAdsState();

  final String currentTheme;
  final String userUID;
  final String posterName;

  SpecificUserAds({this.currentTheme, this.userUID, this.posterName});
}

class _SpecificUserAdsState extends State<SpecificUserAds> {
  bool loading = false;
  PostAdModel model;

  @override
  Widget build(BuildContext context) {
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

    if (loading) {
      return Loading(
        currentTheme: widget.currentTheme,
      );
    } else {
      return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('ads')
              .where('uid', isEqualTo: widget.userUID)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
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
                                'Ads from ${widget.posterName}',
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
                          child: snapshot.data.docs.length == 0
                              ? Text(
                                  'This user has not posted any ads.',
                                  style: TextStyle(
                                      color: secondaryColor,
                                      fontSize: 13,
                                      fontFamily: 'Poppins Bold'),
                                )
                              : null,
                        ),
                      ),
                      Expanded(
                          child: ListView.builder(
                              itemCount: snapshot.data.docs.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: secondaryColor, width: 1),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    //margin: EdgeInsets.fromLTRB(20, 6 , 20, 0),
                                    color: secondaryColor,
                                    elevation: 0,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(10),
                                      onTap: () async {
                                        GeoPoint adLocation = snapshot
                                            .data.docs[index]
                                            .data()['location'];
                                        Position newAdLocation = Position(
                                            latitude: adLocation.latitude,
                                            longitude: adLocation.longitude);
                                        model = PostAdModel(
                                            uid: snapshot.data.docs[index]
                                                .data()['uid'],
                                            uniqueName:
                                                snapshot.data.docs[index].id,
                                            mainCategory: snapshot.data.docs[index]
                                                .data()['mainCat'],
                                            subCategory: snapshot.data.docs[index]
                                                .data()['subCat'],
                                            bookTitle: snapshot.data.docs[index]
                                                .data()['title'],
                                            cover: NetworkImage(snapshot.data.docs[index]
                                                .data()['coverImage']),
                                            author: snapshot.data.docs[index]
                                                .data()['author'],
                                            dateOfPost: snapshot.data.docs[index]
                                                .data()['postDate']
                                                .toDate(),
                                            condition: snapshot.data.docs[index]
                                                .data()['condition'],
                                            description: snapshot.data.docs[index].data()['description'],
                                            adLocation: newAdLocation,
                                            adGeoPoint: snapshot.data.docs[index].data()['location'],
                                            generalLocation: snapshot.data.docs[index].data()['generalLocation'],
                                            price: snapshot.data.docs[index].data()['price'],
                                            rawPrice: snapshot.data.docs[index].data()['rawPrice'],
                                            imageLink: snapshot.data.docs[index].data()['coverImage'],
                                            adPosted: true);
                                        Position userLocation = Position(
                                            latitude: model.adGeoPoint.latitude,
                                            longitude:
                                                model.adGeoPoint.longitude);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ViewSpecificAd(
                                                currentTheme: widget.currentTheme,
                                                postAdModel: model,
                                                currentUserLocation: userLocation,
                                              )),
                                        );
                                      },
                                      child: Column(
                                        children: [
                                          ListTile(
                                            leading: CircleAvatar(
                                              radius: 30,
                                              backgroundImage: NetworkImage(
                                                  snapshot.data.docs[index]
                                                      .data()['coverImage']),
                                            ),
                                            title: Text(
                                              snapshot.data.docs[index]
                                                  .data()['title'],
                                              style: TextStyle(
                                                  color: primaryColor,
                                                  fontFamily: 'Poppins Bold',
                                                  fontSize: 15),
                                            ),
                                            subtitle: Text(
                                              'Author: ${snapshot.data.docs[index].data()['author']}',
                                              style: TextStyle(
                                                  color: primaryColor,
                                                  fontFamily:
                                                      'Poppins Regular'),
                                              textAlign: TextAlign.left,
                                            ),
                                            trailing: Text(
                                              snapshot.data.docs[index]
                                                  .data()['price'],
                                              style: TextStyle(
                                                  color: primaryColor,
                                                  fontFamily:
                                                      'Poppins Regular'),
                                            ),
                                          ),
                                          ListTile(
                                            selectedTileColor:
                                                Colors.transparent,
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
                                              'Condition: ${snapshot.data.docs[index].data()['condition']}',
                                              style: TextStyle(
                                                  color: primaryColor,
                                                  fontFamily: 'Poppins Bold',
                                                  fontSize: 13),
                                            ),
                                            subtitle: Text(
                                              '${snapshot.data.docs[index].data()['generalLocation']}',
                                              style: TextStyle(
                                                  color: primaryColor,
                                                  fontFamily: 'Poppins Regular',
                                                  fontSize: 13),
                                            ),
                                          ),
                                        ],
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
