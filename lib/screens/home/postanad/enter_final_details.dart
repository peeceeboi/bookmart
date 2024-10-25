import 'package:bookmart/models/post_ad_data_model.dart';
import 'package:bookmart/screens/home/postanad/adpostsuccess.dart';
import 'package:bookmart/shared/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:groovin_widgets/groovin_widgets.dart';
import 'package:bookmart/shared/loading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:bookmart/services/database.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:provider/provider.dart';
import 'package:bookmart/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:pattern_formatter/pattern_formatter.dart';
import 'dart:math';

class EnterFinalDetails extends StatefulWidget {
  @override
  _EnterFinalDetailsState createState() => _EnterFinalDetailsState();

  String specificAdName;
  String currentTheme;
  PostAdModel currentWorkingModel;
  Function goToAdSuccess;
  bool fromProfilePage;

  EnterFinalDetails(
      {this.currentTheme,
      this.currentWorkingModel,
      this.goToAdSuccess,
      this.fromProfilePage,
      this.specificAdName});

  // String currency;
}

class _EnterFinalDetailsState extends State<EnterFinalDetails> {


  bool editedCoverImage = false;

  bool isValidPrice;
  String description = '';

  var locationMessage = '';

  List<File> _images = [];

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey();
  final titleFieldKey = GlobalKey();

  List<String> currentSubList;
  String generalAddress;

  bool otherReadOnly = true;
  bool locationProvided = false;

  String locationText;
  Color locationTextColor;
  Color locationIconColor;

  var position, lastPosition, address;

  bool loading = false;
  bool hasCoverImage = false;
  bool hasAdditionalImage = false;

  int imagesCollected = 0;

  String currentPrice = '';
  String rawPrice = '';

