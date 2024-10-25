import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:bookmart/shared/confirmation_dialog.dart';
import 'package:bookmart/shared/start_withdrawal.dart';
import 'package:flutter/foundation.dart';
import 'package:forex_conversion/forex_conversion.dart';
import 'package:intl/intl.dart';
import 'package:algolia/algolia.dart';
import 'package:bookmart/models/user.dart';
import 'package:bookmart/screens/home/search/select_category.dart';
import 'package:bookmart/screens/home/search/test.dart';
import 'package:bookmart/shared/constants.dart';
import 'package:bookmart/shared/deposit_amount.dart';
import 'package:bookmart/shared/enter_phone_number.dart';
import 'package:bookmart/shared/loading.dart';
import 'package:bookmart/shared/search_by_isbn_or_book_name.dart';
import 'package:bookmart/shared/view_specific_ad.dart';
import 'package:books_finder/books_finder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:bookmart/services/database.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:phone_number/phone_number.dart';
import 'package:prompt_dialog/prompt_dialog.dart';
import 'package:provider/provider.dart';
import 'package:geocoder/geocoder.dart';
import 'package:bookmart/ad_helper.dart';
import 'package:show_up_animation/show_up_animation.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:http/http.dart' as http;

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();

  final currentUserLocation;
  final String currentTheme;
  final Function goToCategorySelect;
  final Function goToSearchResults;
  String categorySelected;

  SearchScreen(
      {this.currentTheme,
      this.goToCategorySelect,
      this.categorySelected,
      this.goToSearchResults,
      this.currentUserLocation});
}

class _SearchScreenState extends State<SearchScreen> {
  bool loading = false;
  String searchQuery = '';
  bool searchingForMainCategory, searchingForSubCategory;
  var position;
  InterstitialAd _interstitialAd;
  bool _isInterstitialAdReady = false;
  Color primaryColor = Colors.blueAccent;
  Color secondaryColor = Colors.white;
  String userCurrentCountry;
  List<String> receivedBanks;
  List<Widget> bankTexts = [];
  Map<String, dynamic> respMap;
  bool balanceTestMode = false;

  void _loadInterstitialAd() {
    _interstitialAd.load();
  }

  // AdListener _onInterstitialAdEvent;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  bool hasSearchResults = false;

  List<AlgoliaObjectSnapshot> searchResults;

  String selectedCurrency;

