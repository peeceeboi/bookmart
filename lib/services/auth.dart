import 'package:bookmart/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookmart/services/database.dart';
import 'dart:convert';
import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:crypto/crypto.dart';

class AuthService {

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn =
      GoogleSignIn();

  final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  final _fcm = FirebaseMessaging.instance;

  String generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> appleSignIn() async {

    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    try {

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce
      );

      print('Apple Credentials retrieved: ${appleCredential.email}');

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      print('Attempting to sign in.');

      final authResult =
      await _auth.signInWithCredential(oauthCredential);

      User user = authResult
          .user;

      DocumentSnapshot userSnap = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (!userSnap.exists) {

        print('User snap is null. Updating data...');
        int index = user.email.indexOf('@');
        String username = user.email.substring(0, index);
        String fcmToken = await _fcm.getToken();
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': user.email,
          'isGoogleUser': true,
          'username': username,
          'token': fcmToken
        });

      }

      return true;


    } catch(e) {
      print(e.toString());
      return false;
    }



  }


  Future<bool> googleSignIn() async {
    try {
      GoogleSignInAccount googleUser = await _googleSignIn
          .signIn();

      GoogleSignInAuthentication googleAuth = await googleUser
          .authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth
              .idToken); // credential for sign in retrieved with access tokens

      UserCredential result = await _auth
          .signInWithCredential(credential); // user credentials returned

      User user = result
          .user; // Firebase user is instantiated with credential which is used to login

      // Get User data to see if updating the data is needed
      DocumentSnapshot userSnap = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (!userSnap.exists) {

        print('User snap is null. Updating data...');
        int index = user.email.indexOf('@');
        String username = user.email.substring(0, index);
        String fcmToken = await _fcm.getToken();
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': user.email,
          'isGoogleUser': true,
          'username': username,
          'token': fcmToken
        });

      }

      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }


  // create user object based on FireBase user

  CustomUser _userFromFirebaseUser(User user) {
    return user != null ? CustomUser(uid: user.uid) : null;
  }

  // auth change user stream
  Stream<CustomUser> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  // sign in anonymously
  Future signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

// sign in with email and password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<bool> sendEmailVerification() async {
    try {
      await _auth.currentUser.sendEmailVerification();
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

// register with email and password
  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User user = result.user;
      await user.sendEmailVerification();

      //create a new document for the user with the uid
      int index = email.indexOf('@');
      String username = email.substring(0, index);
      String fcmToken = await _fcm.getToken();
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': email,
        'isGoogleUser': false,
        'username': username,
        'token': fcmToken
      });
      //await DatabaseService(uid: user.uid).updateUserData(email, false);

      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

// sign out
  Future signOut() async {
    try {
      _googleSignIn.signOut();
      _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }

  }

  bool emailVerified() {
    try {
      User currentUser = _auth.currentUser;
      bool isVerified = currentUser.emailVerified;
      print('Verified: $isVerified');
      return isVerified;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  String uid() {
    try {
      User currentUser = _auth.currentUser;
      String uid = currentUser.uid;
      return uid;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future resetPassword() async {

    try {
      User currentUser = _auth.currentUser;
      await _auth.sendPasswordResetEmail(email: currentUser.email);
      return true;

    } catch(e) {
      print(e.toString());
      return false;
    }


  }

  Future forgotPassword(String email) async {

    try {

      await _auth.sendPasswordResetEmail(email: email);
      return true;

    } catch(e) {
      print(e.toString());
      return false;
    }


  }
}
