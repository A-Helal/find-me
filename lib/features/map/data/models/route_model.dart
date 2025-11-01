import 'package:find_me_and_my_theme/features/map/domain/entiities/route_info.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteModel extends RouteInfo {
  const RouteModel({
    required super.polylinePoints,
    required super.distance,
    required super.duration,
    required super.summary,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    final route = json['routes'][0];
    final leg = route['legs'][0];

    // Decode polyline
    final polylineString = route['overview_polyline']['points'];
    final polylinePoints = _decodePolyline(polylineString);

    return RouteModel(
      polylinePoints: polylinePoints,
      distance: leg['distance']['text'],
      duration: leg['duration']['text'],
      summary: route['summary'] ?? '',
    );
  }

  static List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }
}