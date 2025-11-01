import 'package:find_me_and_my_theme/core/theming/app_colors.dart';
import 'package:find_me_and_my_theme/features/map/domain/entiities/place.dart';
import 'package:find_me_and_my_theme/features/map/domain/entiities/route_info.dart';
import 'package:find_me_and_my_theme/features/map/domain/usecases/get_current_location.dart';
import 'package:find_me_and_my_theme/features/map/domain/usecases/get_directions.dart';
import 'package:find_me_and_my_theme/features/map/domain/usecases/search_places.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

part 'maps_state.dart';

class MapsCubit extends Cubit<MapsState> {
  final GetCurrentLocation getCurrentLocation;
  final GetDirections getDirections;
  final SearchPlaces searchPlaces;

  MapsCubit({
    required this.getCurrentLocation,
    required this.getDirections,
    required this.searchPlaces,
  }) : super(const MapsState());

  final Uuid _uuid = const Uuid();

  Future<void> loadCurrentLocation() async {
    emit(state.copyWith(status: MapsStatus.loading));

    final result = await getCurrentLocation();

    result.fold(
      (failure) => emit(
        state.copyWith(status: MapsStatus.error, errorMessage: failure.message),
      ),
      (position) => emit(
        state.copyWith(status: MapsStatus.success, currentPosition: position),
      ),
    );
  }

  Future<void> searchPlacesNearby(String query) async {
    if (state.currentPosition == null) {
      emit(
        state.copyWith(
          status: MapsStatus.error,
          errorMessage: "Current location isn't available",
        ),
      );
      return;
    }
    emit(state.copyWith(isSearching: true));

    final result = await searchPlaces(query, state.currentPosition!);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: MapsStatus.error,
          errorMessage: failure.message,
          isSearching: false,
        ),
      ),
      (places) {
        final markers = _createMarkersPlacesForm(places);
        emit(
          state.copyWith(
            status: MapsStatus.success,
            searchResults: places,
            markers: markers,
            isSearching: false,
          ),
        );
      },
    );
  }

  Future<void> getDirectionsToPlace(Place place) async {
    if (state.currentPosition == null) return;

    emit(state.copyWith(status: MapsStatus.loading));

    final destination = Position(
      latitude: place.location.latitude,
      longitude: place.location.longitude,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );

    final result = await getDirections(state.currentPosition!, destination);

    result.fold(
      (failure) => emit(
        state.copyWith(status: MapsStatus.error, errorMessage: failure.message),
      ),
      (route) {
        final polyline = Polyline(
          polylineId: PolylineId(_uuid.v4()),
          points: route.polylinePoints,
          color: AppColors.sky100,
          width: 5,
        );

        emit(
          state.copyWith(
            status: MapsStatus.success,
            currentRoute: route,
            polyLines: {polyline},
          ),
        );
      },
    );
  }

  void selectPlace(Place place) {
    emit(state.copyWith(selectedPlace: place));
  }

  Set<Marker> _createMarkersPlacesForm(List<Place> places) {
    return places.map((place) {
      return Marker(
        markerId: MarkerId(place.id),
        position: place.location,
        infoWindow: InfoWindow(title: place.name, snippet: place.address),
        onTap: () => selectPlace,
      );
    }).toSet();
  }

  void addMarker(LatLng position) {
    final marker = Marker(
      markerId: MarkerId(_uuid.v4()),
      position: position,
      infoWindow: const InfoWindow(title: 'Pinned Location'),
    );

    final updatedMarkers = Set<Marker>.from(state.markers)..add(marker);
    emit(state.copyWith(markers: updatedMarkers));
  }

  void clearRoute() {
    emit(state.copyWith(polyLines: const {}, currentRoute: null));
  }

  void clearSearch() {
    emit(
      state.copyWith(
        searchResults: const [],
        markers: const {},
        selectedPlace: null,
      ),
    );
  }
}
