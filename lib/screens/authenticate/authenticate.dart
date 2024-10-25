import 'package:bookmart/screens/authenticate/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:bookmart/screens/authenticate/register.dart';
import 'package:bookmart/services/database.dart';
import 'package:bookmart/shared/loading.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
  String currentTheme;
  Authenticate({this.currentTheme});
}




class _AuthenticateState extends State<Authenticate> {
  bool showSignIn = true;


  String transferredTheme;

  @override
  Widget build(BuildContext context)  {


    void toggleView(String currentTheme) {
      setState(() {
        showSignIn = !showSignIn;

        widget.currentTheme = currentTheme;
        print('Authenticate theme: ' + widget.currentTheme);
      });
    }



    if (showSignIn) {
      return SignIn(toggleView: toggleView, currentTheme: widget.currentTheme,);
    } else {
      return Register(toggleView: toggleView, currentTheme: widget.currentTheme,);
    }

  }
}
