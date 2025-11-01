part of 'maps_cubit.dart';

enum MapsStatus { initial, loading, success, error }

enum TravelMode { driving, walking, bicycling, transit }

extension TravelModeExtension on TravelMode {
  String get value {
    switch (this) {
      case TravelMode.driving:
        return 'driving';
      case TravelMode.walking:
        return 'walking';
      case TravelMode.bicycling:
        return 'bicycling';
      case TravelMode.transit:
        return 'transit';
    }
  }

  String get displayName {
    switch (this) {
      case TravelMode.driving:
        return 'Driving';
      case TravelMode.walking:
        return 'Walking';
      case TravelMode.bicycling:
        return 'Bicycling';
      case TravelMode.transit:
        return 'Transit';
    }
  }

  IconData get icon {
    switch (this) {
      case TravelMode.driving:
        return Icons.directions_car;
      case TravelMode.walking:
        return Icons.directions_walk;
      case TravelMode.bicycling:
        return Icons.directions_bike;
      case TravelMode.transit:
        return Icons.directions_transit;
    }
  }
}

class MapsState extends Equatable {
  final MapsStatus status;
  final Position? currentPosition;
  final double? currentHeading;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final Set<Circle> circles;
  final List<Place> searchResults;
  final Place? selectedPlace;
  final Place? destinationPlace;
  final RouteInfo? currentRoute;
  final TravelMode selectedTravelMode;
  final String? errorMessage;
  final bool isSearching;

  const MapsState({
    this.status = MapsStatus.initial,
    this.currentPosition,
    this.currentHeading,
    this.markers = const {},
    this.polylines = const {},
    this.circles = const {},
    this.searchResults = const [],
    this.selectedPlace,
    this.destinationPlace,
    this.currentRoute,
    this.selectedTravelMode = TravelMode.driving,
    this.errorMessage,
    this.isSearching = false,
  });

  MapsState copyWith({
    MapsStatus? status,
    Position? currentPosition,
    double? currentHeading,
    Set<Marker>? markers,
    Set<Polyline>? polylines,
    Set<Circle>? circles,
    List<Place>? searchResults,
    Place? selectedPlace,
    Place? destinationPlace,
    RouteInfo? currentRoute,
    TravelMode? selectedTravelMode,
    String? errorMessage,
    bool? isSearching,
    bool clearDestination = false,
  }) {
    return MapsState(
      status: status ?? this.status,
      currentPosition: currentPosition ?? this.currentPosition,
      currentHeading: currentHeading ?? this.currentHeading,
      markers: markers ?? this.markers,
      polylines: polylines ?? this.polylines,
      circles: circles ?? this.circles,
      searchResults: searchResults ?? this.searchResults,
      selectedPlace: selectedPlace,
      destinationPlace: clearDestination
          ? null
          : (destinationPlace ?? this.destinationPlace),
      currentRoute: currentRoute,
      selectedTravelMode: selectedTravelMode ?? this.selectedTravelMode,
      errorMessage: errorMessage,
      isSearching: isSearching ?? this.isSearching,
    );
  }

  @override
  List<Object?> get props => [
    status,
    currentPosition,
    currentHeading,
    markers,
    polylines,
    circles,
    searchResults,
    selectedPlace,
    destinationPlace,
    currentRoute,
    selectedTravelMode,
    errorMessage,
    isSearching,
  ];
}
