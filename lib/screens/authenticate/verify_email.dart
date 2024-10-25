import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:bookmart/shared/loading.dart';
import 'package:bookmart/services/auth.dart';
import 'package:bookmart/screens/home/home.dart';
import 'package:bookmart/screens/authenticate/sign_in.dart';

final AuthService _auth = AuthService();

class VerifyEmail extends StatefulWidget {
  @override
  _VerifyEmailState createState() => _VerifyEmailState();
  final String currentTheme;
  VerifyEmail({this.currentTheme});
}

class _VerifyEmailState extends State<VerifyEmail> {

  bool loading = false;
  bool connectionProblem = false;
  bool emailVerified;
  bool buttonEnabled = true;

  @override
  Widget build(BuildContext context) {

    Color primaryColor;
    Color secondaryColor;

    Gradient currentGradient;
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

    if (loading == true) {
      return Loading(currentTheme: widget.currentTheme,);
    }
      if (loading == false) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            color: primaryColor,
              gradient: currentGradient
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                SizedBox(height: 75,),
                Icon(
                  Icons.email,
                  color: secondaryColor,
                ),
                SizedBox(height: 10,),
                Text(
                  'Please verify your email address by clicking on the link that was emailed to you. You may then sign into your account.',
                  style: TextStyle(
                      fontFamily: 'Poppins Regular', color: secondaryColor),),
                SizedBox(height: 20,),
                RaisedButton.icon(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: secondaryColor)
                  ),
                  label: Text('Resend Verification Email', style: TextStyle(color:  primaryColor, fontFamily: 'Poppins Regular'),),
                  icon: Icon(Icons.mail, color: primaryColor,),
                  color: secondaryColor,
                  onPressed: () async {
                    if (buttonEnabled) {
                      setState(() {
                        loading = true;
                      });
                      bool result = await _auth.sendEmailVerification();
                      setState(() {
                        loading = false;
                      });
                      if (result) {
                        buttonEnabled = false;
                        showDialog(
                            context: context,
                            builder: (_) {
                              return AlertDialog(
                                title: Center(
                                    child: Text(
                                      'Attention',
                                      style: TextStyle(
                                          fontFamily: 'Poppins Bold',
                                          color: secondaryColor),
                                    )),
                                content: Text(
                                    'Verification email has been resent to you (remember to check your spam folder).',
                                    style: TextStyle(
                                        fontFamily: 'Poppins Regular',
                                        color: secondaryColor)),
                                actions: [
                                  FlatButton(
                                      onPressed: () {
                                        Navigator
                                            .of(
                                            context,
                                            rootNavigator: true)
                                            .pop();
                                      },
                                      child: Text(
                                        'Ok',
                                        style: TextStyle(
                                            color: secondaryColor,
                                            fontFamily: 'Poppins Regular'),
                                      ))
                                ],
                                elevation: 24,
                                backgroundColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius
                                        .all(
                                        Radius
                                            .circular(
                                            20))),
                              );
                            },
                            barrierDismissible: false);

                      } else {
                        showDialog(
                            context: context,
                            builder: (_) {
                              return AlertDialog(
                                title: Center(
                                    child: Text(
                                      'Attention',
                                      style: TextStyle(
                                          fontFamily: 'Poppins Bold',
                                          color: secondaryColor),
                                    )),
                                content: Text(
                                    'Could not resend verification email. Check your internet connection and do not resend the email too many times.',
                                    style: TextStyle(
                                        fontFamily: 'Poppins Regular',
                                        color: secondaryColor)),
                                actions: [
                                  FlatButton(
                                      onPressed: () {
                                        Navigator
                                            .of(
                                            context,
                                            rootNavigator: true)
                                            .pop();
                                      },
                                      child: Text(
                                        'Ok',
                                        style: TextStyle(
                                            color: secondaryColor,
                                            fontFamily: 'Poppins Regular'),
                                      ))
                                ],
                                elevation: 24,
                                backgroundColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius
                                        .all(
                                        Radius
                                            .circular(
                                            20))),
                              );
                            },
                            barrierDismissible: false);
                      }
                    } else {
                      showDialog(
                          context: context,
                          builder: (_) {
                            return AlertDialog(
                              title: Center(
                                  child: Text(
                                    'Attention',
                                    style: TextStyle(
                                        fontFamily: 'Poppins Bold',
                                        color: secondaryColor),
                                  )),
                              content: Text(
                                  'The verification email has already been resent to you.',
                                  style: TextStyle(
                                      fontFamily: 'Poppins Regular',
                                      color: secondaryColor)),
                              actions: [
                                FlatButton(
                                    onPressed: () {
                                      Navigator
                                          .of(
                                          context,
                                          rootNavigator: true)
                                          .pop();
                                    },
                                    child: Text(
                                      'Ok',
                                      style: TextStyle(
                                          color: secondaryColor,
                                          fontFamily: 'Poppins Regular'),
                                    ))
                              ],
                              elevation: 24,
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius
                                      .all(
                                      Radius
                                          .circular(
                                          20))),
                            );
                          },
                          barrierDismissible: false);
                    }

                  },
                ),
                RaisedButton.icon(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  label: Text('Return to Login', style: TextStyle(color:  primaryColor, fontFamily: 'Poppins Regular'),),
                  icon: Icon(Icons.arrow_back, color: primaryColor,),
                  color: secondaryColor,
                  onPressed: () async {
                    await _auth.signOut();
                    return SignIn();



                  },
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
