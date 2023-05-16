import 'package:flutter/material.dart';
import 'Welcome.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null && message.notification != null) {
        print("Received initial message: ${message.notification!.title}");
      }
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        print("Received foreground message: ${message.notification!.title}");
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle messages when the app is opened from a terminated state
      if (message.notification != null) {
        print(
            "Opened app from terminated state: ${message.notification!.title}");
      }
    });

    FirebaseMessaging.instance.getToken().then((String? token) {
      assert(token != null);
    });

    FirebaseMessaging.instance.setAutoInitEnabled(true);
    return MaterialApp(
      routes: {
        '/': (context) => Welcome(),
      },
      initialRoute: '/',
    );
  }
}
