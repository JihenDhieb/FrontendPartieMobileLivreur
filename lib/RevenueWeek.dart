import 'dart:convert';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:delivery/RevenueMonth.dart';
import 'package:delivery/dashbord.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'RevenueDay.dart';

class BarChartModel {
  final DateTime date;
  final double revenue;
  BarChartModel(this.date, this.revenue);
}

class MyRevenueWeek extends StatefulWidget {
  final Map<String, dynamic> userData;
  MyRevenueWeek({required this.userData});
  @override
  MyRevenueWeekState createState() => MyRevenueWeekState();
}

class MyRevenueWeekState extends State<MyRevenueWeek> {
  List<BarChartModel> data = [];
  List<Color> chartColors = [
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.purple,
  ];

  Future<void> displayDataFromBackend() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('id');
    final response = await http.get(
      Uri.parse('http://192.168.1.26:8080/User/weekRevenue/$id'),
    );

    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        print('Empty response body');
        return;
      }

      List<dynamic> responseData = json.decode(response.body);

      List<BarChartModel> barChartDataList = [];

      for (var data in responseData) {
        if (data.containsKey('revenue') && data.containsKey('date')) {
          dynamic revenue = data['revenue'];
          dynamic date = data['date'];

          DateTime parsedDate = DateFormat('yyyy-MM-dd').parse(date);
          double parsedRevenue = double.tryParse(revenue.toString()) ?? 0.0;

          BarChartModel barChartData = BarChartModel(parsedDate, parsedRevenue);
          barChartDataList.add(barChartData);
        } else {
          print('Invalid or missing "revenue" or "date" in the response');
        }
      }

      setState(() {
        data = barChartDataList;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    displayDataFromBackend();
  }

  @override
  Widget build(BuildContext context) {
    List<charts.Series<BarChartModel, String>> series = [
      charts.Series(
        id: 'financial',
        data: data,
        domainFn: (BarChartModel series, _) =>
            DateFormat('MM-dd').format(series.date),
        measureFn: (BarChartModel series, _) => series.revenue,
        colorFn: (BarChartModel series, _) {
          int index = data.indexOf(series) % chartColors.length;
          return charts.ColorUtil.fromDartColor(chartColors[index]);
        },
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text("Earnings"),
        centerTitle: true,
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => dashbord(widget.userData)),
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: Text('Day'),
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
              title: Text('Week'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MyRevenueWeek(userData: {
                      'revenueDates': widget.userData['revenueDates'],
                    }),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Month'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MyRevenueMonth(userData: {
                      'revenueDates': widget.userData['revenueDates'],
                    }),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
        child: Column(
          children: [
            SizedBox(height: 20),
            Expanded(
              child: charts.BarChart(
                series,
                animate: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
