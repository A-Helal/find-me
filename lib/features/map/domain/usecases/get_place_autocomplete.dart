import 'package:dartz/dartz.dart';
import 'package:find_me_and_my_theme/core/errors/failures.dart';
import 'package:find_me_and_my_theme/features/map/domain/entiities/place.dart';
import 'package:geolocator/geolocator.dart';
import '../repositories/maps_repository.dart';

class GetPlaceAutocomplete {
  final MapsRepository repository;

  GetPlaceAutocomplete(this.repository);

  Future<Either<Failure, List<Place>>> call(String query, Position position) async {
    if (query.isEmpty) {
      return const Right([]);
    }
    return await repository.getPlaceAutocomplete(query, position);
  }
}