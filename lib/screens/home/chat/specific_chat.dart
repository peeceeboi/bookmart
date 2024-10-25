import 'dart:ffi';
import 'dart:io';
import 'package:bookmart/shared/confirmation_dialog.dart';
import 'package:bookmart/shared/deposit_amount.dart';
import 'package:bookmart/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:provider/provider.dart';
import 'package:bookmart/models/user.dart';
import 'package:pay/pay.dart';

class SpecificChat extends StatefulWidget {
  @override
  _SpecificChatState createState() => _SpecificChatState();

  final String currentTheme;
  final String chatroomID;
  String chattingTo;
  final bool payable;

  SpecificChat({this.currentTheme, this.chatroomID, this.chattingTo, this.payable});
}

class _SpecificChatState extends State<SpecificChat> {
  bool hasNotifiedOfRisk = false;

  var _paymentItems = [
    PaymentItem(
      label: 'Total',
      amount: '99.99',
      status: PaymentItemStatus.final_price,
    )
  ];


  String userMessage = '';

  final ScrollController _scrollController = ScrollController();
  final messageFieldController = TextEditingController();

  bool canSendMessage = true;

  bool loading = false;

  void onGooglePayResult(paymentResult) {
    // Send the resulting Google Pay token to your server / PSP
  }
  bool iosPlatform = Platform.isIOS;

  @override
  Widget build(BuildContext context) {
    Color primaryColor;
    Color secondaryColor;

    String imagePath;
    Gradient currentGradient;
    if (widget.currentTheme == 'Light') {
      primaryColor = Colors.teal;
      secondaryColor = Colors.white;
      imagePath = 'images/book-blueAccent.png';
      currentGradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.teal, Colors.white]);
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

    final user = Provider.of<CustomUser>(context);

