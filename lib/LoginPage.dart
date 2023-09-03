import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dashbord.dart';
import 'LocationService.dart';
import 'package:permission_handler/permission_handler.dart';
import 'Config.dart';

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
  final LocationService _locationService = LocationService();
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
        _locationService.initState();
      }
    });
  }

  Future<void> _login() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final response = await http.post(
      Uri.parse(ApiUrls.baseUrl + '/api/auth/loginUser'),
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
          Uri.parse(ApiUrls.baseUrl + '/notification/addDevice'),
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
        Uri.parse(ApiUrls.baseUrl + '/User/$id'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
        },
      );
      if (userResponse.statusCode == 200) {
        final LocationService _locationService = LocationService();
        _locationService.getCurrentLocation();
        _locationService.submitForm();
        final Map<String, dynamic> userData = json.decode(userResponse.body);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => dashbord(userData)));
      }
    } else {
      print('Login failed.');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Erreur"),
            content: Text("Adresse e-mail ou mot de passe invalide."),
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
                top: MediaQuery.of(context).size.height / 2 - 300,
                left: 0,
                right: 0,
                child: Container(
                  width: 100,
                  height: 400,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('android/images/2.png'),
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
                            'Connexion',
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
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                                return 'Veuillez entrer votre adresse e-mail';
                              }
                              if (!value.contains('@')) {
                                return 'Veuillez entrer une adresse e-mail valide';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: TextFormField(
                            controller: _passwordController,
                            keyboardType: TextInputType.visiblePassword,
                            decoration: InputDecoration(
                              labelText: 'Mot de passe',
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
                                    _obscureText = !_obscureText;
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
                            obscureText: _obscureText,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Veuillez entrer votre mot de passe';
                              }
                              if (value.length < 8) {
                                return 'Le mot de passe doit contenir au moins 8 caractères';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          width: 250,
                          height: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30.0),
                            color: Color(0xFFFF9800),
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
                                    'Se connecter',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 25.0,
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
