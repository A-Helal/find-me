import 'package:dartz/dartz.dart';
import 'package:find_me_and_my_theme/core/errors/failures.dart';
import 'package:find_me_and_my_theme/features/map/domain/repositories/maps_repository.dart';
import 'package:geolocator/geolocator.dart';

class GetCurrentLocation {
  final MapsRepository mapsRepository;

  GetCurrentLocation(this.mapsRepository);

  Future<Either<Failure, Position>> call() async {
    return await mapsRepository.getCurrentLocation();
  }
}
