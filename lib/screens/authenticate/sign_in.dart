import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:bookmart/services/auth.dart';
import 'package:bookmart/services/database.dart';
import 'package:bookmart/shared/view_privacy_policy.dart';
import 'package:bookmart/shared/view_terms_of_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:bookmart/shared/constants.dart';
import 'package:email_validator/email_validator.dart';
import 'package:auth_buttons/auth_buttons.dart';
import 'package:bookmart/shared/loading.dart';
import 'package:bookmart/shared/change_theme.dart';
import 'package:prompt_dialog/prompt_dialog.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:show_up_animation/show_up_animation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io';
import 'package:notification_permissions/notification_permissions.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;
  String currentTheme;

  SignIn({this.toggleView, this.currentTheme});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final AuthService _auth = AuthService();
  var permGranted = "granted";
  var permDenied = "denied";
  var permUnknown = "unknown";
  var permProvisional = "provisional";

  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String email = '';
  String password = '';
  String error = '';

  Color primaryColor = Colors.white;
  Color secondaryColor = Colors.blueAccent;

  @override
  Widget build(BuildContext context) {

    void _showThemePanel() async {
      dynamic theme = await getTheme();

      showModalBottomSheet(
          context: context,
          builder: (context) {
            return ChangeTheme(
              currentTheme: widget.currentTheme,
            );
          });
    }

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

    Future<PermissionStatus> status = NotificationPermissions.getNotificationPermissionStatus();
    NotificationPermissions.getNotificationPermissionStatus().then((status) {
      switch (status) {
        case PermissionStatus.denied:
          return permDenied;
        case PermissionStatus.granted:
          return {
            print('Notification permisssion already granted.')
          };
        case PermissionStatus.unknown: return
          {
           NotificationPermissions.requestNotificationPermissions
          };
        case PermissionStatus.provisional:
          return permProvisional;
        default:
          return null;
      }
    });

    final appleSignInAvailable = Provider.of<bool>(context, listen: false);
    print('apple available: ${appleSignInAvailable}');
    bool iosPlatform = Platform.isIOS;
    if (loading) {
      return Loading(
        currentTheme: widget.currentTheme,
      );
    } else {
      return Scaffold(
        backgroundColor: primaryColor,
        body: Container(
          decoration:
              BoxDecoration(color: primaryColor, gradient: currentGradient),
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
                      children: <Widget>[
                        Container(alignment: Alignment.center,child: Image(image: ResizeImage(AssetImage(imagePath), width: 80, height: 80), fit: BoxFit.scaleDown)),
                        ShowUpAnimation(
                          // delayStart: Duration(seconds: 0),
                          animationDuration: Duration(milliseconds: 300),
                          curve: Curves.decelerate,
                          direction: Direction.vertical,
                          offset: 0.5,
                          child: Center(
                              child: Text(
                                'Bookmart',
                                style: TextStyle(
                                    color: secondaryColor,
                                    fontSize: 28,
                                    fontFamily: 'Poppins Bold'),
                              )),
                        ),
                        SizedBox(height: 8,),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),       // fromLTRB(10, 7, 10, 7)
                          child: TextFormField(
                            
                            style: TextStyle(fontFamily: 'Poppins Regular'),
                            decoration: textInputDecoration.copyWith(hintText: 'Email'),
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
                            decoration:
                            textInputDecoration.copyWith(hintText: 'Password'),
                            validator: (val) {
                              if (val.isEmpty) {
                                return 'Enter a password';
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
                        SizedBox(
                          height: 3,
                        ),
                        Center(
                            child: Text(error,
                                style: TextStyle(
                                    color: secondaryColor,
                                    fontFamily: 'Poppins Regular',
                                    fontSize: 13))),
                        SizedBox(
                          height: 3,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(15, 5, 15, 0),
                          child: Center(
                            child: RaisedButton(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                  side: BorderSide(color: secondaryColor)),
                              color: secondaryColor,
                              child: Text(
                                'Sign in',
                                style: TextStyle(
                                    color: primaryColor,
                                    fontFamily: 'Poppins Regular',
                                    fontSize: 15),
                              ),
                              onPressed: () async {
                                if (_formKey.currentState.validate()) {
                                  setState(() {
                                    loading = true;
                                  });
                                  dynamic result = await _auth
                                      .signInWithEmailAndPassword(email, password);

                                  if (result == null) {
                                    setState(() {
                                      loading = false;
                                      error = 'Credential/Connection Error';
                                    });
                                  }
                                }
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Center(
                            child: Text(
                              'OR',
                              style: TextStyle(
                                  color: secondaryColor,
                                  fontFamily: 'Poppins Regular',
                                  fontSize: 16),
                            )),
                        SizedBox(
                          height: 10,
                        ),
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
                        Padding(
                          padding: const EdgeInsets.fromLTRB(60, 5, 60, 0),
                          child: Center(
                            child: GoogleAuthButton(
                              elevation: 0,
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
                              buttonColor: secondaryColor,
                              borderColor: secondaryColor,
                              darkMode: false,
                              textStyle: TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'Poppins Regular',
                                  color: primaryColor),
                            ),
                          ),
                        ),

                        SizedBox(
                          height: 30,
                        ),
                        Center(
                          child: Text(
                            'No account? Register here:',
                            style: TextStyle(
                                color: secondaryColor,
                                fontFamily: 'Poppins Regular'),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(15, 5, 15, 0),
                          child: Center(
                            child: RaisedButton(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                  side: BorderSide(color: secondaryColor)),
                              color: secondaryColor,
                              child: Text(
                                'Create an Account',
                                style: TextStyle(
                                    color: primaryColor,
                                    fontFamily: 'Poppins Regular',
                                    fontSize: 15),
                              ),
                              onPressed: () async {
                                // if (_formKey.currentState.validate()) {
                                //   setState(() {
                                //     loading = true;
                                //   });
                                //   dynamic result = await _auth
                                //       .signInWithEmailAndPassword(email, password);
                                //
                                //   if (result == null) {
                                //     setState(() {
                                //       loading = false;
                                //       error = 'Credential/Connection Error';
                                //     });
                                //   }
                                // }
                                print(widget.currentTheme);
                                widget.toggleView(widget.currentTheme);

                                //return Authenticate(currentTheme: widget.currentTheme, showWhat: Register, );
                                //widget.returnRegister();
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(15, 5, 15, 0),
                          child: Center(
                            child: RaisedButton(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                  side: BorderSide(color: secondaryColor)),
                              color: secondaryColor,
                              child: Text(
                                'Forgot my Password',
                                style: TextStyle(
                                    color: primaryColor,
                                    fontFamily: 'Poppins Regular',
                                    fontSize: 15),
                              ),
                              onPressed: () async {
                                String entry = await prompt(
                                  context,
                                  title: Text('Enter your email:', style: TextStyle(color: primaryColor, fontSize: 17, fontFamily: 'Poppins Bold'),),
                                  initialValue: '',
                                  textOK: Text('Ok', style: TextStyle(color: primaryColor, fontSize: 17, fontFamily: 'Poppins Regular')),
                                  textCancel: Text('Cancel', style: TextStyle(color: primaryColor, fontSize: 17, fontFamily: 'Poppins Regular')),
                                  hintText: '',
                                  minLines: 1,
                                  maxLines: 1,
                                  autoFocus: false,
                                  obscureText: false,
                                  obscuringCharacter: '•',
                                  textCapitalization: TextCapitalization.none,
                                );
                                print(entry);

                                if (entry != null) {
                                  bool isEmail = EmailValidator.validate(entry.trim());
                                  if (isEmail) {
                                    QuerySnapshot userSnap = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: entry.trim()).get();
                                    if (userSnap.docs.isEmpty) {
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
                                                  'If there is a user linked to this email, an email containing instructions on how to reset your password will be emailed to you.',
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
                                      Timestamp timestamp = userSnap.docs.first.data()['lastEmailSent'] ?? null;
                                      bool emailAllowed = true;

                                      if (timestamp != null) {
                                        DateTime date = timestamp.toDate();
                                        if (DateTime.now().difference(date).inMinutes < 30) {
                                          emailAllowed = false;
                                        }
                                      } else {
                                        emailAllowed = true;
                                      }
                                      if (emailAllowed) {

                                        final prefs = await SharedPreferences.getInstance();
                                        final lastForgotPasswordSent = prefs.getString('lastForgotPasswordSent') ?? null;
                                        if (lastForgotPasswordSent != null) {
                                          DateTime stamp = DateTime.parse(lastForgotPasswordSent);
                                          if (DateTime.now().difference(stamp).inDays == 0) {
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
                                                        'Please refrain from sending too many emails. Make sure to check your inbox as well as your spam folder.',
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
                                            return;
                                          } else {
                                            await prefs.setString("lastForgotPasswordSent", DateTime.now().toString());

                                          }

                                        }

                                        await AuthService().forgotPassword(entry.trim());
                                        // userSnap.docs.first.reference.update
                                        // await userSnap.docs.first.reference.update(
                                        //     {
                                        //       'lastEmailSent' : DateTime.now(),
                                        //     }
                                        // );
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
                                                    'If there is a user linked to this email, an email containing instructions on how to reset your password will be emailed to you.',
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
                                                    'Please refrain from sending too many emails. Make sure to check your inbox as well as your spam folder.',
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
                                                'Please enter a valid email.',
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
                                }

                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        // !(Platform.isIOS) ? Center(
                        //   child: FlatButton.icon(
                        //     onPressed: () async {
                        //       _showThemePanel();
                        //     },
                        //     icon: Icon(
                        //       Icons.menu,
                        //       color: secondaryColor,
                        //     ),
                        //     label: Text(
                        //       'Change Theme',
                        //       style: TextStyle(
                        //           fontFamily: 'Poppins Regular',
                        //           color: secondaryColor),
                        //     ),
                        //   ),
                        // )
                        // : SizedBox(height: 1,)
                      ],
                    ),
                  ),
                ),
              ],
            )


          ),
        ),
      );
    }
  }
}
