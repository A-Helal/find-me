import 'package:dartz/dartz.dart';
import 'package:find_me_and_my_theme/core/errors/failures.dart';
import 'package:find_me_and_my_theme/features/map/domain/entiities/place.dart';
import 'package:find_me_and_my_theme/features/map/domain/entiities/route_info.dart';
import 'package:geolocator/geolocator.dart';

abstract class MapsRepository {
  Future<Either<Failure, Position>> getCurrentLocation();

  Future<Either<Failure, List<Place>>> searchPlaces(
    String query,
    Position position,
  );

  Future<Either<Failure, List<Place>>> getPlaceAutocomplete(
    String query,
    Position position,
  );

  Future<Either<Failure, Place>> getPlaceDetails(String placeId); // NEW
  Future<Either<Failure, RouteInfo>> getDirections(
    Position origin,
    Position destination,
    String travelMode,
  );

  Future<Either<Failure, String>> getAddressFromCoordinates(
    double lat,
    double lng,
  );
}