  bool hasPassedCoverImage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.currentWorkingModel.cover != null) {
      hasPassedCoverImage = true;
    } else {
      hasPassedCoverImage = false;
    }
    if (widget.currentWorkingModel.adLocation != null) {
      locationProvided = true;
    }
   // widget.currency = getCurrency();
  }

  TextEditingController priceController = TextEditingController(text: "");

  Future<String> getGeneralAddress() async {
    final coordinates = Coordinates(
        widget.currentWorkingModel.adLocation.latitude,
        widget.currentWorkingModel.adLocation.longitude);
    try {
      List<Address> addressLocation =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);
      print(addressLocation.toString());
      String generalLocation = addressLocation.first.locality +
          ', ' +
          addressLocation.first.adminArea +
          ', ' +
          addressLocation.first.countryName;
      return generalLocation;
    } catch (e) {
      return null;
    }
  }

  bool _isNumeric(String result) {
    if (result == null) {
      return false;
    }
    return double.tryParse(result) != null;
  }

  final checkConnectionSnackBar =
      SnackBar(content: Text('Check your internet connection and try again.'));
  final fieldsSnackBar = SnackBar(
      content:
          Text('Make sure that all fields have been filled in correctly.'));

  String userCurrency = NumberFormat.simpleCurrency(locale: Platform.localeName).currencyName;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
    // if (widget.currentWorkingModel.cover != null) {
    //   _images.add(File(widget.currentWorkingModel.cover));
    //   imagesCollected = imagesCollected + 1;
    // }

    // Future<bool> getCurrency() async {
    //   try {
    //     var record = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();
    //     userCurrency = record.data()['currency'];
    //     return true;
    //   } catch (e) {
    //     return false;
    //   }
    //
    // }
    List<String> educationList = [
      'Textbooks',
      'Study Guides',
      'Notes',
      'Other'
    ];

    List<String> fictionalGenreList = [
      'Crime / Mystery',
      'Fantasy',
      'Romance',
      'Science fiction',
      'Inspirational',
      'Horror',
      'Action / Adventure',
      'Suspense / Thriller',
      'Young Adult',
      'Historical',
      'Western',
    ];

    List<String> nonFictionalGenreList = [
      'History',
      'Biographies, autobiographies, and memoirs',
      'Travel guides and travelogues',
      'Philosophy and insight',
      'Journalism',
      'Self-help and instruction',
      'Guides and how-to manuals',
      'Humor and commentary',
    ];

    fictionalGenreList.sort((a, b) => a.toString().compareTo(b.toString()));
    fictionalGenreList.add('Other');
    nonFictionalGenreList.sort((a, b) => a.toString().compareTo(b.toString()));
    nonFictionalGenreList.add('Other');

    if (widget.currentWorkingModel.mainCategory == null) {
      widget.currentWorkingModel.mainCategory = 'Academics';
    }

    if (widget.currentWorkingModel.mainCategory == 'Academics') {
      //currentSubList = educationList;
      currentSubList = allMajors;
    }

    if (widget.currentWorkingModel.mainCategory == 'Fiction') {
      currentSubList = fictionalGenreList;
    }

    if (widget.currentWorkingModel.mainCategory == 'Non-fiction') {
      currentSubList = nonFictionalGenreList;
    }

    print(widget.currentWorkingModel.toString());

    Color primaryColor, secondaryColor;
    String imagePath;
    Gradient currentGradient;
    if (widget.currentTheme == 'Light') {
      primaryColor = Colors.white;
      secondaryColor = Colors.blueAccent;
      imagePath = 'images/book-blueAccent.png';
      currentGradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.grey[200]]);
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
          colors: [Colors.black, Colors.grey[800]]);
    }

    Future getCurrentLocation() async {
      try {
        LocationPermission permission = await Geolocator.requestPermission();
        position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium);

        //lastPosition = await Geolocator.getLastKnownPosition();

        print(
            '$position: Lat: ${position.latitude} // Long: ${position.longitude}');
        print(lastPosition);

        return position;
      } catch (e) {
        position = null;
        lastPosition = null;
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
      }
    }

    Future getAddress() async {
      final coordinates = Coordinates(position.latitude, position.longitude);
      address = await Geocoder.local.findAddressesFromCoordinates(coordinates);
      return address;
    }

    IconData locationIcon;

    if (!locationProvided) {
      locationText = 'No Location Provided';
      //locationTextColor = Colors.red;
      locationIcon = Icons.assignment_late_outlined;
      //locationIconColor = Colors.red;
      locationIconColor = secondaryColor;
      locationTextColor = secondaryColor;
    } else {
      locationText = widget.currentWorkingModel.generalLocation;
      // locationTextColor = Colors.green[400];
      locationIcon = Icons.assignment_turned_in;
      // locationIconColor = Colors.green[400];
      locationTextColor = secondaryColor;
      locationIconColor = secondaryColor;
    }

    Future getImage(bool gallery, String caller) async {
      ImagePicker picker = ImagePicker();
      PickedFile pickedFile;

      try {
        if (gallery) {
          pickedFile = await picker.getImage(
              source: ImageSource.gallery, imageQuality: 10);
        } else {
          pickedFile = await picker.getImage(
              source: ImageSource.camera, imageQuality: 10);
        }
      } catch (e) {
        print(e.toString());
        setState(() {
          loading = false;
        });
      }

      setState(() {
        if (pickedFile != null) {
          _images.add(File(pickedFile.path));
          imagesCollected = imagesCollected + 1;
          if (caller == 'Front') {
            _images[0] = File(pickedFile.path);
            // compressImage(_images[0]);
            hasCoverImage = true;
            hasPassedCoverImage = false;
            widget.currentWorkingModel.providedCover = _images[0];
          }

          // if (caller == 'Back') {
          //  _images[1] = File(pickedFile.path);
          //   hasAdditionalImage = true;
          //   widget.currentWorkingModel.providedBackCover = _images[1];
          // }

          setState(() {
            editedCoverImage = true;
            loading = false;
          });
        } else {
          print('No image selected.');
          //hasCoverImage = false;
          setState(() {
            loading = false;
          });
        }
      });
    }

    // if (widget.currentWorkingModel.rawPrice != null) {
    //   currentPrice = widget.currentWorkingModel.rawPrice.toString();
    // }

    Widget _customPopupItemBuilderExample(
        BuildContext context, String item, bool isSelected) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 8),
          decoration: !isSelected
              ? null
              : BoxDecoration(
                  border: Border.all(
                    style: BorderStyle.solid,
                    color: primaryColor,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  color: secondaryColor,
                ),
          child: ListTile(
            selected: isSelected,
            title: Center(
              child: Text(item,
                  style: TextStyle(
                      fontFamily: "Poppins Regular",
                      color: primaryColor,
                      fontSize: 15),
              textAlign: TextAlign.center,
              )
              ,

            ),
          ),
        ),
      );
    }

    Widget _noResultsFoundSpecifiedCategory(
        BuildContext context, String _addressFilteredName) {
      return Container(
          child: Center(
        child: Text(
          "No results found.",
          style: TextStyle(
            fontSize: 15,
            fontFamily: "Poppins Bold",
            color: primaryColor,
          ),
          // textAlign: TextAlign.center,
        ),
      ));
    }

    Widget _customDropDownAddress(
        BuildContext context, _addressFilteredName, String itemDesignation) {
      return Container(
          child: _addressFilteredName != null
              ? Text(_addressFilteredName.toString(),
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: "Poppins Regular",
                    color: primaryColor,
                  ))
              : Text("Specified Category",
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: "Poppins Regular",
                    color: Colors.grey[600],
                  )));
    }



    if (loading) {
      print("main load");
      return Loading(
        currentTheme: widget.currentTheme,
      );
    } else {
      if (widget.currentWorkingModel.adPosted && !widget.fromProfilePage) {
        return AdPostSuccess(
          currentTheme: widget.currentTheme,
          createdModel: widget.currentWorkingModel,
        );
      } else {
        // return FutureBuilder<bool>(
        //   future: getCurrency(),
        //   builder: (BuildContext context, AsyncSnapshot<bool> snapshot2) {
              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    // UserData userData = snapshot.data;
                    return Scaffold(
                        key: _scaffoldKey,
                        appBar: AppBar(
                          elevation: 0,
                          backgroundColor: primaryColor,
                        ),
                        body: Container(
                          decoration: BoxDecoration(
                              gradient: currentGradient, color: primaryColor),
                          child: Flex(
                            direction: Axis.vertical,
                            children: [
                              SizedBox(
                                height: 14,
                              ),
                              // Text(
                              //   'Specify further:',
                              //   style: TextStyle(
                              //       color: secondaryColor,
                              //       fontSize: 16,
                              //       fontFamily: 'Open Sans Bold'),
                              // ),
                              // TypewriterAnimatedTextKit(
                              //   textAlign: TextAlign.center,
                              //   speed: Duration(milliseconds: 40),
                              //   isRepeatingAnimation: false,
                              //   totalRepeatCount: 0,
                              //   text: [" Almost done..."],
                              //   textStyle: TextStyle(
                              //       fontSize: 16,
                              //       fontFamily: 'Open Sans Bold',
                              //       color: secondaryColor),
                              //   pause: Duration(milliseconds: 50),
                              // ),
                              // SizedBox(
                              //   height: 14,
                              // ),
                              Expanded(
                                  child: Form(
                                    key: _formKey,
                                    child: ListView(
                                      children: [
                                        SizedBox(
                                          height: 2,
                                        ),
                                        Text(
                                          'Item Name:',
                                          style: TextStyle(
                                              color: secondaryColor,
                                              fontFamily: 'Poppins Bold',
                                              fontSize: 20),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(
                                          height: 9,
                                        ),
                                        Padding(
                                          padding:
                                          const EdgeInsets.fromLTRB(10, 7, 10, 7),
                                          // fromLTRB(10, 7, 10, 7)
                                          child: TextFormField(
                                            initialValue:
                                            widget.currentWorkingModel.bookTitle,
                                            key: titleFieldKey,
                                            style:
                                            TextStyle(fontFamily: 'Poppins Regular'),
                                            decoration: textInputDecoration.copyWith(
                                                hintText: 'Item Name'),
                                            validator: (val) {
                                              if (val.isEmpty ||
                                                  val.length < 3 ||
                                                  val.length > 40) {
                                                return 'Please enter a valid title. Length should be between 3 and 40 characters.';
                                              } else {
                                                return null;
                                              }
                                            },
                                            onChanged: (val) {
                                              setState(() {
                                                widget.currentWorkingModel.bookTitle =
                                                    val.trim();
                                              });
                                            },
                                          ),
                                        ),
                                        // SizedBox(
                                        //   height: 7,
                                        // ),
                                        Divider(
                                          height: 17,
                                          color: secondaryColor,
                                        ),
                                        Text(
                                          'Author:',
                                          style: TextStyle(
                                              color: secondaryColor,
                                              fontFamily: 'Poppins Bold',
                                              fontSize: 20),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(
                                          height: 9,
                                        ),
                                        Padding(
                                          padding:
                                          const EdgeInsets.fromLTRB(10, 7, 10, 7),
                                          // fromLTRB(10, 7, 10, 7)
                                          child: TextFormField(
                                            initialValue:
                                            widget.currentWorkingModel.author,
                                            style:
                                            TextStyle(fontFamily: 'Poppins Regular'),
                                            decoration: textInputDecoration.copyWith(
                                                hintText: 'Author name'),
                                            onChanged: (val) {
                                              setState(() {
                                                widget.currentWorkingModel.author =
                                                    val.trim();
                                              });
                                            },
                                            validator: (val) {
                                              if (val.length > 20 || val.length < 3) {
                                                return 'Author needs to be less than 20 characters and more than 3 characters.';
                                              } else {
                                                return null;
                                              }
                                            },
                                          ),
                                        ),
                                        Divider(
                                          height: 17,
                                          color: secondaryColor,
                                        ),
                                        Text(
                                          'Category:',
                                          style: TextStyle(
                                              color: secondaryColor,
                                              fontFamily: 'Poppins Bold',
                                              fontSize: 20),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(
                                          height: 7,
                                        ),
                                        Padding(
                                          padding:
                                          const EdgeInsets.fromLTRB(10, 7, 10, 0),
                                          child: OutlineDropdownButtonFormField(
                                            hint: Text('Main Category'),
                                            elevation: 0,
                                            style: TextStyle(
                                                color: Colors.blueAccent,
                                                fontFamily: 'Poppins Regular'),
                                            decoration: InputDecoration(
                                              labelStyle: TextStyle(
                                                  fontFamily: 'Poppins Regular'),
                                              hintStyle: TextStyle(
                                                  fontFamily: 'Poppins Regular'),
                                              fillColor: Colors.white,
                                              filled: true,
                                              // enabledBorder:
                                              // OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 2), borderRadius: BorderRadius.all(Radius.circular(12))),
                                              focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.all(
                                                      Radius.circular(12)),
                                                  borderSide: BorderSide(
                                                    color: Colors.white,
                                                  )),
                                              border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.all(
                                                      Radius.circular(12)),
                                                  borderSide: BorderSide(
                                                    color: Colors.white,
                                                  )),
                                            ),
                                            value:
                                            widget.currentWorkingModel.mainCategory,
                                            items: [
                                              DropdownMenuItem(
                                                  value: 'Academics',
                                                  child: Text(
                                                    'Academics',
                                                    style: TextStyle(
                                                        color: primaryColor,
                                                        fontFamily: 'Poppins Regular',
                                                        fontSize: 15),
                                                  )),
                                              DropdownMenuItem(
                                                  value: 'Fiction',
                                                  child: Text(
                                                    'Fiction',
                                                    style: TextStyle(
                                                        color: primaryColor,
                                                        fontFamily: 'Poppins Regular',
                                                        fontSize: 15),
                                                  )),
                                              DropdownMenuItem(
                                                  value: 'Non-fiction',
                                                  child: Text(
                                                    'Non-fiction',
                                                    style: TextStyle(
                                                        color: primaryColor,
                                                        fontFamily: 'Poppins Regular',
                                                        fontSize: 15),
                                                  ))
                                            ],
                                            onChanged: (value) {
                                              setState(() {
                                                widget.currentWorkingModel.mainCategory =
                                                    value;
                                                widget.currentWorkingModel.subCategory =
                                                null;
                                              });
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                          const EdgeInsets.fromLTRB(10, 7, 10, 0),
                                          // child: OutlineDropdownButtonFormField(
                                          //   validator: (value) {
                                          //     if (value == null) {
                                          //       return 'Please select a specified category.';
                                          //     } else {
                                          //       return null;
                                          //     }
                                          //   },
                                          //   hint: Text('Specified Category'),
                                          //   elevation: 0,
                                          //   style: TextStyle(
                                          //       color: primaryColor,
                                          //       fontFamily: 'Poppins Regular'),
                                          //   decoration: InputDecoration(
                                          //     labelStyle:
                                          //     TextStyle(
                                          //         fontFamily: 'Poppins Regular'),
                                          //     hintStyle:
                                          //     TextStyle(
                                          //         fontFamily: 'Poppins Regular'),
                                          //     fillColor: Colors.white,
                                          //     filled: true,
                                          //     // enabledBorder:
                                          //     // OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 2), borderRadius: BorderRadius.all(Radius.circular(12))),
                                          //     focusedBorder: OutlineInputBorder(
                                          //         borderRadius:
                                          //         BorderRadius.all(
                                          //             Radius.circular(12)),
                                          //         borderSide: BorderSide(
                                          //           color: Colors.white,
                                          //         )),
                                          //     border: OutlineInputBorder(
                                          //         borderRadius:
                                          //         BorderRadius.all(
                                          //             Radius.circular(12)),
                                          //         borderSide: BorderSide(
                                          //           color: Colors.white,
                                          //         )),
                                          //   ),
                                          //   value: widget.currentWorkingModel
                                          //       .subCategory,
                                          //   items: currentSubList.map((String item) {
                                          //     return DropdownMenuItem(
                                          //         value: item,
                                          //         child: Text(
                                          //           item,
                                          //           style: TextStyle(
                                          //               color: primaryColor,
                                          //               fontFamily: 'Poppins Regular',
                                          //               fontSize: 15),
                                          //         ));
                                          //   }).toList(),
                                          //   // DropdownMenuItem(
                                          //   //     value: 'Academics',
                                          //   //     child: Text(
                                          //   //       'Academics',
                                          //   //       style: TextStyle(
                                          //   //           color: primaryColor,
                                          //   //           fontFamily: 'Open Sans Bold', fontSize: 15),
                                          //   //     )),
                                          //
                                          //   onChanged: (value) {
                                          //     setState(() {
                                          //       widget.currentWorkingModel
                                          //           .subCategory = value;
                                          //     });
                                          //   },
                                          // ),
                                          child: DropdownSearch<String>(
                                            // popupBackgroundColor: primaryColor,
                                            dropdownSearchBaseStyle: TextStyle(
                                                fontFamily: 'Poppins Regular',
                                                color: primaryColor),
                                            selectedItem:
                                            widget.currentWorkingModel.subCategory ??
                                                null,
                                            dropdownBuilder: _customDropDownAddress,
                                            emptyBuilder:
                                            _noResultsFoundSpecifiedCategory,
                                            hint: "Specified Category",
                                            popupItemBuilder:
                                            _customPopupItemBuilderExample,
                                            searchFieldProps: TextFieldProps(
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                contentPadding:
                                                EdgeInsets.fromLTRB(12, 12, 8, 0),
                                                labelText: "Search",
                                                hintStyle: TextStyle(
                                                    fontFamily: 'Poppins Regular'),
                                              ),
                                              style: TextStyle(
                                                  fontFamily: 'Poppins Regular'),
                                            ),
                                            popupShape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15))),
                                            // searchBoxDecoration: InputDecoration(
                                            //   labelStyle:
                                            //   TextStyle(
                                            //       fontFamily: 'Poppins Regular', color: Colors.black),
                                            //   hintStyle:
                                            //   TextStyle(
                                            //       fontFamily: 'Poppins Regular'),
                                            //   fillColor: Colors.white,
                                            //   filled: true,
                                            //   // enabledBorder:
                                            //   // OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 2), borderRadius: BorderRadius.all(Radius.circular(12))),
                                            //   focusedBorder: OutlineInputBorder(
                                            //       borderRadius:
                                            //       BorderRadius.all(
                                            //           Radius.circular(12)),
                                            //       borderSide: BorderSide(
                                            //         color: Colors.white,
                                            //       )),
                                            //   border: OutlineInputBorder(
                                            //       borderRadius:
                                            //       BorderRadius.all(
                                            //           Radius.circular(12)),
                                            //       borderSide: BorderSide(
                                            //         color: Colors.white,
                                            //       )),
                                            // )

                                            dropdownSearchDecoration: InputDecoration(
                                              labelStyle: TextStyle(
                                                  fontFamily: 'Poppins Regular',
                                                  fontSize: 15),
                                              hintStyle: TextStyle(
                                                  fontFamily: 'Poppins Regular',
                                                  fontSize: 15),
                                              fillColor: Colors.white,
                                              filled: true,
                                              // enabledBorder:
                                              // OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 2), borderRadius: BorderRadius.all(Radius.circular(12))),
                                              focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.all(
                                                      Radius.circular(12)),
                                                  borderSide: BorderSide(
                                                    color: Colors.white,
                                                  )),
                                              border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.all(
                                                      Radius.circular(12)),
                                                  borderSide: BorderSide(
                                                    color: Colors.white,
                                                  )),
                                            ),
                                            // popupBarrierColor: primaryColor,
                                            showSearchBox: true,
                                            mode: Mode.BOTTOM_SHEET,
                                            // items: currentSubList.map((String item) {
                                            //   return DropdownMenuItem(
                                            //       value: item.toString(),
                                            //       child: Text(
                                            //         item.toString(),
                                            //         style: TextStyle(
                                            //             color: primaryColor,
                                            //             fontFamily: 'Poppins Regular',
                                            //             fontSize: 15),
                                            //       ));
                                            // }).toList(),
                                            items: currentSubList,
                                            // items: currentSubList.map((item) => null)
                                            // currentSubList.map((e) => null)

                                            // label: "",
                                            // hint: "country in menu mode",
                                            // popupItemDisabled: (String s) => s.startsWith('I'),
                                            onChanged: (value) {
                                              setState(() {
                                                widget.currentWorkingModel.subCategory =
                                                    value;
                                              });
                                            },
                                          ),
                                        ),
                                        // SizedBox(
                                        //   height: 14,
                                        // ),
                                        Divider(
                                          height: 17,
                                          color: secondaryColor,
                                        ),
                                        Text(
                                          'Condition:',
                                          style: TextStyle(
                                              color: secondaryColor,
                                              fontFamily: 'Poppins Bold',
                                              fontSize: 20),
                                          textAlign: TextAlign.center,
                                        ),
                                        // Text(
                                        //   '(leave more info in the description)',
                                        //   style: TextStyle(
                                        //       color: secondaryColor,
                                        //       fontFamily: 'Poppins Regular',
                                        //       fontSize: 11),
                                        //   textAlign: TextAlign.center,
                                        // ),
                                        SizedBox(
                                          height: 7,
                                        ),
                                        Padding(
                                          padding:
                                          const EdgeInsets.fromLTRB(10, 7, 10, 0),
                                          child: OutlineDropdownButtonFormField(
                                            hint: Text('Condition'),
                                            elevation: 0,
                                            style: TextStyle(
                                                color: Colors.blueAccent,
                                                fontFamily: 'Poppins Regular'),
                                            decoration: InputDecoration(
                                              labelStyle: TextStyle(
                                                  fontFamily: 'Poppins Regular'),
                                              hintStyle: TextStyle(
                                                  fontFamily: 'Poppins Regular'),
                                              fillColor: Colors.white,
                                              filled: true,
                                              // enabledBorder:
                                              // OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 2), borderRadius: BorderRadius.all(Radius.circular(12))),
                                              focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.all(
                                                      Radius.circular(12)),
                                                  borderSide: BorderSide(
                                                    color: Colors.white,
                                                  )),
                                              border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.all(
                                                      Radius.circular(12)),
                                                  borderSide: BorderSide(
                                                    color: Colors.white,
                                                  )),
                                            ),
                                            value: widget.currentWorkingModel.condition,
                                            items: [
                                              DropdownMenuItem(
                                                  value: 'Brand New',
                                                  child: Text(
                                                    'Brand New',
                                                    style: TextStyle(
                                                        color: primaryColor,
                                                        fontFamily: 'Poppins Regular',
                                                        fontSize: 15),
                                                  )),
                                              DropdownMenuItem(
                                                  value: 'Good',
                                                  child: Text(
                                                    'Good',
                                                    style: TextStyle(
                                                        color: primaryColor,
                                                        fontFamily: 'Poppins Regular',
                                                        fontSize: 15),
                                                  )),
                                              DropdownMenuItem(
                                                  value: 'Fair',
                                                  child: Text(
                                                    'Fair',
                                                    style: TextStyle(
                                                        color: primaryColor,
                                                        fontFamily: 'Poppins Regular',
                                                        fontSize: 15),
                                                  )),
                                              DropdownMenuItem(
                                                  value: 'Poor',
                                                  child: Text(
                                                    'Poor',
                                                    style: TextStyle(
                                                        color: primaryColor,
                                                        fontFamily: 'Poppins Regular',
                                                        fontSize: 15),
                                                  )),
                                            ],
                                            onChanged: (value) {
                                              setState(() {
                                                widget.currentWorkingModel.condition =
                                                    value;
                                              });
                                            },
                                          ),
                                        ),
                                        Divider(
                                          height: 17,
                                          color: secondaryColor,
                                        ),
                                        Text(
                                          'Description:',
                                          style: TextStyle(
                                              color: secondaryColor,
                                              fontFamily: 'Poppins Bold',
                                              fontSize: 20),
                                          textAlign: TextAlign.center,
                                        ),

                                        SizedBox(
                                          height: 14,
                                        ),
                                        // Padding(
                                        //   key: description,
                                        //   padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                        //   child: TextField(
                                        //     decoration: textInputDecoration,
                                        //     //style: TextStyle(color: secondaryColor, fontFamily: 'Open Sans Semi Bold'),
                                        //     keyboardType: TextInputType.multiline,
                                        //     maxLines: null,
                                        //     onChanged: (value) {
                                        //       description = value;
                                        //     },
                                        //   ),
                                        // ),
                                        Padding(
                                          padding:
                                          const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                          child: TextFormField(
                                            style:
                                            TextStyle(fontFamily: 'Poppins Regular'),
                                            initialValue:
                                            widget.currentWorkingModel.description,
                                            maxLines: null,
                                            decoration: textInputDecoration.copyWith(
                                                hintText: '(not required)'),
                                            keyboardType: TextInputType.multiline,
                                            onChanged: (value) {
                                              widget.currentWorkingModel.description =
                                                  value.trim();
                                            },
                                            validator: (val) {
                                              if (val.length > 100) {
                                                return 'Description needs to be less than 100 characters.';
                                              } else {
                                                return null;
                                              }
                                            },
                                          ),
                                        ),
                                        Divider(
                                          height: 17,
                                          color: secondaryColor,
                                        ),
                                        Text(
                                          'Your Location:',
                                          style: TextStyle(
                                              color: secondaryColor,
                                              fontFamily: 'Poppins Bold',
                                              fontSize: 20),
                                          textAlign: TextAlign.center,
                                        ),

                                        SizedBox(
                                          height: 14,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(7, 0, 7, 0),
                                          child: Text(
                                            locationText,
                                            style: TextStyle(
                                                color: locationTextColor,
                                                fontFamily: 'Poppins Regular',
                                                fontSize: 16),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 7,
                                        ),
                                        Icon(
                                          locationIcon,
                                          color: locationIconColor,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                                          child: SizedBox(
                                            width: double.infinity,
                                            child: RaisedButton.icon(
                                              icon: Icon(
                                                Icons.add_location_alt_outlined,
                                                color: primaryColor,
                                              ),
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(18.0),
                                                  side:
                                                  BorderSide(color: secondaryColor)),
                                              color: secondaryColor,
                                              label: Padding(
                                                padding: EdgeInsets.all(8),
                                                child: Text(
                                                  'Provide current general location',
                                                  style: TextStyle(
                                                      color: primaryColor,
                                                      fontFamily: 'Poppins Regular',
                                                      fontSize: 15),
                                                ),
                                              ),
                                              onPressed: () async {
                                                // setState(() {
                                                //   loading = true;
                                                // });

                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) => Loading(
                                                        currentTheme:
                                                        widget.currentTheme,
                                                      )),
                                                );

                                                position = await getCurrentLocation();
                                                address = await getAddress();
                                                String savedAddress =
                                                    address.first.addressLine;
                                                print(address.first.addressLine);
                                                print(
                                                    'Country: ${address.first.countryName} , Admin Area: ${address.first.adminArea} , SubAdminArea: ${address.first.subAdminArea}');
                                                if (position == null) {
                                                  print('null position');
                                                } else {
                                                  setState(() {
                                                    widget.currentWorkingModel
                                                        .adLocation = position;
                                                    Navigator.pop(context);
                                                    locationProvided = true;
                                                    // generalAddress = address.first.locality +
                                                    //     ', ' +
                                                    //     address.first.adminArea +
                                                    //     ', ' +
                                                    //     address.first.countryName;
                                                    generalAddress =
                                                        address.first.addressLine;
                                                    print(generalAddress.indexOf(','));
                                                    generalAddress =
                                                        generalAddress.substring(
                                                            generalAddress.indexOf(',') +
                                                                2,
                                                            generalAddress.length);
                                                    widget.currentWorkingModel
                                                        .generalLocation = generalAddress;
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                        Divider(
                                          height: 17,
                                          color: secondaryColor,
                                        ),
                                        // Container(
                                        //     width: 100,
                                        //     child: Icon(Icons.cloud_upload_outlined)
                                        // ),
                                        // SizedBox(
                                        //   height: 14,
                                        // ),
                                        Text(
                                          'Cover Image:',
                                          style: TextStyle(
                                              color: secondaryColor,
                                              fontFamily: 'Poppins Bold',
                                              fontSize: 20),
                                          textAlign: TextAlign.center,
                                        ),
                                        // Padding(
                                        //     padding: const EdgeInsets.fromLTRB(3, 7, 3, 0),
                                        //     child: Center(
                                        //       child: Text(
                                        //         'Cover Image:',
                                        //         style: TextStyle(
                                        //             color: secondaryColor,
                                        //             fontSize: 17,
                                        //             fontFamily: 'Open Sans Bold'),
                                        //       ),
                                        //     )),
                                        Center(
                                          child: hasPassedCoverImage || hasCoverImage
                                              ? Container(
                                              margin: EdgeInsets.all(14),
                                              child: Image(
                                                  image: hasPassedCoverImage
                                                      ? widget
                                                      .currentWorkingModel.cover
                                                      : hasCoverImage
                                                      ? FileImage(_images[0])
                                                      : Padding(
                                                    padding:
                                                    const EdgeInsets
                                                        .fromLTRB(
                                                        16, 64, 16, 64),
                                                    child: Text(
                                                      "No image provided",
                                                      style: TextStyle(
                                                          color:
                                                          secondaryColor,
                                                          fontFamily:
                                                          "Poppins Regular",
                                                          fontSize: 14),
                                                    ),
                                                  )))
                                              : Center(
                                              child: Padding(
                                                padding: const EdgeInsets.fromLTRB(
                                                    8, 32, 8, 32),
                                                child: Text(
                                                  "No image uploaded",
                                                  style: TextStyle(
                                                      color: secondaryColor,
                                                      fontFamily: "Poppins Regular",
                                                      fontSize: 16),
                                                ),
                                              )),
                                        ),

                                        Column(
                                          children: [
                                            Padding(
                                              padding:
                                              const EdgeInsets.fromLTRB(8, 0, 8, 0),
                                              child: SizedBox(
                                                width: double.infinity,
                                                child: RaisedButton.icon(
                                                  icon: Icon(
                                                    Icons.camera_alt_outlined,
                                                    color: primaryColor,
                                                  ),
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(18.0),
                                                      side: BorderSide(
                                                          color: secondaryColor)),
                                                  color: secondaryColor,
                                                  // child: Text(
                                                  //   'Upload a cover image',
                                                  //   style: TextStyle(
                                                  //       color: primaryColor,
                                                  //       fontFamily: 'Open Sans Semi Bold',
                                                  //       fontSize: 15),
                                                  // ),
                                                  label: Text(
                                                    'Take a picture',
                                                    style: TextStyle(
                                                        color: primaryColor,
                                                        fontFamily: 'Poppins Regular',
                                                        fontSize: 15),
                                                  ),
                                                  onPressed: () async {
                                                    if (hasCoverImage) {
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
                                                                  'You have already uploaded a cover image.',
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                      'Poppins Regular',
                                                                      color:
                                                                      secondaryColor)),
                                                              actions: [
                                                                FlatButton(
                                                                    onPressed: () {
                                                                      Navigator.of(
                                                                          context,
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
                                                            ;
                                                          },
                                                          barrierDismissible: false);
                                                    } else {
                                                      // setState(() {
                                                      //   loading = true;
                                                      // });

                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) => Loading(
                                                              currentTheme:
                                                              widget.currentTheme,
                                                            )),
                                                      );

                                                      await getImage(false, 'Front');

                                                      // setState(() {
                                                      //   loading = false;
                                                      // });

                                                      Navigator.pop(context);
                                                    }
                                                  },
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                              const EdgeInsets.fromLTRB(8, 0, 8, 0),
                                              child: SizedBox(
                                                width: double.infinity,
                                                child: RaisedButton.icon(
                                                  icon: Icon(
                                                    Icons.cloud_upload_outlined,
                                                    color: primaryColor,
                                                  ),
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(18.0),
                                                      side: BorderSide(
                                                          color: secondaryColor)),
                                                  color: secondaryColor,
                                                  // child: Text(
                                                  //   'Upload a cover image',
                                                  //   style: TextStyle(
                                                  //       color: primaryColor,
                                                  //       fontFamily: 'Open Sans Semi Bold',
                                                  //       fontSize: 15),
                                                  // ),
                                                  label: Text(
                                                    'Upload a cover image',
                                                    style: TextStyle(
                                                        color: primaryColor,
                                                        fontFamily: 'Poppins Regular',
                                                        fontSize: 15),
                                                  ),
                                                  onPressed: () async {
                                                    if (hasCoverImage) {
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
                                                                  'You have already uploaded a cover image.',
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                      'Poppins Regular',
                                                                      color:
                                                                      secondaryColor)),
                                                              actions: [
                                                                FlatButton(
                                                                    onPressed: () {
                                                                      Navigator.of(
                                                                          context,
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
                                                            ;
                                                          },
                                                          barrierDismissible: false);
                                                    } else {
                                                      // setState(() {
                                                      //   loading = true;
                                                      // });

                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) => Loading(
                                                              currentTheme:
                                                              widget.currentTheme,
                                                            )),
                                                      );

                                                      await getImage(true, 'Front');

                                                      // setState(() {
                                                      //   loading = false;
                                                      // });

                                                      Navigator.pop(context);
                                                    }
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        // Divider(
                                        //   height: 2,
                                        //   color: secondaryColor,
                                        // ),
                                        // Padding(
                                        //     padding: const EdgeInsets.fromLTRB(3, 7, 3, 0),
                                        //     child: Center(
                                        //       child: Text(
                                        //         'Back Cover Image:',
                                        //         style: TextStyle(
                                        //             color: secondaryColor,
                                        //             fontSize: 17,
                                        //             fontFamily: 'Open Sans Bold'),
                                        //       ),
                                        //     )),
                                        // Padding(
                                        //   padding: const EdgeInsets.fromLTRB(120, 20, 120, 0),
                                        //   child: Container(
                                        //       width: 20,
                                        //       child: Image(
                                        //         image: hasAdditionalImage
                                        //             ? FileImage(_images[1])
                                        //             : AssetImage('images/imagenotfound.png'),
                                        //       )),
                                        // ),
                                        // Padding(
                                        //   padding: const EdgeInsets.fromLTRB(15, 5, 15, 0),
                                        //   child: Center(
                                        //     child: RaisedButton.icon(
                                        //       icon: Icon(
                                        //         Icons.cloud_upload_outlined,
                                        //         color: primaryColor,
                                        //       ),
                                        //       elevation: 0,
                                        //       shape: RoundedRectangleBorder(
                                        //           borderRadius: BorderRadius.circular(18.0),
                                        //           side: BorderSide(color: primaryColor)),
                                        //       color: secondaryColor,
                                        //       // child: Text(
                                        //       //   'Upload a cover image',
                                        //       //   style: TextStyle(
                                        //       //       color: primaryColor,
                                        //       //       fontFamily: 'Open Sans Semi Bold',
                                        //       //       fontSize: 15),
                                        //       // ),
                                        //       label: Text(
                                        //         'Upload a back cover image',
                                        //         style: TextStyle(
                                        //             color: primaryColor,
                                        //             fontFamily: 'Open Sans Semi Bold',
                                        //             fontSize: 15),
                                        //       ),
                                        //       onPressed: () async {
                                        //         if (hasAdditionalImage) {
                                        //           showDialog(
                                        //               context: context,
                                        //               builder: (_) {
                                        //                 return AlertDialog(
                                        //                   title: Center(
                                        //                       child: Text(
                                        //                     'Attention',
                                        //                     style: TextStyle(
                                        //                         fontFamily: 'Open Sans Semi Bold',
                                        //                         color: secondaryColor),
                                        //                   )),
                                        //                   content: Text(
                                        //                       'You have already uploaded a back cover image.',
                                        //                       style: TextStyle(
                                        //                           fontFamily: 'Open Sans Semi Bold',
                                        //                           color: secondaryColor)),
                                        //                   actions: [
                                        //                     FlatButton(
                                        //                         onPressed: () {
                                        //                           Navigator.of(context,
                                        //                                   rootNavigator: true)
                                        //                               .pop();
                                        //                         },
                                        //                         child: Text(
                                        //                           'Ok',
                                        //                           style: TextStyle(
                                        //                               color: secondaryColor,
                                        //                               fontFamily:
                                        //                                   'Open Sans Semi Bold'),
                                        //                         ))
                                        //                   ],
                                        //                   elevation: 24,
                                        //                   backgroundColor: primaryColor,
                                        //                   shape: RoundedRectangleBorder(
                                        //                       borderRadius: BorderRadius.all(
                                        //                           Radius.circular(20))),
                                        //                 );
                                        //                 ;
                                        //               },
                                        //               barrierDismissible: false);
                                        //         } else {
                                        //           setState(() {
                                        //             loading = true;
                                        //           });
                                        //
                                        //           await getImage(true, 'Back');
                                        //
                                        //           setState(() {
                                        //             loading = false;
                                        //           });
                                        //         }
                                        //       },
                                        //     ),
                                        //   ),
                                        // ),
                                        Divider(
                                          height: 9,
                                          color: secondaryColor,
                                        ),
                                        // Center(child: Text(
                                        //   '.', style: TextStyle(color: secondaryColor, fontFamily: 'Open Sans Semi Bold', fontSize: 15),
                                        // )),
                                        Padding(
                                            padding:
                                            const EdgeInsets.fromLTRB(3, 8, 3, 0),
                                            child: Center(
                                              child: Text(
                                                'Price:',
                                                style: TextStyle(
                                                    color: secondaryColor,
                                                    fontSize: 20,
                                                    fontFamily: 'Poppins Bold'),
                                              ),
                                            )),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(5, 8, 5, 5),
                                          child: Center(
                                            child: Text(
                                              'Currency: ${userCurrency}',
                                              style: TextStyle(
                                                  color: secondaryColor,
                                                  fontSize: 17,
                                                  fontFamily: 'Poppins Regular'),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                                          child: SizedBox(
                                            width: double.infinity,
                                            child: RaisedButton(
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(18.0),
                                                  side:
                                                      BorderSide(color: secondaryColor)),
                                              color: secondaryColor,
                                              child: Text(
                                                'Change Currency',
                                                style: TextStyle(
                                                    color: primaryColor,
                                                    fontFamily: 'Poppins Regular',
                                                    fontSize: 15),
                                              ),
                                              onPressed: () {
                                                print(currentPrice);
                                                showCurrencyPicker(
                                                  context: context,
                                                  showFlag: true,
                                                  showCurrencyName: true,
                                                  showCurrencyCode: true,
                                                  onSelect: (Currency currency) {
                                                    print(
                                                        'Select currency: ${currency.name}');
                                                    setState(() {
                                                      userCurrency = currency.code;
                                                    });
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 14,
                                        ),
                                        Padding(
                                            padding:
                                            const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                            child: TextFormField(
                                              // initialValue: currentPrice,
                                              controller: priceController,
                                              keyboardType: TextInputType.number,
                                              inputFormatters: [
                                                // CurrencyTextInputFormatter()
                                                ThousandsFormatter(allowFraction: false)
                                              ],
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontFamily: 'Poppins Regular'),
                                              decoration: textInputDecoration.copyWith(
                                                  hintText: 'Amount'),
                                              // validator: (val) {
                                              //   if (val.isEmpty) {
                                              //     // || double.tryParse(val) != null
                                              //     return 'Please enter a valid price.';
                                              //   } else {
                                              //     return null;
                                              //   }
                                              // },
                                              onChanged: (val) {
                                                if (val.isNotEmpty && val != null) {
                                                  currentPrice = val.toString();

                                                  double actualRawPrice = double.tryParse(
                                                      val.replaceAll(",", ""));

                                                  double mod = pow(10.0, 2);
                                                  actualRawPrice = ((actualRawPrice * mod)
                                                      .round()
                                                      .toDouble() /
                                                      mod);

                                                  // currentPrice = actualRawPrice.toString();
                                                  print(currentPrice);
                                                  // currentPrice =
                                                  //    val.trim().replaceAll(',', '.');

                                                  widget.currentWorkingModel.price =
                                                      userCurrency +
                                                          " " +
                                                          currentPrice;
                                                  rawPrice = val.replaceAll(",", "");
                                                  print("Raw Price: $rawPrice");
                                                  print(
                                                      "Raw Price Length: ${rawPrice.length}");
                                                  widget.currentWorkingModel.rawPrice =
                                                      actualRawPrice;
                                                  //  });

                                                  // setState(() {
                                                  // });
                                                }
                                                // setState(() {
                                              },
                                            )),
                                        // Padding(
                                        //   padding: const EdgeInsets.fromLTRB(
                                        //       10, 0, 10, 0),
                                        //   child: TextFormField(
                                        //     initialValue: currentPrice,
                                        //     // controller: priceController,
                                        //     keyboardType: TextInputType.number,
                                        //     textAlign: TextAlign.center,
                                        //     style: TextStyle(
                                        //         fontFamily: 'Poppins Regular'),
                                        //     decoration: textInputDecoration.copyWith(
                                        //         hintText: 'Amount'),
                                        //     validator: (val) {
                                        //       if (val.isEmpty) {
                                        //         // || double.tryParse(val) != null
                                        //         return 'Please enter a valid price.';
                                        //       } else {
                                        //         return null;
                                        //       }
                                        //     },
                                        //     onChanged: (val) {
                                        //
                                        //
                                        //         if (val.isNotEmpty && val != null) {
                                        //
                                        //           double actualRawPrice = double.tryParse(val);
                                        //
                                        //           currentPrice = actualRawPrice.toString();
                                        //           print(currentPrice);
                                        //          // currentPrice =
                                        //           //    val.trim().replaceAll(',', '.');
                                        //
                                        //           widget.currentWorkingModel.price =
                                        //               widget.currency + " " +
                                        //                   currentPrice;
                                        //           rawPrice =
                                        //               val.trim().replaceAll(',', '.');
                                        //
                                        //           widget.currentWorkingModel.rawPrice = actualRawPrice;
                                        //           //  });
                                        //
                                        //
                                        //           setState(() {
                                        //           });
                                        //         }
                                        //      // setState(() {
                                        //
                                        //
                                        //     },
                                        //   ),
                                        // ),
                                        Divider(
                                          height: 9,
                                          color: secondaryColor,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(8, 5, 8, 10),
                                          child: SizedBox(
                                            width: double.infinity,
                                            child: RaisedButton.icon(
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(18.0),
                                                  side:
                                                  BorderSide(color: secondaryColor)),
                                              color: secondaryColor,
                                              icon: Icon(
                                                Icons.upload_outlined,
                                                color: primaryColor,
                                              ),
                                              label: widget.fromProfilePage
                                                  ? Text(
                                                'Apply Changes',
                                                style: TextStyle(
                                                    color: primaryColor,
                                                    fontFamily: 'Poppins Regular',
                                                    fontSize: 15),
                                              )
                                                  : Text(
                                                'Publish Advertisement',
                                                style: TextStyle(
                                                    color: primaryColor,
                                                    fontFamily: 'Poppins Regular',
                                                    fontSize: 15),
                                              ),
                                              onPressed: () async {
                                                print(
                                                    'Price type: ${widget.currentWorkingModel.price.runtimeType}');

                                                // double bookPrice;
                                                // bookPrice = double.tryParse(widget.currentWorkingModel.price);
                                                //
                                                // int otherBookPrice;
                                                // otherBookPrice = int.tryParse(widget.currentWorkingModel.price);
                                                //
                                                // if (bookPrice == null && otherBookPrice == null) {
                                                //   isValidPrice = false;
                                                // } else {
                                                //   isValidPrice = true;
                                                // }
                                                String enteredTitle;
                                                String enteredAuthor;
                                                isValidPrice = true;
                                                print(isValidPrice);
                                                final filter = ProfanityFilter();
                                                bool hasProfanity1 = filter.hasProfanity(
                                                    widget.currentWorkingModel
                                                        .bookTitle ??
                                                        '');
                                                bool hasProfanity2 = filter.hasProfanity(
                                                    widget.currentWorkingModel.author ??
                                                        '');
                                                bool hasProfanity3 = filter.hasProfanity(
                                                    widget.currentWorkingModel
                                                        .description ??
                                                        '');
                                                if (hasProfanity1 ||
                                                    hasProfanity2 ||
                                                    hasProfanity3) {
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
                                                              'Profanity is not allowed.',
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
                                                } else {
                                                  int maxLength = 15;

                                                  if (rawPrice.length > maxLength) {
                                                    // exit;
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
                                                                'The maximum price length is $maxLength digits.',
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                    'Poppins Regular',
                                                                    color:
                                                                    secondaryColor)),
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
                                                  } else {
                                                    if (widget.currentWorkingModel.bookTitle != null &&
                                                        widget.currentWorkingModel
                                                            .bookTitle !=
                                                            '' &&
                                                        widget.currentWorkingModel
                                                            .author !=
                                                            '' &&
                                                        widget.currentWorkingModel.mainCategory !=
                                                            null &&
                                                        widget.currentWorkingModel.subCategory !=
                                                            null &&
                                                        (hasPassedCoverImage ||
                                                            hasCoverImage) &&
                                                        widget.currentWorkingModel
                                                            .adLocation !=
                                                            null &&
                                                        widget.currentWorkingModel.price !=
                                                            null &&
                                                        widget.currentWorkingModel
                                                            .condition !=
                                                            null &&
                                                        isValidPrice &&
                                                        widget.currentWorkingModel
                                                            .author !=
                                                            null) {
                                                      print('Starting Posting / Editing');
                                                      // double actualRawPrice = double
                                                      //     .parse(currentPrice);
                                                      // widget.currentWorkingModel.rawPrice = actualRawPrice;
                                                      if (widget.fromProfilePage ==
                                                          false) {
                                                        widget.currentWorkingModel
                                                            .generalLocation =
                                                            generalAddress;
                                                      }
                                                      setState(() {
                                                        loading = true;
                                                      });
                                                      if ((hasPassedCoverImage &&
                                                          !hasCoverImage)) {
                                                        print(
                                                            'Generating file from URL (from ISBN)');
                                                        final uri = Uri.parse(widget
                                                            .currentWorkingModel
                                                            .cover
                                                            .url);
                                                        final response =
                                                        await http.get(uri);

                                                        final documentDirectory =
                                                        await getApplicationDocumentsDirectory();

                                                        final file = File(join(
                                                            documentDirectory.path,
                                                            'image${DateTime.now().microsecond}${DateTime.now().millisecond}.png'));

                                                        file.writeAsBytesSync(
                                                            response.bodyBytes);

                                                        widget.currentWorkingModel
                                                            .providedCover = file;
                                                        print(
                                                            'Generated File for ${widget.currentWorkingModel.cover.url}');
                                                      }

                                                      // if (editedCoverImage && widget.fromProfilePage) {
                                                      //
                                                      //   print('Generating file from URL (ad edit)');
                                                      //   final response = await http.get(
                                                      //       widget.currentWorkingModel
                                                      //           .cover.url);
                                                      //
                                                      //   final documentDirectory =
                                                      //   await getApplicationDocumentsDirectory();
                                                      //
                                                      //   final file = File(join(
                                                      //       documentDirectory.path,
                                                      //       'image${DateTime
                                                      //           .now()
                                                      //           .microsecond}${DateTime
                                                      //           .now()
                                                      //           .millisecond}.png'));
                                                      //
                                                      //   file.writeAsBytesSync(
                                                      //       response.bodyBytes);
                                                      //
                                                      //   widget.currentWorkingModel
                                                      //       .providedCover =
                                                      //       file;
                                                      //   print('Generated File for ${widget.currentWorkingModel
                                                      //       .cover.url}');
                                                      //
                                                      // }

                                                      widget.currentWorkingModel
                                                          .currencySymbol =
                                                          userCurrency;

                                                      if (widget.fromProfilePage &&
                                                          editedCoverImage) {
                                                        print(
                                                            'Deleting previous picture.');
                                                        print(widget.currentWorkingModel
                                                            .imageLink);
                                                        bool result =
                                                        await DatabaseService(
                                                            uid: user.uid)
                                                            .deleteCoverImage(widget
                                                            .specificAdName);
                                                        if (result) {
                                                          print('Deletion successful.');
                                                        }
                                                      }
                                                      print('Attempting to post.');
                                                      dynamic result =
                                                      await DatabaseService(
                                                          uid: user.uid)
                                                          .addAdvertisement(
                                                          widget
                                                              .currentWorkingModel,
                                                          widget.specificAdName);

                                                      if (result == null) {
                                                        print(
                                                            'Could not post successfully.');
                                                        setState(() {
                                                          loading = false;
                                                        });

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
                                                                    'Please check your internet connection and try again.',
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                        'Poppins Regular',
                                                                        color:
                                                                        secondaryColor)),
                                                                actions: [
                                                                  FlatButton(
                                                                      onPressed: () {
                                                                        Navigator.of(
                                                                            context,
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
                                                                        Radius
                                                                            .circular(
                                                                            20))),
                                                              );
                                                            },
                                                            barrierDismissible: false);
                                                      } else {
                                                        setState(() {
                                                          widget.fromProfilePage = false;
                                                          loading = false;
                                                          widget.currentWorkingModel
                                                              .adPosted = true;
                                                          widget.currentWorkingModel
                                                              .imageLink = result;
                                                          widget.currentWorkingModel.uid =
                                                              user.uid;
                                                          //widget.goToAdSuccess(
                                                          //widget.currentWorkingModel);
                                                        });
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
                                                                        fontFamily:
                                                                        'Poppins Bold',
                                                                        color:
                                                                        secondaryColor),
                                                                  )),
                                                              content: Text(
                                                                  'Please make sure all fields have been filled in correctly.',
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                      'Poppins Regular',
                                                                      color:
                                                                      secondaryColor)),
                                                              actions: [
                                                                FlatButton(
                                                                    onPressed: () {
                                                                      Navigator.of(
                                                                          context,
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
                                                    }
                                                  }
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                            ],
                          ),
                        ));
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
}
