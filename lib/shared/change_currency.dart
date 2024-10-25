import 'package:flutter/material.dart';

class ChangeCurrency extends StatefulWidget {

  @override
  _ChangeCurrencyState createState() => _ChangeCurrencyState();
}

class _ChangeCurrencyState extends State<ChangeCurrency> {

  Gradient currentGradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [Colors.lightBlue[600], Colors.blueAccent]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,

      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: currentGradient
        ),
        // child: ,
      ),
    );
  }
}
