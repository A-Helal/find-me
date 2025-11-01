import 'package:dio/dio.dart';
import 'package:find_me_and_my_theme/features/map/data/datasources/maps_remote_datasources.dart';
import 'package:find_me_and_my_theme/features/map/data/repositories/maps_repository_impl.dart';
import 'package:find_me_and_my_theme/features/map/domain/repositories/maps_repository.dart';
import 'package:find_me_and_my_theme/features/map/domain/usecases/get_current_location.dart';
import 'package:find_me_and_my_theme/features/map/domain/usecases/get_directions.dart';
import 'package:find_me_and_my_theme/features/map/domain/usecases/search_places.dart';
import 'package:find_me_and_my_theme/features/map/presentation/cubit/maps_cubit.dart';
import 'package:get_it/get_it.dart';

import '../../features/map/domain/usecases/get_place_autocomplete.dart';
import '../../features/map/domain/usecases/get_place_details.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  sl.registerLazySingleton<Dio>(
    () => Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<MapsRemoteDataSource>(
    () => MapsRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<MapsRepository>(() => MapsRepositoryImpl(sl()));

  // Use Cases
  sl.registerLazySingleton(() => GetCurrentLocation(sl()));
  sl.registerLazySingleton(() => SearchPlaces(sl()));
  sl.registerLazySingleton(() => GetDirections(sl()));
  sl.registerLazySingleton(() => GetPlaceAutocomplete(sl()));
  sl.registerLazySingleton(() => GetPlaceDetails(sl()));

  // Cubits/Blocs
  sl.registerFactory(
    () => MapsCubit(
      getCurrentLocation: sl(),
      searchPlaces: sl(),
      getDirections: sl(),
      getPlaceAutocomplete: sl(),
      getPlaceDetails: sl(),
    ),
  );
}
