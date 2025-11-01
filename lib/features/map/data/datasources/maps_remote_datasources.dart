import 'package:dio/dio.dart';
import 'package:find_me_and_my_theme/features/map/data/models/place_model.dart';
import 'package:find_me_and_my_theme/features/map/data/models/route_model.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/constants/app_constants.dart';

abstract class MapsRemoteDataSource {
  Future<List<PlaceModel>> searchPlaces(String query, Position position);

  Future<List<PlaceModel>> getPlaceAutocomplete(
    String query,
    Position position,
  );

  Future<PlaceModel> getPlaceDetails(String placeId);

  Future<RouteModel> getDirections(
    Position origin,
    Position destination,
    String travelMode,
  );
}

class MapsRemoteDataSourceImpl implements MapsRemoteDataSource {
  final Dio dio;

  MapsRemoteDataSourceImpl(this.dio);

  @override
  Future<RouteModel> getDirections(
    Position origin,
    Position destination,
    String travelMode,
  ) async {
    try {
      final response = await dio.get(
        'https://maps.googleapis.com/maps/api/directions/json',
        queryParameters: {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'mode': travelMode, // driving, walking, bicycling, transit
          'key': AppConstants.googleMapsApiKey,
        },
      );

      if (response.statusCode == 200 &&
          response.data['status'] == 'OK' &&
          response.data['routes'].isNotEmpty) {
        return RouteModel.fromJson(response.data);
      } else {
        throw Exception('No routes found: ${response.data['status']}');
      }
    } catch (e) {
      throw Exception('Error getting directions: $e');
    }
  }

  @override
  Future<List<PlaceModel>> searchPlaces(String query, Position position) async {
    try {
      final response = await dio.get(
        'https://maps.googleapis.com/maps/api/place/textsearch/json',
        queryParameters: {
          'query': query,
          'location': '${position.latitude},${position.longitude}',
          'radius': 5000,
          'key': AppConstants.googleMapsApiKey,
        },
      );

      if (response.statusCode == 200 && response.data['status'] == 'OK') {
        final results = response.data['results'] as List;
        return results.map((json) => PlaceModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search places: ${response.data['status']}');
      }
    } catch (e) {
      throw Exception('Error searching places: $e');
    }
  }

  @override
  Future<List<PlaceModel>> getPlaceAutocomplete(
    String query,
    Position position,
  ) async {
    try {
      final response = await dio.get(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json',
        queryParameters: {
          'input': query,
          'location': '${position.latitude},${position.longitude}',
          'radius': 50000,
          'key': AppConstants.googleMapsApiKey,
        },
      );

      if (response.statusCode == 200 && response.data['status'] == 'OK') {
        final predictions = response.data['predictions'] as List;

        return predictions.map((json) {
          return PlaceModel.fromAutocomplete(json);
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Error getting autocomplete: $e');
    }
  }

  @override
  Future<PlaceModel> getPlaceDetails(String placeId) async {
    try {
      final response = await dio.get(
        'https://maps.googleapis.com/maps/api/place/details/json',
        queryParameters: {
          'place_id': placeId,
          'fields':
              'name,formatted_address,geometry,formatted_phone_number,rating,photos',
          'key': AppConstants.googleMapsApiKey,
        },
      );

      if (response.statusCode == 200 && response.data['status'] == 'OK') {
        return PlaceModel.fromJson(response.data['result']);
      } else {
        throw Exception('Failed to get place details');
      }
    } catch (e) {
      throw Exception('Error getting place details: $e');
    }
  }
}
