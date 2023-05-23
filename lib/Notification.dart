import 'dart:convert';
import 'package:delivery/Caisse.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPage extends StatefulWidget {
  final String idCaisse;

  NotificationPage({required this.idCaisse});
  @override
  NotificationPageState createState() => NotificationPageState();
}

class NotificationPageState extends State<NotificationPage> {
  late Map<String, dynamic> CaisseData = {};
  @override
  void initState() {
    super.initState();
    _openNotification(context);
  }

  Future<void> _acceptOrder(BuildContext context) async {
    if (CaisseData['idDelivery'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order taken by another Delivery guy!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString('id');
      final String idCaisse1 = widget.idCaisse;
      final request = await http.get(Uri.parse(
          'http://192.168.1.26:8080/caisse/addDeliveryToCaisse/$idCaisse1/$id'));

      if (!mounted) {
        return;
      }

      if (request.statusCode == 200) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => Caisse(idCaisse: idCaisse1)));
      }
      final responce = await http
          .get(Uri.parse('http://192.168.1.26:8080/caisse/SetSold/$idCaisse1'));
      if (request.statusCode == 200) {
        print("yesss");
      }
    }
  }

  Future<void> _openNotification(BuildContext context) async {
    final String idCaisse1 = widget.idCaisse;
    final request = await http
        .get(Uri.parse('http://192.168.1.26:8080/caisse/getCaisse/$idCaisse1'));

    if (!mounted) {
      return;
    }

    if (request.statusCode == 200) {
      setState(() {
        CaisseData = json.decode(request.body);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _acceptOrder(context);
              },
              child: Text(
                'Accept Notification ',
                style: TextStyle(fontSize: 20.0),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                primary: Colors.green, // Couleur de fond du bouton
              ),
            ),
            SizedBox(height: 20), // Espacement entre les boutons
            ElevatedButton(
              onPressed: () {},
              child: Text(
                'Refuse Notification',
                style: TextStyle(fontSize: 20.0),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                primary: Colors.red, // Couleur de fond du bouton
              ),
            ),
          ],
        ),
      ),
    );
  }
}
