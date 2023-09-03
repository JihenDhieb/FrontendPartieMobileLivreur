import 'dart:convert';
import 'package:delivery/Compte.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'Caisse.dart';
import 'dashbord.dart';
import 'Config.dart';

class ListDelivery extends StatefulWidget {
  final dynamic userData;
  ListDelivery({required this.userData});

  @override
  ListDeliveryState createState() => ListDeliveryState();
}

class ListDeliveryState extends State<ListDelivery> {
  late Map<String, dynamic> page = {};
  Future<List<dynamic>> Commandes() async {
    late List<dynamic> articlesCaisse = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('id');
    final response = await http
        .get(Uri.parse(ApiUrls.baseUrl + '/caisse/caisseListDelivery/$id'));
    if (response.statusCode == 200) {
      final jsonList = json.decode(response.body) as List<dynamic>;
      final responsee = await http.post(
        Uri.parse(ApiUrls.baseUrl + '/caisse/getCaisseArticles'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(jsonList[0]["articles"]),
      );
      if (responsee.statusCode == 200) {
        articlesCaisse = json.decode(responsee.body);
        page = articlesCaisse[0]['page'];
      }
      return jsonList.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => dashbord(widget.userData),
            ),
          );
          return false;
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text("Liste de livraison"),
              backgroundColor: Colors.orange, // ajouter la couleur orange ici
              leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => dashbord(widget.userData)),
                    );
                  }),
            ),
            body: FutureBuilder<List<dynamic>>(
              future: Commandes(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final data = snapshot.data!;
                  return ListView.separated(
                    separatorBuilder: (BuildContext context, int index) =>
                        Divider(),
                    itemCount: data.length,
                    itemBuilder: (BuildContext context, int index) {
                      final item = data[index];
                      return Card(
                        elevation: 4,
                        child: ListTile(
                          subtitle: Text(
                              ('${item['reference']} ${item['selectedTime']}')),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${item['status']}',
                                style: TextStyle(
                                  color: item['status'] == 'Cancel'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => Caisse(
                                              idCaisse: item['id'],
                                            )),
                                  );
                                },
                                icon: Icon(
                                  Icons.arrow_forward,
                                  color: Color.fromARGB(255, 14, 14, 14),
                                ),
                              ),
                              SizedBox(width: 4),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Votre liste est vide',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            )));
  }
}
