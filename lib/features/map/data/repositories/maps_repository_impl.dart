import 'package:dartz/dartz.dart';
import 'package:find_me_and_my_theme/core/errors/failures.dart';
import 'package:find_me_and_my_theme/features/map/data/datasources/maps_remote_datasources.dart';
import 'package:find_me_and_my_theme/features/map/domain/entiities/place.dart';
import 'package:find_me_and_my_theme/features/map/domain/entiities/route_info.dart';
import 'package:find_me_and_my_theme/features/map/domain/repositories/maps_repository.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class MapsRepositoryImpl implements MapsRepository {
  final MapsRemoteDataSource remoteDataSource;

  MapsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, String>> getAddressFromCoordinates(
    double lat,
    double lng,
  ) async {
    try {
      final placeMarks = await placemarkFromCoordinates(lat, lng);
      if (placeMarks.isNotEmpty) {
        final place = placeMarks.first;
        return Right('${place.street}, ${place.locality}, ${place.country}');
      }
      return const Left(NetworkFailure('No address found'));
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Position>> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const Left(LocationFailure('Location services are disabled'));
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return const Left(PermissionFailure('Location permissions denied'));
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return const Left(
          PermissionFailure('Location permissions are permanently denied'),
        );
      }

      final position = await Geolocator.getCurrentPosition();
      return Right(position);
    } catch (e) {
      return Left(LocationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, RouteInfo>> getDirections(
    Position origin,
    Position destination,
  ) async {
    try {
      final route = await remoteDataSource.getDirections(origin, destination);
      return Right(route);
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Place>>> searchPlaces(
    String query,
    Position position,
  ) async {
    try {
      final places = await remoteDataSource.searchPlaces(query, position);
      return Right(places);
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }
}
