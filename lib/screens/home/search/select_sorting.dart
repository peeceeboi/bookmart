import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class SelectSorting extends StatefulWidget {
  @override
  _SelectSortingState createState() => _SelectSortingState();

  final String currentTheme;

  SelectSorting({this.currentTheme});
}

class _SelectSortingState extends State<SelectSorting> {
  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.fromLTRB(8, 75, 8, 25),
              child: Text(
                'How would you like results sorted?',
                style: TextStyle(
                    color: secondaryColor,
                    fontSize: 16,
                    fontFamily: 'Poppins Bold'),
              ),
            ),
            Expanded(
                child: ListView(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: secondaryColor)),
                    color: secondaryColor,
                    child: ListTile(
                      onTap: () {
                        Navigator.pop(context, 'Distance: Nearest to Furthest');
                      },
                      title: Text(
                        'Distance: Nearest to Furthest',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: primaryColor,
                            fontSize: 14,
                            fontFamily: 'Poppins Regular'),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: secondaryColor)),
                    color: secondaryColor,
                    child: ListTile(
                      onTap: () {
                        Navigator.pop(context, 'Distance: Furthest to Nearest');
                      },
                      title: Text(
                        'Distance: Furthest to Nearest',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: primaryColor,
                            fontSize: 14,
                            fontFamily: 'Poppins Regular'),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: secondaryColor)),
                    color: secondaryColor,
                    child: ListTile(
                      onTap: () {
                        Navigator.pop(context, 'Price: Low to High');
                      },
                      title: Text(
                        'Price: Low to High',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: primaryColor,
                            fontSize: 14,
                            fontFamily: 'Poppins Regular'),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: secondaryColor)),
                    color: secondaryColor,
                    child: ListTile(
                      onTap: () {
                        Navigator.pop(context, 'Price: High to Low');
                      },
                      title: Text(
                        'Price: High to Low',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: primaryColor,
                            fontSize: 14,
                            fontFamily: 'Poppins Regular'),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: secondaryColor)),
                    color: secondaryColor,
                    child: ListTile(
                      onTap: () {
                        Navigator.pop(context, 'Date Listed: Most Recent');
                      },
                      title: Text(
                        'Date Listed: Most Recent',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: primaryColor,
                            fontSize: 14,
                            fontFamily: 'Poppins Regular'),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: secondaryColor)),
                    color: secondaryColor,
                    child: ListTile(
                      onTap: () {
                        Navigator.pop(context, 'Date Listed: Oldest');
                      },
                      title: Text(
                        'Date Listed: Oldest',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: primaryColor,
                            fontSize: 14,
                            fontFamily: 'Poppins Regular'),
                      ),
                    ),
                  ),
                ),
              ],
            ))
          ],
        ),
      ),
    );
  }
}
