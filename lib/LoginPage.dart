import 'package:delivery/Edit.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dashbord.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late SharedPreferences _prefs;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      _prefs = prefs;
      final String? email = _prefs.getString('email');
      final String? password = _prefs.getString('password');
      if (email != null && password != null) {
        _emailController.text = email;
        _passwordController.text = password;
        _login();
      }
    });
  }

  Future<void> _login() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;

    final response = await http.post(
      Uri.parse('http://192.168.1.26:8080/api/auth/loginUser'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final String token = responseData['token'];
      final String id = responseData['id'];
      await _prefs.setString('id', id);
      await _prefs.setString('email', email);
      await _prefs.setString('password', password);
      await _prefs.setString('token', token);

      FirebaseMessaging.instance.getToken().then((token) async {
        final response = await http.post(
          Uri.parse('http://192.168.1.26:8080/notification/addDevice'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<dynamic, dynamic>{
            'token': token,
            'email': email,
          }),
        );
      });
      final userResponse = await http.get(
        Uri.parse('http://192.168.1.26:8080/User/$id'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
        },
      );
      if (userResponse.statusCode == 200) {
        final Map<String, dynamic> userData = json.decode(userResponse.body);
        if (userData['imageProfile'] == null) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => Edit(userData)));
        } else {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => dashbord(userData)));
        }
      }
    } else {
      print('Login failed.');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Invalid email or password."),
            actions: [
              TextButton(
                child: Text("OK", style: TextStyle(color: Colors.orange)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        child: Center(
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
                top: MediaQuery.of(context).size.height / 2 -
                    300, // Position verticale centrée
                left: 0,
                right: 0,
                child: Container(
                  width: 100,
                  height: 400,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          'android/images/2.png'), // Remplacez par le chemin d'accès à votre image
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height * 0.39,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Sign In',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 50.0,
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
                        ),
                        Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                labelStyle: TextStyle(
                                  color: Colors.orange[800],
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.orange[800]!,
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter your email address';
                                }
                                if (!value.contains('@')) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                            )),
                        SizedBox(height: 10),
                        Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: TextFormField(
                              controller: _passwordController,
                              keyboardType: TextInputType.visiblePassword,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: TextStyle(
                                  color: Colors.orange[800],
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.orange[800]!,
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscureText =
                                          !_obscureText; // toggle password visibility
                                    });
                                  },
                                  icon: Icon(
                                    _obscureText
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              obscureText:
                                  _obscureText, // use _obscureText variable to determine password visibility
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 8) {
                                  return 'The password must contain at least 8 characters';
                                }
                                return null;
                              },
                            )),
                        SizedBox(height: 20),
                        Container(
                          width: 250, // Largeur personnalisée
                          height: 70,
                          // Hauteur personnalisée
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30.0),
                            color: Color(0xFFFF9800), // Couleur orange
                          ),
                          child: TextButton(
                            onPressed: () {
                              _login();
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(width: 5.0),
                                  Text(
                                    'Login ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 25.0,
                                      fontWeight: FontWeight
                                          .bold, // Style de police en gras
                                      fontStyle: FontStyle
                                          .italic, // Style d'écriture en italique
                                      // Couleur du soulignement
                                      decorationThickness:
                                          2.0, // Épaisseur du soulignement
                                      letterSpacing:
                                          2.0, // Espacement entre les lettres
                                      shadows: [
                                        Shadow(
                                          color: Colors.grey,
                                          blurRadius: 3.0,
                                          offset: Offset(2.0, 2.0),
                                        ),
                                      ], // Ombre du texte
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
