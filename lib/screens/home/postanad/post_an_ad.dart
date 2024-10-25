import 'package:bookmart/models/autogenjsondartbooks.dart';
import 'package:bookmart/models/book_from_isbn_api.dart';
import 'package:bookmart/models/post_ad_data_model.dart';
import 'package:bookmart/screens/home/postanad/isbn_fetch_window.dart';
import 'package:bookmart/screens/home/postanad/publisheducation.dart';
import 'package:bookmart/screens/home/postanad/publishotherbooks.dart';
import 'package:books_finder/books_finder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:bookmart/shared/constants.dart';
import 'package:bookmart/shared/loading.dart';
import 'package:string_validator/string_validator.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';


class PostAnAd extends StatefulWidget {
  @override
  _PostAnAdState createState() => _PostAnAdState();

  String currentTheme;
  final Function goToEducation;
  final Function goToISBNFetch;
  final Function goToOtherBooks;

  PostAnAd({this.currentTheme, this.goToEducation, this.goToISBNFetch, this.goToOtherBooks});

  PostAdModel currentAdModel;

}

class _PostAnAdState extends State<PostAnAd> {
  final _isbnKey = GlobalKey<FormState>();
  String isbnInput = '';
  String error = '';
  String errorTwo = '';
  bool loading = false;


