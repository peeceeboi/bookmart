import 'dart:math';
import 'package:algolia/algolia.dart';
import 'package:bookmart/models/autogenjsondartbooks.dart';
import 'package:bookmart/models/post_ad_data_model.dart';
import 'package:bookmart/models/user.dart';
import 'package:bookmart/screens/authenticate/verify_email.dart';
import 'package:bookmart/screens/home/chat/chat.dart';
import 'package:bookmart/screens/home/postanad/enter_final_details.dart';
import 'package:bookmart/screens/home/postanad/publishfictionbooks.dart';
import 'package:bookmart/screens/home/postanad/publishotherbooks.dart';
import 'package:bookmart/screens/home/search/search_home_screen.dart';
import 'package:bookmart/screens/home/search/search_results.dart';
import 'package:bookmart/screens/home/search/select_category.dart';
import 'package:bookmart/shared/view_specific_ad.dart';
import 'package:bookmart/services/auth.dart';
import 'package:bookmart/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'myprofile/my_profile.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'postanad/post_an_ad.dart';
import 'postanad/publisheducation.dart';
import 'postanad/isbn_fetch_window.dart';
import 'postanad/publishnonfictionbooks.dart';
import 'postanad/adpostsuccess.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:bookmart/ad_helper.dart';

final AuthService _auth = AuthService();

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
  String currentTheme;

  Home({this.currentTheme});
}

class _HomeState extends State<Home> {
  //final AuthService _auth = AuthService();
  String nameOfAdBeingViewed;
  Color primaryColor;
  Color secondaryColor;

  int _currentIndex = 0;

  double userBalance;
  String userCurrency;

  final tabTitles = [
    'Home',
    'Chat',
    'Post an Ad',
    'My Profile',
    'Publish Educational Books:',
    'We found your book.',
    'Publish Literature',
    'Publish Fictional Books',
    'Publish Non-fiction',
    'Almost done',
    'Success',
    'Select a Category',
    'Search Results',
    'View Specific Ad'
  ];

  bool emailVerified = _auth.emailVerified();

  var position;

  //emailVerified = _auth.user.

  BannerAd _ad;
  bool _isAdLoaded = false;

  final pressAgain = SnackBar(
      content: Text('Press the button again to ch.',
          style:
              TextStyle(color: Colors.white, fontFamily: 'Poppins Regular')));


  Future getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      //lastPosition = await Geolocator.getLastKnownPosition();

