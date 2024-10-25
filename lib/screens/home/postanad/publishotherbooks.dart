import 'package:bookmart/models/post_ad_data_model.dart';
import 'package:bookmart/screens/home/postanad/publishfictionbooks.dart';
import 'package:bookmart/screens/home/postanad/publishnonfictionbooks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class PublishOtherBooks extends StatefulWidget {
  @override
  _PublishOtherBooksState createState() => _PublishOtherBooksState();

  String currentTheme;
  final Function goToFiction;
  final Function goToNonFiction;
  PostAdModel currentWorkingModel;

  PublishOtherBooks({this.currentTheme, this.goToFiction, this.goToNonFiction, this.currentWorkingModel});
}

class _PublishOtherBooksState extends State<PublishOtherBooks> {
  @override
  Widget build(BuildContext context) {

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

    List<String> otherBooksList = [
      'Fiction',
      'Non-fiction',
    ];

    void goSomewhere(int currentIndex) {
      if (currentIndex == 0) {
        widget.currentWorkingModel.mainCategory = 'Fiction';
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  PublishFiction(
                    currentTheme:
                    widget.currentTheme,
                    currentWorkingModel:
                    widget.currentWorkingModel,
                  )),
        );
        //widget.goToFiction(widget.currentWorkingModel);
      }
      if (currentIndex == 1) {
        widget.currentWorkingModel.mainCategory = 'Non-fiction';
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  PublishNonFiction(
                    currentTheme:
                    widget.currentTheme,
                    currentWorkingModel:
                    widget.currentWorkingModel,
                  )),
        );
        //widget.goToNonFiction(widget.currentWorkingModel);
      }
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
      ),
      body: Container(
        decoration:
        BoxDecoration(color: primaryColor, gradient: currentGradient),
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
            TypewriterAnimatedTextKit(
              textAlign: TextAlign.center,
              speed: Duration(milliseconds: 40),
              isRepeatingAnimation: false,
              totalRepeatCount: 0,
              text: ["  Specify further"],
              textStyle:
              TextStyle(fontSize: 16, fontFamily: 'Poppins Bold', color: secondaryColor),
              pause: Duration(milliseconds: 50),
            ),
            SizedBox(
              height: 14,
            ),
            Expanded(
                child: ListView.builder(
                    itemCount: otherBooksList.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: secondaryColor)),
                          color: secondaryColor,
                          child: ListTile(
                            onTap: () {
                              goSomewhere(index);
                            },
                            title: Text(
                              otherBooksList[index],
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
                      );
                    }))
          ],
        ),
      ),
    );
  }
}
