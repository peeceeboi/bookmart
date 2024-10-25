import 'dart:convert';
import 'dart:math';

import 'package:bookmart/models/user.dart';
import 'package:bookmart/shared/confirmation_dialog.dart';
import 'package:bookmart/shared/constants.dart';
import 'package:bookmart/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:groovin_widgets/groovin_widgets.dart';
import 'package:http/http.dart' as http;
import 'package:pattern_formatter/numeric_formatter.dart';
import 'package:provider/provider.dart';

class StartWithdrawal extends StatefulWidget {
  final List<String> banks;
  final Map<String, dynamic> response;
  final String currency;
  final String email;
  final bool isBalanceTestMode;

  StartWithdrawal({this.banks, this.response, this.currency, this.email, this.isBalanceTestMode});

  @override
  _StartWithdrawalState createState() => _StartWithdrawalState();
}

class _StartWithdrawalState extends State<StartWithdrawal> {
  Color primaryColor = Colors.blueAccent;
  Color secondaryColor = Colors.white;

  String selectedBank;
  String selectedBankCode = "";
  String accountNumber = "";
  String billingAddress = "";
  String firstName = "";
  String lastName = "";
  // double amount;

  double actualCurrentPrice;

  List<DropdownMenuItem<dynamic>> dropDownBanks = [];

