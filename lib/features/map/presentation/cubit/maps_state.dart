part of 'maps_cubit.dart';

enum MapsStatus { initial, loading, success, error }

@immutable
class MapsState extends Equatable {
  final MapsStatus status;
  final Position? currentPosition;
  final Set<Marker> markers;
  final Set<Polyline> polyLines;
  final List<Place> searchResults;
  final Place? selectedPlace;
  final RouteInfo? currentRoute;
  final String? errorMessage;
  final bool isSearching;

  const MapsState({
    this.status = MapsStatus.initial,
    this.currentPosition,
    this.markers = const {},
    this.polyLines = const {},
    this.searchResults = const [],
    this.selectedPlace,
    this.currentRoute,
    this.errorMessage,
    this.isSearching = false,
  });

  MapsState copyWith({
    MapsStatus? status,
    Position? currentPosition,
    Set<Marker>? markers,
    Set<Polyline>? polyLines,
    List<Place>? searchResults,
    Place? selectedPlace,
    RouteInfo? currentRoute,
    String? errorMessage,
    bool? isSearching,
  }) {
    return MapsState(
      status: status ?? this.status,
      currentPosition: currentPosition ?? this.currentPosition,
      markers: markers ?? this.markers,
      polyLines: polyLines ?? this.polyLines,
      searchResults: searchResults ?? this.searchResults,
      selectedPlace: selectedPlace,
      currentRoute: currentRoute,
      errorMessage: errorMessage,
      isSearching: isSearching ?? this.isSearching,
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [
    status,
    currentPosition,
    markers,
    polyLines,
    searchResults,
    selectedPlace,
    currentRoute,
    errorMessage,
    isSearching,
  ];
}