  Future<bool> verifyTransaction(String transactionID) async {
    print("VERIFYING TRANSACTION");

    try {
      Map<String, String> userHeader = {
        "Content-Type": "application/json",
        "Accept": "application/json"
      };

      var body = json.encode({
        "txref": transactionID,
        "SECKEY": balanceTestMode
            ? ""
            : "",
      });

      Uri url =
          Uri.parse("https://api.ravepay.co/flwv3-pug/getpaidx/api/v2/verify");
      http.Response resp =
          await http.post(url, headers: userHeader, body: body);
      print("BODY: " + resp.body);

      var jsonBodyResp = jsonDecode(resp.body);

      if (jsonBodyResp != null) {
        if (jsonBodyResp['message'] == 'Tx Fetched') {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<List<String>> availableSouthAfricanBanksForWithdrawal() async {
    Map<String, String> userHeader = {
      "Content-Type": "application/json",
      "Accept": "application/json"
    };
    Uri url = Uri.parse("https://api.ravepay.co/v2/banks/ZA?public_key=" +
        (balanceTestMode
            ? ""
            : ""));
    http.Response resp = await http.get(url, headers: userHeader);
    print(resp.body);
    respMap = jsonDecode(resp.body);
    List<String> banks = [];
    bool done = false;
    int index = 0;
    while (!done) {
      try {
        if (respMap['data']['Banks'][index] == null) {
          done = true;
        } else {
          banks.add(respMap['data']['Banks'][index]["Name"]);
        }
        index++;
      } catch (e) {
        done = true;
      }
    }
    // print(bank);
    return banks;
  }

  Future<String> _askedToLead() async {
    switch (await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            elevation: 24,
            backgroundColor: Colors.blueAccent,
            shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.white, width: 1),
                borderRadius: BorderRadius.all(Radius.circular(20))),
            title: Text(
              'What would you like to do?',
              style: TextStyle(color: Colors.white, fontFamily: 'Poppins Bold'),
            ),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 'Deposit');
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15)),
                  // color: secondaryColor,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Deposit',
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Poppins Regular',
                          color: Colors.blueAccent),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 'Withdraw');
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15)),
                  // color: secondaryColor,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          'Withdraw',
                          style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Poppins Regular',
                              color: Colors.blueAccent),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "Supported Banks:",
                          style: TextStyle(
                              color: Colors.blueAccent,
                              fontFamily: "Poppins Bold"),
                          textAlign: TextAlign.center,
                        ),
                        Column(
                          children: bankTexts,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // SimpleDialogOption(
              //   onPressed: () {
              //     Navigator.pop(context, 'Currency');
              //   },
              //   child: Container(
              //     decoration: BoxDecoration(
              //         color: Colors.white,
              //         borderRadius: BorderRadius.circular(15)),
              //     // color: secondaryColor,
              //     child: Padding(
              //       padding: const EdgeInsets.all(8.0),
              //       child: Text(
              //         'Change Currency',
              //         style: TextStyle(
              //             fontSize: 18,
              //             fontFamily: 'Poppins Regular',
              //             color: Colors.blueAccent),
              //         textAlign: TextAlign.center,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          );
        })) {
      case 'Deposit':
        {
          return 'Deposit';
        }

        break;

      case 'Withdraw':
        {
          return 'Withdraw';
        }
        break;

      case 'Currency':
        {
          return 'Currency';
        }
    }
  }

  Future<bool> checkCurrencyChangeAllowed(String uid) async {
    try {
      var userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      Timestamp timestamp = userDoc.data()['lastCurrencyChange'] ?? null;
      bool changeAllowed = true;
      DateTime date;

      if (timestamp != null) {
        date = timestamp.toDate();
        if (DateTime.now().difference(date).inDays < 30) {
          changeAllowed = false;
        }
      } else {
        changeAllowed = true;
      }
      if (changeAllowed) {
        print("USER MAY CHANGE CURRENCY");
        return true;
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
                    'You can only change your currency every 30 days (${date.add(Duration(days: 30)).toString().substring(0, 10)})',
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

        return false;
      }
    } catch (e) {
      print("FAILED TO CONNECT AND CHECK IF USER CAN CHANGE CURRENCY");
      return false;
    }
  }

  Future<bool> depositToBalance(String username, String email, String uid,
      String phoneNumber, double amount, String userCurrency) async {
    Random objectname = Random();
    int number = objectname.nextInt(100);

    final style = FlutterwaveStyle(
        appBarText: "Payment Gateway",
        buttonColor: Colors.blueAccent,
        // appBarIcon: Icon(Icons.message, color: Color(0xffd0ebff)),
        buttonTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: "Poppins Regular"),
        buttonText: "Start Payment",
        appBarColor: Colors.blueAccent,
        appBarTitleTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            fontFamily: "Poppins Regular"),
        dialogCancelTextStyle: TextStyle(
          color: Colors.redAccent,
          fontSize: 18,
        ),
        dialogContinueTextStyle: TextStyle(
          color: Colors.blue,
          fontSize: 18,
        ));
    final Customer customer =
        Customer(name: username, phoneNumber: phoneNumber, email: email);
    double addedCommision = ((0.055 * amount) < 10) ? 10 : (0.055 * amount);

    final Flutterwave flutterwave = Flutterwave(
        context: context,
        style: style,
        publicKey: balanceTestMode
            ? ""
            : "",
        currency: userCurrency,
        txRef: uid + DateTime.now().toString() + number.toString(),
        amount: (amount + addedCommision).toString(),
        customer: customer,
        paymentOptions: "card",
        customization: Customization(title: "Payment Gateway"),
        isTestMode: balanceTestMode);

    final ChargeResponse response = await flutterwave.charge();
    if (response != null) {
      print(response.toJson());
      if (response.success) {
        print("succ");
        bool result = await verifyTransaction(response.txRef) ?? false;
        return result;
      } else {
        print("no succ");
        return false;
      }
    } else {
      print("cancel");
      return false;
    }
  }

  void showDepositSuccessDialog(String amount) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Center(
                child: Text(
              'Success',
              style:
                  TextStyle(fontFamily: 'Poppins Bold', color: secondaryColor),
            )),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.payment_rounded,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Successfully deposited $amount.',
                    style: TextStyle(
                      fontFamily: 'Poppins Regular',
                      color: secondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
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

  bool showingConfirmationDialog = false;

  double truncateToDecimalPlaces(num value, int fractionalDigits) =>
      (value * pow(10, fractionalDigits)).truncate() /
      pow(10, fractionalDigits);

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    _interstitialAd = InterstitialAd(
        adUnitId: AdHelper.interstitialAdUnitId,
        listener: AdListener(
          onAdLoaded: (_) {
            _isInterstitialAdReady = true;
            _loadInterstitialAd();
          },
          onAdFailedToLoad: (ad, error) {
            // Releases an ad resource when it fails to load
            ad.dispose();

            print(
                'Ad load failed (code=${error.code} message=${error.message})');
          },
        ),
        request: AdRequest());

    final user = Provider.of<CustomUser>(context);
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
      imagePath = 'images/Bookmart Icon-128x128.png';
      // currentGradient = LinearGradient(
      //     begin: Alignment.topCenter,
      //     end: Alignment.bottomCenter,
      //     colors: [Colors.lightBlue[300], Colors.blue[700]]);
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

    Future<void> getUserCountry() async {
      if (position == null) {
        try {
          LocationPermission permission = await Geolocator.requestPermission();
          position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high);

          //position = widget.currentUserLocation;

          final coordinates =
              Coordinates(position.latitude, position.longitude);
          List<Address> addressLocation =
              await Geocoder.local.findAddressesFromCoordinates(coordinates);
          print('user country: ${addressLocation.first.countryName}');
          userCurrentCountry = addressLocation.first.countryName;
          // String userCountry = addressLocation.first.countryName;
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
        }
      }
    }

    Future<bool> initializeUserCurrencyInDatabase() async {
      print("INITIALIZING CURRENCY");

      await getUserCountry();
      print("USER COUNTRY : " + userCurrentCountry);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'lastCountry': userCurrentCountry});

      var doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      String currentCurrency = doc.data()['currency'] ??
          NumberFormat.simpleCurrency(locale: Platform.localeName).currencyName;
      double balance = (doc.data()['balance'] ?? 0.0) * 1.0;

      bool userHasCurrency = doc.data()['currency'] != null;

      if (userHasCurrency) {
        if (selectedCurrency != null && !showingConfirmationDialog) {
          try {
            final fx = Forex();
            showingConfirmationDialog = true;
            double conversion = (await fx.getCurrencyConverted(
                currentCurrency, selectedCurrency, balance));
            conversion = truncateToDecimalPlaces(conversion, 2);

            bool result = await Navigator.push(
                  this.context,
                  MaterialPageRoute(
                      builder: (context) => ConfirmationDialog(
                            text:
                                'To change your currency to $selectedCurrency, please type "confirm" in the box below.',
                          )),
                ) ??
                false;

            if (result) {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .update({
                'currency': selectedCurrency,
                'balance': conversion,
                'lastCurrencyChange': DateTime.now()
              });
              selectedCurrency = null;
              showingConfirmationDialog = false;
            } else {
              selectedCurrency = null;
              showingConfirmationDialog = false;
            }
          } catch (e) {
            return false;
          }
        }

        return true;
      }

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'currency':
              userCurrentCountry == "South Africa"
                  ? "ZAR"
                  : NumberFormat.simpleCurrency(locale: Platform.localeName)
                      .currencyName,
          'balance': 0,
        });

        return true;
      } catch (e) {
        return false;
      }
    }

    Future<void> addBookToWishlist() async {
      String entry = await prompt(
        context,
        title: Text(
          'Search for ISBN or book name',
          style: TextStyle(
              color: primaryColor, fontSize: 17, fontFamily: 'Poppins Bold'),
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
                        fontFamily: 'Poppins Bold', color: secondaryColor),
                  )),
                  content: Text(
                      'Something went wrong with your search. Please check your internet connection or try again later.',
                      style: TextStyle(
                          fontFamily: 'Poppins Regular',
                          color: secondaryColor)),
                  actions: [
                    FlatButton(
                        onPressed: () {
                          Navigator.of(this.context, rootNavigator: true).pop();
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
          setState(() {
            loading = false;
          });
          return;
        }
      }
    }

    Future<void> findBuyersLookingForISBN() async {
      String entry = await prompt(
        context,
        title: Text(
          'Search for your book',
          style: TextStyle(
              color: primaryColor, fontSize: 17, fontFamily: 'Poppins Bold'),
        ),
        keyboardType: TextInputType.text,
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
        setState(() {
          loading = true;
        });

        print(entry);

        entry = entry.trim();

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
                      fromLookingFor: true,
                      fromAddToWishlist: false,
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
                        fontFamily: 'Poppins Bold', color: secondaryColor),
                  )),
                  content: Text(
                      'Something went wrong with your search. Please check your internet connection or try again later.',
                      style: TextStyle(
                          fontFamily: 'Poppins Regular',
                          color: secondaryColor)),
                  actions: [
                    FlatButton(
                        onPressed: () {
                          Navigator.of(this.context, rootNavigator: true).pop();
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
          setState(() {
            loading = false;
          });
          return;
        }
      }
    }

    double userBalance;

    if (loading) {
      return Loading(currentTheme: widget.currentTheme);
    } else {
      return FutureBuilder<bool>(
          future: initializeUserCurrencyInDatabase(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot2) {
            if (snapshot2.hasData) {
              print("App has currency initialization data");
              if (snapshot2.data) {
                print("Successfully initialized currency");
                return StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("users")
                        .doc(user.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        print("HAVE SNAPSHOT DATA");
                        // UserData userData = snapshot.data;
                        userBalance =
                            ((snapshot.data.data()['balance'] ?? 0) * 1.0) ??
                                (0 * 1.0);
                        return Scaffold(
                          appBar: (userCurrentCountry == "South Africa")
                              ? AppBar(
                                  elevation: 0,
                                  backgroundColor: Colors.blueAccent,
                                  centerTitle: true,
                                  title: RaisedButton.icon(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18.0),
                                        side: BorderSide(color: primaryColor)),
                                    color: secondaryColor,
                                    icon: Icon(
                                      Icons.account_balance_wallet_outlined,
                                      color: primaryColor,
                                      size: 30,
                                    ),
                                    label: Text(
                                      'Balance: ' +
                                          snapshot.data.data()['currency'] +
                                          " " +
                                          userBalance.toStringAsFixed(2),
                                      style: TextStyle(
                                          color: primaryColor,
                                          fontFamily: 'Poppins Regular',
                                          fontSize: 20),
                                    ),
                                    onPressed: () async {
                                      setState(() {
                                        loading = true;
                                      });

                                      if (receivedBanks == null) {
                                        receivedBanks =
                                            await availableSouthAfricanBanksForWithdrawal();
                                        for (int index = 0;
                                            index < receivedBanks.length;
                                            index++) {
                                          bankTexts.add(Text(
                                            receivedBanks[index],
                                            style: TextStyle(
                                                color: Colors.blueAccent,
                                                fontFamily: 'Poppins Regular'),
                                          ));
                                        }
                                      }

                                      setState(() {
                                        loading = false;
                                      });

                                      String result = await _askedToLead();
                                      if (result == 'Withdraw') {
                                        setState(() {
                                          loading = true;
                                        });

                                        bool result = await Navigator.push(
                                          this.context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  StartWithdrawal(
                                                    banks: receivedBanks,
                                                    response: respMap,
                                                    currency: snapshot.data
                                                        .data()['currency'],
                                                    email: snapshot.data
                                                        .data()['email'],
                                                    isBalanceTestMode:
                                                        balanceTestMode,
                                                  )),
                                        );

                                        setState(() {
                                          loading = false;
                                        });

                                        if (result == null) return;

                                        if (result) {
                                          await showDialog(
                                              context: this.context,
                                              builder: (_) {
                                                return AlertDialog(
                                                  title: Center(
                                                      child: Text(
                                                    'Success',
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Poppins Bold',
                                                        color: secondaryColor),
                                                    textAlign: TextAlign.center,
                                                  )),
                                                  content: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.all(8),
                                                          child: Icon(
                                                            Icons.done,
                                                            color: Colors.white,
                                                            size: 40,
                                                          ),
                                                        ),
                                                        Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8),
                                                            child: Text(
                                                              "Your request to withdraw has been successful. The transaction will take 2-3 working days to complete.",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      "Poppins Regular",
                                                                  color: Colors
                                                                      .white),
                                                            )),
                                                      ]),
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
                                          await showDialog(
                                              context: this.context,
                                              builder: (_) {
                                                return AlertDialog(
                                                  title: Center(
                                                      child: Text(
                                                    'Failed',
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Poppins Bold',
                                                        color: secondaryColor),
                                                    textAlign: TextAlign.center,
                                                  )),
                                                  content: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.all(8),
                                                          child: Icon(
                                                            Icons.clear,
                                                            color: Colors.white,
                                                            size: 40,
                                                          ),
                                                        ),
                                                        Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8),
                                                            child: Text(
                                                              "Your withdrawal could not be completed.",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      "Poppins Regular",
                                                                  color: Colors
                                                                      .white),
                                                            )),
                                                      ]),
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

                                        return;
                                      }
                                      if (result == 'Deposit') {
                                        setState(() {
                                          loading = true;
                                        });

                                        String region = await PhoneNumberUtil()
                                            .carrierRegionCode();

                                        String phoneNumber =
                                            await Navigator.push(
                                          this.context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  EnterPhoneNumber(
                                                    carrierRegionCode: region,
                                                  )),
                                        );

                                        if (phoneNumber == null ||
                                            phoneNumber.length == 0) {
                                          setState(() {
                                            loading = false;
                                          });
                                          return;
                                        }

                                        double depositAmount =
                                            await Navigator.push(
                                          this.context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  DepositAmount()),
                                        );

                                        if (depositAmount == null) {
                                          setState(() {
                                            loading = false;
                                          });
                                          return;
                                        }

                                        String uid = user.uid;
                                        String email =
                                            snapshot.data.data()['email'];
                                        String username =
                                            snapshot.data.data()['username'];

                                        setState(() {
                                          loading = false;
                                        });

                                        bool success = await depositToBalance(
                                                username,
                                                email,
                                                uid,
                                                phoneNumber,
                                                depositAmount,
                                                snapshot.data
                                                    .data()['currency']) ??
                                            false;

                                        if (success) {
                                          setState(() {
                                            loading = true;
                                          });
                                          var userBalance =
                                              snapshot.data.data()['balance'] +
                                                  depositAmount;
                                          await FirebaseFirestore.instance
                                              .collection("users")
                                              .doc(user.uid)
                                              .update({'balance': userBalance});
                                          setState(() {
                                            loading = false;
                                          });
                                          showDepositSuccessDialog(snapshot.data
                                                  .data()['currency'] +
                                              " " +
                                              depositAmount.toStringAsFixed(2));
                                        }
                                      }

                                      if (result == 'Currency') {
                                        bool canChange =
                                            await checkCurrencyChangeAllowed(
                                                user.uid);

                                        print('Can Change: ' +
                                            canChange.toString());

                                        if (!canChange) {
                                          return;
                                        }

                                        await showDialog(
                                                context: this.context,
                                                builder: (_) {
                                                  return AlertDialog(
                                                    title: Center(
                                                        child: Text(
                                                      'Disclaimer',
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Poppins Bold',
                                                          color:
                                                              secondaryColor),
                                                    )),
                                                    content: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        'You can only change your currency every 30 days. Think carefully before you change it.',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Poppins Regular',
                                                          color: secondaryColor,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
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
                                                barrierDismissible: false)
                                            .then((value) =>
                                                print("User tapped ok."));

                                        String tempSelectedCurrency;

                                        showCurrencyPicker(
                                          context: this.context,
                                          showFlag: true,
                                          showCurrencyName: true,
                                          showCurrencyCode: true,
                                          onSelect: (Currency currency) async {
                                            setState(() {
                                              // loading = false;
                                              selectedCurrency = currency.code;
                                            });
                                          },
                                        );
                                      }
                                    },
                                  ),
                                )
                              : null,
                          backgroundColor: primaryColor,
                          body: Stack(children: [
                            //  buildSearchBar(),
                            FloatingSearchBar(
                              // padding: EdgeInsets.all(8),
                              borderRadius: BorderRadius.circular(25),
                              elevation: 0,
                              automaticallyImplyBackButton: false,
                              hint: 'Search for books',
                              shadowColor: Colors.blueAccent,
                              backdropColor: Colors.blueAccent,
                              hintStyle: TextStyle(
                                  fontFamily: 'Poppins Regular',
                                  fontSize: 24,
                                  color: Colors.grey),
                              queryStyle: TextStyle(
                                  fontFamily: 'Poppins Regular',
                                  fontSize: 24,
                                  color: Colors.grey),
                              scrollPadding:
                                  const EdgeInsets.only(top: 16, bottom: 56),
                              transitionDuration:
                                  const Duration(milliseconds: 800),
                              transitionCurve: Curves.easeInOut,
                              physics: const BouncingScrollPhysics(),
                              axisAlignment: isPortrait ? 0.0 : -1.0,
                              openAxisAlignment: 0.0,
                              width: isPortrait ? 600 : 500,
                              debounceDelay: const Duration(milliseconds: 500),
                              onQueryChanged: (query) async {
                                // Call your model, bloc, controller here.

                                searchQuery = query;
                                await Future.delayed(Duration(seconds: 1));
                                final validCharacters = RegExp('[A-Za-z]+');
                                bool validQuery =
                                    validCharacters.hasMatch(searchQuery);
                                // bool validQuery2 = isAlphanumeric(searchQuery);
                                if (searchQuery != '' &&
                                    validQuery &&
                                    searchQuery.length > 1) {
                                  print("Searching");
                                  //String userCountry =
                                  await getUserCountry();

                                  if (_isInterstitialAdReady) {
                                    // await _interstitialAd.load();
                                    try {
                                      await _interstitialAd.show();
                                    } catch (e) {
                                      print('Error: ${e.toString()}');
                                    }
                                  }

                                  if (userCurrentCountry != '') {
                                    searchResults = await DatabaseService(
                                            uid: user.uid)
                                        .getAdsFromAllCategories(
                                            searchQuery, userCurrentCountry);

                                    setState(() {
                                      hasSearchResults = true;
                                    });
                                  }
                                }
                              },
                              // Specify a custom transition to be used for
                              // animating between opened and closed stated.
                              transition: CircularFloatingSearchBarTransition(),
                              body:
                                  Container(
                                      decoration: BoxDecoration(
                                          color: primaryColor,
                                          gradient: currentGradient),
                                      alignment: Alignment.center,
                                      child: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // SizedBox(height: 65,),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: homeSelectionCard(
                                                  "Add books to my wishlist",
                                                  Icon(
                                                    Icons.add,
                                                    color: Colors.blueAccent,
                                                    size: 45,
                                                  ),
                                                  addBookToWishlist),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: homeSelectionCard(
                                                  "Find buyers looking for your book",
                                                  Icon(
                                                    Icons.search,
                                                    color: Colors.blueAccent,
                                                    size: 45,
                                                  ),
                                                  findBuyersLookingForISBN),
                                            ),
                                          ],
                                        ),
                                      )),

                              builder: (context, transition) {
                                return !hasSearchResults
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SpinKitHourGlass(
                                            color: secondaryColor),
                                      )
                                    : // Text("Loaded");
                                    searchResults.length == 0
                                        ? Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "No items could be found.",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: secondaryColor,
                                                  fontFamily:
                                                      "Poppins Regular"),
                                            ),
                                          )
                                        : ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Material(
                                              color: Colors.transparent,
                                              elevation: 0,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: List.generate(
                                                  searchResults.length,
                                                  (index) => Card(
                                                    shape: RoundedRectangleBorder(
                                                        side: BorderSide(
                                                            color:
                                                                secondaryColor,
                                                            width: 1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    //margin: EdgeInsets.fromLTRB(20, 6 , 20, 0),
                                                    color: secondaryColor,
                                                    elevation: 0,
                                                    child: InkWell(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  ViewSpecificAd(
                                                                    currentTheme:
                                                                        widget
                                                                            .currentTheme,
                                                                    model: searchResults[
                                                                        index],
                                                                    currentUserLocation:
                                                                        position,
                                                                  )),
                                                        );
                                                      },
                                                      child: Column(
                                                        children: [
                                                          ListTile(
                                                            leading:
                                                                CircleAvatar(
                                                              radius: 30,
                                                              backgroundImage: NetworkImage(
                                                                  searchResults[
                                                                              index]
                                                                          .data[
                                                                      'coverImage']),
                                                            ),
                                                            title: Text(
                                                              searchResults[
                                                                          index]
                                                                      .data[
                                                                  'title'],
                                                              style: TextStyle(
                                                                  color:
                                                                      primaryColor,
                                                                  fontFamily:
                                                                      'Poppins Bold',
                                                                  fontSize: 15),
                                                            ),
                                                            subtitle: Text(
                                                              'Author: ${searchResults[index].data['author']}',
                                                              style: TextStyle(
                                                                  color:
                                                                      primaryColor,
                                                                  fontFamily:
                                                                      'Poppins Regular'),
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                            ),
                                                            trailing: Text(
                                                              searchResults[
                                                                          index]
                                                                      .data[
                                                                  'price'],
                                                              style: TextStyle(
                                                                  color:
                                                                      primaryColor,
                                                                  fontFamily:
                                                                      'Poppins Regular'),
                                                            ),
                                                          ),
                                                          ListTile(
                                                            selectedTileColor:
                                                                Colors
                                                                    .transparent,
                                                            title: Text(
                                                              'Condition: ${searchResults[index].data['condition']}',
                                                              style: TextStyle(
                                                                  color:
                                                                      primaryColor,
                                                                  fontFamily:
                                                                      'Poppins Bold',
                                                                  fontSize: 13),
                                                            ),
                                                            subtitle: Text(
                                                              '${searchResults[index].data['generalLocation']}',
                                                              style: TextStyle(
                                                                  color:
                                                                      primaryColor,
                                                                  fontFamily:
                                                                      'Poppins Regular',
                                                                  fontSize: 13),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                // return List.generate(10, (index) => simpleTestCard());
                              },
                            )
                          ]),
                        );
                      } else {
                        print(2);
                        return Loading(
                          currentTheme: widget.currentTheme,
                        );
                      }
                    });
              } else {
                print(3);
                return Loading(
                  currentTheme: 'Blue',
                );
              }
            } else {
              print(4);
              return Loading(
                currentTheme: 'Blue',
              );
            }
          });
    }
  }


}
