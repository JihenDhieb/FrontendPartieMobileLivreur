import 'dart:convert';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:delivery/dashbord.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    Colors.green,
    Colors.red,
    Color.fromARGB(255, 120, 123, 193),
    Colors.orange,
    Colors.purple, // Add more colors if needed
  ];
  String selectedFilter = 'Day';

  List<BarChartModel> dayData = [];
  List<BarChartModel> weekData = [];
  List<BarChartModel> monthData = [];

  @override
  void initState() {
    super.initState();
    List<dynamic> revenuesDates = widget.userData['revenueDates'];
    // Convert data into BarChartModel objects for each option
    dayData = revenuesDates.map((item) {
      DateTime date = DateTime.parse(item['date']);
      double revenue = double.parse(item['revenue'].toString());
      return BarChartModel(date, revenue);
    }).toList();
    // Apply filters to weekData and monthData accordingly

    // Set the initial data based on the selected filter
    setDataByFilter(selectedFilter);
  }

  void setDataByFilter(String filter) {
    setState(() {
      selectedFilter = filter;
      // Update data based on the selected filter
      if (selectedFilter == 'Day') {
        data = dayData;
      } else if (selectedFilter == 'Week') {
        data = weekData;
      } else if (selectedFilter == 'Month') {
        data = monthData;
      }
    });
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
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => setDataByFilter('Day'),
                  style: TextButton.styleFrom(
                    backgroundColor:
                        selectedFilter == 'Day' ? Colors.orange : Colors.grey,
                  ),
                  child: Text(
                    'Day',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () => setDataByFilter('Week'),
                  style: TextButton.styleFrom(
                    backgroundColor:
                        selectedFilter == 'Week' ? Colors.orange : Colors.grey,
                  ),
                  child: Text(
                    'Week',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () => setDataByFilter('Month'),
                  style: TextButton.styleFrom(
                    backgroundColor:
                        selectedFilter == 'Month' ? Colors.orange : Colors.grey,
                  ),
                  child: Text(
                    'Month',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
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
