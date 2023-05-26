import 'package:flutter/material.dart';
import 'LoginPage.dart';

class Welcome extends StatefulWidget {
  const Welcome({Key? key}) : super(key: key);
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
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
                height: MediaQuery.of(context).size.height * 0.32,
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
                            'Hello Delivery Partner',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 50.0,
                              fontWeight:
                                  FontWeight.bold, // Style de police en gras
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
                        ),
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
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage()),
                              );
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.login, color: Colors.white),
                                  SizedBox(width: 5.0),
                                  Text(
                                    'Login Now',
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
