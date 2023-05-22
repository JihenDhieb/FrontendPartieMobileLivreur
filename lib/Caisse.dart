import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:delivery/LoginPage.dart';
import 'package:flutter/material.dart';

class Caisse extends StatefulWidget {
  final String idCaisse;
  Caisse({required this.idCaisse});
  @override
  CaisseState createState() => CaisseState();
}

class CaisseState extends State<Caisse> {
  late Map<String, dynamic> CaisseData = {};
  late Map<String, dynamic> page = {};
  @override
  void initState() {
    super.initState();
    _openNotification(context);
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
        _getArticles(CaisseData["articles"], context);
      });
    }
  }

  Future<void> _getArticles(
      List<dynamic> articles, BuildContext context) async {
    late List<dynamic> articlesCaisse = [];
    if (!mounted) {
      return;
    }
    final response = await http.post(
      Uri.parse('http://192.168.1.26:8080/caisse/getCaisseArticles'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(articles),
    );
    if (response.statusCode == 200) {
      setState(() {
        articlesCaisse = json.decode(response.body);
        page = articlesCaisse[0]['page'];
      });
    }
  }

  Future<void> _SetStatutBeingdelivred() async {
    final String idCaisse1 = widget.idCaisse;
    final request = await http.get(Uri.parse(
        'http://192.168.1.26:8080/caisse/SetStatutBeingdelivred/$idCaisse1'));
    if (request.statusCode == 200) {
      setState(() {
        _openNotification(context);
      });
    }
  }

  Future<void> _SetStatutdelivred() async {
    final String idCaisse1 = widget.idCaisse;
    final request = await http.get(Uri.parse(
        'http://192.168.1.26:8080/caisse/SetStatutdelivred/$idCaisse1'));
    if (request.statusCode == 200) {
      setState(() {
        _openNotification(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Commande '),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => LoginPage()),
            );
          },
        ),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Information Client',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                'Address: ${CaisseData['address']}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
              Text(
                'Street Address: ${CaisseData['streetAddress']}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
              Text(
                'Phone: ${CaisseData['phone']}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
              Text(
                'Selected Time: ${CaisseData['selectedTime']}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Price',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                'Subtotal: ${CaisseData['subTotal']}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
              Text(
                'Frais: ${CaisseData['frais']}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
              Text(
                'Total Price: ${CaisseData['totalPrice']}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Information Vendor',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Name Vendor: ${page['title']}',
              ),
              SizedBox(height: 16.0),
              Text(
                'Phone Vendor: ${page['phone']}',
              ),
              SizedBox(height: 16.0),
              Text(
                'Address Vendor: ${page['address']}',
              ),
              Visibility(
                visible: CaisseData['status'] == 'IN_PREPARATION',
                child: ElevatedButton(
                  onPressed: () {
                    _SetStatutBeingdelivred();
                  },
                  child: Text('BEING_DELIVERED'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.orange, // Couleur orange
                    shadowColor: Colors.transparent,
                    elevation: 0,
                  ),
                ),
              ),
              Visibility(
                visible: CaisseData['status'] == 'BEING_DELIVERED',
                child: ElevatedButton(
                  onPressed: () {
                    _SetStatutdelivred();
                  },
                  child: Text('DELIVERED'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.orange, // Couleur orange
                    shadowColor: Colors.transparent,
                    elevation: 0,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
