import 'package:delivery/Edit.dart';
import 'package:delivery/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'ListDelivery.dart';
import 'EditPosition.dart';
import 'Revenue.dart';

class Compte extends StatefulWidget {
  final Map<String, dynamic> userData;
  Compte(this.userData);

  @override
  _CompteState createState() => _CompteState();
}

class _CompteState extends State<Compte> {
  late bool isOnline;

  @override
  void initState() {
    super.initState();
    isOnline = widget.userData['enLigne'];
  }

  void toggleOnlineOffline() async {
    String id = widget.userData['id'];
    final response = await http.get(
      Uri.parse('http://192.168.1.26:8080/User/modifyStatusDelivery/$id'),
    );
    if (response.statusCode == 200) {
      setState(() {
        isOnline = !isOnline;
      });
    }
  }

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
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => LoginPage()));
          },
        ),
        // Remove the shadow from the app bar
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => Edit(userData: widget.userData)));
            },
          ),
          IconButton(
            icon: Icon(Icons.location_on),
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => EditPosition(widget.userData['longitude'],
                          widget.userData['latitude'])));
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              leading: Icon(Icons.list),
              title: Text(
                'Delivery List',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 0, 0, 0), // Couleur du texte
                ),
              ),
              tileColor: Colors.grey[200], // Couleur de fond du bouton
              onTap: () {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => ListDelivery()));
              },
            ),
            ListTile(
              leading: Icon(Icons.monetization_on),
              title: Text(
                'Revenue',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 0, 0, 0), // Couleur du texte
                ),
              ),
              tileColor: Colors.grey[200],
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
              leading: Icon(Icons.account_balance_wallet),
              title: Text(
                'Sold',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 0, 0, 0), // Couleur du texte
                ),
              ),
              tileColor: Colors.grey[200],
              onTap: () {
                // Action for "Solde" button
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_circle,
                          size: 100, color: Colors.blueGrey),
                      SizedBox(width: 20),
                    ],
                  ),
                  SizedBox(height: 30),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: isOnline ? Colors.green : Colors.red,
                    ),
                    child: InkWell(
                      onTap: toggleOnlineOffline,
                      borderRadius: BorderRadius.circular(30),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        child: Text(
                          isOnline ? 'En ligne' : 'Hors ligne',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    'First Name: ${widget.userData['firstName']}',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Last Name: ${widget.userData['lastName']}',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Phone Number: ${widget.userData['phone']}',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Email: ${widget.userData['email']}',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Solde: ${widget.userData['sold']}',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
