import 'dart:convert';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'LoginPage.dart';

class BarChartModel {
  final DateTime date;
  final double revenue;

  BarChartModel(this.date, this.revenue);
}

class MyRevenue extends StatefulWidget {
  final Map<String, dynamic> userData;

  MyRevenue({required this.userData});

  @override
  MyRevenueState createState() => MyRevenueState();
}

class MyRevenueState extends State<MyRevenue> {
  List<BarChartModel> data = [];

  List<Color> chartColors = [
    Color.fromARGB(255, 120, 123, 193),

    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red, // Add more colors if needed
  ];

  @override
  void initState() {
    super.initState();
    List<dynamic> revenuesDates = widget.userData['revenueDates'];
    print(revenuesDates);
    // Convert data into BarChartModel objects
    data = revenuesDates.map((item) {
      DateTime date = DateTime.parse(item['date']);
      double revenue = double.parse(item['revenue'].toString());
      return BarChartModel(date, revenue);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<charts.Series<BarChartModel, String>> series = [
      charts.Series(
        id: 'financial',
        data: data,
        domainFn: (BarChartModel series, _) =>
            DateFormat('yyyy-MM-dd').format(series.date),
        measureFn: (BarChartModel series, _) => series.revenue,
        colorFn: (BarChartModel series, _) {
          int index = data.indexOf(series) % chartColors.length;
          return charts.ColorUtil.fromDartColor(chartColors[index]);
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Revenue"),
        centerTitle: true,
        backgroundColor: Colors.green[700],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => LoginPage()),
            );
          },
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
        child: Column(
          children: [
            Text(
              'Revenue Dates:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: data.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text('Revenue: ${data[index].revenue}'),
                    subtitle: Text('Date: ${data[index].date}'),
                  );
                },
              ),
            ),
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
