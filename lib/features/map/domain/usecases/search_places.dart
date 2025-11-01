import 'package:dartz/dartz.dart';
import 'package:find_me_and_my_theme/core/errors/failures.dart';
import 'package:find_me_and_my_theme/features/map/domain/entiities/place.dart';
import 'package:find_me_and_my_theme/features/map/domain/repositories/maps_repository.dart';
import 'package:geolocator/geolocator.dart';

class SearchPlaces {
  final MapsRepository mapsRepository;

  SearchPlaces(this.mapsRepository);

  Future<Either<Failure, List<Place>>> call(
    String query,
    Position position,
  ) async {
    return await mapsRepository.searchPlaces(query, position);
  }
}
