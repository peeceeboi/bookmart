import 'package:bookmart/shared/constants.dart';
import 'package:flutter/material.dart';

class ViewTermsOfService extends StatefulWidget {
  @override
  _ViewTermsOfServiceState createState() => _ViewTermsOfServiceState();

  bool fromLogin = false;
  final currentTheme;
  ViewTermsOfService({this.currentTheme, this.fromLogin});
  
}

class _ViewTermsOfServiceState extends State<ViewTermsOfService> {
  @override
  Widget build(BuildContext context) {

    Gradient currentGradient;
    Color primaryColor;
    Color secondaryColor;
    if (widget.currentTheme == 'Light') {
      primaryColor = Colors.white;
      secondaryColor = Colors.blueAccent;
      currentGradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.grey[200]]);
    }

    if (widget.currentTheme == 'Blue') {
      primaryColor = Colors.blueAccent;
      secondaryColor = Colors.white;
      currentGradient = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.lightBlue[600], Colors.blueAccent]);
    }

    if (widget.currentTheme == 'Dark') {
      primaryColor = Colors.black;
      secondaryColor = Colors.grey[350];
      currentGradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, Colors.grey[800]]);
    }
    
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        actions: [
          widget.fromLogin ?? false ? FlatButton.icon(
            onPressed: () async {
              Navigator.pop(this.context, true);
            },
            icon: Icon(Icons.check, color: secondaryColor,),
            label: Text("I have read and accept", style: TextStyle(color: secondaryColor, fontFamily: 'Poppins Bold'),),
            color: primaryColor,

          ) : Center()
        ],
      ),
      body: Container(
        decoration:
          BoxDecoration(color: primaryColor, gradient: currentGradient),
        child: Flex(
          direction: Axis.vertical,
          children: [
            Expanded(child: ListView(
              scrollDirection: Axis.vertical,
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
                          'Terms of Service',
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
                  padding: const EdgeInsets.all(12.0),
                  child: Text(termsOfService, style: TextStyle(color: secondaryColor, fontFamily: 'Poppins Regular'),),
                )
              ],
            ))
          ],
        ),
      ),
    );
  }
}
