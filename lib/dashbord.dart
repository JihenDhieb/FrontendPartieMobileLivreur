import 'package:delivery/Compte.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'ListDelivery.dart';
import 'LoginPage.dart';
import 'RevenueDay.dart';
import 'dart:convert';

class dashbord extends StatefulWidget {
  final Map<String, dynamic> userData;
  dashbord(this.userData);
  @override
  _dashbordState createState() => _dashbordState();
}

Future<int> _getDeliveredCount() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? id = prefs.getString('id');
  final response = await http.get(
    Uri.parse('http://192.168.1.26:8080/caisse/$id/delivered-count'),
  );
  if (response.statusCode == 200) {
    int deliveredCount = jsonDecode(response.body);
    return deliveredCount;
  } else {
    throw Exception('Failed to get deliveredCount');
  }
}

Future<int> _getCancelCount() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? id = prefs.getString('id');
  final response = await http.get(
    Uri.parse('http://192.168.1.26:8080/caisse/$id/cancel-count'),
  );
  if (response.statusCode == 200) {
    int cancelCount = jsonDecode(response.body);
    return cancelCount;
  } else {
    throw Exception('Failed to get cancelCount');
  }
}

Future<int> _gettotalCount() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? id = prefs.getString('id');
  final response = await http.get(
    Uri.parse('http://192.168.1.26:8080/caisse/$id/caisses/count'),
  );
  if (response.statusCode == 200) {
    int caisseCount = jsonDecode(response.body);
    return caisseCount;
  } else {
    throw Exception('Failed to get cancelCount');
  }
}

Future<int> _getRevenueCount() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? id = prefs.getString('id');
  final response = await http.get(
    Uri.parse('http://192.168.1.26:8080/caisse/$id/revenue/total'),
  );
  if (response.statusCode == 200) {
    int revenueCount = jsonDecode(response.body);
    return revenueCount;
  } else {
    throw Exception('Failed to get cancelCount');
  }
}

class _dashbordState extends State<dashbord> {
  @override
  void initState() {
    super.initState();
    _getDeliveredCount();
    _getCancelCount();
    _gettotalCount();
    _getRevenueCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Colors.orange,
        toolbarHeight: 80, // Augmenter la hauteur de l'AppBar à 80 pixels
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => dashbord(widget.userData)));
              },
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('My Profile'),
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => Compte(widget.userData)));
              },
            ),
            ListTile(
              leading: Icon(Icons.local_shipping),
              title: Text('My Delivery'),
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            ListDelivery(userData: widget.userData)));
              },
            ),
            ListTile(
              leading: Icon(Icons.attach_money),
              title: Text('Earnings'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MyRevenue(userData: {
                      'revenueDates': widget.userData['revenueDates'],
                    }),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Log Out'),
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await Future.wait([
                  prefs.remove('id'),
                  prefs.remove('email'),
                  prefs.remove('password'),
                ]);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        color: Color.fromARGB(255, 255, 255, 255),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          padding: EdgeInsets.all(10),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Container(
                    color: Colors.green,
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delivery_dining,
                            size: 48,
                            color: Colors.white,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Completed delivery',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          FutureBuilder<int>(
                            future: _getDeliveredCount(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                int deliveredCount = snapshot.data!;
                                return Text(
                                  ' $deliveredCount',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                );
                              } else {
                                return CircularProgressIndicator();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Container(
                    color: Colors.red,
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cancel,
                            size: 48,
                            color: Colors.white,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Cancelled delivery',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          FutureBuilder<int>(
                            future: _getCancelCount(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                int cancelCount = snapshot.data!;
                                return Text(
                                  ' $cancelCount',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                );
                              } else {
                                return CircularProgressIndicator();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Container(
                    color: Colors.orange,
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.money,
                            size: 48,
                            color: Colors.white,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Total Collected',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          FutureBuilder<int>(
                            future: _gettotalCount(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                int caisseCount = snapshot.data!;
                                return Text(
                                  ' $caisseCount',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                );
                              } else {
                                return CircularProgressIndicator();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Container(
                    color: Colors.blue,
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.attach_money,
                            size: 48,
                            color: Colors.white,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Earnings',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          FutureBuilder<int>(
                            future: _getRevenueCount(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                int revenueCount = snapshot.data!;
                                return Text(
                                  ' $revenueCount',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                );
                              } else {
                                return CircularProgressIndicator();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Définir la largeur souhaitée
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: const Color.fromARGB(255, 243, 33, 222),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.money,
                      size: 48,
                      color: Colors.white,
                    ),
                    SizedBox(height: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sold',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.userData['sold'].toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomAppBar(
          color: Colors.white,
          child: Container(
            height: 100,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Column(
                    children: [
                      Icon(Icons.dashboard, color: Colors.grey),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => Compte(widget.userData)));
                  },
                  icon: Column(
                    children: [
                      Icon(Icons.account_circle, color: Colors.grey),
                    ],
                  ),
                ),
                Stack(
                  children: [
                    IconButton(
                      icon: Icon(Icons.local_shipping, color: Colors.grey),
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    ListDelivery(userData: widget.userData)));
                      },
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.attach_money, color: Colors.grey),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MyRevenue(userData: {
                          'revenueDates': widget.userData['revenueDates'],
                        }),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
