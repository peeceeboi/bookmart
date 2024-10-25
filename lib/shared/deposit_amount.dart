import 'dart:math';

import 'package:bookmart/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:pattern_formatter/numeric_formatter.dart';

class DepositAmount extends StatefulWidget {

  @override
  _DepositAmountState createState() => _DepositAmountState();
}

class _DepositAmountState extends State<DepositAmount> {

  String currentPrice;
  double actualCurrentPrice;
  TextEditingController priceController = TextEditingController();

  Gradient currentGradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [Colors.lightBlue[600], Colors.blueAccent]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blueAccent,
      ),
      backgroundColor: Colors.blueAccent,
      body: Container(
        decoration: BoxDecoration(
          gradient: currentGradient

        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                      color:
                      Colors.white,
                    ),
                    borderRadius: BorderRadius.circular(25)),
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Center(
                    child: Text(
                      'Please enter an amount',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontFamily: 'Poppins Bold'),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
                padding:
                const EdgeInsets.all(20),
                child: TextFormField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    ThousandsFormatter(allowFraction: false)
                  ],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Poppins Regular'),
                  decoration: textInputDecoration.copyWith(
                      hintText: 'Amount'),
                  onChanged: (val) {
                    if (val.isNotEmpty && val != null) {

                      currentPrice = val.toString();

                      actualCurrentPrice = double.tryParse(
                          val.replaceAll(",", ""));

                      double mod = pow(10.0, 2);
                      actualCurrentPrice = ((actualCurrentPrice * mod)
                          .round()
                          .toDouble() /
                          mod);
                    }
                    // setState(() {
                  },
                )),
            Padding(
              padding: EdgeInsets.all(12),
              child: RaisedButton(
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: Colors.white)),
                color: Colors.white,
                child: Text(
                  "Done",
                  style: TextStyle(
                      color: Colors.blueAccent,
                      fontFamily: 'Poppins Regular',
                      fontSize: 15),
                ),
                onPressed: () async {

                  print("String: " + currentPrice);
                  print("Actual: " + actualCurrentPrice.toString());
                  Navigator.pop(context, actualCurrentPrice);

                },
              ),
            ),
          ],
        ),

      ),

    );
  }
}
