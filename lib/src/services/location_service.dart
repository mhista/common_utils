import 'dart:async';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Location Service
/// Comprehensive location services with permissions, GPS, geocoding, and calculations
class LocationService {
  LocationService._();

  static LocationService? _instance;

  /// Get singleton instance
  static LocationService get instance {
    _instance ??= LocationService._();
    return _instance!;
  }

  // ==================== Permission Handling ====================

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check location permission status
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Check and request permission if needed
  Future<PermissionResult> checkAndRequestPermission() async {
    // Check if location services are enabled
    if (!await isLocationServiceEnabled()) {
      return PermissionResult(
        isGranted: false,
        message: 'Location services are disabled. Please enable them.',
        shouldOpenSettings: true,
      );
    }

    // Check permission
    LocationPermission permission = await checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await requestPermission();
      if (permission == LocationPermission.denied) {
        return PermissionResult(
          isGranted: false,
          message: 'Location permission denied',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return PermissionResult(
        isGranted: false,
        message: 'Location permission permanently denied. Please enable in settings.',
        shouldOpenSettings: true,
      );
    }

    return PermissionResult(isGranted: true);
  }

  /// Open location settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  // ==================== Get Current Location ====================

  /// Get current position
  Future<Position?> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration? timeLimit,
  }) async {
    final permissionResult = await checkAndRequestPermission();
    if (!permissionResult.isGranted) {
      throw LocationException(permissionResult.message);
    }

    try {
      return await Geolocator.getCurrentPosition(
          desiredAccuracy: accuracy,
          timeLimit: timeLimit,
      );
    } catch (e) {
      throw LocationException('Failed to get current location: $e');
    }
  }

  /// Get current location as LatLng
  Future<LatLng?> getCurrentLatLng({
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) async {
    final position = await getCurrentPosition(accuracy: accuracy);
    if (position == null) return null;
    return LatLng(position.latitude, position.longitude);
  }

  /// Get last known position (faster but may be outdated)
  Future<Position?> getLastKnownPosition() async {
    return await Geolocator.getLastKnownPosition();
  }

  // ==================== Location Tracking ====================

  /// Stream location updates
  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10,
    Duration? intervalDuration,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
        timeLimit: intervalDuration,
      ),
    );
  }

  /// Track location with callback
  StreamSubscription<Position> trackLocation({
    required void Function(Position) onLocationUpdate,
    void Function(Object)? onError,
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10,
  }) {
    return getPositionStream(
      accuracy: accuracy,
      distanceFilter: distanceFilter,
    ).listen(
      onLocationUpdate,
      onError: onError,
    );
  }

  // ==================== Distance Calculations ====================

  /// Calculate distance between two points in meters
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Calculate distance between two LatLng points
  double calculateDistanceBetween(LatLng start, LatLng end) {
    return calculateDistance(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }

  /// Calculate distance from current location to a point
  Future<double?> calculateDistanceFromCurrent(
    double latitude,
    double longitude,
  ) async {
    final currentPosition = await getCurrentPosition();
    if (currentPosition == null) return null;

    return calculateDistance(
      currentPosition.latitude,
      currentPosition.longitude,
      latitude,
      longitude,
    );
  }

  /// Calculate bearing between two points (in degrees)
  double calculateBearing(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.bearingBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  // ==================== Geocoding (Address ↔ Coordinates) ====================

  /// Get address from coordinates (Reverse Geocoding)
  Future<List<Placemark>> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      return await placemarkFromCoordinates(latitude, longitude);
    } catch (e) {
      throw LocationException('Failed to get address: $e');
    }
  }

  /// Get formatted address from coordinates
  Future<String?> getFormattedAddress(
    double latitude,
    double longitude,
  ) async {
    final placemarks = await getAddressFromCoordinates(latitude, longitude);
    if (placemarks.isEmpty) return null;

    final place = placemarks.first;
    return [
      place.street,
      place.subLocality,
      place.locality,
      place.administrativeArea,
      place.country,
    ].where((e) => e != null && e.isNotEmpty).join(', ');
  }

  /// Get coordinates from address (Geocoding)
  Future<List<Location>> getCoordinatesFromAddress(String address) async {
    try {
      return await locationFromAddress(address);
    } catch (e) {
      throw LocationException('Failed to get coordinates: $e');
    }
  }

  /// Get first coordinate from address
  Future<LatLng?> getLatLngFromAddress(String address) async {
    final locations = await getCoordinatesFromAddress(address);
    if (locations.isEmpty) return null;
    return LatLng(locations.first.latitude, locations.first.longitude);
  }

  // ==================== Geofencing ====================

  /// Check if a point is within a radius of another point
  bool isWithinRadius({
    required LatLng center,
    required LatLng point,
    required double radiusInMeters,
  }) {
    final distance = calculateDistanceBetween(center, point);
    return distance <= radiusInMeters;
  }

  /// Check if current location is within radius
  Future<bool> isCurrentLocationWithinRadius({
    required LatLng center,
    required double radiusInMeters,
  }) async {
    final current = await getCurrentLatLng();
    if (current == null) return false;
    return isWithinRadius(
      center: center,
      point: current,
      radiusInMeters: radiusInMeters,
    );
  }

  // ==================== Utility Methods ====================

  /// Format distance to human-readable string
  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)} m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(2)} km';
    }
  }

  /// Format distance from miles to meters
  double milesToMeters(double miles) {
    return miles * 1609.344;
  }

  /// Format distance from meters to miles
  double metersToMiles(double meters) {
    return meters / 1609.344;
  }

  /// Generate Google Maps URL
  String getGoogleMapsUrl(double latitude, double longitude, {String? label}) {
    final labelParam = label != null ? '($label)' : '';
    return 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude$labelParam';
  }

  /// Generate Google Maps directions URL
  String getGoogleMapsDirectionsUrl({
    required LatLng destination,
    LatLng? origin,
  }) {
    final originParam = origin != null
        ? '${origin.latitude},${origin.longitude}'
        : 'Current+Location';
    return 'https://www.google.com/maps/dir/?api=1&origin=$originParam&destination=${destination.latitude},${destination.longitude}';
  }

  // ==================== Advanced Calculations ====================

  /// Calculate midpoint between two coordinates
  LatLng calculateMidpoint(LatLng point1, LatLng point2) {
    final lat1 = _degreesToRadians(point1.latitude);
    final lon1 = _degreesToRadians(point1.longitude);
    final lat2 = _degreesToRadians(point2.latitude);
    final lon2 = _degreesToRadians(point2.longitude);

    final bx = math.cos(lat2) * math.cos(lon2 - lon1);
    final by = math.cos(lat2) * math.sin(lon2 - lon1);

    final lat3 = math.atan2(
      math.sin(lat1) + math.sin(lat2),
      math.sqrt((math.cos(lat1) + bx) * (math.cos(lat1) + bx) + by * by),
    );
    final lon3 = lon1 + math.atan2(by, math.cos(lat1) + bx);

    return LatLng(
      _radiansToDegrees(lat3),
      _radiansToDegrees(lon3),
    );
  }

  /// Calculate bounding box for a center point and radius
  BoundingBox calculateBoundingBox({
    required LatLng center,
    required double radiusInMeters,
  }) {
    const earthRadius = 6371000.0; // meters

    final latChange = _radiansToDegrees(radiusInMeters / earthRadius);
    final lonChange = _radiansToDegrees(
      radiusInMeters / (earthRadius * math.cos(_degreesToRadians(center.latitude))),
    );

    return BoundingBox(
      north: center.latitude + latChange,
      south: center.latitude - latChange,
      east: center.longitude + lonChange,
      west: center.longitude - lonChange,
    );
  }

  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  double _radiansToDegrees(double radians) {
    return radians * 180 / math.pi;
  }
}

// ==================== Models ====================

/// Latitude and Longitude model
class LatLng {
  final double latitude;
  final double longitude;

  const LatLng(this.latitude, this.longitude);

  @override
  String toString() => 'LatLng($latitude, $longitude)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LatLng &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;

  Map<String, double> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };

  factory LatLng.fromJson(Map<String, dynamic> json) => LatLng(
        json['latitude'] as double,
        json['longitude'] as double,
      );
}

/// Bounding Box model
class BoundingBox {
  final double north;
  final double south;
  final double east;
  final double west;

  const BoundingBox({
    required this.north,
    required this.south,
    required this.east,
    required this.west,
  });

  bool contains(LatLng point) {
    return point.latitude <= north &&
        point.latitude >= south &&
        point.longitude <= east &&
        point.longitude >= west;
  }
}

/// Permission Result model
class PermissionResult {
  final bool isGranted;
  final String message;
  final bool shouldOpenSettings;

  const PermissionResult({
    required this.isGranted,
    this.message = '',
    this.shouldOpenSettings = false,
  });
}

/// Location Exception
class LocationException implements Exception {
  final String message;

  LocationException(this.message);

  @override
  String toString() => 'LocationException: $message';
}