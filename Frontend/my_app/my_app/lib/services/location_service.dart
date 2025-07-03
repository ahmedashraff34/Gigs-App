import 'package:geolocator/geolocator.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    return serviceEnabled;
  }

  /// Check location permission status
  Future<LocationPermission> checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission;
  }

  /// Request location permission
  Future<LocationPermission> requestPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    return permission;
  }

  /// Get current device location
  Future<Position?> getCurrentLocation() async {
    try {
      print('Debug: Starting location retrieval...');
      
      // Check if location services are enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      print('Debug: Location services enabled: $serviceEnabled');
      
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      // Check location permission
      LocationPermission permission = await checkPermission();
      print('Debug: Location permission: $permission');
      
      if (permission == LocationPermission.denied) {
        print('Debug: Requesting location permission...');
        permission = await requestPermission();
        print('Debug: Permission after request: $permission');
        
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied, we cannot request permissions.');
      }

      print('Debug: Getting current position...');
      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      print('Debug: Location retrieved successfully: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  /// Get last known location (cached)
  Future<Position?> getLastKnownLocation() async {
    try {
      Position? position = await Geolocator.getLastKnownPosition();
      return position;
    } catch (e) {
      print('Error getting last known location: $e');
      return null;
    }
  }

  /// Calculate distance between two positions
  double calculateDistance(Position start, Position end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }

  /// Format location for sharing (Google Maps URL)
  String formatLocationForSharing(Position position) {
    return 'https://www.google.com/maps?q=${position.latitude},${position.longitude}';
  }

  /// Format location for email/telegram sharing
  String formatLocationForMessage(Position position) {
    return 'My current location: ${position.latitude}, ${position.longitude}\n'
           'Google Maps: https://www.google.com/maps?q=${position.latitude},${position.longitude}';
  }
}
