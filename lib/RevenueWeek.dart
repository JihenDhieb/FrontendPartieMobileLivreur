import 'dart:convert';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:delivery/RevenueMonth.dart';
import 'package:delivery/dashbord.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'RevenueDay.dart';
import 'Config.dart';


class BarChartModel {
  final DateTime date;
  final double benefits;
  BarChartModel(this.date, this.benefits);
}

class MyRevenueWeek extends StatefulWidget {
  @override
  MyRevenueWeekState createState() => MyRevenueWeekState();
}

class MyRevenueWeekState extends State<MyRevenueWeek> {
  List<BarChartModel> data = [];
  List<Color> chartColors = [
    Colors.pink,
    Colors.orange,
    Colors.purple,
    Colors.red,
  ];

  Future<void> displayDataFromBackend() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('id');
    final response = await http.get(
      Uri.parse(ApiUrls.baseUrl + '/User/weekRevenue/$id'),
    );

    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        print('Empty response body');
        return;
      }

      List<dynamic> responseData = json.decode(response.body);

      List<BarChartModel> barChartDataList = [];

      for (var data in responseData) {
        if (data.containsKey('benefits') && data.containsKey('date')) {
          dynamic revenue = data['benefits'];
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
            DateFormat('yyyy-MM-dd').format(series.date),
        measureFn: (BarChartModel series, _) => series.benefits,
        colorFn: (BarChartModel series, _) {
          int index = data.indexOf(series) % chartColors.length;
          return charts.ColorUtil.fromDartColor(chartColors[index]);
        },
      ),
    ];
    return WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => dashbord(),
            ),
          );
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Revenu de la semaine"),
            centerTitle: true,
            backgroundColor: Colors.orange,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
               
              },
            ),
          ),
          body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
            child: Column(
              children: [
                SizedBox(height: 20),
                Expanded(
                  flex: 3,
                  child: charts.BarChart(
                    series,
                    animate: true,
                    defaultRenderer: charts.BarRendererConfig(
                      barRendererDecorator: charts.BarLabelDecorator<String>(
                        labelPosition: charts.BarLabelPosition.inside,
                      ),
                    ),
                    domainAxis: charts.OrdinalAxisSpec(
                      renderSpec: charts.SmallTickRendererSpec(
                        labelStyle: charts.TextStyleSpec(
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Bénéfices')),
                      ],
                      rows: data.map((item) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(DateFormat('yyyy-MM-dd').format(item.date)),
                            ),
                            DataCell(
                              Text(item.benefits.toString()),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
