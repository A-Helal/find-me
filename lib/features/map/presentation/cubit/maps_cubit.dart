import 'dart:async';
import 'package:find_me_and_my_theme/core/theming/app_colors.dart';
import 'package:find_me_and_my_theme/features/map/domain/entiities/place.dart';
import 'package:find_me_and_my_theme/features/map/domain/entiities/route_info.dart';
import 'package:find_me_and_my_theme/features/map/domain/usecases/get_current_location.dart';
import 'package:find_me_and_my_theme/features/map/domain/usecases/get_directions.dart';
import 'package:find_me_and_my_theme/features/map/domain/usecases/get_place_autocomplete.dart';
import 'package:find_me_and_my_theme/features/map/domain/usecases/get_place_details.dart';
import 'package:find_me_and_my_theme/features/map/domain/usecases/search_places.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

part 'maps_state.dart';

class MapsCubit extends Cubit<MapsState> {
  final GetCurrentLocation getCurrentLocation;
  final GetDirections getDirections;
  final SearchPlaces searchPlaces;
  final GetPlaceAutocomplete getPlaceAutocomplete;
  final GetPlaceDetails getPlaceDetails;

  MapsCubit({
    required this.getPlaceAutocomplete,
    required this.getPlaceDetails,
    required this.getCurrentLocation,
    required this.getDirections,
    required this.searchPlaces,
  }) : super(const MapsState());

  StreamSubscription<Position>? _positionStreamSubscription;
  final Uuid _uuid = const Uuid();

  Future<void> startLocationTracking() async {
    final result = await getCurrentLocation();
    result.fold(
      (failure) => emit(
        state.copyWith(status: MapsStatus.error, errorMessage: failure.message),
      ),
      (position) {
        emit(
          state.copyWith(
            status: MapsStatus.success,
            currentPosition: position,
            currentHeading: position.heading,
          ),
        );

        _addCurrentLocationCircle(position);
        _positionStreamSubscription =
            Geolocator.getPositionStream(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.high,
                distanceFilter: 10,
              ),
            ).listen((Position position) {
              emit(
                state.copyWith(
                  currentPosition: position,
                  currentHeading: position.heading,
                ),
              );
              _addCurrentLocationCircle(position);
            });
      },
    );
  }

  void _addCurrentLocationCircle(Position position) {
    final circle = Circle(
      circleId: const CircleId('current_location'),
      center: LatLng(position.latitude, position.longitude),
      radius: position.accuracy,
      fillColor: AppColors.sky100.withValues(alpha: 0.2),
      strokeColor: AppColors.sky100,
      strokeWidth: 2,
    );

    emit(state.copyWith(circles: {circle}));
  }

  Future<void> loadCurrentLocation() async {
    emit(state.copyWith(status: MapsStatus.loading));
    await startLocationTracking();
  }

  Future<void> searchPlacesAutocomplete(String query) async {
    if (state.currentPosition == null || query.isEmpty) {
      emit(state.copyWith(searchResults: []));
      return;
    }

    emit(state.copyWith(isSearching: true));

    final result = await getPlaceAutocomplete(query, state.currentPosition!);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: MapsStatus.error,
          errorMessage: failure.message,
          isSearching: false,
        ),
      ),
      (places) {
        emit(
          state.copyWith(
            status: MapsStatus.success,
            searchResults: places,
            isSearching: false,
          ),
        );
      },
    );
  }

  Future<void> selectPlaceFromSearch(String placeId) async {
    emit(state.copyWith(status: MapsStatus.loading));

    final result = await getPlaceDetails(placeId);

    result.fold(
      (failure) => emit(
        state.copyWith(status: MapsStatus.error, errorMessage: failure.message),
      ),
      (place) {
        final marker = Marker(
          markerId: MarkerId(place.id),
          position: place.location,
          infoWindow: InfoWindow(title: place.name, snippet: place.address),
        );

        emit(
          state.copyWith(
            status: MapsStatus.success,
            selectedPlace: place,
            markers: {marker},
            searchResults: [],
          ),
        );
      },
    );
  }

  void selectPlace(Place place) {
    emit(state.copyWith(selectedPlace: place));
  }

  void setDestination(Place place) {
    emit(state.copyWith(destinationPlace: place));
  }

  void changeTravelMode(TravelMode mode) {
    emit(state.copyWith(selectedTravelMode: mode));
  }

  Future<void> getDirectionsToPlace(Place place, TravelMode travelMode) async {
    if (state.currentPosition == null) {
      emit(
        state.copyWith(
          status: MapsStatus.error,
          errorMessage: 'Current location not available',
        ),
      );
      return;
    }

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

    final result = await getDirections(
      state.currentPosition!,
      destination,
      travelMode.value,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(status: MapsStatus.error, errorMessage: failure.message),
      ),
      (route) {
        final polyline = Polyline(
          polylineId: PolylineId(_uuid.v4()),
          points: route.polylinePoints,
          color: _getColorForTravelMode(travelMode),
          width: 5,
        );

        // Add destination marker
        final destinationMarker = Marker(
          markerId: MarkerId(place.id),
          position: place.location,
          infoWindow: InfoWindow(title: place.name, snippet: place.address),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        );

        emit(
          state.copyWith(
            status: MapsStatus.success,
            currentRoute: route,
            polylines: {polyline},
            markers: {destinationMarker},
            destinationPlace: place,
          ),
        );
      },
    );
  }

  Color _getColorForTravelMode(TravelMode mode) {
    switch (mode) {
      case TravelMode.driving:
        return AppColors.sky200;
      case TravelMode.walking:
        return AppColors.success200;
      case TravelMode.bicycling:
        return AppColors.warning100;
      case TravelMode.transit:
        return AppColors.error100;
    }
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
    emit(
      state.copyWith(
        polylines: const {},
        currentRoute: null,
        clearDestination: true,
      ),
    );
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

  @override
  Future<void> close() {
    _positionStreamSubscription?.cancel();
    return super.close();
  }
}
