import 'package:algolia/algolia.dart';
import 'package:bookmart/models/post_ad_data_model.dart';
import 'package:bookmart/models/user.dart';
import 'package:bookmart/shared/advertisement_card.dart';
import 'package:bookmart/screens/home/search/select_category.dart';
import 'package:bookmart/screens/home/search/select_sorting.dart';
import 'package:bookmart/shared/search_by_isbn_or_book_name.dart';
import 'package:bookmart/shared/view_specific_ad.dart';
import 'package:bookmart/services/database.dart';
import 'package:bookmart/shared/loading.dart';
import 'package:books_finder/books_finder.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:prompt_dialog/prompt_dialog.dart';
import 'dart:math' show cos, sqrt, asin;

import 'package:provider/provider.dart';
import 'package:string_validator/string_validator.dart';

class SearchResults extends StatefulWidget {
  @override
  _SearchResultsState createState() => _SearchResultsState();

  final Function viewSpecificAd;
  final Function goToHomeSearch;
  String currentCategory;
  var userLocation;
  final String currentTheme;
  String currentUserCountry;
  List<AlgoliaObjectSnapshot> searchResults;
  String currentSortingMethod;

  SearchResults(
      {this.goToHomeSearch,
      this.currentTheme,
      this.searchResults,
      this.userLocation,
      this.currentCategory,
      this.currentSortingMethod,
      this.currentUserCountry,
      this.viewSpecificAd});
}

class _SearchResultsState extends State<SearchResults> {
  bool loading = false;

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  void sort(String method) {}

  //Future<List> listOfAllAds;

  void changeCategory(String newCategory) {}

  CustomUser user;

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //
  //   //listOfAllAds = DatabaseService(uid: user.uid).ads;
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  bool firstRun = true;

