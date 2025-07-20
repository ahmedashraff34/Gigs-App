import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<String?> fetchCity(
    {required double latitude, required double longitude}) async {
  final apiKey = 'a35cf0bb2b3319a01adcb635cf87e425';
  final url =
      'https://api.openweathermap.org/data/2.5/weather?lat=${latitude}&lon=${longitude}&appid=$apiKey';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['name'];
    } else {
      print('❌ Failed with status: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('❌ Error: $e');
    return null;
  }
}

Future<LatLng?> getCurrentLatLng() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Check if location services are enabled
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    print('Location services are disabled.');
    return null;
  }

  // Check location permission status
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      print('Location permission denied.');
      return null;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    print('Location permissions are permanently denied.');
    return null;
  }

  // Get current position
  final position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.best,
  );

  return LatLng(position.latitude, position.longitude);
}

Future<Position?> getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Check if location services are enabled
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    print('Location services are disabled.');
    return null;
  }

  // Check location permission status
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      print('Location permission denied.');
      return null;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    print('Location permissions are permanently denied.');
    return null;
  }

  // Get current position
  return await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.best,
  );
}

double calculateDistance({
  required double lat1,
  required double lon1,
  required double lat2,
  required double lon2,
}) {
  const double earthRadiusKm = 6371.0;
  double dLat = _toRadians(lat2 - lat1);
  double dLon = _toRadians(lon2 - lon1);

  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRadians(lat1)) *
          cos(_toRadians(lat2)) *
          sin(dLon / 2) *
          sin(dLon / 2);

  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  double distance = earthRadiusKm * c;

  // Return with one decimal place
  return double.parse(distance.toStringAsFixed(1));
}

double _toRadians(double degree) => degree * pi / 180;
