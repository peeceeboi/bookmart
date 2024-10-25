import 'package:bookmart/models/user.dart';
import 'package:bookmart/screens/home/myprofile/viewmypublicwishlist.dart';
import 'package:bookmart/screens/home/search/buyers_by_isbn.dart';
import 'package:bookmart/shared/loading.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:string_validator/string_validator.dart';

class SearchAddWishlist extends StatefulWidget {
  @override
  _SearchAddWishlistState createState() => _SearchAddWishlistState();

  final currentTheme;
  var books;
  final fromLookingFor;
  final fromAddToWishlist;
  bool fromSearchResults;

  SearchAddWishlist({this.currentTheme, this.books, this.fromLookingFor, this
  .fromAddToWishlist, this.fromSearchResults});

}

class _SearchAddWishlistState extends State<SearchAddWishlist> {

  bool loading = false;


  String userCountry;

  @override
  Widget build(BuildContext context) {

    Color primaryColor;
    Color secondaryColor;
    Gradient currentGradient;
    var position;
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

    widget.books.removeWhere((item) => item.info.industryIdentifier.length == 0);
    widget.books.removeWhere((item) => item.info.industryIdentifier[0].toString().substring(0, 4) != "ISBN");

    Future getUserCountry() async {
      try {
        LocationPermission permission = await Geolocator.requestPermission();
        position = await Geolocator.getCurrentPosition( desiredAccuracy: LocationAccuracy.high);

        //position = widget.currentUserLocation;

        final coordinates = Coordinates(position.latitude, position.longitude);
        List<Address> addressLocation =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
        print('user country: ${addressLocation.first.countryName}');
        String userCountry = addressLocation.first.countryName;
        return userCountry;
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
        return "";
      }
    }


    Future getUserLocation() async {
      Position position;
      try {
        LocationPermission permission = await Geolocator.requestPermission();
        position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        final coordinates = Coordinates(position.latitude, position.longitude);
        List<Address> addressLocation =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
        print('user country: ${addressLocation.first.countryName}');
        userCountry = addressLocation.first.countryName;
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
                          fontFamily: 'Poppins Bold', color: secondaryColor ),
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

    if (loading) {
      return Loading(currentTheme: widget.currentTheme,);

    }  else {

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
                padding: EdgeInsets.all(20),
                child: widget.books.isEmpty
                    ? Center(
                      child: Text(
                  'No books could be found.',
                  style: TextStyle(
                        color: secondaryColor,
                        fontSize: 15,
                        fontFamily: 'Poppins Regular'),
                  textAlign: TextAlign.center,
                ),
                    )
                    : null,
              ),
              Expanded(
                flex: 1,
                  child: ListView.builder(
                      itemCount: widget.books.length,
                      itemBuilder: (BuildContext context, int index) {


                        final info = widget.books[index].info;


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
                                // print(info.imageLinks);
                                // print(info.industryIdentifier[0]);

                                if (widget.fromAddToWishlist) {
                                  String ISBN;

                                  if (info.industryIdentifier[0].toString().substring(0, 7) == "ISBN_13") {
                                    ISBN = info.industryIdentifier[0].toString().substring(8, info.industryIdentifier[0].toString().length);

                                  } else if (info.industryIdentifier[1].toString().substring(0, 7) == "ISBN_13") {
                                    ISBN = info.industryIdentifier[1].toString().substring(8, info.industryIdentifier[1].toString().length);

                                  } else {
                                    showDialog(
                                        context: this.context,
                                        builder: (_) {
                                          return AlertDialog(
                                            title: Center(
                                                child: Text(
                                                  'Attention',
                                                  style: TextStyle(
                                                      fontFamily: 'Poppins Bold', color: secondaryColor ),
                                                )),
                                            content: Text(
                                                'Something went wrong while trying to add this item. Please try again later.',
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
                                    return;
                                  }

                                  setState(() {
                                    loading = true;
                                  });

                                  dynamic position = await getUserLocation();

                                  if (position == null) {

                                    setState(() {
                                      loading = false;
                                    });

                                    return;

                                  }

                                  GeoPoint adLoc = GeoPoint(position.latitude,position.longitude);



                                  // DatabaseService database = DatabaseService(uid: user.uid);
                                  // bool result = await database.addToPublicWishlist(entry);
                                  bool result = false;
                                  CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

                                  try {
                                    DocumentSnapshot snapshot = await userCollection.doc(user.uid).get();
                                    List<dynamic> wishlist = snapshot.data()['publicWishlist'] ?? [];
                                    bool exists = false;
                                    if (wishlist.isEmpty) {
                                      List<String> list = [ISBN];
                                      wishlist = list;
                                      exists = false;
                                    } else {
                                      for (int index = 0; index < wishlist.length; index++) {
                                        if (wishlist[index] == ISBN) {
                                          exists = true;
                                          break;
                                        }
                                      }
                                      wishlist.add(ISBN);
                                    }


                                    if (exists) {
                                      result = false;
                                    } else {

                                      await userCollection.doc(user.uid).update({
                                        'publicWishlist' : wishlist,
                                        'lastKnownLocation' : adLoc,
                                        'lastCountry' : userCountry
                                      });
                                      result = true;

                                    }


                                  } catch (e) {
                                    print(e.toString());
                                    result = false;

                                  }

                                  setState(() {
                                    loading = false;
                                  });

                                  if (result) {

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
                                                'ISBN number added. Sellers will now be able to find you if they have your item for sale.',
                                                style: TextStyle(
                                                    fontFamily: 'Poppins Regular',
                                                    color: secondaryColor)),
                                            actions: [
                                              FlatButton(
                                                  onPressed: () {
                                                    bool temp = widget.fromSearchResults ?? false;
                                                    if (temp) {
                                                      Navigator
                                                          .of(
                                                          this.context,
                                                          rootNavigator: true)
                                                          .pop();
                                                    } else {
                                                      Navigator.of(this.context).popUntil((route) => route.isFirst);
                                                      Navigator.push(
                                                        this.context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                ViewMyPublicWishlist(
                                                                  currentTheme: widget
                                                                      .currentTheme,
                                                                )),
                                                      );
                                                    }


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
                                                'This item is already on your wishlist.',
                                                style: TextStyle(
                                                    fontFamily: 'Poppins Regular',
                                                    color: secondaryColor)),
                                            actions: [
                                              FlatButton(
                                                  onPressed: () {
                                                    Navigator
                                                        .of(
                                                        this.context,
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


                                } else if (widget.fromLookingFor) {

                                  print("Looking for buyers looking for this book");
                                  String ISBN = "";
                                  if (info.industryIdentifier[0].toString().substring(0, 7) == "ISBN_13") {
                                    ISBN = info.industryIdentifier[0].toString().substring(8, info.industryIdentifier[0].toString().length);

                                  } else if (info.industryIdentifier[1].toString().substring(0, 7) == "ISBN_13") {
                                    ISBN = info.industryIdentifier[1].toString().substring(8, info.industryIdentifier[1].toString().length);

                                  }

                                  print(ISBN);

                                  bool match = isISBN(ISBN);

                                  if (match) {

                                    setState(() {
                                      loading = true;
                                    });

                                    // if (entry.length == 10) {
                                    //   print("awe");
                                    //   entry = ISBN10toISBN13(entry);
                                    //   print(entry);
                                    // }


                                    print("Getting Country");
                                    String userCountry = await getUserCountry();

                                    if (userCountry != "" && position != null) {

                                      setState(() {
                                        loading = false;
                                      });

                                      Navigator.push(
                                        this.context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                BuyersByISBN(
                                                  currentTheme: widget
                                                      .currentTheme,
                                                  ISBN: ISBN,
                                                  userCountry: userCountry,
                                                  userPosition: position,
                                                )),
                                      );

                                    } else {

                                      setState(() {
                                        loading = false;
                                      });

                                    }



                                   } else {
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
                                                'The ISBN number you have entered is not valid.',
                                                style: TextStyle(
                                                    fontFamily: 'Poppins Regular',
                                                    color: secondaryColor)),
                                            actions: [
                                              FlatButton(
                                                  onPressed: () {
                                                    Navigator
                                                        .of(
                                                        this.context,
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
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: info.imageLinks['thumbnail'] != null ? CachedNetworkImage(imageUrl: info.imageLinks['thumbnail'].toString(), width: 100, height: 100, placeholder: (context, url) {
                                      return Loading(currentTheme: widget.currentTheme,);
                                    },) : null,
                                    title: info.title.isNotEmpty ? Text(
                                      info.title,
                                      style: TextStyle(
                                          color: primaryColor,
                                          fontFamily: 'Poppins Bold',
                                          fontSize: 15),
                                    ) : Text(
                                      'No title found',
                                      style: TextStyle(
                                          color: primaryColor,
                                          fontFamily: 'Poppins Bold',
                                          fontSize: 15),
                                    ),
                                    subtitle: info.authors.isNotEmpty ? Text(
                                      'Author: ' + info.authors[0],
                                      style: TextStyle(
                                          color: primaryColor,
                                          fontFamily: 'Poppins Regular',
                                          fontSize: 15),
                                    ) : Text(
                                      'Author: Unknown',
                                      style: TextStyle(
                                          color: primaryColor,
                                          fontFamily: 'Poppins Regular',
                                          fontSize: 15),
                                    ),
                                    // trailing:
                                    //
                                    //
                                    //   CachedNetworkImage(imageUrl: info.imageLinks['thumbnail'].toString(), width: 100, height: 100, placeholder: (context, url) {
                                    //       return Loading(currentTheme: widget.currentTheme,);
                                    //     },),

                                  ),
                                  ListTile(
                                    title: info.industryIdentifier.length > 0 ? Text(
                                      info.industryIdentifier[0].toString(),
                                      style: TextStyle(
                                          color: primaryColor,
                                          fontFamily: 'Poppins Regular',
                                          fontSize: 15),
                                    ) : null,
                                    subtitle:  info.industryIdentifier.length > 1 ? Text(
                                      info.industryIdentifier[1].toString(),
                                      style: TextStyle(
                                          color: primaryColor,
                                          fontFamily: 'Poppins Regular',
                                          fontSize: 15),
                                    ) : null,
                                    // leading:Text(
                                    //   info.industryIdentifier[1].toString(),
                                    //   style: TextStyle(
                                    //       color: primaryColor,
                                    //       fontFamily: 'Poppins Regular',
                                    //       fontSize: 15),
                                    // ) ,
                                    // trailing: Container(
                                    //     width: 100,
                                    //     height: 100,
                                    //     child: CachedNetworkImage(imageUrl: info.imageLinks['thumbnail'].toString(), width: 100, height: 100, placeholder: (context, url) {
                                    //       return Loading(currentTheme: widget.currentTheme,);
                                    //     },)
                                    // ),
                                  ),
                                  // CachedNetworkImage(imageUrl: info.imageLinks['thumbnail'].toString(), width: 150, height: 150, placeholder: (context, url) {
                                  //   return Loading(currentTheme: widget.currentTheme,);
                                  // },),
                                ],
                              ),
                            ),
                          ),
                        );
                      }))
            ]
        ))
      );


    }

  }
}
