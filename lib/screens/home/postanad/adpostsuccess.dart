import 'package:bookmart/models/post_ad_data_model.dart';
import 'package:bookmart/screens/home/postanad/post_an_ad.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:bookmart/shared/loading.dart';
import 'package:geolocator/geolocator.dart';
import '../../../shared/advertisement_card.dart';

class AdPostSuccess extends StatefulWidget {
  @override
  _AdPostSuccessState createState() => _AdPostSuccessState();
  final Function goToHomeSearch;
  final String currentTheme;
  final PostAdModel createdModel;
  AdPostSuccess({this.goToHomeSearch, this.currentTheme, this.createdModel});
}

class _AdPostSuccessState extends State<AdPostSuccess> {

  bool loading = false;
  bool connectionProblem = false;
  var position, lastPosition;

  Future getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      //lastPosition = await Geolocator.getLastKnownPosition();

      print(
          '$position: Lat: ${position.latitude} // Long: ${position.longitude}');
      print(lastPosition);

      setState(() {
        loading = false;
      });;
    } catch (e) {
      print('Cant get location.');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      loading  = true;
    });
    getCurrentLocation();
  }

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


    if (loading) {
      return Loading(currentTheme: widget.currentTheme,);
    }
    else {
      return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            leading: Container(),
            elevation: 0,
            backgroundColor: primaryColor,
          ),
          body: Container(
            decoration: BoxDecoration(
                color: primaryColor,
                gradient: currentGradient
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Column(
                  children: [
                    SizedBox(height: 75,),
                    Icon(
                      Icons.assignment_turned_in,
                      color: secondaryColor,
                    ),
                    SizedBox(height: 10,),
                    Text(
                      'Advertisement Posted.',
                      style: TextStyle(
                          fontFamily: 'Poppins Bold', color: secondaryColor),),
                    SizedBox(height: 20,),
                    Text(
                      'View it here:',
                      style: TextStyle(
                          fontFamily: 'Poppins Regular', color: secondaryColor),),
                    SizedBox(height: 5,),
                    Center(child: AdvertisementCard(currentTheme: widget.currentTheme, currentModel: widget.createdModel, currentLocation: position,)),
                    SizedBox(height: 10,),
                    RaisedButton.icon(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: secondaryColor)
                      ),
                      label: Text('Return to Home', style: TextStyle(color:  primaryColor, fontFamily: 'Open Sans Semi Bold'),),
                      icon: Icon(Icons.home, color: primaryColor,),
                      color: secondaryColor,
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
}
