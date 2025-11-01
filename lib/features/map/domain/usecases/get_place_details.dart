import 'package:dartz/dartz.dart';
import 'package:find_me_and_my_theme/core/errors/failures.dart';
import '../entiities/place.dart';
import '../repositories/maps_repository.dart';

class GetPlaceDetails {
  final MapsRepository repository;

  GetPlaceDetails(this.repository);

  Future<Either<Failure, Place>> call(String placeId) async {
    return await repository.getPlaceDetails(placeId);
  }
}
