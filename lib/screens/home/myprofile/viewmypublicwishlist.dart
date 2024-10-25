import 'package:bookmart/models/user.dart';
import 'package:bookmart/shared/loading.dart';
import 'package:bookmart/shared/search_by_isbn_or_book_name.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:prompt_dialog/prompt_dialog.dart';
import 'package:provider/provider.dart';
import 'package:string_validator/string_validator.dart';
import 'package:books_finder/books_finder.dart';

class ViewMyPublicWishlist extends StatefulWidget {
  String currentTheme;

  ViewMyPublicWishlist({this.currentTheme});

  @override
  _ViewMyPublicWishlistState createState() => _ViewMyPublicWishlistState();
}

class _ViewMyPublicWishlistState extends State<ViewMyPublicWishlist> {
  bool loading = false;
  String userCountry;

  bool hasTitles = false;

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

    Future<List<String>> getBookNamesFromISBN(List<dynamic> wishlist) async {

      List<String> bookNames = List.generate(wishlist.length, (index) => "");

      try {

        for (int index = 0; index < wishlist.length; index++) {

            List<Book> books = await queryBooks(
            "isbn:" + wishlist[index],
            maxResults: 1,
            printType: PrintType.all,
            orderBy: OrderBy.relevance,
            reschemeImageLinks: true,
          );
          bookNames[index] = books.first.info.title;


        }

        return bookNames;


      } catch (e) {

        print(e.toString());
        return null;

      }

    }

    Future<bool> deleteFromPublishWishlist(String ISBN) async {
      try {
        final CollectionReference userCollection =
            FirebaseFirestore.instance.collection('users');
        DocumentSnapshot snapshot = await userCollection.doc(user.uid).get();
        var wishlist = snapshot.data()['publicWishlist'] ?? [];

        if (wishlist.isEmpty) {
          return false;
        } else {
          wishlist.removeWhere((element) => element == ISBN);
          await userCollection
              .doc(user.uid)
              .update({'publicWishlist': wishlist});
          return true;
        }
      } catch (e) {
        print(e.toString());
        return false;
      }
    }

    dynamic wishlist;

    Future<bool> _askedToLead(String ISBN) async {
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
                    'Remove from wish list',
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
            bool result = await deleteFromPublishWishlist(ISBN);

            setState(() {
              loading = false;
            });

            return result;
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
              DocumentSnapshot doc = snapshot.data;
              wishlist = doc.data()['publicWishlist'] ?? [];

            } else {
              return Loading(
                currentTheme: widget.currentTheme,
              );
            }
            return FutureBuilder<List<dynamic>>(
              future: getBookNamesFromISBN(wishlist),
              builder: (context, future) {
                if (future.hasData) {

                  return Scaffold(
                    appBar: AppBar(
                      actions: [
                        FlatButton.icon(
                          onPressed: () async {
                            String entry = await prompt(
                              context,
                              title: Text(
                                'Search for ISBN or book name',
                                style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 17,
                                    fontFamily: 'Poppins Bold'),
                              ),
                              //keyboardType: TextInputType.number,
                              initialValue: '',
                              textOK: Text('Ok',
                                  style: TextStyle(
                                      color: primaryColor,
                                      fontSize: 17,
                                      fontFamily: 'Poppins Regular')),
                              textCancel: Text('Cancel',
                                  style: TextStyle(
                                      color: primaryColor,
                                      fontSize: 17,
                                      fontFamily: 'Poppins Regular')),
                              hintText: '',
                              minLines: 1,
                              maxLines: 1,
                              autoFocus: false,
                              obscureText: false,
                              obscuringCharacter: '•',
                              textCapitalization: TextCapitalization.words,
                            );
                            if (entry != null) {

                              print(entry);

                              entry.trim();

                              setState(() {
                                loading = true;
                              });

                              try {
                                final List<Book> books = await queryBooks(
                                  entry,
                                  maxResults: 30,
                                  printType: PrintType.all,
                                  orderBy: OrderBy.relevance,
                                  reschemeImageLinks: true,
                                );
                                setState(() {
                                  loading = false;
                                });
                                Navigator.push(
                                  this.context,
                                  MaterialPageRoute(
                                      builder: (context) => SearchAddWishlist(
                                        currentTheme: widget.currentTheme,
                                        books: books,
                                        fromAddToWishlist: true,
                                        fromLookingFor: false,
                                      )),
                                );
                              } catch (e) {
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
                                            'Something went wrong with your search. Please check your internet connection or try again later.',
                                            style: TextStyle(
                                                fontFamily: 'Poppins Regular',
                                                color: secondaryColor)),
                                        actions: [
                                          FlatButton(
                                              onPressed: () {
                                                Navigator.of(this.context,
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
                                            borderRadius:
                                            BorderRadius.all(Radius.circular(20))),
                                      );
                                    },
                                    barrierDismissible: false);
                                setState(() {
                                  loading = false;
                                });
                                return;
                              }

                            }

                          },
                          icon: Icon(
                            Icons.search,
                            color: secondaryColor,
                          ),
                          color: primaryColor,
                          label: Text(
                            "Add by ISBN or book name",
                            style: TextStyle(
                                color: secondaryColor, fontFamily: "Poppins Bold"),
                          ),
                        ),
                      ],
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
                                    'Current wishlist:',
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
                              child: wishlist.isEmpty
                                  ? Text(
                                'You have no items on your wish list.',
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
                                  itemCount: wishlist.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                                color: secondaryColor, width: 1),
                                            borderRadius: BorderRadius.circular(10)),
                                        color: secondaryColor,
                                        elevation: 0,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(10),
                                          onTap: () async {
                                            bool result =
                                            await _askedToLead(wishlist[index]);
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
                                                          'Something went wrong.',
                                                          style: TextStyle(
                                                              fontFamily:
                                                              'Poppins Regular',
                                                              color: secondaryColor)),
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
                                                          'Book has been removed from wish list.',
                                                          style: TextStyle(
                                                              fontFamily:
                                                              'Poppins Regular',
                                                              color: secondaryColor)),
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
                                            title: Center(
                                              child: Text(
                                                future.data[index < future.data.length ? index : 0],
                                                style: TextStyle(
                                                    color: primaryColor,
                                                    fontFamily: 'Poppins Bold',
                                                    fontSize: 15),
                                              ),
                                            ),
                                            subtitle: Center(
                                              child: Text(
                                                "ISBN_13: " + wishlist[index],
                                                style: TextStyle(
                                                    color: primaryColor,
                                                    fontFamily: 'Poppins Regular',
                                                    fontSize: 15),
                                              ),
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

                  return Loading(currentTheme: widget.currentTheme,);

                }

              }
            );
          });
    }
  }
}
