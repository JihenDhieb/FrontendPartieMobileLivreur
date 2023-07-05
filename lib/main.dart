import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'Welcome.dart';
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
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id', // Replace with your own channel ID
      'your_channel_name', // Replace with your own channel name
      'your_channel_description', // Replace with your own channel description
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'notification_payload', // Replace with your own payload data
    );
  }

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
        showNotification(
          message.notification!.title!,
          message.notification!.body!,
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
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

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
      if (payload != null) {
        MyApp.navigatorKey.currentState
            ?.pushReplacementNamed('/notification', arguments: payload);
      }
    });

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
