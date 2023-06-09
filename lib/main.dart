import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'Welcome.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'Notification.dart';
import 'LocationService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final LocationService locationService = LocationService();
  locationService.initState();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  final LocationService _locationService = LocationService();

  @override
  Widget build(BuildContext context) {
    _locationService.getCurrentLocation();
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
        MyApp.navigatorKey.currentState?.pushReplacementNamed('/notification',
            arguments: message.data["idCaisse"]);
      }
    });

    FirebaseMessaging.instance.getToken().then((String? token) {
      assert(token != null);
    });

    FirebaseMessaging.instance.setAutoInitEnabled(true);

    return MaterialApp(
      navigatorKey: navigatorKey, // Set the navigatorKey
      routes: {
        '/': (context) => Welcome(),
        '/notification': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as String?;
          return NotificationPage(idCaisse: args ?? '');
        },
      },
      initialRoute: '/',
    );
  }
}