    Future<String> _askedToLead() async {
      switch (await showDialog<String>(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              elevation: 24,
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: secondaryColor, width: 1),
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              title: Text(
                'Settings',
                style: TextStyle(
                    color: secondaryColor, fontFamily: 'Poppins Bold'),
              ),
              children: <Widget>[
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, 'Delete');
                  },
                  child: Text(
                    'Delete this Chat',
                    style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Poppins Regular',
                        color: secondaryColor),
                  ),
                ),
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, 'Block');
                  },
                  child: Text(
                    'Report and Block',
                    style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Poppins Regular',
                        color: secondaryColor),
                  ),
                ),
              ],
            );
          })) {
        case 'Delete':
          {
            setState(() {
              loading = true;
            });
            DocumentSnapshot chatroomRef = await FirebaseFirestore.instance
                .collection('chatrooms')
                .doc(widget.chatroomID)
                .get();
            List<dynamic> visibleTo = chatroomRef.data()['visibleTo'];
            DocumentReference currentUser =
                FirebaseFirestore.instance.collection('users').doc(user.uid);
            int index =
                visibleTo.indexWhere((element) => element == currentUser);
            visibleTo[index] = null;
            await FirebaseFirestore.instance
                .collection('chatrooms')
                .doc(widget.chatroomID)
                .update({'visibleTo': visibleTo});
            print('visibleTo: ${visibleTo[0] == null && visibleTo[1] == null}');
            DocumentSnapshot doc = await FirebaseFirestore.instance
                .collection('chatrooms')
                .doc(widget.chatroomID)
                .get();
            bool NoMessages;
            if (doc.data()['messages'].isEmpty) {
              NoMessages = true;
            } else {
              NoMessages = false;
            }
            if ((visibleTo[0] == null && visibleTo[1] == null) || NoMessages) {
              await chatroomRef.reference.delete();
            }
            setState(() {
              loading = false;
            });
            return 'Delete';
          }

          break;

        case 'Block':
          {
            setState(() {
              loading = true;
            });
            bool alreadyBlocked = false;
            DocumentSnapshot chatroomRef = await FirebaseFirestore.instance
                .collection('chatrooms')
                .doc(widget.chatroomID)
                .get();
            DocumentReference sellerUserRef =
                chatroomRef.data()['participants'][0];
            DocumentReference otherUserRef;
            if (sellerUserRef.id == user.uid) {
              otherUserRef = chatroomRef.data()['participants'][1];
            } else {
              otherUserRef = sellerUserRef;
            }
            print('Other user ID: ${otherUserRef.id}');
            DocumentSnapshot otherUserSnap = await otherUserRef.get();
            int numOtherUserFlagged =
                otherUserSnap.data()['timesReported'] ?? 0;
            DocumentSnapshot currentUserSnap = await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();
            List<dynamic> blockedUsers =
                currentUserSnap.data()['blockedUsers'] ??
                    List.generate(0, (index) => null);
            if (blockedUsers == null) {
              blockedUsers.add(otherUserRef);
            } else {
              alreadyBlocked = blockedUsers.contains(otherUserRef);
              if (!alreadyBlocked) {
                blockedUsers.add(otherUserRef);
              }
            }
            numOtherUserFlagged++;
            List<dynamic> visibleTo = chatroomRef.data()['visibleTo'];
            int index =
                visibleTo.indexWhere((element) => element.id == user.uid);
            visibleTo[index] = null;
            //visibleTo.removeWhere((element) => element.id == user.uid);
            if (!alreadyBlocked) {
              await chatroomRef.reference.update({'visibleTo': visibleTo});
              await otherUserRef.update({'timesReported': numOtherUserFlagged});
              await currentUserSnap.reference
                  .update({'blockedUsers': blockedUsers});
              print(numOtherUserFlagged);
              Navigator.pop(context);
            } else {
              showDialog(
                  context: context,
                  builder: (_) {
                    return AlertDialog(
                      title: Center(
                          child: Text(
                        'Attention',
                        style: TextStyle(
                            fontFamily: 'Poppins Bold', color: secondaryColor),
                      )),
                      content: Text('You have already blocked this user.',
                          style: TextStyle(
                              fontFamily: 'Poppins Regular',
                              color: secondaryColor)),
                      actions: [
                        FlatButton(
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true).pop();
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
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                    );
                  },
                  barrierDismissible: false);
            }
            setState(() {
              loading = false;
            });
            return 'Block';
          }
          break;
      }
    }

    void pay() {
      showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Center(
                  child: Text(
                    'AvailableAvailable payment methods',
                    style: TextStyle(
                        fontFamily:
                        'Poppins Bold',
                        color:
                        secondaryColor),
                  )),
              content: Container(
                child:  iosPlatform ? ApplePayButton(
                  paymentConfigurationAsset: 'payment_configurations/default_payment_profile_apple_pay.json',
                  paymentItems: _paymentItems,
                  style: ApplePayButtonStyle.white,
                  type: ApplePayButtonType.buy,
                  // width: double.infinity,
                  // height: double.infinity,
                  // margin: const EdgeInsets.fromLTRB(5, 1, 5, 1),
                  onPaymentResult: onGooglePayResult,
                  loadingIndicator: Center(
                    child: Loading(currentTheme: widget.currentTheme,),
                  ),
                ) : GooglePayButton(
                  paymentConfigurationAsset: 'payment_configurations/default_payment_profile_google_pay.json',
                  paymentItems: _paymentItems,
                  style: GooglePayButtonStyle.white,
                  type: GooglePayButtonType.pay,
                  // margin: const EdgeInsets.only(top: 15.0),
                  onPaymentResult: onGooglePayResult,
                  loadingIndicator: Center(
                    child: Loading(currentTheme: widget.currentTheme,),
                  ),
                ),
              ),
              // actions: [
              //   FlatButton(
              //       onPressed: () {
              //         Navigator.of(
              //             context,
              //             rootNavigator:
              //             true)
              //             .pop();
              //       },
              //       child: Text(
              //         'Ok',
              //         style: TextStyle(
              //             color:
              //             secondaryColor,
              //             fontFamily:
              //             'Poppins Regular'),
              //       ))
              // ],
              elevation: 24,
              backgroundColor:
              primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.all(
                      Radius
                          .circular(
                          20))),
            );
          },
          barrierDismissible: true);
    }


    String currentUserRole = '';
    String chatTitle = '';

    Future<bool> sendMessageToChatroom(
        String message, bool isCurrentUserSeller) async {
      final filter = ProfanityFilter();
      bool hasProfanity = filter.hasProfanity(message);
      if (hasProfanity) {
        return false;
      } else {
        try {
          DocumentReference authorRef =
              FirebaseFirestore.instance.collection('users').doc(user.uid);
          DocumentReference chatroomRef = FirebaseFirestore.instance
              .collection('chatrooms')
              .doc(widget.chatroomID);
          // Map<String, dynamic> messageOnly = {
          //   'content' : message,
          //   'sender' : user.uid,
          // };
          List<bool> readBy = List.generate(2, (index) => false);
          if (isCurrentUserSeller) {
            readBy[0] = true;
          } else {
            readBy[1] = true;
          }
          Map<String, dynamic> serializedMessage = {
            'content': message,
            'sender': user.uid,
            'timestamp': DateTime.now(),
            'readBy': readBy
          };
          await chatroomRef.update({
            "messages": FieldValue.arrayUnion([serializedMessage])
          });
          return true;
        } catch (e) {
          print(e.toString());
          return false;
        }
      }
    }

    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chatrooms')
            .doc(widget.chatroomID)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            bool isParticipantsNull = snapshot.data.data() == null;
            if (!isParticipantsNull) {
              if (snapshot.data.data()['participants'][0] ==
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)) {
                currentUserRole = 'seller';
              } else {
                currentUserRole = 'buyer';
              }
            } else {
              currentUserRole = 'seller';
            }

            if (currentUserRole == 'seller') {
              bool isParticipantsNull = snapshot.data.data() == null;
              if (!isParticipantsNull) {
                chatTitle = 'Buying ${snapshot.data.data()['initialProduct']}';
              }
            } else {
              if (!isParticipantsNull) {
                chatTitle = 'Selling ${snapshot.data.data()['initialProduct']}';
              }
            }

            var messages = snapshot.data.data() != null
                ? snapshot.data.data()['messages']
                : null;

            if (loading) {
              return Loading(
                currentTheme: widget.currentTheme,
              );
            } else {
              return Scaffold(
                  appBar: AppBar(
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    backgroundColor: primaryColor,
                    flexibleSpace: SafeArea(
                      child: Container(
                        padding: EdgeInsets.only(right: 16),
                        child: Row(
                          children: <Widget>[
                            IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(
                                Icons.arrow_back,
                                color: secondaryColor,
                              ),
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    widget.chattingTo,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Poppins Bold',
                                        color: secondaryColor),
                                  ),
                                  Text(
                                    chatTitle,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'Poppins Regular',
                                        color: secondaryColor),
                                  ),
                                ],
                              ),
                            ),
                            (widget.payable ?? false) ? FlatButton.icon(color: Colors.blueAccent, onPressed: () async {

                              // pay();

                              try {

                                setState(() {
                                  loading = true;
                                });

                                DocumentReference buyer = snapshot.data.data()['participants'][1];
                                DocumentReference seller = snapshot.data.data()['participants'][0];

                                var buyerDoc, sellerDoc;

                                if (user.uid == buyer.id) {
                                  buyerDoc = await buyer.get();
                                  sellerDoc = await seller.get();

                                } else {
                                  buyerDoc = await seller.get();
                                  sellerDoc = await buyer.get();

                                }

                                double buyerBalance = buyerDoc.data()['balance'] * 1.0;
                                double sellerBalance = sellerDoc.data()['balance'] * 1.0;

                                double payableAmount = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          DepositAmount(

                                          )),
                                );

                                if (payableAmount != null) {

                                  if (payableAmount > buyerBalance) {
                                    showDialog(
                                        context: context,
                                        builder: (_) {
                                          return AlertDialog(
                                            title: Center(
                                                child: Text(
                                                  'Attention',
                                                  style: TextStyle(
                                                      fontFamily:
                                                      'Poppins Bold',
                                                      color:
                                                      secondaryColor),
                                                )),
                                            content: Text(
                                                'Insufficient funds.',
                                                style: TextStyle(
                                                    fontFamily:
                                                    'Poppins Regular',
                                                    color:
                                                    secondaryColor), textAlign: TextAlign.center,),
                                            actions: [
                                              FlatButton(
                                                  onPressed: () {
                                                    Navigator.of(
                                                        context,
                                                        rootNavigator:
                                                        true)
                                                        .pop();
                                                  },
                                                  child: Text(
                                                    'Ok',
                                                    style: TextStyle(
                                                        color:
                                                        secondaryColor,
                                                        fontFamily:
                                                        'Poppins Regular'),
                                                  ))
                                            ],
                                            elevation: 24,
                                            backgroundColor:
                                            primaryColor,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.all(
                                                    Radius
                                                        .circular(
                                                        20))),
                                          );
                                        },
                                        barrierDismissible: false);
                                    setState(() {
                                      loading = false;
                                    });
                                    return;

                                  }

                                  bool confirmation = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ConfirmationDialog(
                                              text: 'To pay ${widget.chattingTo} a total of ${buyerDoc.data()['currency']} ${payableAmount.toStringAsFixed(2)}, please type "confirm" in the field below.',
                                            )),
                                  ) ?? false;

                                  if (!confirmation) {

                                    setState(() {
                                      loading = false;
                                    });
                                    return;
                                  }



                                  if ((buyerBalance != null) &&  (sellerBalance != null)) {
                                    double newBuyerBalance = buyerBalance - payableAmount;
                                    double newSellerBalance = sellerBalance + payableAmount;

                                    var collection = FirebaseFirestore.instance.collection('users');

                                    await collection.doc(buyerDoc.id).update(
                                        {
                                          'balance' : newBuyerBalance
                                        });
                                    await collection.doc(sellerDoc.id).update(
                                        {
                                          'balance' : newSellerBalance
                                        });

                                    setState(() {
                                      loading = false;
                                    });

                                    showDialog(
                                        context: context,
                                        builder: (_) {
                                          return AlertDialog(
                                            title: Center(
                                                child: Text(
                                                  'Success',
                                                  style: TextStyle(
                                                      fontFamily:
                                                      'Poppins Bold',
                                                      color:
                                                      secondaryColor),
                                                )),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.done_rounded, color: Colors.white, size: 25,),
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text(
                                                      'Your payment was successful.',
                                                      style: TextStyle(
                                                          fontFamily:
                                                          'Poppins Regular',
                                                          color:
                                                          secondaryColor)),
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              FlatButton(
                                                  onPressed: () {
                                                    Navigator.of(
                                                        context,
                                                        rootNavigator:
                                                        true)
                                                        .pop();
                                                  },
                                                  child: Text(
                                                    'Ok',
                                                    style: TextStyle(
                                                        color:
                                                        secondaryColor,
                                                        fontFamily:
                                                        'Poppins Regular'),
                                                  ))
                                            ],
                                            elevation: 24,
                                            backgroundColor:
                                            primaryColor,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.all(
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
                                                      fontFamily:
                                                      'Poppins Bold',
                                                      color:
                                                      secondaryColor),
                                                )),
                                            content: Text(
                                                'Something went wrong while trying to pay the other user. Please try again later.',
                                                style: TextStyle(
                                                    fontFamily:
                                                    'Poppins Regular',
                                                    color:
                                                    secondaryColor)),
                                            actions: [
                                              FlatButton(
                                                  onPressed: () {
                                                    Navigator.of(
                                                        context,
                                                        rootNavigator:
                                                        true)
                                                        .pop();
                                                  },
                                                  child: Text(
                                                    'Ok',
                                                    style: TextStyle(
                                                        color:
                                                        secondaryColor,
                                                        fontFamily:
                                                        'Poppins Regular'),
                                                  ))
                                            ],
                                            elevation: 24,
                                            backgroundColor:
                                            primaryColor,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.all(
                                                    Radius
                                                        .circular(
                                                        20))),
                                          );
                                        },
                                        barrierDismissible: false);


                                  }

                                } else {


                                  setState(() {
                                    loading = false;

                                  });
                                  return;
                                }


                              } catch (e) {
                                print(e.toString());
                                showDialog(
                                    context: context,
                                    builder: (_) {
                                      return AlertDialog(
                                        title: Center(
                                            child: Text(
                                              'Attention',
                                              style: TextStyle(
                                                  fontFamily:
                                                  'Poppins Bold',
                                                  color:
                                                  secondaryColor),
                                            )),
                                        content: Text(
                                            'Something went wrong while trying to pay the other user. Please make sure you are connected to the internet.',
                                            style: TextStyle(
                                                fontFamily:
                                                'Poppins Regular',
                                                color:
                                                secondaryColor)),
                                        actions: [
                                          FlatButton(
                                              onPressed: () {
                                                Navigator.of(
                                                    context,
                                                    rootNavigator:
                                                    true)
                                                    .pop();
                                              },
                                              child: Text(
                                                'Ok',
                                                style: TextStyle(
                                                    color:
                                                    secondaryColor,
                                                    fontFamily:
                                                    'Poppins Regular'),
                                              ))
                                        ],
                                        elevation: 24,
                                        backgroundColor:
                                        primaryColor,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.all(
                                                Radius
                                                    .circular(
                                                    20))),
                                      );
                                    },
                                    barrierDismissible: false);
                                return;

                              }



                            }, icon: Icon(Icons.payment_outlined, color: secondaryColor,), label: Text(
                              'Pay',
                                       style: TextStyle(
                                           fontSize: 18,
                                           fontFamily: 'Poppins Regular',
                                           color: secondaryColor),

                            ),): Center()
                            ,IconButton(
                                icon: Icon(
                                  Icons.settings,
                                  color: secondaryColor,
                                ),
                                onPressed: () async {
                                  String result = await _askedToLead();
                                  if (result == 'Delete') {
                                    Navigator.pop(context);
                                    //return Chat(currentTheme: widget.currentTheme,);
                                  }
                                })
                          ],
                        ),
                      ),
                    ),
                  ),
                  body: Container(
                      decoration: BoxDecoration(
                          color: primaryColor, gradient: currentGradient),
                      child: Flex(
                        direction: Axis.vertical,
                        children: [
                          Expanded(
                            child: messages != null
                                ? ListView.builder(
                                    itemCount:
                                        snapshot.data.data()['messages'].length,
                                    controller: _scrollController,
                                    shrinkWrap: true,
                                    reverse: true,
                                    padding:
                                        EdgeInsets.only(top: 10, bottom: 10),
                                    //physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      Map<String, dynamic> message =
                                          snapshot.data.data()['messages'][
                                              snapshot.data
                                                      .data()['messages']
                                                      .length -
                                                  1 -
                                                  index];
                                      return Container(
                                        padding: message['sender'] == user.uid
                                            ? EdgeInsets.only(
                                                left: 40,
                                                right: 16,
                                                top: 5,
                                                bottom: 12)
                                            : EdgeInsets.only(
                                                left: 16,
                                                right: 40,
                                                top: 5,
                                                bottom: 12),
                                        child: Align(
                                            alignment:
                                                (message['sender'] == user.uid
                                                    ? Alignment.topRight
                                                    : Alignment.topLeft),
                                            child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  border: Border.all(
                                                      color: secondaryColor),
                                                  color: (message['sender'] ==
                                                          user.uid
                                                      ? primaryColor
                                                      : secondaryColor),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          12, 6, 12, 6),
                                                  child: SelectableText(
                                                    message['content'],
                                                    style: TextStyle(
                                                        color:
                                                            message['sender'] ==
                                                                    user.uid
                                                                ? secondaryColor
                                                                : primaryColor,
                                                        fontFamily:
                                                            'Poppins Regular',
                                                        fontSize: 16),
                                                  ),
                                                ))),
                                      );
                                    },
                                  )
                                : Center(),
                          ),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Container(
                                // padding: EdgeInsets.only(left: 10,bottom: 10,top: 10,),
                                height: 60,
                                width: double.infinity,
                                // color: secondaryColor,
                                decoration: BoxDecoration(
                                    color: secondaryColor,
                                    borderRadius: BorderRadius.circular(25)),
                                child: Row(
                                  children: <Widget>[
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextField(
                                          controller: messageFieldController,
                                          decoration: InputDecoration(
                                              hintText: "Write message...",
                                              hintStyle: TextStyle(
                                                  color: Colors.black54,
                                                  fontFamily: 'Poppins Regular',
                                                  fontSize: 15),
                                              border: InputBorder.none),
                                          onChanged: (val) {
                                            userMessage = val.trim();
                                          },
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: FloatingActionButton(
                                        onPressed: () async {
                                          messageFieldController.clear();
                                          if (!hasNotifiedOfRisk) {
                                            dynamic otherUserRef;
                                            if (currentUserRole == 'seller') {
                                              otherUserRef = snapshot.data
                                                  .data()['participants'][1];
                                            } else {
                                              otherUserRef = snapshot.data
                                                  .data()['participants'][0];
                                            }
                                            DocumentSnapshot otherUserSnap =
                                                await otherUserRef.get();
                                            var totalReports = otherUserSnap
                                                    .data()['timesReported'] ??
                                                0;
                                            if (totalReports > 3) {
                                              showDialog(
                                                  context: context,
                                                  builder: (_) {
                                                    return AlertDialog(
                                                      title: Center(
                                                          child: Text(
                                                        'Attention',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Poppins Bold',
                                                            color:
                                                                secondaryColor),
                                                      )),
                                                      content: Text(
                                                          'Please note that this user has been reported by some other users. You may communicate with them at your own risk.',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Poppins Regular',
                                                              color:
                                                                  secondaryColor)),
                                                      actions: [
                                                        FlatButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context,
                                                                      rootNavigator:
                                                                          true)
                                                                  .pop();
                                                            },
                                                            child: Text(
                                                              'Ok',
                                                              style: TextStyle(
                                                                  color:
                                                                      secondaryColor,
                                                                  fontFamily:
                                                                      'Poppins Regular'),
                                                            ))
                                                      ],
                                                      elevation: 24,
                                                      backgroundColor:
                                                          primaryColor,
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          20))),
                                                    );
                                                  },
                                                  barrierDismissible: false);
                                            } else {
                                              bool firstMessage = false;
                                              int lastIndex;
                                              DateTime lastSendDate =
                                                  DateTime.now().subtract(
                                                      Duration(seconds: 60));
                                              Duration difference =
                                                  Duration(seconds: 5);
                                              if (canSendMessage) {
                                                lastIndex = snapshot.data
                                                                .data()[
                                                            'messages'] ==
                                                        null
                                                    ? 0 - 1
                                                    : snapshot.data
                                                            .data()['messages']
                                                            .length -
                                                        1;
                                                if (lastIndex == -1) {
                                                  firstMessage = true;
                                                } else {
                                                  lastSendDate = snapshot.data
                                                      .data()['messages']
                                                          [lastIndex]
                                                          ['timestamp']
                                                      .toDate();
                                                  difference = DateTime.now()
                                                      .difference(lastSendDate);
                                                }

                                                print('here');
                                                print(difference.inMinutes);
                                                print(difference.inSeconds);
                                                print(!(difference.inMinutes ==
                                                        0 &&
                                                    difference.inSeconds < 3));
                                                if (!(difference.inMinutes ==
                                                            0 &&
                                                        difference.inSeconds <
                                                            3) ||
                                                    firstMessage) {
                                                  if (userMessage == '') {
                                                    showDialog(
                                                        context: context,
                                                        builder: (_) {
                                                          return AlertDialog(
                                                            title: Center(
                                                                child: Text(
                                                              'Attention',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Poppins Bold',
                                                                  color:
                                                                      secondaryColor),
                                                            )),
                                                            content: Text(
                                                                'You need to enter some text to send.',
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Poppins Regular',
                                                                    color:
                                                                        secondaryColor)),
                                                            actions: [
                                                              FlatButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context,
                                                                            rootNavigator:
                                                                                true)
                                                                        .pop();
                                                                  },
                                                                  child: Text(
                                                                    'Ok',
                                                                    style: TextStyle(
                                                                        color:
                                                                            secondaryColor,
                                                                        fontFamily:
                                                                            'Poppins Regular'),
                                                                  ))
                                                            ],
                                                            elevation: 24,
                                                            backgroundColor:
                                                                primaryColor,
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            20))),
                                                          );
                                                        },
                                                        barrierDismissible:
                                                            false);
                                                  } else {
                                                    //bool Ad = message['sender'] == user.uid
                                                    bool isCurrentUserSeller;
                                                    if (currentUserRole ==
                                                        'seller') {
                                                      isCurrentUserSeller =
                                                          true;
                                                    } else {
                                                      isCurrentUserSeller =
                                                          false;
                                                    }
                                                    bool result =
                                                        await sendMessageToChatroom(
                                                            userMessage,
                                                            isCurrentUserSeller);
                                                    print(
                                                        'Message send result: $result');
                                                    if (!result) {
                                                      showDialog(
                                                          context: context,
                                                          builder: (_) {
                                                            return AlertDialog(
                                                              title: Center(
                                                                  child: Text(
                                                                'Attention',
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Poppins Bold',
                                                                    color:
                                                                        secondaryColor),
                                                              )),
                                                              content: Text(
                                                                  'There was a problem sending your message. '
                                                                  'Either your internet connection is bad or your message contains profanity.',
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Poppins Regular',
                                                                      color:
                                                                          secondaryColor)),
                                                              actions: [
                                                                FlatButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context,
                                                                              rootNavigator: true)
                                                                          .pop();
                                                                    },
                                                                    child: Text(
                                                                      'Ok',
                                                                      style: TextStyle(
                                                                          color:
                                                                              secondaryColor,
                                                                          fontFamily:
                                                                              'Poppins Regular'),
                                                                    ))
                                                              ],
                                                              elevation: 24,
                                                              backgroundColor:
                                                                  primaryColor,
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              20))),
                                                            );
                                                          },
                                                          barrierDismissible:
                                                              false);
                                                    } else {
                                                      messageFieldController
                                                          .clear();
                                                      canSendMessage = true;
                                                      userMessage = '';
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
                                                                fontFamily:
                                                                    'Poppins Bold',
                                                                color:
                                                                    secondaryColor),
                                                          )),
                                                          content: Text(
                                                              'You are sending messages too quickly or your connection is too slow.',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Poppins Regular',
                                                                  color:
                                                                      secondaryColor)),
                                                          actions: [
                                                            FlatButton(
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context,
                                                                          rootNavigator:
                                                                              true)
                                                                      .pop();
                                                                },
                                                                child: Text(
                                                                  'Ok',
                                                                  style: TextStyle(
                                                                      color:
                                                                          secondaryColor,
                                                                      fontFamily:
                                                                          'Poppins Regular'),
                                                                ))
                                                          ],
                                                          elevation: 24,
                                                          backgroundColor:
                                                              primaryColor,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          20))),
                                                        );
                                                      },
                                                      barrierDismissible:
                                                          false);
                                                }
                                                canSendMessage = true;
                                              } else {
                                                showDialog(
                                                    context: context,
                                                    builder: (_) {
                                                      return AlertDialog(
                                                        title: Center(
                                                            child: Text(
                                                          'Attention',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Poppins Bold',
                                                              color:
                                                                  secondaryColor),
                                                        )),
                                                        content: Text(
                                                            'You are sending messages too quickly or your connection is too slow.',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Poppins Regular',
                                                                color:
                                                                    secondaryColor)),
                                                        actions: [
                                                          FlatButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context,
                                                                        rootNavigator:
                                                                            true)
                                                                    .pop();
                                                              },
                                                              child: Text(
                                                                'Ok',
                                                                style: TextStyle(
                                                                    color:
                                                                        secondaryColor,
                                                                    fontFamily:
                                                                        'Poppins Regular'),
                                                              ))
                                                        ],
                                                        elevation: 24,
                                                        backgroundColor:
                                                            primaryColor,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            20))),
                                                      );
                                                    },
                                                    barrierDismissible: false);
                                              }
                                            }
                                            hasNotifiedOfRisk = true;
                                          } else {
                                            bool firstMessage = false;
                                            int lastIndex;
                                            DateTime lastSendDate =
                                                DateTime.now().subtract(
                                                    Duration(seconds: 60));
                                            Duration difference =
                                                Duration(seconds: 5);
                                            if (canSendMessage) {
                                              lastIndex = snapshot.data
                                                          .data()['messages'] ==
                                                      null
                                                  ? 0 - 1
                                                  : snapshot.data
                                                          .data()['messages']
                                                          .length -
                                                      1;
                                              if (lastIndex == -1) {
                                                firstMessage = true;
                                              } else {
                                                lastSendDate = snapshot.data
                                                    .data()['messages']
                                                        [lastIndex]['timestamp']
                                                    .toDate();
                                                difference = DateTime.now()
                                                    .difference(lastSendDate);
                                              }

                                              print('here');
                                              print(difference.inMinutes);
                                              print(difference.inSeconds);
                                              print(!(difference.inMinutes ==
                                                      0 &&
                                                  difference.inSeconds < 3));
                                              if (!(difference.inMinutes == 0 &&
                                                      difference.inSeconds <
                                                          3) ||
                                                  firstMessage) {
                                                if (userMessage == '') {
                                                  showDialog(
                                                      context: context,
                                                      builder: (_) {
                                                        return AlertDialog(
                                                          title: Center(
                                                              child: Text(
                                                            'Attention',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Poppins Bold',
                                                                color:
                                                                    secondaryColor),
                                                          )),
                                                          content: Text(
                                                              'You need to enter some text to send.',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Poppins Regular',
                                                                  color:
                                                                      secondaryColor)),
                                                          actions: [
                                                            FlatButton(
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context,
                                                                          rootNavigator:
                                                                              true)
                                                                      .pop();
                                                                },
                                                                child: Text(
                                                                  'Ok',
                                                                  style: TextStyle(
                                                                      color:
                                                                          secondaryColor,
                                                                      fontFamily:
                                                                          'Poppins Regular'),
                                                                ))
                                                          ],
                                                          elevation: 24,
                                                          backgroundColor:
                                                              primaryColor,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          20))),
                                                        );
                                                      },
                                                      barrierDismissible:
                                                          false);
                                                } else {
                                                  //bool Ad = message['sender'] == user.uid
                                                  bool isCurrentUserSeller;
                                                  if (currentUserRole ==
                                                      'seller') {
                                                    isCurrentUserSeller = true;
                                                  } else {
                                                    isCurrentUserSeller = false;
                                                  }
                                                  bool result =
                                                      await sendMessageToChatroom(
                                                          userMessage,
                                                          isCurrentUserSeller);
                                                  print(
                                                      'Message send result: $result');
                                                  if (!result) {
                                                    showDialog(
                                                        context: context,
                                                        builder: (_) {
                                                          return AlertDialog(
                                                            title: Center(
                                                                child: Text(
                                                              'Attention',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Poppins Bold',
                                                                  color:
                                                                      secondaryColor),
                                                            )),
                                                            content: Text(
                                                                'There was a problem sending your message. '
                                                                'Either your internet connection is bad or your message contains profanity.',
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Poppins Regular',
                                                                    color:
                                                                        secondaryColor)),
                                                            actions: [
                                                              FlatButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context,
                                                                            rootNavigator:
                                                                                true)
                                                                        .pop();
                                                                  },
                                                                  child: Text(
                                                                    'Ok',
                                                                    style: TextStyle(
                                                                        color:
                                                                            secondaryColor,
                                                                        fontFamily:
                                                                            'Poppins Regular'),
                                                                  ))
                                                            ],
                                                            elevation: 24,
                                                            backgroundColor:
                                                                primaryColor,
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            20))),
                                                          );
                                                        },
                                                        barrierDismissible:
                                                            false);
                                                  } else {
                                                    messageFieldController
                                                        .clear();
                                                    canSendMessage = true;
                                                    userMessage = '';
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
                                                              fontFamily:
                                                                  'Poppins Bold',
                                                              color:
                                                                  secondaryColor),
                                                        )),
                                                        content: Text(
                                                            'You are sending messages too quickly or your connection is too slow.',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Poppins Regular',
                                                                color:
                                                                    secondaryColor)),
                                                        actions: [
                                                          FlatButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context,
                                                                        rootNavigator:
                                                                            true)
                                                                    .pop();
                                                              },
                                                              child: Text(
                                                                'Ok',
                                                                style: TextStyle(
                                                                    color:
                                                                        secondaryColor,
                                                                    fontFamily:
                                                                        'Poppins Regular'),
                                                              ))
                                                        ],
                                                        elevation: 24,
                                                        backgroundColor:
                                                            primaryColor,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            20))),
                                                      );
                                                    },
                                                    barrierDismissible: false);
                                              }
                                              canSendMessage = true;
                                            } else {
                                              showDialog(
                                                  context: context,
                                                  builder: (_) {
                                                    return AlertDialog(
                                                      title: Center(
                                                          child: Text(
                                                        'Attention',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Poppins Bold',
                                                            color:
                                                                secondaryColor),
                                                      )),
                                                      content: Text(
                                                          'You are sending messages too quickly or your connection is too slow.',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Poppins Regular',
                                                              color:
                                                                  secondaryColor)),
                                                      actions: [
                                                        FlatButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context,
                                                                      rootNavigator:
                                                                          true)
                                                                  .pop();
                                                            },
                                                            child: Text(
                                                              'Ok',
                                                              style: TextStyle(
                                                                  color:
                                                                      secondaryColor,
                                                                  fontFamily:
                                                                      'Poppins Regular'),
                                                            ))
                                                      ],
                                                      elevation: 24,
                                                      backgroundColor:
                                                          primaryColor,
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          20))),
                                                    );
                                                  },
                                                  barrierDismissible: false);
                                            }
                                          }
                                        },
                                        child: Icon(
                                          Icons.send,
                                          color: secondaryColor,
                                          size: 18,
                                        ),
                                        backgroundColor: primaryColor,
                                        elevation: 0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )));
            }
          } else {
            return Loading(
              currentTheme: widget.currentTheme,
            );
          }
        });
  }
}
