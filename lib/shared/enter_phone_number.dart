  import 'dart:io';

import 'package:bookmart/shared/constants.dart';
import 'package:bookmart/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:phone_number/phone_number.dart' as phone_validate;

class EnterPhoneNumber extends StatefulWidget {
  @override
  _EnterPhoneNumberState createState() => _EnterPhoneNumberState();

  final String carrierRegionCode;
  EnterPhoneNumber({this.carrierRegionCode});

}

class _EnterPhoneNumberState extends State<EnterPhoneNumber> {


  bool loading = false;

  String phoneNumber;
  String region;
  String isoCode;

  Gradient currentGradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [Colors.lightBlue[600], Colors.blueAccent]);

  void showErrorMessage(String error) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Center(
                child: Text(
                  'Attention',
                  style: TextStyle(
                      fontFamily: 'Poppins Bold', color: Colors.white),
                )),
            content: Text(
                error,
                style: TextStyle(
                    fontFamily: 'Poppins Regular', color: Colors.white)),
            actions: [
              FlatButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: Text(
                    'Ok',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins Regular'),
                  ))
            ],
            elevation: 24,
            backgroundColor: Colors.blueAccent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
          );
        },
        barrierDismissible: false);

  }

  @override
  Widget build(BuildContext context) {
    if (loading) return Loading(currentTheme: "Blue",);
    else
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 0,
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
                          Colors.white, //                   <--- border color
                    ),
                    borderRadius: BorderRadius.circular(25)),
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Center(
                    child: Text(
                      'Please provide a valid phone number:',
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
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                      color:
                      Colors.white, //                   <--- border color
                    ),
                    borderRadius: BorderRadius.circular(25)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: InternationalPhoneNumberInput(
                    // inputDecoration: textInputDecoration,
                    onInputChanged: (PhoneNumber number) {
                      phoneNumber = number.toString();
                      region = number.dialCode;
                      isoCode = number.isoCode;
                    //  print("locale: " + Platform.localeName);
                      print("Dial Code: " + region);
                      print(number.phoneNumber);
                    },
                    onInputValidated: (bool value) {
                      print(value);
                    },
                    locale: Platform.localeName,
                    inputDecoration: InputDecoration(
                      labelStyle: TextStyle(
                          fontFamily: 'Poppins Regular', color: Colors.white),
                      hintStyle: TextStyle(fontFamily: 'Poppins Regular'),
                      fillColor: Colors.white,
                      filled: true,
                      hintText: "Phone number",
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueAccent),
                          borderRadius: BorderRadius.all((Radius.circular(12)))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all((Radius.circular(12))),
                          borderSide: BorderSide(color: Colors.blueAccent)),
                    ),
                    searchBoxDecoration: InputDecoration(
                      labelStyle: TextStyle(
                          fontFamily: 'Poppins Regular', color: Colors.white),
                      hintStyle: TextStyle(fontFamily: 'Poppins Regular'),
                      fillColor: Colors.white,
                      filled: true,
                      hintText: "Search for your country",
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueAccent),
                          borderRadius: BorderRadius.all((Radius.circular(12)))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all((Radius.circular(12))),
                          borderSide: BorderSide(color: Colors.blueAccent)),
                    ),
                    selectorConfig: SelectorConfig(
                      selectorType: PhoneInputSelectorType.DIALOG,
                    ),
                    ignoreBlank: true,
                    autoValidateMode: AutovalidateMode.disabled,
                    textStyle: TextStyle(
                        color: Colors.grey, fontFamily: "Poppins Regular"),
                    selectorTextStyle: TextStyle(
                        color: Colors.white,
                        fontFamily: "Poppins Regular",fontSize: 18),
                    // initialValue: number,
                    textFieldController: null,
                    formatInput: true,
                    keyboardType: TextInputType.number,
                    inputBorder: OutlineInputBorder(),
                    onSaved: (PhoneNumber number) {
                      print('On Saved: $number');
                    },
                  ),
                ),
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
                  "Done",
                  style: TextStyle(
                      color: Colors.blueAccent,
                      fontFamily: 'Poppins Regular',
                      fontSize: 15),
                ),
                onPressed: () async {

                  setState(() {
                    loading = true;
                  });

                  if (phoneNumber == null || region == null) {
                    print("phone or region is null");
                    return;
                  }
                  print("region: " + region.substring(1));

                  try {
                    phone_validate.PhoneNumber phoneNumberObj = await phone_validate.PhoneNumberUtil().parse(phoneNumber);

                  } catch (e) {
                    print("Unable to parse");
                    setState(() {
                      loading = false;
                    });
                    showErrorMessage("Please enter a valid phone number.");
                    return;

                  }

                  phone_validate.PhoneNumberUtil validator =
                      phone_validate.PhoneNumberUtil();

                  String countryName;

                  List countries = await phone_validate.PhoneNumberUtil().allSupportedRegions();
                  for (int index = 0; index < countries.length; index++) {
                      if (countries[index].code == isoCode) {
                        countryName = countries[index].name;
                      }

                  }
                  phone_validate.RegionInfo regionObj = phone_validate.RegionInfo(name: countryName, code: isoCode, prefix: int.parse(region.substring(1)));

                  bool validNumber =
                      await validator.validate(phoneNumber, regionObj.code);

                  if (validNumber) {
                    phoneNumber = await validator.format(phoneNumber, region);
                    setState(() {
                      loading = false;
                    });
                    Navigator.pop(context, phoneNumber);
                  } else {
                    print("Invalid Number");
                    setState(() {
                      loading = false;
                    });
                    showErrorMessage("Please enter a valid phone number.");
                    setState(() {
                      loading = false;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
