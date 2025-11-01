import 'dart:async';
import 'dart:math' as math;
import 'package:find_me_and_my_theme/features/map/domain/entiities/place.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../cubit/maps_cubit.dart';
import '../widgets/destination_dialog.dart';
import '../widgets/route_info_card.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/travel_mode_dialog.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  final Completer<GoogleMapController> _completer = Completer();
  GoogleMapController? _controller;
  MapType _currentMapType = MapType.normal;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(26.55840578778722, 31.69720143751444),
    zoom: 14,
  );

  @override
  void initState() {
    super.initState();
    context.read<MapsCubit>().startLocationTracking();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<MapsCubit, MapsState>(
        listener: (context, state) {
          if (state.status == MapsStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'An error occurred'),
                backgroundColor: Colors.red,
              ),
            );
          }

          if (state.currentPosition != null &&
              state.status == MapsStatus.success &&
              state.currentRoute == null) {
            _animateToPosition(
              LatLng(
                state.currentPosition!.latitude,
                state.currentPosition!.longitude,
              ),
              16,
            );
          }

          if (state.selectedPlace != null && state.currentRoute == null) {
            _showDestinationDialog(state.selectedPlace!);
          }

          // Auto zoom to show entire route
          if (state.currentRoute != null && state.currentPosition != null) {
            _zoomToRoute(state);
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: _initialPosition,
                mapType: _currentMapType,
                onMapCreated: (controller) {
                  _completer.complete(controller);
                  _controller = controller;
                },
                onTap: (position) {
                  // Show dialog for setting destination
                  _showTapDestinationDialog(position);
                },
                markers: _buildMarkers(state),
                polylines: state.polylines,
                circles: state.circles,
                myLocationEnabled: false,
                // We're drawing custom circle
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                compassEnabled: true,
                mapToolbarEnabled: false,
              ),

              // Custom current location indicator with direction
              if (state.currentPosition != null)
                _buildCustomLocationIndicator(state),

              // Search Bar
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 0,
                right: 0,
                child: SearchBarWidget(
                  onSearch: (query) {
                    context.read<MapsCubit>().searchPlacesAutocomplete(query);
                  },
                  onClear: () {
                    context.read<MapsCubit>().clearSearch();
                  },
                ),
              ),

              // Route Info Card
              if (state.currentRoute != null)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 80,
                  left: 0,
                  right: 0,
                  child: RouteInfoCard(
                    route: state.currentRoute!,
                    onClear: () {
                      context.read<MapsCubit>().clearRoute();
                    },
                  ),
                ),

              // Loading Indicator
              if (state.status == MapsStatus.loading || state.isSearching)
                Container(
                  color: Colors.black26,
                  child: const Center(child: CircularProgressIndicator()),
                ),

              // Search Results List
              if (state.searchResults.isNotEmpty && state.currentRoute == null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildSearchResults(state),
                ),

              // Control Buttons
              Positioned(
                right: 16,
                bottom: state.searchResults.isNotEmpty ? 220 : 100,
                child: Column(
                  children: [
                    // My Location Button
                    FloatingActionButton(
                      heroTag: 'location',
                      mini: true,
                      backgroundColor: Colors.white,
                      onPressed: () {
                        context.read<MapsCubit>().loadCurrentLocation();
                      },
                      child: const Icon(Icons.my_location, color: Colors.blue),
                    ),
                    const SizedBox(height: 8),

                    // Map Type Button
                    FloatingActionButton(
                      heroTag: 'layers',
                      mini: true,
                      backgroundColor: Colors.white,
                      onPressed: _showMapTypeDialog,
                      child: const Icon(Icons.layers, color: Colors.blue),
                    ),
                    const SizedBox(height: 8),

                    // Travel Mode Button (when route is active)
                    if (state.currentRoute != null)
                      FloatingActionButton(
                        heroTag: 'travel_mode',
                        mini: true,
                        backgroundColor: Colors.white,
                        onPressed: () => _showTravelModeDialog(state),
                        child: Icon(
                          state.selectedTravelMode.icon,
                          color: Colors.blue,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Set<Marker> _buildMarkers(MapsState state) {
    final markers = Set<Marker>.from(state.markers);

    // Don't add current location marker as we're using custom circle + direction

    return markers;
  }

  Widget _buildCustomLocationIndicator(MapsState state) {
    return FutureBuilder<LatLng>(
      future: _getScreenPosition(
        LatLng(
          state.currentPosition!.latitude,
          state.currentPosition!.longitude,
        ),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        return Positioned(
          left: snapshot.data!.longitude,
          top: snapshot.data!.latitude,
          child: Transform.translate(
            offset: const Offset(-12, -12), // Center the dot
            child: Transform.rotate(
              angle: (state.currentHeading ?? 0) * math.pi / 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Blue dot
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  // Direction indicator (cone shape pointing up)
                  if (state.currentHeading != null && state.currentHeading! > 0)
                    Positioned(
                      top: -8,
                      child: CustomPaint(
                        size: const Size(16, 16),
                        painter: DirectionPainter(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<LatLng> _getScreenPosition(LatLng position) async {
    if (_controller == null) return const LatLng(0, 0);

    final screenCoordinate = await _controller!.getScreenCoordinate(position);
    return LatLng(screenCoordinate.y.toDouble(), screenCoordinate.x.toDouble());
  }

  Widget _buildSearchResults(MapsState state) {
    return Container(
      height: 200,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: state.searchResults.length,
              itemBuilder: (context, index) {
                final place = state.searchResults[index];
                return ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.red),
                  title: Text(
                    place.name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    place.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: place.rating != null
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                place.rating!.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                      : null,
                  onTap: () {
                    context.read<MapsCubit>().selectPlaceFromSearch(place.id);
                    _animateToPosition(place.location, 16);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _animateToPosition(LatLng position, double zoom) async {
    final controller = await _completer.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(position, zoom));
  }

  Future<void> _zoomToRoute(MapsState state) async {
    if (state.currentRoute == null || state.currentPosition == null) return;

    final controller = await _completer.future;

    // Calculate bounds to include current position and all route points
    double minLat = state.currentPosition!.latitude;
    double maxLat = state.currentPosition!.latitude;
    double minLng = state.currentPosition!.longitude;
    double maxLng = state.currentPosition!.longitude;

    for (var point in state.currentRoute!.polylinePoints) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  void _showDestinationDialog(place) {
    showDialog(
      context: context,
      builder: (context) => DestinationDialog(
        place: place,
        onGetDirections: (travelMode) {
          context.read<MapsCubit>().getDirectionsToPlace(place, travelMode);
        },
      ),
    );
  }

  void _showTapDestinationDialog(LatLng position) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Destination?'),
        content: Text(
          'Do you want to set this location as your destination?\n\n'
          'Location: ${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Create a temporary place object
              final place = Place(
                id: 'custom_${position.latitude}_${position.longitude}',
                name: 'Custom Location',
                address:
                    'Lat: ${position.latitude.toStringAsFixed(5)}, Lng: ${position.longitude.toStringAsFixed(5)}',
                location: position,
              );
              _showDestinationDialog(place);
            },
            child: const Text('Set Destination'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<MapsCubit>().addMarker(position);
            },
            child: const Text('Add Marker'),
          ),
        ],
      ),
    );
  }

  // void _showPlaceDetails(place) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) => PlaceDetailsSheet(
  //       place: place,
  //       onGetDirections: () {
  //         Navigator.pop(context);
  //         _showDestinationDialog(place);
  //       },
  //     ),
  //   );
  // }

  void _showTravelModeDialog(MapsState state) {
    showDialog(
      context: context,
      builder: (context) => TravelModeDialog(
        currentMode: state.selectedTravelMode,
        onModeSelected: (mode) {
          if (state.destinationPlace != null) {
            context.read<MapsCubit>().getDirectionsToPlace(
              state.destinationPlace!,
              mode,
            );
          }
        },
      ),
    );
  }

  void _showMapTypeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Map Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMapTypeOption('Normal', MapType.normal),
            _buildMapTypeOption('Satellite', MapType.satellite),
            _buildMapTypeOption('Terrain', MapType.terrain),
            _buildMapTypeOption('Hybrid', MapType.hybrid),
          ],
        ),
      ),
    );
  }

  Widget _buildMapTypeOption(String title, MapType type) {
    return ListTile(
      title: Text(title),
      leading: Radio<MapType>(
        value: type,
        groupValue: _currentMapType,
        onChanged: (MapType? value) {
          setState(() {
            _currentMapType = value!;
          });
          Navigator.pop(context);
        },
      ),
      onTap: () {
        setState(() {
          _currentMapType = type;
        });
        Navigator.pop(context);
      },
    );
  }
}

// Custom painter for direction indicator
class DirectionPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0); // Top point
    path.lineTo(0, size.height); // Bottom left
    path.lineTo(size.width, size.height); // Bottom right
    path.close();

    canvas.drawPath(path, paint);

    // White border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