  @override
  Widget build(BuildContext context) {
    // print(listOfAllAds[1].)
    dynamic userr = Provider.of<CustomUser>(context);
    if (widget.currentSortingMethod != null) {
      // Sort here
    }

    Color primaryColor;
    Color secondaryColor;
    // List<PostAdModel> adModels = List.generate(
    //     widget.searchResults.length,
    //         (i) => PostAdModel()
    // );
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
    // print('Result: ${widget.searchResults
    //     .data['mainCat']}');

    print('Result: ${widget.searchResults}');

    bool isASearchResult(DocumentSnapshot snapshot) {
      String snapshotID = snapshot.id;
      bool found = false;
      for (int i = 0; i <= widget.searchResults.length - 1; i++) {
        if (widget.searchResults[i].objectID == snapshotID) {
          found = true;
          break;
        }
      }
      return found;
    }

    if (loading) {
      return Loading(
        currentTheme: widget.currentTheme,
      );
    } else {
      return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('ads')
              .where('country', isEqualTo: widget.currentUserCountry)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Scaffold(
                backgroundColor: primaryColor,
                body: Container(
                  decoration: BoxDecoration(
                    color: primaryColor,
                    gradient: currentGradient,
                  ),
                  child: Flex(
                    direction: Axis.vertical,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Expanded(
                        child: widget.searchResults.length == 0
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'No items with that name could be found.',
                                      style: TextStyle(
                                          color: secondaryColor,
                                          fontSize: 16,
                                          fontFamily: 'Poppins Regular'),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(20, 8, 20, 8),
                                    child: Text(
                                      'Alternatively, you could add an ISBN number to your public wish list to allow sellers to find you.',
                                      style: TextStyle(
                                          color: secondaryColor,
                                          fontSize: 14,
                                          fontFamily: 'Poppins Regular'),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  RaisedButton.icon(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                    ),
                                    label: Text(
                                      'Add book to wish list',
                                      style: TextStyle(
                                          color: primaryColor,
                                          fontFamily: 'Open Sans Semi Bold'),
                                    ),
                                    icon: Icon(
                                      Icons.add,
                                      color: primaryColor,
                                    ),
                                    color: secondaryColor,
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
                                        textCapitalization:
                                            TextCapitalization.words,
                                      );
                                      if (entry != null) {
                                        print(entry);

                                        entry.trim();

                                        setState(() {
                                          loading = true;
                                        });

                                        try {
                                          final List<Book> books =
                                              await queryBooks(
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
                                                builder: (context) =>
                                                    SearchAddWishlist(
                                                      currentTheme:
                                                          widget.currentTheme,
                                                      books: books,
                                                      fromAddToWishlist: true,
                                                      fromLookingFor: false,
                                                      fromSearchResults: true,
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
                                                        fontFamily:
                                                            'Poppins Bold',
                                                        color: secondaryColor),
                                                  )),
                                                  content: Text(
                                                      'Something went wrong with your search. Please check your internet connection or try again later.',
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
                                          setState(() {
                                            loading = false;
                                          });
                                          return;
                                        }
                                      }
                                    },
                                  ),
                                  RaisedButton.icon(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                    ),
                                    label: Text(
                                      'Return to Home',
                                      style: TextStyle(
                                          color: primaryColor,
                                          fontFamily: 'Open Sans Semi Bold'),
                                    ),
                                    icon: Icon(
                                      Icons.home,
                                      color: primaryColor,
                                    ),
                                    color: secondaryColor,
                                    onPressed: () async {
                                      widget.goToHomeSearch(null);
                                    },
                                  )
                                ],
                              )
                            : ListView.builder(
                                itemCount: widget.searchResults.length,
                                itemBuilder: (BuildContext context, int index) {
                                  var adPosition = widget
                                      .searchResults[index].data['location'];

                                  print(adPosition.toString());
                                  //print(adPosition['_latitude']);

                                  var distance = calculateDistance(
                                          adPosition['_latitude'],
                                          adPosition['_longitude'],
                                          widget.userLocation.latitude,
                                          widget.userLocation.longitude)
                                      .round();
                                  if (index == 0) {
                                    return Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            widget.searchResults.length == 1
                                                ? '${widget.searchResults.length} ad found'
                                                : '${widget.searchResults.length} ads found',
                                            style: TextStyle(
                                                color: secondaryColor,
                                                fontSize: 26,
                                                fontFamily: 'Poppins Bold'),
                                          ),
                                        ),
                                        // Padding(
                                        //   padding: const EdgeInsets.all(8.0),
                                        //   child: Text(
                                        //     'Category Selected: ${widget.currentCategory ?? 'All Categories'}',
                                        //     style: TextStyle(
                                        //         color: secondaryColor,
                                        //         fontSize: 16,
                                        //         fontFamily: 'Poppins Bold'),
                                        //   ),
                                        // ),

                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: SizedBox(
                                            width: double.infinity,
                                            child: RaisedButton.icon(
                                              icon: Icon(
                                                Icons.edit_attributes_outlined,
                                                color: primaryColor,
                                              ),
                                              elevation: 0,
                                              onPressed: () async {
                                                widget.currentCategory =
                                                    await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          SelectCategory(
                                                            currentTheme: widget
                                                                .currentTheme,
                                                            calledFromResultsScreen:
                                                                true,
                                                          )),
                                                );
                                                print(widget.currentCategory);
                                                widget.goToHomeSearch(
                                                    widget.currentCategory);
                                              },
                                              label: Text(
                                                'Change Category',
                                                style: TextStyle(
                                                    color: primaryColor,
                                                    fontFamily:
                                                        'Poppins Regular',
                                                    fontSize: 15),
                                              ),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          18.0),
                                                  side: BorderSide(
                                                      color: secondaryColor)),
                                              color: secondaryColor,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: SizedBox(
                                            width: double.infinity,
                                            child: RaisedButton.icon(
                                              icon: Icon(
                                                Icons.sort,
                                                color: primaryColor,
                                              ),
                                              elevation: 0,
                                              onPressed: () async {
                                                String previousSortingMethod =
                                                    widget.currentSortingMethod;
                                                String newSortingMethod =
                                                    await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          SelectSorting(
                                                            currentTheme: widget
                                                                .currentTheme,
                                                          )),
                                                );
                                                print(widget
                                                    .currentSortingMethod);
                                                if (newSortingMethod != null) {
                                                  print(newSortingMethod);
                                                  widget.currentSortingMethod =
                                                      newSortingMethod;
                                                  setState(() {
                                                    switch (widget
                                                        .currentSortingMethod) {
                                                      case 'Distance: Nearest to Furthest':
                                                        {
                                                          //List resultDistances = [0];

                                                          List resultDistances =
                                                              List.generate(
                                                                  widget
                                                                      .searchResults
                                                                      .length,
                                                                  (i) => i);

                                                          for (int index = 0;
                                                              index <
                                                                  widget
                                                                      .searchResults
                                                                      .length;
                                                              index++) {
                                                            var adPosition = widget
                                                                .searchResults[
                                                                    index]
                                                                .data['location'];
                                                            var distance = calculateDistance(
                                                                adPosition[
                                                                    '_latitude'],
                                                                adPosition[
                                                                    '_longitude'],
                                                                widget
                                                                    .userLocation
                                                                    .latitude,
                                                                widget
                                                                    .userLocation
                                                                    .longitude);
                                                            resultDistances[
                                                                    index] =
                                                                distance;
                                                          }
                                                          for (int i = 0;
                                                              i <
                                                                  widget.searchResults
                                                                          .length -
                                                                      1;
                                                              i++) {
                                                            for (int j = 0;
                                                                j <
                                                                    widget.searchResults
                                                                            .length -
                                                                        i -
                                                                        1;
                                                                j++) {
                                                              if (resultDistances[
                                                                      j] >
                                                                  resultDistances[
                                                                      j + 1]) {
                                                                // Swapping using temporary variable
                                                                var temp =
                                                                    resultDistances[
                                                                        j];
                                                                AlgoliaObjectSnapshot
                                                                    temp2 =
                                                                    widget.searchResults[
                                                                        j];
                                                                //var temp3 = newSearchDocuments[j];
                                                                resultDistances[
                                                                        j] =
                                                                    resultDistances[
                                                                        j + 1];
                                                                widget.searchResults[
                                                                    j] = widget
                                                                        .searchResults[
                                                                    j + 1];
                                                                //newSearchDocuments[j] = newSearchDocuments[j + 1];
                                                                resultDistances[
                                                                        j + 1] =
                                                                    temp;
                                                                //newSearchDocuments[j + 1] = temp3;
                                                                widget.searchResults[
                                                                        j + 1] =
                                                                    temp2;
                                                              }
                                                            }
                                                          }
                                                        }
                                                        break;

                                                      case 'Distance: Furthest to Nearest':
                                                        {
                                                          List resultDistances =
                                                              List.generate(
                                                                  widget
                                                                      .searchResults
                                                                      .length,
                                                                  (i) => i);

                                                          for (int index = 0;
                                                              index <
                                                                  widget
                                                                      .searchResults
                                                                      .length;
                                                              index++) {
                                                            var adPosition = widget
                                                                .searchResults[
                                                                    index]
                                                                .data['location'];
                                                            var distance = calculateDistance(
                                                                adPosition[
                                                                    '_latitude'],
                                                                adPosition[
                                                                    '_longitude'],
                                                                widget
                                                                    .userLocation
                                                                    .latitude,
                                                                widget
                                                                    .userLocation
                                                                    .longitude);
                                                            resultDistances[
                                                                    index] =
                                                                distance;
                                                          }
                                                          for (int i = 0;
                                                              i <
                                                                  widget.searchResults
                                                                          .length -
                                                                      1;
                                                              i++) {
                                                            for (int j = 0;
                                                                j <
                                                                    widget.searchResults
                                                                            .length -
                                                                        i -
                                                                        1;
                                                                j++) {
                                                              if (resultDistances[
                                                                      j] <
                                                                  resultDistances[
                                                                      j + 1]) {
                                                                // Swapping using temporary variable
                                                                var temp =
                                                                    resultDistances[
                                                                        j];
                                                                AlgoliaObjectSnapshot
                                                                    temp2 =
                                                                    widget.searchResults[
                                                                        j];
                                                                //var temp3 = newSearchDocuments[j];
                                                                resultDistances[
                                                                        j] =
                                                                    resultDistances[
                                                                        j + 1];
                                                                widget.searchResults[
                                                                    j] = widget
                                                                        .searchResults[
                                                                    j + 1];
                                                                //newSearchDocuments[j] = newSearchDocuments[j + 1];
                                                                resultDistances[
                                                                        j + 1] =
                                                                    temp;
                                                                //newSearchDocuments[j + 1] = temp3;
                                                                widget.searchResults[
                                                                        j + 1] =
                                                                    temp2;
                                                              }
                                                            }
                                                          }
                                                        }
                                                        break;

                                                      case 'Price: Low to High':
                                                        {
                                                          for (int i = 0;
                                                              i <
                                                                  widget.searchResults
                                                                          .length -
                                                                      1;
                                                              i++) {
                                                            for (int j = 0;
                                                                j <
                                                                    widget.searchResults
                                                                            .length -
                                                                        i -
                                                                        1;
                                                                j++) {
                                                              if (widget
                                                                          .searchResults[
                                                                              j]
                                                                          .data[
                                                                      'rawPrice'] >
                                                                  widget
                                                                      .searchResults[
                                                                          j + 1]
                                                                      .data['rawPrice']) {
                                                                // Swapping using temporary variable
                                                                //var temp = newSearchDocuments[j];
                                                                AlgoliaObjectSnapshot
                                                                    temp2 =
                                                                    widget.searchResults[
                                                                        j];
                                                                //newSearchDocuments[j] = newSearchDocuments[j + 1];
                                                                widget.searchResults[
                                                                    j] = widget
                                                                        .searchResults[
                                                                    j + 1];
                                                                //newSearchDocuments[j + 1] = temp;
                                                                widget.searchResults[
                                                                        j + 1] =
                                                                    temp2;
                                                              }
                                                            }
                                                          }
                                                        }
                                                        break;

                                                      case 'Price: High to Low':
                                                        {
                                                          for (int i = 0;
                                                              i <
                                                                  widget.searchResults
                                                                          .length -
                                                                      1;
                                                              i++) {
                                                            for (int j = 0;
                                                                j <
                                                                    widget.searchResults
                                                                            .length -
                                                                        i -
                                                                        1;
                                                                j++) {
                                                              if (widget
                                                                          .searchResults[
                                                                              j]
                                                                          .data[
                                                                      'rawPrice'] <
                                                                  widget
                                                                      .searchResults[
                                                                          j + 1]
                                                                      .data['rawPrice']) {
                                                                // Swapping using temporary variable
                                                                //var temp = newSearchDocuments[j];
                                                                AlgoliaObjectSnapshot
                                                                    temp2 =
                                                                    widget.searchResults[
                                                                        j];
                                                                //newSearchDocuments[j] = newSearchDocuments[j + 1];
                                                                widget.searchResults[
                                                                    j] = widget
                                                                        .searchResults[
                                                                    j + 1];
                                                                //newSearchDocuments[j + 1] = temp;
                                                                widget.searchResults[
                                                                        j + 1] =
                                                                    temp2;
                                                              }
                                                            }
                                                          }
                                                        }
                                                        break;

                                                      case 'Date Listed: Most Recent':
                                                        {
                                                          for (int i = 0;
                                                              i <
                                                                  widget.searchResults
                                                                          .length -
                                                                      1;
                                                              i++) {
                                                            for (int j = 0;
                                                                j <
                                                                    widget.searchResults
                                                                            .length -
                                                                        i -
                                                                        1;
                                                                j++) {
                                                              if (widget.searchResults[j].data[
                                                                          'postDate']
                                                                      [
                                                                      '_seconds'] <
                                                                  widget
                                                                      .searchResults[
                                                                          j + 1]
                                                                      .data['postDate']['_seconds']) {
                                                                // Swapping using temporary variable
                                                                //var temp = newSearchDocuments[j];
                                                                AlgoliaObjectSnapshot
                                                                    temp2 =
                                                                    widget.searchResults[
                                                                        j];
                                                                //newSearchDocuments[j] = newSearchDocuments[j + 1];
                                                                widget.searchResults[
                                                                    j] = widget
                                                                        .searchResults[
                                                                    j + 1];
                                                                // newSearchDocuments[j + 1] = temp;
                                                                widget.searchResults[
                                                                        j + 1] =
                                                                    temp2;
                                                              }
                                                            }
                                                          }
                                                        }
                                                        break;

                                                      case 'Date Listed: Oldest':
                                                        {
                                                          for (int i = 0;
                                                              i <
                                                                  widget.searchResults
                                                                          .length -
                                                                      1;
                                                              i++) {
                                                            for (int j = 0;
                                                                j <
                                                                    widget.searchResults
                                                                            .length -
                                                                        i -
                                                                        1;
                                                                j++) {
                                                              if (widget.searchResults[j].data[
                                                                          'postDate']
                                                                      [
                                                                      '_seconds'] >
                                                                  widget
                                                                      .searchResults[
                                                                          j + 1]
                                                                      .data['postDate']['_seconds']) {
                                                                // Swapping using temporary variable
                                                                //var temp = newSearchDocuments[j];
                                                                AlgoliaObjectSnapshot
                                                                    temp2 =
                                                                    widget.searchResults[
                                                                        j];
                                                                //newSearchDocuments[j] = newSearchDocuments[j + 1];
                                                                widget.searchResults[
                                                                    j] = widget
                                                                        .searchResults[
                                                                    j + 1];
                                                                //newSearchDocuments[j + 1] = temp;
                                                                widget.searchResults[
                                                                        j + 1] =
                                                                    temp2;
                                                              }
                                                            }
                                                          }
                                                        }
                                                        break;
                                                    }
                                                  });
                                                }
                                                if (previousSortingMethod !=
                                                    widget
                                                        .currentSortingMethod) {}
                                              },
                                              label: Text(
                                                'Sort Results',
                                                style: TextStyle(
                                                    color: primaryColor,
                                                    fontFamily:
                                                        'Poppins Regular',
                                                    fontSize: 15),
                                              ),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          18.0),
                                                  side: BorderSide(
                                                      color: secondaryColor)),
                                              color: secondaryColor,
                                            ),
                                          ),
                                        ),
                                        widget.currentSortingMethod != null
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child:
                                                    widget.currentSortingMethod !=
                                                            null
                                                        ? Text(
                                                            '${widget.currentSortingMethod ?? 'No Sorting Applied'}',
                                                            style: TextStyle(
                                                                color:
                                                                    secondaryColor,
                                                                fontSize: 16,
                                                                fontFamily:
                                                                    'Poppins Regular'),
                                                          )
                                                        : Center(),
                                              )
                                            : Center(),
                                        Padding(
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
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ViewSpecificAd(
                                                            currentTheme: widget
                                                                .currentTheme,
                                                            model: widget
                                                                    .searchResults[
                                                                index],
                                                            currentUserLocation:
                                                                widget
                                                                    .userLocation,
                                                          )),
                                                );
                                              },
                                              child: Column(
                                                children: [
                                                  ListTile(
                                                    leading: CircleAvatar(
                                                      radius: 30,
                                                      backgroundImage:
                                                          NetworkImage(widget
                                                                  .searchResults[
                                                                      index]
                                                                  .data[
                                                              'coverImage']),
                                                    ),
                                                    title: Text(
                                                      widget
                                                          .searchResults[index]
                                                          .data['title'],
                                                      style: TextStyle(
                                                          color: primaryColor,
                                                          fontFamily:
                                                              'Poppins Bold',
                                                          fontSize: 15),
                                                    ),
                                                    subtitle: Text(
                                                      'Author: ${widget.searchResults[index].data['author']}',
                                                      style: TextStyle(
                                                          color: primaryColor,
                                                          fontFamily:
                                                              'Poppins Regular'),
                                                      textAlign: TextAlign.left,
                                                    ),
                                                    trailing: Text(
                                                      widget
                                                          .searchResults[index]
                                                          .data['price'],
                                                      style: TextStyle(
                                                          color: primaryColor,
                                                          fontFamily:
                                                              'Poppins Regular'),
                                                    ),
                                                  ),
                                                  ListTile(
                                                    selectedTileColor:
                                                        Colors.transparent,
                                                    title: Text(
                                                      'Condition: ${widget.searchResults[index].data['condition']}',
                                                      style: TextStyle(
                                                          color: primaryColor,
                                                          fontFamily:
                                                              'Poppins Bold',
                                                          fontSize: 13),
                                                    ),
                                                    subtitle: Text(
                                                      '${widget.searchResults[index].data['generalLocation']}',
                                                      style: TextStyle(
                                                          color: primaryColor,
                                                          fontFamily:
                                                              'Poppins Regular',
                                                          fontSize: 13),
                                                    ),
                                                    trailing: Text(
                                                      distance.toString() +
                                                          ' km away',
                                                      style: TextStyle(
                                                          color: primaryColor,
                                                          fontFamily:
                                                              'Poppins Regular'),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        widget.searchResults.length == 1
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        20, 8, 20, 8),
                                                child: Text(
                                                  "Didn't find what you were looking for? You could add an ISBN number to your public wish list to allow sellers to find you.",
                                                  style: TextStyle(
                                                      color: secondaryColor,
                                                      fontSize: 14,
                                                      fontFamily:
                                                          'Poppins Regular'),
                                                  textAlign: TextAlign.center,
                                                ),
                                              )
                                            : Center(),
                                        widget.searchResults.length == 1
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: RaisedButton.icon(
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            18.0),
                                                  ),
                                                  label: Text(
                                                    'Add book to wish list',
                                                    style: TextStyle(
                                                        color: primaryColor,
                                                        fontFamily:
                                                            'Open Sans Semi Bold'),
                                                  ),
                                                  icon: Icon(
                                                    Icons.add,
                                                    color: primaryColor,
                                                  ),
                                                  color: secondaryColor,
                                                  onPressed: () async {
                                                    String entry = await prompt(
                                                      context,
                                                      title: Text(
                                                        'Search for ISBN or book name',
                                                        style: TextStyle(
                                                            color: primaryColor,
                                                            fontSize: 17,
                                                            fontFamily:
                                                                'Poppins Bold'),
                                                      ),
                                                      //keyboardType: TextInputType.number,
                                                      initialValue: '',
                                                      textOK: Text('Ok',
                                                          style: TextStyle(
                                                              color:
                                                                  primaryColor,
                                                              fontSize: 17,
                                                              fontFamily:
                                                                  'Poppins Regular')),
                                                      textCancel: Text('Cancel',
                                                          style: TextStyle(
                                                              color:
                                                                  primaryColor,
                                                              fontSize: 17,
                                                              fontFamily:
                                                                  'Poppins Regular')),
                                                      hintText: '',
                                                      minLines: 1,
                                                      maxLines: 1,
                                                      autoFocus: false,
                                                      obscureText: false,
                                                      obscuringCharacter: '•',
                                                      textCapitalization:
                                                          TextCapitalization
                                                              .words,
                                                    );
                                                    if (entry != null) {
                                                      print(entry);

                                                      entry.trim();

                                                      setState(() {
                                                        loading = true;
                                                      });

                                                      try {
                                                        final List<Book> books =
                                                            await queryBooks(
                                                          entry,
                                                          maxResults: 30,
                                                          printType:
                                                              PrintType.all,
                                                          orderBy:
                                                              OrderBy.relevance,
                                                          reschemeImageLinks:
                                                              true,
                                                        );
                                                        setState(() {
                                                          loading = false;
                                                        });
                                                        Navigator.push(
                                                          this.context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  SearchAddWishlist(
                                                                    currentTheme:
                                                                        widget
                                                                            .currentTheme,
                                                                    books:
                                                                        books,
                                                                    fromAddToWishlist:
                                                                        true,
                                                                    fromLookingFor:
                                                                        false,
                                                                    fromSearchResults:
                                                                        true,
                                                                  )),
                                                        );
                                                      } catch (e) {
                                                        showDialog(
                                                            context:
                                                                this.context,
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
                                                                    'Something went wrong with your search. Please check your internet connection or try again later.',
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            'Poppins Regular',
                                                                        color:
                                                                            secondaryColor)),
                                                                actions: [
                                                                  FlatButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(this.context,
                                                                                rootNavigator: true)
                                                                            .pop();
                                                                      },
                                                                      child:
                                                                          Text(
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
                                                                            Radius.circular(20))),
                                                              );
                                                            },
                                                            barrierDismissible:
                                                                false);
                                                        setState(() {
                                                          loading = false;
                                                        });
                                                        return;
                                                      }
                                                    }
                                                  },
                                                ),
                                              )
                                            : Center(),
                                      ],
                                    );
                                  }
                                  if (index ==
                                      widget.searchResults.length - 1) {
                                    return Column(
                                      children: [
                                        Padding(
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
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ViewSpecificAd(
                                                            currentTheme: widget
                                                                .currentTheme,
                                                            model: widget
                                                                    .searchResults[
                                                                index],
                                                            currentUserLocation:
                                                                widget
                                                                    .userLocation,
                                                          )),
                                                );
                                              },
                                              child: Column(
                                                children: [
                                                  ListTile(
                                                    leading: CircleAvatar(
                                                      radius: 30,
                                                      backgroundImage:
                                                          NetworkImage(widget
                                                                  .searchResults[
                                                                      index]
                                                                  .data[
                                                              'coverImage']),
                                                    ),
                                                    title: Text(
                                                      widget
                                                          .searchResults[index]
                                                          .data['title'],
                                                      style: TextStyle(
                                                          color: primaryColor,
                                                          fontFamily:
                                                              'Poppins Bold',
                                                          fontSize: 15),
                                                    ),
                                                    subtitle: Text(
                                                      'Author: ${widget.searchResults[index].data['author']}',
                                                      style: TextStyle(
                                                          color: primaryColor,
                                                          fontFamily:
                                                              'Poppins Regular'),
                                                      textAlign: TextAlign.left,
                                                    ),
                                                    trailing: Text(
                                                      widget
                                                          .searchResults[index]
                                                          .data['price'],
                                                      style: TextStyle(
                                                          color: primaryColor,
                                                          fontFamily:
                                                              'Poppins Regular'),
                                                    ),
                                                  ),
                                                  ListTile(
                                                    selectedTileColor:
                                                        Colors.transparent,
                                                    title: Text(
                                                      'Condition: ${widget.searchResults[index].data['condition']}',
                                                      style: TextStyle(
                                                          color: primaryColor,
                                                          fontFamily:
                                                              'Poppins Bold',
                                                          fontSize: 13),
                                                    ),
                                                    subtitle: Text(
                                                      '${widget.searchResults[index].data['generalLocation']}',
                                                      style: TextStyle(
                                                          color: primaryColor,
                                                          fontFamily:
                                                              'Poppins Regular',
                                                          fontSize: 13),
                                                    ),
                                                    trailing: Text(
                                                      distance.toString() +
                                                          ' km away',
                                                      style: TextStyle(
                                                          color: primaryColor,
                                                          fontFamily:
                                                              'Poppins Regular'),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              20, 8, 20, 8),
                                          child: Text(
                                            "Didn't find what you were looking for? You could add an ISBN number to your public wish list to allow sellers to find you.",
                                            style: TextStyle(
                                                color: secondaryColor,
                                                fontSize: 14,
                                                fontFamily: 'Poppins Regular'),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: RaisedButton.icon(
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18.0),
                                            ),
                                            label: Text(
                                              'Add book to wish list',
                                              style: TextStyle(
                                                  color: primaryColor,
                                                  fontFamily:
                                                      'Open Sans Semi Bold'),
                                            ),
                                            icon: Icon(
                                              Icons.add,
                                              color: primaryColor,
                                            ),
                                            color: secondaryColor,
                                            onPressed: () async {
                                              String entry = await prompt(
                                                context,
                                                title: Text(
                                                  'Search for ISBN or book name',
                                                  style: TextStyle(
                                                      color: primaryColor,
                                                      fontSize: 17,
                                                      fontFamily:
                                                          'Poppins Bold'),
                                                ),
                                                //keyboardType: TextInputType.number,
                                                initialValue: '',
                                                textOK: Text('Ok',
                                                    style: TextStyle(
                                                        color: primaryColor,
                                                        fontSize: 17,
                                                        fontFamily:
                                                            'Poppins Regular')),
                                                textCancel: Text('Cancel',
                                                    style: TextStyle(
                                                        color: primaryColor,
                                                        fontSize: 17,
                                                        fontFamily:
                                                            'Poppins Regular')),
                                                hintText: '',
                                                minLines: 1,
                                                maxLines: 1,
                                                autoFocus: false,
                                                obscureText: false,
                                                obscuringCharacter: '•',
                                                textCapitalization:
                                                    TextCapitalization.words,
                                              );
                                              if (entry != null) {
                                                print(entry);

                                                entry.trim();

                                                setState(() {
                                                  loading = true;
                                                });

                                                try {
                                                  final List<Book> books =
                                                      await queryBooks(
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
                                                        builder: (context) =>
                                                            SearchAddWishlist(
                                                              currentTheme: widget
                                                                  .currentTheme,
                                                              books: books,
                                                              fromAddToWishlist:
                                                                  true,
                                                              fromLookingFor:
                                                                  false,
                                                              fromSearchResults:
                                                                  true,
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
                                                                fontFamily:
                                                                    'Poppins Bold',
                                                                color:
                                                                    secondaryColor),
                                                          )),
                                                          content: Text(
                                                              'Something went wrong with your search. Please check your internet connection or try again later.',
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
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          20))),
                                                        );
                                                      },
                                                      barrierDismissible:
                                                          false);
                                                  setState(() {
                                                    loading = false;
                                                  });
                                                  return;
                                                }
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  }
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
                                        onTap: () {
                                          //widget.viewSpecificAd(widget.searchResults[index]);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ViewSpecificAd(
                                                      currentTheme:
                                                          widget.currentTheme,
                                                      model: widget
                                                          .searchResults[index],
                                                      currentUserLocation:
                                                          widget.userLocation,
                                                    )),
                                          );
                                          print('Tapped Ad.');
                                        },
                                        child: Column(
                                          children: [
                                            ListTile(
                                              leading: CircleAvatar(
                                                radius: 30,
                                                backgroundImage: NetworkImage(
                                                    widget.searchResults[index]
                                                        .data['coverImage']),
                                              ),
                                              title: Text(
                                                widget.searchResults[index]
                                                    .data['title'],
                                                style: TextStyle(
                                                    color: primaryColor,
                                                    fontFamily: 'Poppins Bold',
                                                    fontSize: 15),
                                              ),
                                              subtitle: Text(
                                                'Author: ${widget.searchResults[index].data['author']}',
                                                style: TextStyle(
                                                    color: primaryColor,
                                                    fontFamily:
                                                        'Poppins Regular'),
                                                textAlign: TextAlign.left,
                                              ),
                                              trailing: Text(
                                                widget.searchResults[index]
                                                    .data['price'],
                                                style: TextStyle(
                                                    color: primaryColor,
                                                    fontFamily:
                                                        'Poppins Regular'),
                                              ),
                                            ),
                                            ListTile(
                                              selectedTileColor:
                                                  Colors.transparent,
                                              title: Text(
                                                'Condition: ${widget.searchResults[index].data['condition']}',
                                                style: TextStyle(
                                                    color: primaryColor,
                                                    fontFamily: 'Poppins Bold',
                                                    fontSize: 13),
                                              ),
                                              subtitle: Text(
                                                '${widget.searchResults[index].data['generalLocation']}',
                                                style: TextStyle(
                                                    color: primaryColor,
                                                    fontFamily:
                                                        'Poppins Regular',
                                                    fontSize: 13),
                                              ),
                                              trailing: Text(
                                                distance.toString() +
                                                    ' km away',
                                                style: TextStyle(
                                                    color: primaryColor,
                                                    fontFamily:
                                                        'Poppins Regular'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                      )
                    ],
                  ),
                ),
              );
            } else {
              return Loading(currentTheme: widget.currentTheme);
            }
          });
    }
  }
}
