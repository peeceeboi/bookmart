import 'package:bookmart/screens/authenticate/authenticate.dart';
import 'package:bookmart/services/database.dart';
import 'package:bookmart/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:bookmart/main.dart';


class ChangeTheme extends StatefulWidget {
  @override
  _ChangeThemeState createState() => _ChangeThemeState();
  String currentTheme;

  ChangeTheme({this.currentTheme});

}

class _ChangeThemeState extends State<ChangeTheme> {

  final initialTheme = currentTheme;

  @override
  Widget build(BuildContext context) {

    Color primaryColor;

    Color secondaryColor;

    print(initialTheme);


    Gradient currentGradient;
    if (initialTheme == 'Light') {
      primaryColor = Colors.white;
      secondaryColor = Colors.blueAccent;
      currentGradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.grey[400]]);
    }
    if (initialTheme == 'Blue') {
      primaryColor = Colors.blueAccent;
      secondaryColor = Colors.white;
      currentGradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.lightBlue[300], Colors.blue[700]]);
    }


    if (initialTheme == 'Dark') {
      primaryColor = Colors.black;
      secondaryColor = Colors.grey[350];
      currentGradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, Colors.grey[800]]);
    }

        return Container(
          //color: primaryColor,
          decoration: BoxDecoration(color: primaryColor, gradient: currentGradient),
          child: Padding(
            padding: const EdgeInsets.all(50),
            child: Column(
              children: [
                Center(child: Text('Select your theme here: ', style: TextStyle(color: secondaryColor, fontFamily: 'Poppins Regular', fontSize: 14),)),
                SizedBox(height: 15,),
                Center(
                  child: DropdownButtonFormField(

                      style: TextStyle(color: secondaryColor, fontFamily: 'Poppins Regular'),
                      dropdownColor: secondaryColor,
                      decoration: InputDecoration(
                        labelStyle: TextStyle(fontFamily: 'Poppins Regular'),
                        hintStyle: TextStyle(fontFamily: 'Poppins Regular'),
                        fillColor: secondaryColor,
                        filled: true,
                        focusedBorder: OutlineInputBorder( borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(color: Colors.transparent, width: 2)), border: OutlineInputBorder( borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(color: Colors.transparent, width: 2)),

                      ),
                      value: widget.currentTheme,
                      items: [
                        DropdownMenuItem(
                            value: 'Blue',
                            child: Text(
                              'Blue',
                              style: TextStyle(
                                  color: primaryColor,
                                  fontFamily: 'Poppins Regular',
                                  fontSize: 14),
                            )),
                        DropdownMenuItem(
                            value: 'Dark',
                            child: Text(
                              'Dark',
                              style: TextStyle(
                                  color: primaryColor,
                                  fontFamily: 'Poppins Regular',
                                  fontSize: 14),
                            )),
                      ],

                      onChanged: (value) {
                        setState(() {
                          widget.currentTheme = value;
                          //return Authenticate();

                        });
                      }),
                ),
                SizedBox(
                  height: 10,
                ),
                Center(
                    child: RaisedButton(
                      onPressed: () async {
                       await saveTheme(widget.currentTheme);
                       main(); // wtf
                       Navigator.pop(context, widget.currentTheme);
                      },
                  color: secondaryColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: secondaryColor)),
                  child: Text(
                    'Save',
                    style: TextStyle(
                        color: primaryColor,
                        fontFamily: 'Poppins Regular',
                        fontSize: 14),
                  ),
                ))
              ],
            ),
          ),
        );

      }
  }