  Gradient currentGradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [Colors.lightBlue[600], Colors.blueAccent]);

  bool loading = false;

  Future<bool> isValidBankInformation() async {
    try {

      Map<String, String> userHeader = {
        "Content-Type": "application/json",
        "Accept": "application/json"
      };

      var body = json.encode(
          {
            "recipientaccount": widget.isBalanceTestMode ? "" : accountNumber,
            "destbankcode": widget.isBalanceTestMode ? "" : selectedBankCode,
            "PBFPubKey": widget.isBalanceTestMode ? "" : ""
          }
      );

      Uri url = Uri.parse("https://api.ravepay.co/flwv3-pug/getpaidx/api/resolve_account");
      http.Response resp =
      await http.post(url, headers: userHeader, body: body);
      print("RESPONSE: " + resp.body);

      dynamic parsedJson = jsonDecode(resp.body);
      String responseCode = parsedJson['data']['data']['responsecode'] ?? "";

      return (responseCode == "00");

    } catch(e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<CustomUser>(context);

    Future<bool> withdraw() async {
      print("ATTEMPTING TO WITHDRAW");

      try {

        var userDoc = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();
        double userBalance = (userDoc.data()['balance'] * 1.0);
        double newBalance = userBalance - actualCurrentPrice;

        if (newBalance < 0) {
          print("Insufficient funds");
          return false;
        }

        Map<String, String> userHeader = {
          "Content-Type": "application/json",
          "Accept": "application/json"
        };

        print("FIRST NAME : " + firstName);
        print("LAST NAME : " + lastName);

        var body = json.encode({
          "seckey": widget.isBalanceTestMode ? "" : "",
          "title": DateTime.now().toString(),
          "bulk_data": [
            {
              "Bank": widget.isBalanceTestMode ? "" : selectedBankCode,
              'Account Number': widget.isBalanceTestMode ? "" : accountNumber,
              "Amount": actualCurrentPrice,
              "Currency": "",
              "meta":
              [
              {
                "FirstName": firstName,
                "LastName": lastName,
                "EmailAddress": widget.email,
                "Address": billingAddress
              }
              ]
            }
          ]
        });
        Uri url = Uri.parse("https://api.ravepay.co/v2/gpx/transfers/create_bulk");

        http.Response resp =
            await http.post(url, headers: userHeader, body: body);

        var jsonBodyResp = jsonDecode(resp.body);
        if (jsonBodyResp["message"] == "BULK-TRANSFER-CREATED") {

          await FirebaseFirestore.instance.collection("users").doc(user.uid).update(
              {
                'balance' : newBalance

              });

          return true;

        } else {
          return false;
        }

      } catch (e) {
        print("ERROR: " + e.toString());
        return false;
      }
    }

    if (loading) {
      return Loading(currentTheme: 'Blue',);
    } else {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.blueAccent,
        ),
        backgroundColor: Colors.blueAccent,
        body: Container(
          decoration: BoxDecoration(gradient: currentGradient),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(
                          color:
                          secondaryColor, //                   <--- border color
                        ),
                        borderRadius: BorderRadius.circular(25)),
                    child: Padding(
                      padding: EdgeInsets.all(15),
                      child: Center(
                        child: Text(
                          'We need some details',
                          style: TextStyle(
                              color: secondaryColor,
                              fontSize: 25,
                              fontFamily: 'Poppins Bold'),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 9,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 7, 10, 0),
                  child: OutlineDropdownButtonFormField(
                    hint: Text('Bank Name'),
                    elevation: 0,
                    style: TextStyle(
                        color: Colors.blueAccent, fontFamily: 'Poppins Regular'),
                    decoration: InputDecoration(
                      labelStyle: TextStyle(fontFamily: 'Poppins Regular'),
                      hintStyle: TextStyle(fontFamily: 'Poppins Regular',),
                      fillColor: Colors.white,
                      filled: true,
                      // enabledBorder:
                      // OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 2), borderRadius: BorderRadius.all(Radius.circular(12))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(
                            color: Colors.white,
                          )),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(
                            color: Colors.white,
                          )),
                    ),
                    value: selectedBank,
                    items: List.generate(
                      widget.banks.length,
                          (index) => DropdownMenuItem(
                          value: widget.banks[index],
                          child: Text(
                            widget.banks[index],
                            style: TextStyle(
                                color: primaryColor,
                                fontFamily: 'Poppins Regular',
                                fontSize: 15),
                          )),
                    ),
                    onChanged: (value) {

                      selectedBank = value;
                      bool done = false;
                      int index = 0;

                      while (!done) {
                        try {
                          if (widget.response['data']['Banks'][index] == null) {
                            done = true;

                          } else {
                            if (widget.response['data']['Banks'][index]["Name"] == selectedBank) {
                              selectedBankCode = widget.response['data']['Banks'][index]['Code'];
                            }
                          }
                          index++;
                        } catch (e) {
                          done = true;
                        }

                      }

                      setState(() {});

                      print("SELECTED: " + selectedBankCode);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
                  // fromLTRB(10, 7, 10, 7)
                  child: TextFormField(
                    initialValue: "",
                    style: TextStyle(fontFamily: 'Poppins Regular'),
                    decoration:
                    textInputDecoration.copyWith(hintText: 'Account Number'),
                    onChanged: (val) {
                      setState(() {
                        accountNumber = val;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
                  // fromLTRB(10, 7, 10, 7)
                  child: TextFormField(
                    initialValue: "",
                    style: TextStyle(fontFamily: 'Poppins Regular'),
                    decoration:
                    textInputDecoration.copyWith(hintText: 'First Name'),
                    onChanged: (val) {
                      setState(() {
                        firstName = val;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
                  // fromLTRB(10, 7, 10, 7)
                  child: TextFormField(
                    initialValue: "",
                    style: TextStyle(fontFamily: 'Poppins Regular'),
                    decoration:
                    textInputDecoration.copyWith(hintText: 'Last Name'),
                    onChanged: (val) {
                      setState(() {
                        lastName = val;
                      });
                    },
                  ),
                ),
                Padding(
                    padding:
                    const EdgeInsets.fromLTRB(10, 7, 10, 7),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        // CurrencyTextInputFormatter()
                        ThousandsFormatter(allowFraction: false)
                      ],
                      // textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Poppins Regular'),
                      decoration: textInputDecoration.copyWith(
                          hintText: 'Amount'),
                      // validator: (val) {
                      //   if (val.isEmpty) {
                      //     // || double.tryParse(val) != null
                      //     return 'Please enter a valid price.';
                      //   } else {
                      //     return null;
                      //   }
                      // },
                      onChanged: (val) {
                        if (val.isNotEmpty && val != null) {

                          // currentPrice = val.toString();

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
                  padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
                  // fromLTRB(10, 7, 10, 7)
                  child: TextFormField(
                    initialValue: "",
                    style: TextStyle(fontFamily: 'Poppins Regular'),
                    decoration:
                    textInputDecoration.copyWith(hintText: 'Billing Address'),
                    onChanged: (val) {
                      setState(() {
                        billingAddress = val;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12),
                  child: RaisedButton(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.white)),
                    color: Colors.white,
                    child: Text(
                      "Withdraw",
                      style: TextStyle(
                          color: Colors.blueAccent,
                          fontFamily: 'Poppins Regular',
                          fontSize: 15),
                    ),
                    onPressed: () async {

                      if ((selectedBankCode.length == 0) || (accountNumber.length == 0) || (actualCurrentPrice == null) || (billingAddress.length == 0)) {
                        showDialog(
                            context: context,
                            builder: (_) {
                              return AlertDialog(
                                title: Center(
                                    child: Text(
                                      'Attention',
                                      style:
                                      TextStyle(fontFamily: 'Poppins Bold', color: secondaryColor),
                                    )),
                                content: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Please fill in all fields.',
                                    style: TextStyle(
                                      fontFamily: 'Poppins Regular',
                                      color: secondaryColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                actions: [
                                  FlatButton(
                                      onPressed: () {
                                        Navigator.of(context, rootNavigator: true).pop();
                                      },
                                      child: Text(
                                        'Ok',
                                        style: TextStyle(
                                            color: secondaryColor, fontFamily: 'Poppins Regular'),
                                      ))
                                ],
                                elevation: 24,
                                backgroundColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(20))),
                              );
                            },
                            barrierDismissible: false);
                        return;
                      }

                      bool result = await Navigator.push(
                        this.context,
                        MaterialPageRoute(
                            builder: (context) => ConfirmationDialog(
                              text:
                              'To withdraw ${widget.currency} ${actualCurrentPrice.toStringAsFixed(2)}, please type "confirm" in the box below.',
                            )),
                      ) ??
                          false;

                      if (result) {
                        setState(() {
                          loading = true;
                        });
                        bool validInfo = true; // await isValidBankInformation();

                        if (validInfo) {

                          bool success = await withdraw() ?? false;
                          setState(() {
                            loading = false;
                          });
                          Navigator.pop(context, success);

                        } else {
                          setState(() {
                            loading = false;
                          });
                          showDialog(
                              context: context,
                              builder: (_) {
                                return AlertDialog(
                                  title: Center(
                                      child: Text(
                                        'Attention',
                                        style:
                                        TextStyle(fontFamily: 'Poppins Bold', color: secondaryColor),
                                      )),
                                  content: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'We were unable to verify your information. Please insure that all fields contain valid entries.',
                                      style: TextStyle(
                                        fontFamily: 'Poppins Regular',
                                        color: secondaryColor,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  actions: [
                                    FlatButton(
                                        onPressed: () {
                                          Navigator.of(context, rootNavigator: true).pop();
                                        },
                                        child: Text(
                                          'Ok',
                                          style: TextStyle(
                                              color: secondaryColor, fontFamily: 'Poppins Regular'),
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
                        // Verify + Withdraw
                      }

                    },

                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

  }
}
