import 'package:bookmart/screens/authenticate/authenticate.dart';
import 'package:bookmart/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:bookmart/models/user.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {

  final String currentTheme;
  Wrapper({this.currentTheme});

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<CustomUser>(context);


    if (user == null) {
      return Authenticate(currentTheme: currentTheme);
    } else  {
      return Home(currentTheme: currentTheme,);
    }

  }
}
