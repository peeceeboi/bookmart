import 'dart:io';

import 'package:bookmart/main.dart';
import 'package:bookmart/services/auth.dart';
import 'package:bookmart/services/database.dart';
import 'package:bookmart/shared/view_privacy_policy.dart';
import 'package:bookmart/shared/view_terms_of_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:bookmart/shared/constants.dart';
import 'package:auth_buttons/auth_buttons.dart';
import 'package:bookmart/shared/loading.dart';
import 'package:password_strength/password_strength.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';


class Register extends StatefulWidget {
  final Function toggleView;

  String currentTheme;
  Register({this.toggleView,this.currentTheme});



  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {


  final AuthService _auth = AuthService();

  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String email = '';
  String username = '';
  String password = '';
  String confirmPassword = '';
  String error = '';

  Color primaryColor = Colors.white;
  Color secondaryColor = Colors.blueAccent;





  @override
  Widget build(BuildContext context) {

    final appleSignInAvailable = Provider.of<bool>(context, listen: false);
    print('apple available: ${appleSignInAvailable}');
    bool iosPlatform = Platform.isIOS;

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
      imagePath = 'images/icon64x64.png';
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


    if (loading) {
      return Loading(currentTheme: widget.currentTheme,);
    } else {
      return Scaffold(
          body: Container(
            decoration: BoxDecoration(color: primaryColor, gradient: currentGradient),
            child: Form(
              key: _formKey,
              child: Flex(
                direction: Axis.vertical,
                children: [
                  Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            //SizedBox(height: 12,),
                            Container(alignment: Alignment.center,child: Image(image: ResizeImage(AssetImage(imagePath), width: 80, height: 80), fit: BoxFit.scaleDown)),
                            // SizedBox(
                            //   height: 8,
                            // ),
                            Center(
                              child: TypewriterAnimatedTextKit(
                                textAlign: TextAlign.center,
                                speed: Duration(milliseconds: 50),
                                isRepeatingAnimation: false,
                                totalRepeatCount: 0,
                                text: [" We need some details"],
                                textStyle:
                                TextStyle(fontSize: 24, fontFamily: 'Poppins Bold', color: secondaryColor),
                                pause: Duration(milliseconds: 50),
                              ),
                              // child: Text('We need some details', style: TextStyle(fontSize: 24, fontFamily: 'Poppins Bold', color: secondaryColor), )
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
                              child: TextFormField(
                                style: TextStyle(fontFamily: 'Poppins Regular', ),
                                decoration: textInputDecoration.copyWith(
                                    hintText: 'Enter your email'),
                                validator: (val) {
                                  if (val.isEmpty) {
                                    return 'Enter an email';
                                  } else {
                                    return null;
                                  }
                                },
                                onChanged: (val) {
                                  setState(() {
                                    email = val.trim();
                                  });
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
                              child: TextFormField(
                                obscureText: true,
                                style: TextStyle(fontFamily: 'Poppins Regular'),
                                decoration: textInputDecoration.copyWith(
                                    hintText: 'Enter your password'),
                                validator: (val) {
                                  if (val.length < 8) {
                                    return 'Your password needs to be at least 8 characters.';
                                  } else {
                                    return null;
                                  }
                                },
                                onChanged: (val) {
                                  setState(() {
                                    password = val;
                                  });
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
                              child: TextFormField(
                                obscureText: true,
                                style: TextStyle(fontFamily: 'Poppins Regular'),
                                decoration: textInputDecoration.copyWith(
                                    hintText: 'Enter your password again'),
                                validator: (val) {
                                  if (val != password) {
                                    return "Passwords don't match.";
                                  } else {
                                    return null;
                                  }
                                },
                                onChanged: (val) {
                                  setState(() {
                                    confirmPassword = val;
                                  });
                                },
                              ),
                            ),
                            SizedBox(height: 15,),
                            Text(error, textAlign: TextAlign.center, style: TextStyle(color: secondaryColor, fontFamily: 'Poppins Regular', fontSize: 13)),
                            SizedBox(height: 15,),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(15,5,15,0),
                                child: RaisedButton(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side: BorderSide(color: secondaryColor)
                                  ),
                                  color: secondaryColor,
                                  child: Text(
                                    'Create an Account',
                                    style: TextStyle(
                                        color: primaryColor,
                                        fontFamily: 'Poppins Regular',
                                        fontSize: 15),
                                  ),
                                  onPressed: () async {
                                    if (_formKey.currentState.validate()) {

                                      double strength = estimatePasswordStrength(password);

                                      if (strength < 0.3) {
                                        setState(() {
                                          error = "Please use a stronger password.";
                                        });
                                      } else {
                                        setState(() {
                                          loading = true;
                                        });

                                        bool termsAccepted = await getTermsOfServiceStatus();
                                        bool privacyPolicyAccepted = await getPrivacyPolicyStatus();

                                        if (!termsAccepted) {

                                          bool result = await Navigator.push(
                                            this.context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ViewTermsOfService(
                                                      currentTheme: widget
                                                          .currentTheme,
                                                      fromLogin: true,
                                                    )),
                                          ) ?? false;

                                          if (result) {

                                            await saveTermsAsAccepted();

                                          } else {
                                            setState(() {
                                              loading = false;
                                            });
                                            return;
                                          }

                                        }

                                        if (!privacyPolicyAccepted) {

                                          bool result = await Navigator.push(
                                            this.context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ViewPrivacyPolicy(
                                                      currentTheme: widget
                                                          .currentTheme,
                                                      fromLogin: true,
                                                    )),
                                          ) ?? false;

                                          if (result) {

                                            await savePrivacyPolicyAsAccepted();

                                          } else {
                                            setState(() {
                                              loading = false;
                                            });
                                            return;
                                          }

                                        }

                                        dynamic result = await _auth
                                            .registerWithEmailAndPassword(
                                            email, password);


                                        if (result == null) {
                                          setState(() {
                                            email = '';
                                            password = '';
                                            confirmPassword = '';
                                            loading = false;
                                            error = 'Email is invalid or already signed up.';
                                          });
                                        }
                                        print('Validated');
                                      }


                                    }
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 10,),
                            Center(
                              child: Text('OR', style: TextStyle(color: secondaryColor,
                                  fontFamily: 'Poppins Regular',
                                  fontSize: 16),),
                            ),
                            SizedBox(height: 10,),
                            if(appleSignInAvailable && (iosPlatform))
                              Padding(
                                padding: const EdgeInsets.fromLTRB(67, 10, 67, 5),
                                child: Center(
                                  child: SignInWithAppleButton(
                                    style: SignInWithAppleButtonStyle.white,
                                    text: 'Sign in with Apple',
                                    height: 50,
                                    onPressed: () async {
                                      setState(() {
                                        loading = true;
                                      });

                                      bool termsAccepted = await getTermsOfServiceStatus();
                                      bool privacyPolicyAccepted = await getPrivacyPolicyStatus();

                                      if (!termsAccepted) {

                                        bool result = await Navigator.push(
                                          this.context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ViewTermsOfService(
                                                    currentTheme: widget
                                                        .currentTheme,
                                                    fromLogin: true,
                                                  )),
                                        ) ?? false;

                                        if (result) {

                                          await saveTermsAsAccepted();

                                        } else {
                                          setState(() {
                                            loading = false;
                                          });
                                          return;
                                        }

                                      }

                                      if (!privacyPolicyAccepted) {

                                        bool result = await Navigator.push(
                                          this.context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ViewPrivacyPolicy(
                                                    currentTheme: widget
                                                        .currentTheme,
                                                    fromLogin: true,
                                                  )),
                                        ) ?? false;

                                        if (result) {

                                          await savePrivacyPolicyAsAccepted();

                                        } else {
                                          setState(() {
                                            loading = false;
                                          });
                                          return;
                                        }

                                      }


                                      bool result = await _auth.appleSignIn();
                                      if (!result) {
                                        setState(() {
                                          loading = false;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(15, 5, 15, 0),
                                child: GoogleAuthButton(
                                  text: 'Sign in with Google',
                                  onPressed: () async {
                                    setState(() {
                                      loading = true;
                                    });

                                    bool termsAccepted = await getTermsOfServiceStatus();
                                    bool privacyPolicyAccepted = await getPrivacyPolicyStatus();

                                    if (!termsAccepted) {

                                      bool result = await Navigator.push(
                                        this.context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ViewTermsOfService(
                                                  currentTheme: widget
                                                      .currentTheme,
                                                  fromLogin: true,
                                                )),
                                      ) ?? false;

                                      if (result) {

                                        await saveTermsAsAccepted();

                                      } else {
                                        setState(() {
                                          loading = false;
                                        });
                                        return;
                                      }

                                    }

                                    if (!privacyPolicyAccepted) {

                                      bool result = await Navigator.push(
                                        this.context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ViewPrivacyPolicy(
                                                  currentTheme: widget
                                                      .currentTheme,
                                                  fromLogin: true,
                                                )),
                                      ) ?? false;

                                      if (result) {

                                        await savePrivacyPolicyAsAccepted();

                                      } else {
                                        setState(() {
                                          loading = false;
                                        });
                                        return;
                                      }

                                    }

                                    bool result = await _auth.googleSignIn();
                                    if (!result) {
                                      setState(() {
                                        loading = false;
                                      });
                                    }
                                  },
                                  darkMode: false,
                                  buttonColor: secondaryColor,
                                  elevation: 0,
                                  borderColor: secondaryColor,
                                  textStyle: TextStyle(fontSize: 15,
                                      fontFamily: 'Poppins Regular', color: primaryColor),
                                ),
                              ),
                            ),
                            SizedBox(height: 20,),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(15, 5, 15, 0),
                              child: Center(
                                child: RaisedButton(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side: BorderSide(color: secondaryColor)
                                  ),
                                  color: secondaryColor,
                                  child: Text(
                                    'Return to Sign In',
                                    style: TextStyle(
                                        color: primaryColor,
                                        fontFamily: 'Poppins Regular',
                                        fontSize: 15),
                                  ),
                                  onPressed: () async {
                                    widget.toggleView(widget.currentTheme);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                  )
                ],
              )

            ),
          ));
    }
  }
}
