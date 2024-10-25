import 'package:bookmart/screens/home/postanad/enter_final_details.dart';
import 'package:bookmart/shared/loading.dart';
import 'package:books_finder/books_finder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bookmart/models/autogenjsondartbooks.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bookmart/models/post_ad_data_model.dart';

class ISBNFetch extends StatefulWidget {
  @override
  _ISBNFetchState createState() => _ISBNFetchState();

  String currentTheme;
  // final BookFromApi book;
  List<Book> book;
  final Function goToPostAnAd;
  final Function goToFinalDetails;

  ISBNFetch({this.currentTheme, this.book, this.goToPostAnAd, this.goToFinalDetails});

}

class _ISBNFetchState extends State<ISBNFetch> {

  @override
  Widget build(BuildContext context) {

    bool authorAvailable = widget.book.first.info.authors.isNotEmpty;


    NetworkImage cover =  NetworkImage(widget.book.first.info.imageLinks['thumbnail'].toString());

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


    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
      ),
      body: Container(
        alignment: Alignment.center,
        decoration:
            BoxDecoration(color: primaryColor, gradient: currentGradient),
        child: Flex(
          direction: Axis.vertical,
          children: [
            Expanded(
                child: ListView(
                  children: [
                    SizedBox(height: 20,),
                    Center(
                        child: Container(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              widget.book.first.info.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: 'Poppins Bold',
                                  color: secondaryColor),
                            ),
                          ),
                        )),
                    SizedBox(height: 12,),
                    Center(
                      child: Container(
                          // width: 270,
                          child: CachedNetworkImage(imageUrl: widget.book.first.info.imageLinks['thumbnail'].toString(), placeholder: (context, url) {
                            return Loading(currentTheme: widget.currentTheme,);
                          },)
                      ),
                    ),
                    SizedBox(height: 12,),
                    // Center(
                    //     child: Text(
                    //       'Sell this book?',
                    //       style: TextStyle(
                    //           fontSize: 14,
                    //           fontFamily: 'Open Sans Bold',
                    //           color: secondaryColor),
                    //     )),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          15, 0, 15, 5),
                      child: Center(
                        child: RaisedButton(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(18.0),
                                side: BorderSide(
                                    color: secondaryColor)),
                            color: secondaryColor,
                            child: Text(
                              'Sell this Book',
                              style: TextStyle(
                                  color: primaryColor,
                                  fontFamily:
                                  'Poppins Regular',
                                  fontSize: 15),
                            ),
                            onPressed: () async {
                              PostAdModel model = PostAdModel(bookTitle: widget.book.first.info.title, cover: cover, adPosted: false, author: authorAvailable ? widget.book.first.info.authors[0] : null);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        EnterFinalDetails(
                                          currentTheme:
                                          widget.currentTheme,
                                          currentWorkingModel:
                                          model,
                                          fromProfilePage: false,
                                        )),
                              );
                              //widget.goToFinalDetails(model);
                            }
                        ),

                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          15, 0, 15, 5),
                      child: Center(
                        child: RaisedButton(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(18.0),
                                side: BorderSide(
                                    color: secondaryColor)),
                            color: secondaryColor,
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                  color: primaryColor,
                                  fontFamily:
                                  'Poppins Regular',
                                  fontSize: 15),
                            ),
                            onPressed: () async {
                              Navigator.pop(context);
                            }
                        ),

                      ),
                    ),
                  ],
                )
            ),

          ],
        ),
      ),
    );
  }
}
