import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Place extends Equatable {
  final String id;
  final String name;
  final String address;
  final LatLng location;
  final String? phoneNumber;
  final double? rating;
  final String? photoReference;

  const Place({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    this.phoneNumber,
    this.rating,
    this.photoReference,
  });

  @override
  List<Object?> get props => [id, name, address, location];
}