import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../domain/entiities/place.dart';

class PlaceModel extends Place {
  const PlaceModel({
    required super.id,
    required super.name,
    required super.address,
    required super.location,
    super.phoneNumber,
    super.rating,
    super.photoReference,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
      id: json['place_id'] ?? '',
      name: json['name'] ?? '',
      address: json['formatted_address'] ?? json['vicinity'] ?? '',
      location: LatLng(
        json['geometry']['location']['lat'],
        json['geometry']['location']['lng'],
      ),
      phoneNumber: json['formatted_phone_number'],
      rating: json['rating']?.toDouble(),
      photoReference: json['photos'] != null && json['photos'].isNotEmpty
          ? json['photos'][0]['photo_reference']
          : null,
    );
  }

  factory PlaceModel.fromAutocomplete(Map<String, dynamic> json) {
    return PlaceModel(
      id: json['place_id'] ?? '',
      name: json['structured_formatting']['main_text'] ?? '',
      address: json['description'] ?? '',
      location: const LatLng(0, 0),
    );
  }
}
