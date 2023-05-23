import 'dart:convert';
import 'package:delivery/Compte.dart';
import 'package:delivery/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'Caisse.dart';

class ListDelivery extends StatefulWidget {
  @override
  ListDeliveryState createState() => ListDeliveryState();
}

class ListDeliveryState extends State<ListDelivery> {
  late Map<String, dynamic> page = {};
  Future<List<dynamic>> Commandes() async {
    late List<dynamic> articlesCaisse = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('id');
    final response = await http.get(
        Uri.parse('http://192.168.1.26:8080/caisse/caisseListDelivery/$id'));
    if (response.statusCode == 200) {
      final jsonList = json.decode(response.body) as List<dynamic>;
      final responsee = await http.post(
        Uri.parse('http://192.168.1.26:8080/caisse/getCaisseArticles'),
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
    return Scaffold(
        appBar: AppBar(
          title: Text("Delivery List"),
          backgroundColor: Colors.orange, // ajouter la couleur orange ici
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginPage()),
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
                      leading: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: MemoryImage(
                              base64Decode(page['imageProfile']['bytes']),
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        width: 100,
                        height: 100,
                      ),
                      title: Text('${page['title']} '),
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
                  'Your List is empty',
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
        ));
  }
}
