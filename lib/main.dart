import 'package:bookmart/services/auth.dart';
import 'package:bookmart/services/database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/wrapper.dart';
import 'package:provider/provider.dart';
import 'models/user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


String currentTheme;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}



void main() async {


  var permGranted = "granted";
  var permDenied = "denied";
  var permUnknown = "unknown";
  var permProvisional = "provisional";
  WidgetsFlutterBinding.ensureInitialized();
  String deviceTheme = '';
  if (WidgetsBinding.instance.window.platformBrightness == Brightness.dark) {
    deviceTheme = 'Dark';
  } else {
    deviceTheme = 'Blue';
  }
  await Firebase.initializeApp();
  await MobileAds.instance.initialize();
  final _messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await _messaging.requestPermission(alert: true, badge: true, announcement: false, sound: true);
  print('User granted permission: ${settings.authorizationStatus}');
  await _messaging.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    'This channel is used for important notifications.',
    importance: Importance.max,
  );
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification notification = message.notification;
    AndroidNotification android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channel.description,
              icon: android?.smallIcon,
            ),
          ));
    }
  });
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  Future<String> permissionStatus =
  NotificationPermissions.getNotificationPermissionStatus().then((status) {
    switch (status) {
      case PermissionStatus.denied: 
        return permDenied;
      case PermissionStatus.granted:
        return permGranted;
      case PermissionStatus.unknown:
        return permUnknown;
      case PermissionStatus.provisional:
        return permProvisional;
      default:
        return null;
    }
  });
  if ((permissionStatus == permDenied) || (permissionStatus == permGranted)) {
    NotificationPermissions
        .requestNotificationPermissions(
        iosSettings:
        const NotificationSettingsIos(
            sound: true,
            badge: true,
            alert: true));
  }
  currentTheme = deviceTheme;
  String savedTheme;
  savedTheme = await getTheme();
  if (savedTheme == null) {
    currentTheme = deviceTheme;
  } else {
    currentTheme = savedTheme;
  }
  currentTheme = 'Blue';
  final appleSignInAvailable = await SignInWithApple.isAvailable();
  print(currentTheme);
  runApp(Provider<bool>.value(value: appleSignInAvailable,child: MyApp()));
}


class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return StreamProvider<CustomUser>.value(
      value: AuthService().user,
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if(!currentFocus.hasFocus) {
            currentFocus.unfocus();
          }
        },
        child: MaterialApp(
          builder: (context, child) {
            return MediaQuery(
                child: child,
                data: MediaQuery.of(context).copyWith(textScaleFactor: 0.9));
          },
          home: Wrapper(currentTheme: currentTheme)
        ),
      ),
    );
  }
}





