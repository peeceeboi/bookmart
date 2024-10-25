import 'package:bookmart/models/post_ad_data_model.dart';
import 'package:bookmart/models/user.dart';
import 'package:bookmart/screens/home/postanad/enter_final_details.dart';
import 'package:bookmart/screens/home/postanad/post_an_ad.dart';
import 'package:bookmart/shared/constants.dart';
import 'package:bookmart/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:prompt_dialog/prompt_dialog.dart';
import 'package:provider/provider.dart';

class PublishEducation extends StatefulWidget {
  @override
  _PublishEducationState createState() => _PublishEducationState();

  String currentTheme;
  PostAdModel currentWorkingModel;
  final Function goToFinalDetails;

  PublishEducation({this.currentTheme, this.currentWorkingModel, this.goToFinalDetails});
}

class _PublishEducationState extends State<PublishEducation> {
  List<String> searchList = allMajors;
  @override
  Widget build(BuildContext context) {

    final user = Provider.of<CustomUser>(context);

    print(widget.currentWorkingModel.toString());

    Color primaryColor, secondaryColor;
    String imagePath;
    Gradient currentGradient;
    if (widget.currentTheme == 'Light') {
      primaryColor = Colors.white;
      secondaryColor = Colors.blueAccent;
      imagePath = 'images/book-blueAccent.png';
      currentGradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.grey[200]]);
    }

    if (widget.currentTheme == 'Blue') {
      primaryColor = Colors.blueAccent;
      secondaryColor = Colors.white;
      imagePath = 'images/book-white.png';
      currentGradient = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.lightBlue[600], Colors.blueAccent]);
    }

    if (widget.currentTheme == 'Dark') {
      primaryColor = Colors.black;
      secondaryColor = Colors.grey[350];
      imagePath = 'images/book-blueAccent.png';
      currentGradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, Colors.grey[800]]);
    }


    void prepFinalDetails(String userSelection) {



      int userSelectionIndex = 0;

      for (String sName in allMajors) {
        if (sName == userSelection) {
          break;
        } else {
          userSelectionIndex++;
        }
      }

      widget.currentWorkingModel.subCategory = allMajors[userSelectionIndex];

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                EnterFinalDetails(
                  currentTheme:
                  widget.currentTheme,
                  currentWorkingModel:
                  widget.currentWorkingModel,
                  fromProfilePage: false,
                )),
      );
      //widget.goToFinalDetails(widget.currentWorkingModel);
    }

      bool loading = false;

      if (!loading) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: primaryColor,
            actions: [
              FlatButton(
                onPressed: () async {
                  String entry = await prompt(
                    this.context,
                    title: Text("Let us know which category you were looking for.", style: TextStyle(color: primaryColor, fontSize: 17, fontFamily: 'Poppins Bold'),),
                    initialValue: '',
                    textOK: Text('Ok', style: TextStyle(color: primaryColor, fontSize: 17, fontFamily: 'Poppins Regular')),
                    textCancel: Text('Cancel', style: TextStyle(color: primaryColor, fontSize: 17, fontFamily: 'Poppins Regular')),
                    hintText: '',
                    minLines: 1,
                    maxLines: 1,
                    autoFocus: false,
                    obscureText: false,
                    obscuringCharacter: '•',
                    textCapitalization: TextCapitalization.words,
                  );
                  print(entry);
                  if (entry != null) {

                    try {
                      await FirebaseFirestore.instance.collection('feedback').add({
                        'uid' : user.uid,
                        'category' : entry.trim()
                      });
                      // showDialog(
                      //     context: this.context,
                      //     builder: (_) {
                      //       return AlertDialog(
                      //         title: Center(
                      //             child: Text(
                      //               'Attention',
                      //               style: TextStyle(
                      //                   fontFamily: 'Poppins Bold',
                      //                   color: secondaryColor),
                      //             )),
                      //         content: Text(
                      //             'Thank you for your feedback.',
                      //             style: TextStyle(
                      //                 fontFamily: 'Poppins Regular',
                      //                 color: secondaryColor)),
                      //         actions: [
                      //           FlatButton(
                      //               onPressed: () {
                      //                 Navigator
                      //                     .of(
                      //                     context,
                      //                     rootNavigator: true)
                      //                     .pop();
                      //               },
                      //               child: Text(
                      //                 'Ok',
                      //                 style: TextStyle(
                      //                     color: secondaryColor,
                      //                     fontFamily: 'Poppins Regular'),
                      //               ))
                      //         ],
                      //         elevation: 24,
                      //         backgroundColor: primaryColor,
                      //         shape: RoundedRectangleBorder(
                      //             borderRadius: BorderRadius
                      //                 .all(
                      //                 Radius
                      //                     .circular(
                      //                     20))),
                      //       );
                      //     },
                      //     barrierDismissible: false);
                      prepFinalDetails("Unlisted Subject");
                    } catch(e) {
                      print(e.toString());
                      showDialog(
                          context: this.context,
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
                                  'Something went wrong. Make sure that you have a stable internet connection.',
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
                child: Text("Don't see your category?", style: TextStyle(color: secondaryColor, fontFamily: 'Poppins Bold'),),
                color: primaryColor,

              )
            ],
          ),
          body: Container(
            decoration:
            BoxDecoration(color: primaryColor, gradient: currentGradient),
            child: Flex(
              direction: Axis.vertical,
              children: [
                SizedBox(
                  height: 14,
                ),
                // Text(
                //   'Specify further:',
                //   style: TextStyle(
                //       color: secondaryColor,
                //       fontSize: 16,
                //       fontFamily: 'Open Sans Bold'),
                // ),
                TypewriterAnimatedTextKit(
                  textAlign: TextAlign.center,
                  speed: Duration(milliseconds: 40),
                  isRepeatingAnimation: false,
                  totalRepeatCount: 0,
                  text: ["  Specify further"],
                  textStyle:
                  TextStyle(fontSize: 16, fontFamily: 'Poppins Bold', color: secondaryColor),
                  pause: Duration(milliseconds: 50),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(

                    decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        labelStyle: TextStyle(fontFamily: 'Poppins Regular'),
                        hintStyle: TextStyle(fontFamily: 'Poppins Regular'),
                        //labelText: "Search",
                        hintText: "Search",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)))),
                    onChanged: (val) {
                      setState(() {
                        searchList = allMajors.where((element) =>
                        (element.toLowerCase().contains(val.toLowerCase()))).toList();
                      });
                    },
                  ),
                ),
                Expanded(
                    child: ListView.builder(
                        itemCount: searchList.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                  side: BorderSide(color: secondaryColor)),
                              color: secondaryColor,
                              child: ListTile(
                                onTap: () {
                                  prepFinalDetails(searchList[index]);
                                },
                                title: Center(
                                  child: Text(
                                    searchList[index],
                                    style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 14,
                                        fontFamily: 'Poppins Regular'),
                                  ),
                                ),
                                // leading: Icon(
                                //   Icons.menu_book_rounded,
                                //   color: secondaryColor,
                                // ),
                              ),
                            ),
                          );
                        }))
              ],
            ),
          ),
        );
      } else {
        print("LOADING");
        return Loading(currentTheme: widget.currentTheme,);
      }

    }
  }

