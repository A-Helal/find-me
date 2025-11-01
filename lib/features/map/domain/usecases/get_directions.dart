import 'package:dartz/dartz.dart';
import 'package:find_me_and_my_theme/core/errors/failures.dart';
import 'package:find_me_and_my_theme/features/map/domain/entiities/route_info.dart';
import 'package:find_me_and_my_theme/features/map/domain/repositories/maps_repository.dart';
import 'package:geolocator/geolocator.dart';

class GetDirections {
  final MapsRepository mapsRepository;

  GetDirections(this.mapsRepository);

  Future<Either<Failure, RouteInfo>> call(
    Position origin,
    Position destination,
  ) async {
    return await mapsRepository.getDirections(origin, destination);
  }
}