  @override
  Widget build(BuildContext context) {
    Color primaryColor, secondaryColor;
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
      imagePath = 'images/book-white.png';
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
      imagePath = 'images/book-blueAccent.png';
      currentGradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, Colors.grey[800]]);
    }

    if (loading) {
      return Loading(currentTheme: widget.currentTheme,);
    } else {
      return Scaffold(

        body: Container(
          decoration:
              BoxDecoration(color: primaryColor, gradient: currentGradient),
          child: Flex(
            direction: Axis.vertical,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          child: Column(
                            children: [
                              SizedBox(
                                height: 7,
                              ),
                              TypewriterAnimatedTextKit(
                                textAlign: TextAlign.center,
                                speed: Duration(milliseconds: 35),
                                isRepeatingAnimation: false,
                                totalRepeatCount: 0,
                                text: ["  Select a category"],
                                textStyle: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Poppins Bold',
                                    color: secondaryColor),
                                pause: Duration(milliseconds: 50),
                              ),
                              // Text(
                              //   'In which category are you posting?',
                              //   style: TextStyle(
                              //       color: secondaryColor,
                              //       fontSize: 16,
                              //       fontFamily: 'Open Sans Bold'),
                              // ),
                              SizedBox(
                                height: 14,
                              ),
                              Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(color: secondaryColor)),
                                color: secondaryColor,
                                child: ListTile(
                                  onTap: () {
                                    widget.currentAdModel = PostAdModel(mainCategory: 'Academics', subCategory: null, bookTitle: null, adPosted: false);
                                    print(widget.currentAdModel.mainCategory);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PublishEducation(
                                                currentTheme:
                                                widget.currentTheme,
                                                currentWorkingModel: widget.currentAdModel,

                                              )),
                                    );
                                    //widget.goToEducation(widget.currentAdModel);
                                  },
                                  title: Text(
                                    'Academics',
                                    style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 14,
                                        fontFamily: 'Poppins Regular'),
                                  ),
                                  leading: Icon(
                                    Icons.menu_book_rounded,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 7,
                              ),
                              Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(color: secondaryColor)),
                                color: secondaryColor,
                                child: ListTile(
                                  onTap: () {
                                    widget.currentAdModel = PostAdModel(mainCategory: null, subCategory: null, bookTitle: null, adPosted: false);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PublishOtherBooks(
                                                currentTheme:
                                                widget.currentTheme,
                                                currentWorkingModel: widget.currentAdModel,

                                              )),
                                    );
                                    //widget.goToOtherBooks(widget.currentAdModel);
                                  },
                                  title: Text(
                                    'Fiction and Non-fiction',
                                    style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 14,
                                        fontFamily: 'Poppins Regular'),
                                  ),
                                  leading: Icon(
                                    Icons.menu_book_rounded,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Text(
                                'OR',
                                style: TextStyle(
                                    color: secondaryColor,
                                    fontFamily: 'Poppins Regular',
                                    fontSize: 13),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Center(
                                child: RaisedButton.icon(
                                  icon: Icon(Icons.camera_outlined, color: primaryColor,),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(18.0),
                                      side: BorderSide(
                                          color: secondaryColor)),
                                  color: secondaryColor,
                                  label: Text(
                                    'Scan ISBN Barcode',
                                    style: TextStyle(
                                        color: primaryColor,
                                        fontFamily:
                                        'Poppins Regular',
                                        fontSize: 16),
                                  ),
                                  onPressed: () async {
                                    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
                                        '#ff6666',
                                        'Cancel',
                                        false,
                                        ScanMode.BARCODE);
                                    print(barcodeScanRes);

                                    setState(() {
                                      loading = true;
                                    });

                                    // print(barcodeScanRes);
                                    bool match = isISBN(barcodeScanRes);

                                    if (!match) {
                                      setState(() {
                                        loading = false;
                                        errorTwo = 'Invalid ISBN Number';
                                      });
                                    }

                                    if (match) {

                                      // print('Valid ISBN.');
                                      //
                                      String sanitizedInput = barcodeScanRes.replaceAll(RegExp(r'[\s-]+'), '');

                                      print('Valid ISBN.');

                                      List<Book> books = await queryBooks(
                                        "isbn:" + sanitizedInput,
                                        maxResults: 1,
                                        printType: PrintType.all,
                                        orderBy: OrderBy.relevance,
                                        reschemeImageLinks: true,
                                      );

                                      bool titleFound = false;
                                      bool authorFound = false;
                                      bool coverFound = false;

                                      if (books.isNotEmpty) {

                                        titleFound = books[0].info.title.length > 0;
                                        authorFound = books[0].info.authors.length > 0;
                                        coverFound = books[0].info.imageLinks.isNotEmpty;

                                      }

                                      if (books == null || books.isEmpty) {
                                        setState(() {
                                          loading = false;
                                          error = 'We could not find this book.';
                                        });
                                      } else if (!titleFound || !authorFound || !coverFound) {

                                        setState(() {
                                          loading = false;
                                          error = 'We could not find this book.';
                                        });

                                      }
                                      else {
                                        setState(() {
                                          loading = false;
                                          //widget.goToISBNFetch(
                                          //book);
                                        });
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                  ISBNFetch(
                                                      currentTheme:
                                                      widget.currentTheme,
                                                      book:
                                                      books,
                                                    )),
                                          );

                                      }
                                    }

                                  },
                                ),
                              ),
                              SizedBox(height: 7,),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8,0,8,7),
                                child: Center(
                                    child: Text(errorTwo,
                                        style: TextStyle(
                                            color: secondaryColor,
                                            fontFamily:
                                            'Poppins Regular',
                                            fontSize: 13))),
                              ),
                              // SizedBox(
                              //   height: 5  ,
                              // ),
                              Text(
                                'OR',
                                style: TextStyle(
                                    color: secondaryColor,
                                    fontFamily: 'Poppins Regular',
                                    fontSize: 13),
                              ),
                              SizedBox(
                                height: 25,
                              ),
                              // Card(
                              //   shape: RoundedRectangleBorder(
                              //       borderRadius: BorderRadius.circular(18.0),
                              //       side: BorderSide(color: secondaryColor)),
                              //   color: primaryColor,
                              //   child: ListTile(
                              //     onTap: () {
                              //
                              //       //bool match = RegVal.hasMatch(s, p)
                              //     },
                              //     title: Text(
                              //       'Enter an ISBN number',
                              //       style: TextStyle(
                              //           color: secondaryColor,
                              //           fontSize: 14,
                              //           fontFamily: 'Open Sans Bold'),
                              //     ),
                              //     leading: Icon(
                              //       Icons.create,
                              //       color: secondaryColor,
                              //     ),
                              //   ),
                              // ),
                              Form(
                                key: _isbnKey,
                                child: Center(
                                  child: Column(
                                    children: [
                                      Text(
                                        'Enter an ISBN number',
                                        style: TextStyle(
                                            color: secondaryColor,
                                            fontFamily: 'Poppins Bold',
                                            fontSize: 16),
                                      ),
                                      SizedBox(height: 5),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 7, 10, 7),
                                        child: TextFormField(
                                          keyboardType: TextInputType.number,
                                          style: TextStyle(
                                              fontFamily:
                                                  'Poppins Regular'),
                                          decoration:
                                              textInputDecoration.copyWith(
                                                  hintText: 'Enter ISBN number'),
                                          validator: (val) {
                                            if (val.isEmpty) {
                                              return 'Enter an ISBN number';
                                            } else {
                                              return null;
                                            }
                                          },
                                          onChanged: (val) {
                                            setState(() {
                                              isbnInput = val.trim();
                                            });
                                          },
                                        ),
                                      ),
                                      Center(
                                          child: Text(error,
                                              style: TextStyle(
                                                  color: secondaryColor,
                                                  fontFamily:
                                                      'Poppins Regular',
                                                  fontSize: 13))),
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
                                              'Submit',
                                              style: TextStyle(
                                                  color: primaryColor,
                                                  fontFamily:
                                                      'Poppins Regular',
                                                  fontSize: 16),
                                            ),
                                            onPressed: () async {

                                              if (_isbnKey.currentState
                                                  .validate()) {


                                                setState(() {
                                                  loading = true;
                                                });

                                                bool match = isISBN(isbnInput);

                                                if (!match) {
                                                  setState(() {
                                                    loading = false;
                                                    error = 'Invalid ISBN Number';
                                                  });
                                                }

                                                if (match) {

                                                    print('Valid ISBN.');

                                                    String sanitizedInput = isbnInput.replaceAll(RegExp(r'[\s-]+'), '');

                                                    List<Book> books = await queryBooks(
                                                      "isbn:" + sanitizedInput,
                                                      maxResults: 1,
                                                      printType: PrintType.all,
                                                      orderBy: OrderBy.relevance,
                                                      reschemeImageLinks: true,
                                                    );
                                                    bool titleFound = false;
                                                    bool authorFound = false;
                                                    bool coverFound = false;

                                                    if (books.isNotEmpty) {

                                                      titleFound = books[0].info.title.length > 0;
                                                      authorFound = books[0].info.authors.length > 0;
                                                      coverFound = books[0].info.imageLinks.isNotEmpty;

                                                    }

                                                    // BookFromAPI requestedBook = BookFromAPI(isbnNumber: sanitizedInput);
                                                    // dynamic book = await requestedBook.getMetadeta();
                                                     //print(book.details.title);
                                                     //print(book.details.subtitle);
                                                    if (books.isEmpty || books == null) {
                                                      setState(() {
                                                        loading = false;
                                                        error = 'We could not find this book.';
                                                      });
                                                    } else if (!titleFound || !authorFound || !coverFound) {

                                                      setState(() {
                                                        loading = false;
                                                        error = 'We could not find this book.';
                                                      });

                                                    } else {
                                                      setState(() {
                                                        loading = false;
                                                        //widget.goToISBNFetch(
                                                            //book);
                                                      });
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  ISBNFetch(
                                                                    currentTheme:
                                                                    widget.currentTheme,
                                                                    book:
                                                                    books,
                                                                  )),
                                                        );
                                                    }
                                                }
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      );
    }
  }
}
