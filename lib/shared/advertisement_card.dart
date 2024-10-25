import 'package:bookmart/models/post_ad_data_model.dart';
import 'package:bookmart/shared/view_specific_ad.dart';
import 'package:bookmart/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:geocoder/geocoder.dart';
import 'dart:math' show cos, sqrt, asin;

import 'package:geolocator/geolocator.dart';

class AdvertisementCard extends StatefulWidget {
  @override
  _AdvertisementCardState createState() => _AdvertisementCardState();

  final String currentTheme;

  final PostAdModel currentModel;

  final Position currentLocation;


  AdvertisementCard({this.currentTheme, this.currentModel, this.currentLocation});
}

class _AdvertisementCardState extends State<AdvertisementCard> {
  bool loading = false;
  var address;

  bool firstLoad = true;

  Position position, lastPosition;

  var distance;

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
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.lightBlue[300], Colors.blue[700]]);
    }


    if (widget.currentTheme == 'Dark') {
      primaryColor = Colors.black;
      secondaryColor = Colors.grey[350];
      currentGradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, Colors.grey[800]]);
    }


    double calculateDistance(lat1, lon1, lat2, lon2){
      var p = 0.017453292519943295;
      var c = cos;
      var a = 0.5 - c((lat2 - lat1) * p)/2 +
          c(lat1 * p) * c(lat2 * p) *
              (1 - c((lon2 - lon1) * p))/2;
      return 12742 * asin(sqrt(a));
    }


    if (firstLoad) {
      distance = calculateDistance(widget.currentModel.adLocation.latitude, widget.currentModel.adLocation.longitude, widget.currentLocation.latitude , widget.currentLocation.longitude).round();
      firstLoad = false;
    }

    if (loading) {
      return Loading(
        currentTheme: widget.currentTheme,
      );
    } else
      firstLoad = false;
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          shape:
              RoundedRectangleBorder(
                  side: BorderSide(color: secondaryColor, width: 1),
                  borderRadius: BorderRadius.circular(10)),
          color: secondaryColor,
          elevation: 0,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              widget.currentModel.dateOfPost = DateTime.now();
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ViewSpecificAd(
                          currentTheme:
                          widget.currentTheme,
                          postAdModel: widget.currentModel,
                          currentUserLocation: widget.currentLocation,
                          model: null,

                        )),
              );
              print('Tapped Ad.');
            },
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: FileImage(widget.currentModel.providedCover),
                  ),
                  title: Text(
                    widget.currentModel.bookTitle,
                    style: TextStyle(
                        color: primaryColor,
                        fontFamily: 'Poppins Bold',
                        fontSize: 15),
                  ),
                  subtitle: Text(
                    'Author: ${widget.currentModel.author}',
                    style: TextStyle(
                        color: primaryColor, fontFamily: 'Poppins Regular'),
                    textAlign: TextAlign.left,
                  ),
                  trailing: Text(
                    widget.currentModel.price,
                    style: TextStyle(
                        color: primaryColor, fontFamily: 'Poppins Regular'),
                  ),
                ),
                ListTile(
                  title: Text(
                    'Condition: ${widget.currentModel.condition}',
                    style: TextStyle(
                        color: primaryColor,
                        fontFamily: 'Poppins Bold',
                        fontSize: 13),
                  ),
                  subtitle: Text(
                    '${widget.currentModel.generalLocation}',
                    style: TextStyle(
                        color: primaryColor,
                        fontFamily: 'Poppins Regular',
                        fontSize: 13),
                  ),
                  trailing: Text(
                    distance.toString() + ' km away',
                    style: TextStyle(
                        color: primaryColor, fontFamily: 'Poppins Regular'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }
}
