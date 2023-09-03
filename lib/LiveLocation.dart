import 'package:delivery/Compte.dart';
import 'package:delivery/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'LocationService.dart';

class LiveLocationPage extends StatelessWidget {
  final LocationService _locationService = LocationService();
  final dynamic userData;
  LiveLocationPage({required this.userData});
  @override
  Widget build(BuildContext context) {
    _locationService.initState();
    return WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => Compte(userData),
            ),
          );
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('Localisation en direct'),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => Compte(userData)),
                );
              },
            ),
            backgroundColor: Colors.orange,
          ),
          body: Stack(
            children: [
              GoogleMap(
                onMapCreated: _locationService.onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: LatLng(0.0, 0.0),
                  zoom: 1.0,
                ),
                markers: _locationService.getMarkers(),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _locationService.getCurrentLocation,
            child: Icon(Icons.location_searching),
          ),
        ));
  }
}
