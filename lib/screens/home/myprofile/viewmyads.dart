import 'package:bookmart/main.dart';
import 'package:bookmart/models/post_ad_data_model.dart';
import 'package:bookmart/models/user.dart';
import 'package:bookmart/screens/home/postanad/enter_final_details.dart';
import 'package:bookmart/services/database.dart';
import 'package:bookmart/shared/loading.dart';
import 'package:bookmart/shared/view_specific_ad.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class ViewMyAds extends StatefulWidget {
  @override
  _ViewMyAdsState createState() => _ViewMyAdsState();

  final String currentTheme;

  ViewMyAds({this.currentTheme});
}

class _ViewMyAdsState extends State<ViewMyAds> {
  bool loading = false;
  PostAdModel model;

  @override
  Widget build(BuildContext context) {
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

    final user = Provider.of<CustomUser>(context);
    final adDeletedSnackbar = SnackBar(content: Text('Advertisement has been deleted.'));

    Future<String> _askedToLead(String specificIndex, DocumentReference documentReference) async {
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
                'Manage Ad',
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
                    Navigator.pop(context, 'Edit');
                  },
                  child: Text(
                    'Edit',
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
                    'Delete',
                    style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Poppins Regular',
                        color: secondaryColor),
                  ),
                ),
              ],
            );
          })) {
        case 'Edit':
          {

            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EnterFinalDetails(
                    currentTheme: widget.currentTheme,
                    currentWorkingModel: model,
                    fromProfilePage: true,
                    specificAdName: specificIndex,
                  )),
            );

          }
          break;

        case 'View':
          {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ViewSpecificAd(
                        currentTheme: widget.currentTheme,
                        postAdModel: model,
                        currentUserLocation: null,
                      )),
            );
          }
          break;

        case 'Delete':
          {

            print('Deleting Ad.');
            try {
              await documentReference.delete();
              print('DELETING: $specificIndex');
              bool result = await DatabaseService(uid: user.uid).deleteCoverImage(specificIndex);
              if (result) {

                showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        title: Center(child: Text(
                          'Attention', style: TextStyle(
                            fontFamily: 'Poppins Bold',
                            color: secondaryColor),)),
                        content: Text(
                            'Your advertisement has been deleted.',
                            style: TextStyle(
                                fontFamily: 'Poppins Regular',
                                color: secondaryColor)),
                        actions: [
                          FlatButton(onPressed: () {
                            Navigator.of(context,
                                rootNavigator: true)
                                .pop();
                          },
                              child: Text('Ok',
                                style: TextStyle(
                                    color: secondaryColor,
                                    fontFamily: 'Poppins Regular'),))
                        ],
                        elevation: 24,
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius
                                .all(
                                Radius.circular(20)
                            )
                        ),
                      );
                    },
                    barrierDismissible: false
                );

              }
            } catch (e) {
              print(e);
              print('Could not delete ad successfully.');
            }

          }
          // ...
          break;
      }
    }

    if (loading) {
      return Loading(currentTheme: widget.currentTheme);
    } else {
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('ads')
            .where('uid', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<DocumentSnapshot> adList = snapshot.data.docs;
            List<DocumentSnapshot> searchList = snapshot.data.docs;
            List<String> specificNames = List.generate(adList.length, (index) => null);
            for (int index = 0; index <=specificNames.length - 1; index++) {
              specificNames[index] = adList[index].id;
              print(specificNames[index]);
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
                              'Active Ads:',
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
                        child: searchList.length == 0 ? Text(
                          'You have not published any ads.',
                          style: TextStyle(
                              color: secondaryColor,
                              fontSize: 13,
                              fontFamily: 'Poppins Regular'),
                        ) : null,
                      ),
                    ),
                    Expanded(
                        child: ListView.builder(
                            itemCount: searchList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                      side: BorderSide(color: secondaryColor, width: 1),
                                      borderRadius: BorderRadius.circular(10)),
                                  //margin: EdgeInsets.fromLTRB(20, 6 , 20, 0),
                                  color: secondaryColor,
                                  elevation: 0,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(10),
                                    onTap: () async {
                                      GeoPoint adLocation =
                                          searchList[index].data()['location'];
                                      Position newAdLocation = Position(
                                          latitude: adLocation.latitude,
                                          longitude: adLocation.longitude);
                                      model = PostAdModel(
                                        uid: searchList[index].data()['uid'],
                                          uniqueName: searchList[index].id,
                                          mainCategory: searchList[index]
                                              .data()['mainCat'],
                                          subCategory: searchList[index]
                                              .data()['subCat'],
                                          bookTitle:
                                              searchList[index].data()['title'],
                                          cover: NetworkImage(searchList[index]
                                              .data()['coverImage']),
                                          author: searchList[index]
                                              .data()['author'],
                                          dateOfPost: searchList[index]
                                              .data()['postDate']
                                              .toDate(),
                                          postDate: searchList[index]
                                              .data()['postDate']
                                              .toDate(),
                                          condition: searchList[index]
                                              .data()['condition'],
                                          description: searchList[index]
                                              .data()['description'],
                                          adLocation: newAdLocation,
                                          adGeoPoint: searchList[index]
                                              .data()['location'],
                                          generalLocation: searchList[index]
                                              .data()['generalLocation'],
                                          price:
                                              searchList[index].data()['price'],
                                          rawPrice: searchList[index].data()['rawPrice'],
                                          imageLink: searchList[index]
                                              .data()['coverImage'],
                                          adPosted: true);
                                      Position userLocation = Position(
                                          latitude: model.adGeoPoint.latitude,
                                          longitude:
                                              model.adGeoPoint.longitude);
                                      // widget.viewSpecificAd(model);
                                      //widget.viewSpecificAd(widget.searchResults[index]);
                                      DocumentReference ref = FirebaseFirestore.instance.collection('ads').doc(specificNames[index]);
                                      await _askedToLead(specificNames[index], ref);
                                    },
                                    child: Column(
                                      children: [
                                        ListTile(
                                          leading: CircleAvatar(
                                            radius: 30,
                                            backgroundImage: NetworkImage(
                                                searchList[index]
                                                    .data()['coverImage']),
                                          ),
                                          title: Text(
                                            searchList[index].data()['title'],
                                            style: TextStyle(
                                                color: primaryColor,
                                                fontFamily: 'Poppins Bold',
                                                fontSize: 15),
                                          ),
                                          subtitle: Text(
                                            'Author: ${searchList[index].data()['author']}',
                                            style: TextStyle(
                                                color: primaryColor,
                                                fontFamily: 'Poppins Regular'),
                                            textAlign: TextAlign.left,
                                          ),
                                          trailing: Text(
                                            searchList[index].data()['price'],
                                            style: TextStyle(
                                                color: primaryColor,
                                                fontFamily: 'Poppins Regular'),
                                          ),
                                        ),
                                        ListTile(
                                          selectedTileColor: Colors.transparent,
                                          title: Text(
                                            'Condition: ${searchList[index].data()['condition']}',
                                            style: TextStyle(
                                                color: primaryColor,
                                                fontFamily: 'Poppins Bold',
                                                fontSize: 13),
                                          ),
                                          subtitle: Text(
                                            '${searchList[index].data()['generalLocation']}',
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
        },
      );
    }
  }
}
