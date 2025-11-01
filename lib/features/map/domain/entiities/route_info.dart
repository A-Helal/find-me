import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteInfo extends Equatable {
  final List<LatLng> polylinePoints;
  final String distance;
  final String duration;
  final String summary;

  const RouteInfo({
    required this.polylinePoints,
    required this.distance,
    required this.duration,
    required this.summary,
  });

  @override
  List<Object> get props => [polylinePoints, distance, duration, summary];
}