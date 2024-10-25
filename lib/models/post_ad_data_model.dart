import 'package:bookmart/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';

class PostAdModel {

  String mainCategory; // Academics OR Fiction OR Non-Fiction
  String subCategory; // Type / Genre
  String bookTitle;
  String condition;
  String author;
  DateTime postDate; // Date of publication
  DateTime dateOfPost;
  NetworkImage cover;
  String description;
  Position adLocation;
  GeoPoint adGeoPoint;
  dynamic generalLocation;
  File providedCover;
  String price;
  String imageLink;
  String currencySymbol;
  double rawPrice;
  bool adPosted;
  String uniqueName;
  String uid;

  PostAdModel({this.uid,this.mainCategory, this.dateOfPost, this.subCategory, this.bookTitle, this.cover, this.author, this.postDate, this.condition, this.description, this.adLocation, this.generalLocation, this.providedCover, this.price, this.imageLink, this.adGeoPoint, this.currencySymbol, this.rawPrice, this.adPosted, this.uniqueName});

  String toString() {
    return 'Main Category: $mainCategory \n SubCategory: $subCategory \n Book Title: $bookTitle \n PostDate: ${postDate.toString()}';
}

}
