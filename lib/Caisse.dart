import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:delivery/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final request = await http.get(
      Uri.parse('http://192.168.1.26:8080/caisse/getCaisse/$idCaisse1'),
    );

    if (!mounted) {
      return;
    }

    if (request.statusCode == 200) {
      final sharedPreferences = await SharedPreferences.getInstance();

      setState(() {
        CaisseData = json.decode(request.body);
        _getArticles(CaisseData["articles"], context);
      });

      // Store the idCaisse value in local storage
      sharedPreferences.setString('idCaisse', widget.idCaisse);
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
          padding: EdgeInsets.all(70),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    '${CaisseData['reference']}',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 16),
                child: Text(
                  'Information Client',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Address: ${CaisseData['address']}',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Street Address: ${CaisseData['streetAddress']}',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        String phoneNumber = CaisseData['phone'];
                        launch('tel:$phoneNumber');
                      },
                      child: Icon(
                        Icons.phone,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${CaisseData['phone'][0]}${'*' * (CaisseData['phone'].length - 1)}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Selected Time: ${CaisseData['selectedTime']}',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Container(
                margin: EdgeInsets.only(bottom: 16),
                child: Text(
                  'Price',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Subtotal: ${CaisseData['subTotal']}',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Frais: ${CaisseData['frais']}',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 16),
                child: Text(
                  'Total Price: ${CaisseData['totalPrice']}',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
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
              SizedBox(height: 16),
              Container(
                margin: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Name Vendor: ${page['title']}',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Phone: ${page['phone']}',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Address: ${page['address']}',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
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
