import 'package:delivery/Compte.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'ListDelivery.dart';
import 'LoginPage.dart';
import 'RevenueDay.dart';
import 'dart:convert';
import 'Config.dart';

class dashbord extends StatefulWidget {
  final Map<String, dynamic> userData;

  dashbord(this.userData);
  @override
  _dashbordState createState() => _dashbordState();
}

double totlalFrais = 0.0;
Future<int> _getDeliveredCount() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? id = prefs.getString('id');
  final response = await http.get(
    Uri.parse(ApiUrls.baseUrl + '/caisse/$id/delivered-count'),
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
    Uri.parse(ApiUrls.baseUrl + '/caisse/$id/cancel-count'),
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
    Uri.parse(ApiUrls.baseUrl + '/caisse/$id/caisses/count'),
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
    Uri.parse(ApiUrls.baseUrl + '/caisse/$id/revenue/total'),
  );
  if (response.statusCode == 200) {
    int revenueCount = jsonDecode(response.body);
    return revenueCount;
  } else {
    throw Exception('Failed to get cancelCount');
  }
}

Future<double> _getTotalFrais() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? id = prefs.getString('id');

  final totalFraisResponse = await http.get(
    Uri.parse(ApiUrls.baseUrl + '/caisse/totalFrais/$id'),
  );

  if (totalFraisResponse.statusCode == 200) {
    double totalFrais = jsonDecode(totalFraisResponse.body);
    return totalFrais;
  } else {
    throw Exception('Failed to get totalFrais');
  }
}

Future<double> _getTotalCommision() async {
  double totalFrais = await _getTotalFrais();

  final commissionResponse = await http.get(
    Uri.parse(ApiUrls.baseUrl + '/caisse/commission/$totalFrais'),
  );

  if (commissionResponse.statusCode == 200) {
    double commission = jsonDecode(commissionResponse.body);
    return commission;
  } else {
    throw Exception('Failed to get commission');
  }
}

double _totalCommissionAndFrais = 0.0;

class _dashbordState extends State<dashbord> {
  @override
  void initState() {
    super.initState();
    _getDeliveredCount();
    _getCancelCount();
    _gettotalCount();
    _getRevenueCount();
    _getTotalFrais();
    _getTotalCommision();
  }

  bool calculated = false;
  double? cachedCommission;

  @override
  Widget build(BuildContext context) {
    // Your build function code

    Future<double> _fetchCommissionAndFrais() async {
      if (calculated) {
        if (cachedCommission != null) {
          return cachedCommission!;
        }
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString('id');
      final response = await http
          .get(Uri.parse(ApiUrls.baseUrl + '/caisse/commission1/$id'));

      if (response.statusCode == 200) {
        calculated = true;
        final commissionString = response.body;
        try {
          double commission1 = double.parse(commissionString);
          cachedCommission = commission1;
          return commission1;
        } catch (e) {
          throw Exception('Failed to parse commission value');
        }
      } else {
        throw Exception('Failed to fetch commission and frais');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Tableau de bord'),
        backgroundColor: Colors.orange,
        toolbarHeight: 70, // Augmenter la hauteur de l'AppBar à 80 pixels
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Tableau de bord'),
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => dashbord(widget.userData)));
              },
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Compte'),
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => Compte(widget.userData)));
              },
            ),
            ListTile(
              leading: Icon(Icons.local_shipping),
              title: Text('Ma livraison'),
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
              title: Text('Gains'),
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
              title: Text('Déconnexion'),
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
          mainAxisSpacing: 30,
          padding: EdgeInsets.all(10),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                  width: 180,
                  height: 50,
                  color: Colors.green,
                  child: Stack(
                    children: [
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
                                'Livraison terminée',
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
                  )),
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
                            'Livraison annulée',
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
                            'Montant Total Collecté',
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
                            'Frais de livraision',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          FutureBuilder<double>(
                            future: _getTotalFrais(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                double totalFrais = snapshot.data!;
                                return Text(
                                  ' $totalFrais',
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
                    color: Colors.brown,
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.money_off,
                            size: 48,
                            color: Colors.white,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Commission de livraision',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          FutureBuilder<double>(
                            future: _getTotalCommision(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                double commission = snapshot.data!;
                                return Text(
                                  ' $commission',
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
                    color: Colors.purpleAccent,
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.money_off_rounded,
                            size: 48,
                            color: Colors.white,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Commission totale ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          FutureBuilder<double>(
                            future: _fetchCommissionAndFrais(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else if (snapshot.hasData) {
                                double totalCommission = snapshot.data!;
                                return Text(
                                  '$totalCommission',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                );
                              } else {
                                return Text('No Data Available');
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
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => dashbord(widget.userData)));
                  },
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
