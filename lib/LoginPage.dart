import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'Compte.dart';

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
      print('ID: $id');
      await _prefs.setString('email', email);
      print('Email: $email');
      await _prefs.setString('password', password);
      await _prefs.setString('token', token);
      print('Token: $token');
      print('Login Succesfuly');
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
        if (response.statusCode == 200) {
          final userResponse = await http.get(
            Uri.parse('http://192.168.1.26:8080/User/$id'),
            headers: <String, String>{
              'Authorization': 'Bearer $token',
            },
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => Compte(),
            ),
          );
        }
        print(token);
      });
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
                child: Text("OK"),
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
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        body: SafeArea(
            child: Center(
                child: SingleChildScrollView(
                    child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(width: 10),
                                  Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 50.0,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16.0),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                labelStyle: TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color.fromARGB(255, 0, 0, 0)!,
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
                            ),
                            SizedBox(height: 16.0),
                            TextFormField(
                              controller: _passwordController,
                              keyboardType: TextInputType.visiblePassword,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color.fromARGB(255, 0, 0, 0)!,
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
                            ),
                            SizedBox(height: 16.0),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 70,
                                    width: 300,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color.fromARGB(255, 0, 225, 255),
                                            Color.fromARGB(255, 255, 59, 59)
                                          ], // Couleurs du dégradé
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            _login();
                                          }
                                        },
                                        child: Text('Login'),
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors
                                              .transparent, // Couleur transparente pour le bouton
                                          shadowColor: Colors
                                              .transparent, // Couleur transparente pour l'ombre
                                          elevation:
                                              0, // Désactive l'ombre du bouton
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 50),
                            Center(
                              child: Text(
                                'Have An Account?',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Center(
                              child: TextButton(
                                onPressed: () {},
                                style: ButtonStyle(
                                  shape:
                                      MaterialStateProperty.all<OutlinedBorder>(
                                    StadiumBorder(),
                                  ),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    Colors.white,
                                  ),
                                ),
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ],
                        ))))));
  }
}
