import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../cubit/maps_cubit.dart';
import '../widgets/place_details_sheet.dart';
import '../widgets/route_info_card.dart';
import '../widgets/search_bar_widget.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  final Completer<GoogleMapController> _completer = Completer();
  bool _isMapReady = false; //to prevent camera calls before ready
  MapType _mapType = MapType.normal;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(26.55840578778722, 31.69720143751444),
    zoom: 14,
  );

  @override
  void initState() {
    super.initState();
    context.read<MapsCubit>().loadCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<MapsCubit, MapsState>(
        listener: (context, state) {
          // 🔹 Handle errors cleanly
          if (state.status == MapsStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage ?? 'An unexpected error occurred',
                ),
              ),
            );
          }

          // 🔹 When current location is loaded, move camera
          if (state.currentPosition != null &&
              state.status == MapsStatus.success) {
            _animateToPosition(
              LatLng(
                state.currentPosition!.latitude,
                state.currentPosition!.longitude,
              ),
              16,
            );
          }

          // 🔹 When a place is selected, show its details bottom sheet
          if (state.selectedPlace != null) {
            _showPlaceDetails(state.selectedPlace!);
          }
        },
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: _initialPosition,
              mapType: _mapType,
              onMapCreated: (controller) {
                if (!_completer.isCompleted) {
                  _completer.complete(controller);
                }
                setState(() => _isMapReady = true);
              },
              onTap: (position) {
                context.read<MapsCubit>().addMarker(position);
              },
              markers: context.select((MapsCubit c) => c.state.markers),
              polylines: context.select((MapsCubit c) => c.state.polyLines),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: true,
              mapToolbarEnabled: false,
            ),

            // 🔹 Search bar widget
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 0,
              right: 0,
              child: SearchBarWidget(
                onSearch: (query) {
                  context.read<MapsCubit>().searchPlacesNearby(query);
                },
                onClear: () {
                  context.read<MapsCubit>().clearSearch();
                },
              ),
            ),

            // 🔹 Route info card
            BlocBuilder<MapsCubit, MapsState>(
              buildWhen: (prev, curr) => prev.currentRoute != curr.currentRoute,
              builder: (context, state) {
                if (state.currentRoute == null) return const SizedBox.shrink();
                return Positioned(
                  top: MediaQuery.of(context).padding.top + 80,
                  left: 0,
                  right: 0,
                  child: RouteInfoCard(
                    route: state.currentRoute!,
                    onClear: () => context.read<MapsCubit>().clearRoute(),
                  ),
                );
              },
            ),

            // 🔹 Loading overlay
            BlocBuilder<MapsCubit, MapsState>(
              buildWhen: (prev, curr) =>
                  prev.status != curr.status ||
                  prev.isSearching != curr.isSearching,
              builder: (context, state) {
                if (state.status == MapsStatus.loading || state.isSearching) {
                  return Container(
                    color: Colors.black26,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // 🔹 Search results list
            BlocBuilder<MapsCubit, MapsState>(
              buildWhen: (prev, curr) =>
                  prev.searchResults != curr.searchResults ||
                  prev.currentRoute != curr.currentRoute,
              builder: (context, state) {
                if (state.searchResults.isEmpty || state.currentRoute != null) {
                  return const SizedBox.shrink();
                }
                return _buildSearchResults(state);
              },
            ),

            // 🔹 Control buttons
            Positioned(
              right: 16,
              bottom: 100,
              child: Column(
                children: [
                  _controlButton(
                    icon: Icons.my_location,
                    onPressed: () =>
                        context.read<MapsCubit>().loadCurrentLocation(),
                  ),
                  const SizedBox(height: 8),
                  _controlButton(
                    icon: Icons.layers,
                    onPressed: _showMapTypeDialog,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Helper widget for control buttons
  Widget _controlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return FloatingActionButton(
      heroTag: icon.codePoint,
      mini: true,
      backgroundColor: Colors.white,
      onPressed: onPressed,
      child: Icon(icon, color: Colors.blue),
    );
  }

  // 🔹 Extracted builder for search results list
  Widget _buildSearchResults(MapsState state) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 220,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                    leading: const Icon(Icons.location_on),
                    title: Text(place.name),
                    subtitle: Text(
                      place.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: place.rating != null
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber,
                              ),
                              Text(place.rating!.toStringAsFixed(1)),
                            ],
                          )
                        : null,
                    onTap: () {
                      context.read<MapsCubit>().selectPlace(place);
                      _animateToPosition(place.location, 16);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _animateToPosition(LatLng position, double zoom) async {
    if (!_isMapReady) return; // 🔹 guard until map is ready
    final controller = await _completer.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(position, zoom));
  }

  void _showPlaceDetails(place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PlaceDetailsSheet(
        place: place,
        onGetDirections: () {
          Navigator.pop(context);
          context.read<MapsCubit>().getDirectionsToPlace(place);
        },
      ),
    );
  }

  void _showMapTypeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // Use a local variable to avoid closing the wrong context
        MapType? groupValue = _mapType;

        return AlertDialog(
          title: const Text('Select Map Type'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialogState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: MapType.values.where((type) => type != MapType.none).map((type) {
                    final String label;
                    switch (type) {
                      case MapType.normal:
                        label = 'Normal';
                        break;
                      case MapType.satellite:
                        label = 'Satellite';
                        break;
                      case MapType.terrain:
                        label = 'Terrain';
                        break;
                      case MapType.hybrid:
                        label = 'Hybrid';
                        break;
                      default:
                        label = type.toString();
                    }

                    return RadioListTile<MapType>(
                      title: Text(label),
                      value: type,
                      groupValue: groupValue,
                      onChanged: (MapType? newValue) {
                        if (newValue == null) return;

                        setDialogState(() => groupValue = newValue);
                        setState(() => _mapType = newValue);

                        // Close the dialog *after* the state updates
                        Navigator.of(dialogContext).pop();
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
