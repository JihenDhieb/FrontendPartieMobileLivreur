import 'dart:async';
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  Completer<GoogleMapController> _mapController = Completer();
  LocationData _currentLocation = LocationData.fromMap({});
  Location _locationService = Location();
  Set<Marker> _markers = {};

  void initState() {
    _locationService.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 1000,
    );
    _locationService.onLocationChanged.listen((LocationData result) {
      _currentLocation = result;
      _updateCameraPosition();
    });
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    LocationData location;
    try {
      location = await _locationService.getLocation();
    } catch (e) {
      print('Error: $e');
      location = LocationData.fromMap({});
    }
    if (location != null) {
      _currentLocation = location;
      _updateCameraPosition();
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController.complete(controller);
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
        'longitude': _currentLocation.longitude,
        'latitude': _currentLocation.latitude,
      }),
    );
  }

  void _updateCameraPosition() {
    if (_mapController.isCompleted && _currentLocation != null) {
      LatLng currentPosition = LatLng(
        _currentLocation.latitude ?? 0.0,
        _currentLocation.longitude ?? 0.0,
      );

      _mapController.future.then((controller) {
        controller.animateCamera(CameraUpdate.newLatLng(currentPosition));
      });
      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId('currentLocation'),
          position: currentPosition,
        ),
      );
      _submitForm();
    }
  }

  Future<GoogleMapController> getMapController() {
    return _mapController.future;
  }

  Set<Marker> getMarkers() {
    return _markers;
  }

  void getCurrentLocation() {
    _getCurrentLocation();
  }

  void onMapCreated(GoogleMapController controller) {
    _onMapCreated(controller);
  }
}
