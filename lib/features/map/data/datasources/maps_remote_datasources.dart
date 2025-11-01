import 'package:dio/dio.dart';
import 'package:find_me_and_my_theme/features/map/data/models/place_model.dart';
import 'package:find_me_and_my_theme/features/map/data/models/route_model.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/constants/app_constants.dart';

abstract class MapsRemoteDataSource {
  Future<List<PlaceModel>> searchPlaces(String query, Position position);

  Future<RouteModel> getDirections(Position origin, Position destination);
}

class MapsRemoteDataSourceImpl implements MapsRemoteDataSource {
  final Dio dio;

  MapsRemoteDataSourceImpl(this.dio);

  @override
  Future<RouteModel> getDirections(
    Position origin,
    Position destination,
  ) async {
    try {
      final response = await dio.get(
        'https://maps.googleapis.com/maps/api/directions/json',
        queryParameters: {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'key': AppConstants.googleMapsApiKey,
        },
      );

      if (response.statusCode == 200 && response.data['routes'].isNotEmpty) {
        return RouteModel.fromJson(response.data);
      } else {
        throw Exception('No routes found');
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

      if (response.statusCode == 200) {
        final results = response.data['results'] as List;
        return results.map((json) => PlaceModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search places');
      }
    } catch (e) {
      throw Exception('Error searching places: $e');
    }
  }
}
