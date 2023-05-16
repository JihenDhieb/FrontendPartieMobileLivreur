import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Compte extends StatefulWidget {
  final Map<String, dynamic> userData;
  Compte(this.userData);
  @override
  _CompteState createState() => _CompteState();
}

class _CompteState extends State<Compte> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Compte',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {},
        ),
      ),
    );
  }
}
