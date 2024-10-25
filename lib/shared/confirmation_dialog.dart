import 'package:bookmart/shared/constants.dart';
import 'package:flutter/material.dart';

class ConfirmationDialog extends StatefulWidget {
  @override
  _ConfirmationDialogState createState() => _ConfirmationDialogState();

  final String text;

  ConfirmationDialog({this.text});
}

class _ConfirmationDialogState extends State<ConfirmationDialog> {
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
      body: Container(
        decoration: BoxDecoration(gradient: currentGradient),
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
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    widget.text,
                    style: TextStyle(
                        fontFamily: 'Poppins Regular', color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
              child: TextFormField(
                style: TextStyle(fontFamily: 'Poppins Regular'),
                decoration: textInputDecoration.copyWith(
                    hintText: 'Please type "confirm" here'),
                onChanged: (val) {
                  if (val == "confirm") {
                    Navigator.pop(this.context, true);
                  }
                },
              ),
            ),
          ],
        ),
        // child: ,
      ),
    );
  }
}
