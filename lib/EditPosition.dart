import 'dart:convert';
import 'package:delivery/LoginPage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditPosition extends StatefulWidget {
  dynamic longitude;
  dynamic latitude;
  EditPosition(this.longitude, this.latitude);
  @override
  EditPositionState createState() => EditPositionState();
}

class EditPositionState extends State<EditPosition> {
  @override
  void initState() {
    final latLng = LatLng(widget.latitude, widget.longitude);
    super.initState();
    setState(() {
      _markers.clear();
      _markers.add(Marker(
        markerId: MarkerId('selected_location'),
        position: latLng,
      ));
      _selectedLatLng = latLng;
    });
  }

  void _submitForm() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('id');
    final response = await http.put(
      Uri.parse('http://192.168.1.26:8080/User/editDeliveryLatLong'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'idDelivery': id,
        'longitude': widget.longitude,
        'latitude': widget.latitude
      }),
    );

    if (response.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LoginPage(),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Page details updated')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating Page details')),
      );
    }
  }

  late LatLng _selectedLatLng;

  Set<Marker> _markers = {};

  late GoogleMapController _mapController;

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onMapTap(LatLng latLng) {
    setState(() {
      _markers.clear();
      _markers.add(Marker(
        markerId: MarkerId('selected_location'),
        position: latLng,
      ));
      _selectedLatLng = latLng;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => LoginPage(),
                ),
              );
            }),
        backgroundColor: Colors.orange,
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        onTap: _onMapTap,
        markers: _markers,
        initialCameraPosition: CameraPosition(
          target: LatLng(36.8065, 10.1815),
          zoom: 15,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedLatLng != null) {
            widget.longitude = _selectedLatLng.longitude;
            widget.latitude = _selectedLatLng.latitude;
            _submitForm();
          }
        },
        backgroundColor: Colors.orange,
        child: Icon(Icons.save),
      ),
    );
  }
}
