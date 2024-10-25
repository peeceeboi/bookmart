import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookmart/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:geocoder/geocoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bookmart/models/post_ad_data_model.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:algolia/algolia.dart';


class DatabaseService {

  final String uid;

  DatabaseService({this.uid});

  final CollectionReference userCollection = FirebaseFirestore.instance
      .collection('users');
  
  final CollectionReference adCollection = FirebaseFirestore.instance.collection('ads');
  Algolia algolia = Algolia.init(applicationId: '', apiKey: '');


  Future updateUserData(String email, bool isGoogleUser) async {
    int index = email.indexOf('@');
    String username = email.substring(0, index);
    if (isGoogleUser) {
      DocumentSnapshot doc = await userCollection.doc(uid).get();
      String previousUsername = doc.data()['username'] ?? '';
      if (previousUsername != '') {
        if (previousUsername != username) {
          username = previousUsername;
        }
      }
    }

    return await userCollection.doc(uid).update({
      'email': email,
      'isGoogleUser': isGoogleUser,
      'username': username,
    });
  }

  Future<bool> userFullyRegistered () async {
    try {
      DocumentReference userRef = userCollection.doc(uid);
      DocumentSnapshot userSnap = await userRef.get();
      bool exists = userSnap.exists;
      return exists;
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  Future<bool> changeDisplayName (String name) async {
    try {
      await userCollection.doc(uid).update({
        'username' : name
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }

  }

  Future<bool> addToPublicWishlist (String ISBN) async {

    try {
      DocumentSnapshot snapshot = await userCollection.doc(uid).get();
      List<String> wishlist = snapshot.data()['publicWishlist'] ?? [];

      if (wishlist.isEmpty) {
        List<String> list = [ISBN];
        wishlist = list;
      } else {
        wishlist.add(ISBN);
      }

      bool exists = false;

      for (int index = 0; index < wishlist.length; index++) {
        if (wishlist[index] == ISBN) {
          exists = true;
          break;
        }
      }

      if (exists) {
        return false;
      } else {

        await userCollection.doc(uid).update({
          'publicWishlist' : wishlist

        });
        return true;

      }


    } catch (e) {
      print(e.toString());
      return false;

    }

  }

  Future<bool> deleteFromPublishWishlist (String ISBN) async {

    try {
      DocumentSnapshot snapshot = await userCollection.doc(uid).get();
      List<String> wishlist = snapshot.data()['publicWishlist'] ?? [];

      if (wishlist.isEmpty) {
        return false;
      } else {

        wishlist.removeWhere((element) => element == ISBN);
        await userCollection.doc(uid).update({
          'publicWishlist' : wishlist

        });
        return true;
      }


    } catch(e) {
      print(e.toString());
      return false;

    }

  }

  Future<bool> addToWatchlist (String adUID) async {
    DocumentSnapshot snapshot = await userCollection.doc(uid).get();
    String currentWatchlist;
    currentWatchlist = snapshot.data()['watchlist'];
    if (currentWatchlist == null) {
      currentWatchlist = '';
    }
    int numHash = '#'.allMatches(currentWatchlist).length;
    bool exists = false;
    if (numHash > 0) {
      List<String> watchListItems = currentWatchlist.split('#');

      for (int index = 0; index <= watchListItems.length - 1; index ++) {
        print('name: ${watchListItems[index]}');
        if (adUID == watchListItems[index]) {
          exists = true;
        }
      }
    }
    print('User current watchlist: $currentWatchlist');
    if (!exists) {
      String newWatchlist = currentWatchlist + adUID + '#';
      print('User new watchlist: $newWatchlist');
      try {
        await userCollection.doc(uid).update({
          'watchlist': newWatchlist
        });

        return true;
      } catch (e) {
        print(e);
        print('Could not add to watchlist.');
        return false;
      }
    } else {
      return false;
    }
  }

  Future<dynamic> addAdvertisement(PostAdModel model, String uniqueName) async {
    try {
      String imageURL;
      String newUniqueName = null;
      if (model.dateOfPost == null) {
        model.postDate = DateTime.now();
        newUniqueName = (uid + model.postDate.toString()).replaceAll(' ', '');
        imageURL = await saveCoverImage(model.providedCover, newUniqueName);
        print('Uploaded cover picture successfully.');
      } else {
        print('Saving new cover image...');
        imageURL = await saveCoverImage(model.providedCover, uniqueName);
        print('Saved successfully');
      }




      GeoPoint adLoc = GeoPoint(model.adLocation.latitude,model.adLocation.longitude);
      final coordinates = Coordinates(
          adLoc.latitude, adLoc.longitude);
      List<Address> addressLocation = await Geocoder.local.findAddressesFromCoordinates(coordinates);

      model.uniqueName = newUniqueName ?? uniqueName;

      if (model.description == '') {
        model.description = null;
      }

       await adCollection.doc(newUniqueName ?? uniqueName).set({
        'condition' : model.condition,
        'coverImage' : imageURL,
        'description' : model.description,
        'location' : adLoc,
        'mainCat' : model.mainCategory,
        'subCat' : model.subCategory,
        'price' : model.price,
        'uid' : uid,
        'title': model.bookTitle,
         'generalLocation': model.generalLocation,
         'author': model.author,
         'country': addressLocation.first.countryName,
         'postDate': model.postDate,
         'rawPrice' : model.rawPrice,
         'currencySymbol': model.currencySymbol,
         'uniqueName' : newUniqueName ?? uniqueName
      });
       return imageURL;
    } catch(e) {
      print(e.toString());
      return null;
    }


  }

  Future<String> saveCoverImage(File image, String name) async {
    Reference ref = FirebaseStorage.instance.ref().child('coverImages/${name}');
    await ref.putFile(image);
    String URL = await ref.getDownloadURL();
    return URL;
  }

  Future<bool> deleteCoverImage(String uniqueName) async {
    try {
      //Reference ref = FirebaseStorage.instance.refFromURL(imageDownloadLink);
      Reference ref = FirebaseStorage.instance.ref().child('coverImages/${uniqueName}');
      await ref.delete();
      return true;
    } catch(e) {
      print(e);
      print('Deletion of previous image failed');
      return false;
    }
  }


  Stream<UserData> get userData {
    return userCollection.doc(uid).snapshots().map(_userDataFromSnapshot);
  }

  Future<List<DocumentSnapshot>>  ads () {
    //return adCollection.doc().snapshots().map(_postAdModelFromSnapshot);
    return adCollection.doc().snapshots().toList();
  }

  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return UserData(
      uid: uid,
      email: snapshot.data()['email'],
      isGoogleUser: snapshot.data()['isGoogleUser'],
      username: snapshot.data()['username'],
      currency: snapshot.data()['currency'],
      balance: (snapshot.data()['balance'] * 1.0),
    );
  }

  Future<bool> deleteFromWatchlist(String uniqueName) async {
    try {
      DocumentSnapshot doc = await userCollection.doc(uid).get();
      String currentWatchlist = doc.data()['watchlist'];
      List<String> watchlist = currentWatchlist.split('#');
      watchlist.removeWhere((element) => element == uniqueName);
      String newWatchlist = '';
      print('Watchlist new length: ${watchlist.length}');
      for (int i = 0; i <= watchlist.length - 1; i ++) {
        if (watchlist[i] != '') {
          newWatchlist = newWatchlist + watchlist[i] + '#';
        }
      }

      await userCollection.doc(uid).update({
        'watchlist': newWatchlist
      });
      return true;
    } catch(e) {
      print('Could not delete from watchlist successfully.');
      print(e);
      return false;
    }


  }

  PostAdModel _postAdModelFromSnapshot(DocumentSnapshot snapshot) {
    return PostAdModel(
      mainCategory: snapshot.data()['mainCat'],
      subCategory: snapshot.data()['subCat'],
      bookTitle: snapshot.data()['title'],
      cover: NetworkImage(snapshot.data()['coverImage']),
      author: snapshot.data()['author'],
      postDate: snapshot.data()['postDate'],
      condition: snapshot.data()['condition'],
      description: snapshot.data()['description'],
      adGeoPoint :   snapshot.data()['location'],
      generalLocation: snapshot.data()['generalLocation'],
      price: snapshot.data()['price'],
      imageLink: snapshot.data()['coverImage']

    );
  }

  Future<List<AlgoliaObjectSnapshot>> getAdsByMainCategory(String mainCategory, searchQuery, String userCountry) async {

    List<AlgoliaObjectSnapshot> _results = [];

    AlgoliaQuery query = algolia.instance.index('posts');

    query = query.search(searchQuery);

    //query = query.setFacetFilter('mainCat=$mainCategory');

    //query = query.setFacetFilter('country=$userCountry');

    _results = (await query.getObjects()).hits;

    _results.removeWhere((element) => (element.data['country']) != userCountry);
    _results.removeWhere((element) => (element.data['mainCat']) != mainCategory);

    return _results;

  }

  Future<List<AlgoliaObjectSnapshot>> getAdsBySubCategory(String subCategory, searchQuery, String userCountry) async {

    //AlgoliaQuery query;
    List<AlgoliaObjectSnapshot> _results = [];

    AlgoliaQuery query = algolia.instance.index('posts');

    query = query.search(searchQuery);

    //query = query.setFacetFilter('["subCat:$subCategory", "country:$userCountry"]');

   //query = query.setFacetFilter('subCat=$subCategory');

   //query = query.setFacetFilter('country=$userCountry');
    
    //query.setFilters('subCat:$subCategory AND country:$userCountry');

    _results = (await query.getObjects()).hits;

    // List<AlgoliaObjectSnapshot> _filteredResults = _results.where((element) => element.data['country'] == userCountry);
    // List<AlgoliaObjectSnapshot> _filteredResults2 = _filteredResults.where((element) => element.data['subCat'] == subCategory);

    _results.removeWhere((element) => (element.data['country']) != userCountry);
    _results.removeWhere((element) => (element.data['subCat']) != subCategory);

    //_results = (await query.algolia.instance.index('posts').search(searchQuery).setFacetFilter('subCat=$subCategory').setFacetFilter('country=$userCountry').getObjects()).hits;



    return _results;
  }

  Future<List<AlgoliaObjectSnapshot>> getAdsFromAllCategories(searchQuery, String userCountry) async {
    List<AlgoliaObjectSnapshot> _results = [];

    AlgoliaQuery query = algolia.instance.index('posts');

    query = query.search(searchQuery);

    //query = query.setFacetFilter('country=$userCountry');

    _results = (await query.getObjects()).hits;

    _results.removeWhere((element) => (element.data['country']) != userCountry);

    return _results;
  }

}



// Local Things:

Future<String> getTheme() async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'theme';
  final value =  prefs.getString(key) ?? 'Blue';
  print(value);
  return value;
}

Future saveTheme(String theme) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'theme';
  prefs.setString(key, theme);
}

Future<bool> getTermsOfServiceStatus() async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'termsofservice';
  final value =  prefs.getString(key) ?? 'N';
  if (value == 'Y') {
    return true;
  } else {
    return false;
  }
}

Future saveTermsAsAccepted() async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'termsofservice';
  prefs.setString(key, "Y");
}

Future<bool> getPrivacyPolicyStatus() async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'privacypolicy';
  final value =  prefs.getString(key) ?? 'N';
  if (value == 'Y') {
    return true;
  } else {
    return false;
  }
}

Future savePrivacyPolicyAsAccepted() async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'privacypolicy';
  prefs.setString(key, "Y");
}