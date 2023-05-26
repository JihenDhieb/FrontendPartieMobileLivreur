import 'dart:convert';
import 'package:delivery/Edit.dart';
import 'package:delivery/LoginPage.dart';
import 'package:delivery/dashbord.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ListDelivery.dart';
import 'EditPosition.dart';
import 'Revenue.dart';

class Compte extends StatefulWidget {
  late Map<dynamic, dynamic> imageProfile;
  final Map<String, dynamic> userData;
  Compte(this.userData) {
    imageProfile = userData['imageProfile'];
  }
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
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('android/images/3.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 160,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Container(
                    height: 180,
                    width: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: MemoryImage(
                            base64Decode(widget.imageProfile['bytes'])),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        ' ${widget.userData['firstName']}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 35.0,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          decorationThickness: 2.0,
                          letterSpacing: 2.0,
                          shadows: [
                            Shadow(
                              color: Colors.grey,
                              blurRadius: 3.0,
                              offset: Offset(2.0, 2.0),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        ' ${widget.userData['lastName']}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 35.0,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          decorationThickness: 2.0,
                          letterSpacing: 2.0,
                          shadows: [
                            Shadow(
                              color: Colors.grey,
                              blurRadius: 3.0,
                              offset: Offset(2.0, 2.0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
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
                        child: Icon(
                          isOnline ? Icons.check_circle : Icons.cancel,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.43,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(60.0),
                  topRight: Radius.circular(60.0),
                ),
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person_3_sharp,
                                  color: Colors.black,
                                  size: 24,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'FirstName: ${widget.userData['firstName']}',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person_4_rounded,
                                  color: Colors.black,
                                  size: 24,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'MastName: ${widget.userData['lastName']}',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.phone,
                                  color: Colors.black,
                                  size: 24,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Phone Number: ${widget.userData['phone']}',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.email,
                                  color: Colors.black,
                                  size: 24,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Email: ${widget.userData['email']}',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                Edit(widget.userData)));
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.orange),
                                  ),
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => EditPosition(
                                                widget.userData['longitude'],
                                                widget.userData['latitude'])));
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.orange),
                                  ),
                                  child: Icon(
                                    Icons.location_on,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.orange,
                                size: 30, // Augmenter la taille de l'icône
                              ),
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          dashbord(widget.userData)),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