      print(
          '$position: Lat: ${position.latitude} // Long: ${position.longitude}');

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
                          color: secondaryColor, fontFamily: 'Poppins Regular'),
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

  // variables that are passed:

  BookFromApi requestedBook;
  PostAdModel currentWorkingModel; // For post an ad section
  String searchCategorySelected;
  List<AlgoliaObjectSnapshot> currentSearchResults;
  var userCurrentPosition;
  QuerySnapshot adsSnapshot;
  String currentUserCountry;
  AlgoliaObjectSnapshot currentAdBeingViewed;

  ////////////////////////////

  @override
  void initState() {
    //final auth = AuthService();
    //auth.signOut();
    // TODO: implement initState
    super.initState();
    // position = getCurrentLocation();
    _ad = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.banner,
      request: AdRequest(),
      listener: AdListener(
        onAdLoaded: (_) {
          //  setState(() {
          //  print('Banner ad ready');
          _isAdLoaded = true;
          //  });
        },
        onAdFailedToLoad: (ad, error) {
          // Releases an ad resource when it fails to load
          ad.dispose();

          print('Ad load failed (code=${error.code} message=${error.message})');
        },
      ),
    );

    // TODO: Load an ad
    _ad.load();
  }

  bool loading = false;

  // bool userHasCurrency;


  // String selectedCurrency;


  double truncateToDecimalPlaces(num value, int fractionalDigits) =>
      (value * pow(10, fractionalDigits)).truncate() /
      pow(10, fractionalDigits);



  @override
  Widget build(BuildContext context) {
    print("WIDGET TREE CALLED");

    final user = Provider.of<CustomUser>(context);




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
      imagePath = 'images/Bookmart Icon-128x128.png';
      currentGradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.lightBlue[300], Colors.blue[700]]);
    }

    if (widget.currentTheme == 'Dark') {
      primaryColor = Colors.black;
      secondaryColor = Colors.grey[350];
      imagePath = 'images/Bookmart Icon-128x128.png';
      currentGradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, Colors.grey[800]]);
    }

    print('Home: ' + widget.currentTheme);

    void goToHomeSearch(String category) {
      // Home Screen

      searchCategorySelected = category;

      setState(() {
        _currentIndex = 0;
      });
    }

    void goToPostAnAd() {
      // Post Ad Screen
      setState(() {
        _currentIndex = 2;
      });
    }

    void goToEducation(PostAdModel currentAdModel) {
      // Academics screen
      currentWorkingModel = currentAdModel;
      setState(() {
        _currentIndex = 4;
      });
    }

    void goToISBNFetch(BookFromApi book) {
      // ISBN Fetch Screen
      requestedBook = book;
      setState(() {
        _currentIndex = 5;
      });
    }

    void goToOtherBooks(PostAdModel currentModel) {
      // Fiction and Non-fiction button screen

      currentWorkingModel = currentModel;

      setState(() {
        _currentIndex = 6;
      });
    }

    void goToFiction(PostAdModel currentModel) {
      // Fiction Screen

      currentWorkingModel = currentModel;

      setState(() {
        _currentIndex = 7;
      });
    }

    void goToNonFiction(PostAdModel currentModel) {
      // Non-Fiction Screen

      currentWorkingModel = currentModel;

      setState(() {
        _currentIndex = 8;
      });
    }

    void goToFinalDetails(PostAdModel currentModel) {
      // Final Details Screen

      currentWorkingModel = currentModel;

      setState(() {
        _currentIndex = 9;
      });
    }

    void goToAdSuccess(PostAdModel currentModel) {
      // Ad Success Screen
      currentWorkingModel = currentModel;
      setState(() {
        _currentIndex = 10;
      });
    }

    void goToCategorySelect() {
      // Select Category for Search

      setState(() {
        _currentIndex = 11;
      });
    }

    void goToSearchResults(List<AlgoliaObjectSnapshot> searchResults,
        var currentPosition, String currentCategory, String userCountry) async {
      // Search Results Screen
      CollectionReference ads = FirebaseFirestore.instance.collection('ads');
      currentUserCountry = userCountry;
      userCurrentPosition = currentPosition;
      currentSearchResults = searchResults;
      setState(() {
        _currentIndex = 12;
      });
    }

    void viewSpecificAd(AlgoliaObjectSnapshot model) {
      currentAdBeingViewed = model;

      setState(() {
        _currentIndex = 13;
      });
    }



    final tabs = [
      SearchScreen(
        currentTheme: widget.currentTheme,
        goToCategorySelect: goToCategorySelect,
        categorySelected: searchCategorySelected,
        goToSearchResults: goToSearchResults,
        currentUserLocation: position,
      ),
      Chat(
        currentTheme: widget.currentTheme,
      ),
      PostAnAd(
        currentTheme: widget.currentTheme,
        goToEducation: goToEducation,
        goToISBNFetch: goToISBNFetch,
        goToOtherBooks: goToOtherBooks,
      ),
      MyProfile(
        currentTheme: widget.currentTheme,
      ),
      // Additional Tabs
      PublishEducation(
        currentTheme: widget.currentTheme,
        currentWorkingModel: currentWorkingModel,
        goToFinalDetails: goToFinalDetails,
      ),
      ISBNFetch(
        currentTheme: widget.currentTheme,
        goToPostAnAd: goToPostAnAd,
        goToFinalDetails: goToFinalDetails,
      ),
      PublishOtherBooks(
        currentTheme: widget.currentTheme,
        goToFiction: goToFiction,
        goToNonFiction: goToNonFiction,
        currentWorkingModel: currentWorkingModel,
      ),
      PublishFiction(
        currentTheme: widget.currentTheme,
        currentWorkingModel: currentWorkingModel,
        goToFinalDetails: goToFinalDetails,
      ),
      PublishNonFiction(
          currentTheme: widget.currentTheme,
          currentWorkingModel: currentWorkingModel,
          goToFinalDetails: goToFinalDetails),
      EnterFinalDetails(
        currentTheme: widget.currentTheme,
        currentWorkingModel: currentWorkingModel,
        goToAdSuccess: goToAdSuccess,
      ),
      AdPostSuccess(
          goToHomeSearch: goToHomeSearch,
          currentTheme: widget.currentTheme,
          createdModel: currentWorkingModel),
      SelectCategory(
        currentTheme: widget.currentTheme,
        goHomeFromCategorySelect: goToHomeSearch,
      ),
      SearchResults(
        viewSpecificAd: viewSpecificAd,
        goToHomeSearch: goToHomeSearch,
        currentTheme: widget.currentTheme,
        searchResults: currentSearchResults,
        userLocation: userCurrentPosition,
        currentCategory: searchCategorySelected,
        currentUserCountry: currentUserCountry,
      ),
      ViewSpecificAd(
        model: currentAdBeingViewed,
        currentTheme: widget.currentTheme,
      )
    ];

    void pay() {
      showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Center(
                  child: Text(
                'What would you like to do?',
                style: TextStyle(
                    fontFamily: 'Poppins Bold', color: secondaryColor),
              )),
              content: Column(
                children: [
                  ElevatedButton.icon(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(primaryColor)),
                    onPressed: () {
                      pay();
                    },
                    icon: Icon(
                      Icons.upload_outlined,
                      color: secondaryColor,
                    ),
                    label: Text(
                      'Deposit',
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins Regular',
                          color: primaryColor),
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(secondaryColor)),
                    onPressed: () {
                      pay();
                    },
                    icon: Icon(
                      Icons.download_outlined,
                      color: primaryColor,
                    ),
                    label: Text(
                      'Withdraw',
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins Regular',
                          color: secondaryColor),
                    ),
                  ),
                ],
              ),
              // actions: [
              //   FlatButton(
              //       onPressed: () {
              //         Navigator.of(
              //             context,
              //             rootNavigator:
              //             true)
              //             .pop();
              //       },
              //       child: Text(
              //         'Ok',
              //         style: TextStyle(
              //             color:
              //             secondaryColor,
              //             fontFamily:
              //             'Poppins Regular'),
              //       ))
              // ],
              elevation: 24,
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20))),
            );
          },
          barrierDismissible: true);
    }

    if (emailVerified == null) {
      emailVerified = false;
    }

    if (emailVerified == true) {
      if (loading) {
        return Loading(
          currentTheme: widget.currentTheme,
        );
        //bool userRegistered = await DatabaseService().userFullyRegistered();
      } else {
        return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.exists) {
                  // userCurrency = snapshot.data.data()['currency'] ??

                  userBalance =
                      ((snapshot.data.data()['balance'] ?? 0) * 1.0) ??
                          (0 * 1.0);
                  //
                  // if (snapshot.data.data()['currency'] == null) {
                  //   userHasCurrency = false;
                  // } else {
                  //   userHasCurrency = true;
                  // }
                  //
                  // print("stage 2");
                  print("GONE FROM HOME.dart");
                  return Scaffold(
                    bottomNavigationBar: Container(
                      color: primaryColor,
                      child: Center(child: AdWidget(ad: _ad)),
                      width: _ad.size.width.toDouble(),
                      height: _ad.size.height.toDouble(),
                      alignment: Alignment.center,
                    ),
                    body: Scaffold(
                      bottomNavigationBar: CurvedNavigationBar(
                        animationDuration:
                        Duration(milliseconds: 150),
                        animationCurve: Curves.decelerate,
                        color: primaryColor,
                        items: <Widget>[
                          Icon(
                            Icons.shopping_cart,
                            color: secondaryColor,
                          ),
                          Icon(
                            Icons.chat,
                            color: secondaryColor,
                          ),
                          Icon(
                            Icons.create,
                            color: secondaryColor,
                          ),
                          Icon(Icons.person, color: secondaryColor),
                          // Icons.
                        ],
                        onTap: (index) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                        backgroundColor: secondaryColor,
                      ),
                      appBar: AppBar(
                        title: Center(
                          child: Row(
                            children: [
                              Container(
                                  alignment: Alignment.center,
                                  child: Image(
                                      filterQuality:
                                      FilterQuality.high,
                                      image: ResizeImage(
                                          AssetImage(
                                              'images/Bookmart Icon-32x32.png'),
                                          width: 32,
                                          height: 32),
                                      fit: BoxFit.scaleDown)),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  tabTitles[_currentIndex],
                                  style: TextStyle(
                                      fontFamily: 'Poppins Bold',
                                      fontSize: 30,
                                      color: secondaryColor),
                                ),
                              ),

                              // Text(
                              //   "Balance:",
                              //   textAlign: TextAlign.right,
                              //   style: TextStyle(
                              //       fontFamily: 'Poppins Regular',
                              //       fontSize: 20,
                              //       color: secondaryColor),
                              // ),
                            ],
                          ),
                        ),
                        actions: [

                        ],
                        elevation: 0,
                        backgroundColor: primaryColor,
                      ),
                      body: Container(
                        // decoration: BoxDecoration(
                        //     gradient: LinearGradient(
                        //         begin: Alignment.topRight,
                        //         end: Alignment.bottomLeft,
                        //         colors: [Colors.lightBlue[300], Colors.deepPurpleAccent])
                        // ),
                        decoration: BoxDecoration(
                            color: primaryColor,
                            gradient: currentGradient),
                        child: tabs[_currentIndex],
                      ),
                    ),
                  );
                } else {
                  return Loading(
                    currentTheme: 'Blue',
                  );
                }
              } else {
                return Loading(
                  currentTheme: widget.currentTheme,
                );
              }
              // } else {
              //   return Loading(
              //     currentTheme: widget.currentTheme,
              //   );
              // }
            });
      }
    } else if (emailVerified == null)
      return Loading(
        currentTheme: widget.currentTheme,
      );
    else {
      return VerifyEmail(
        currentTheme: widget.currentTheme,
      );
    }
  }
}
