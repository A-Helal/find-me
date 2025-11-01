import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  //promise dart u will complete later
  final Completer<GoogleMapController> _completer =
      Completer<GoogleMapController>();

  //where the maps started
  static const CameraPosition _cameraPosition = CameraPosition(
    target: LatLng(26.55840578778722, 31.69720143751444), //bld elmawaweel
    zoom: 14,
  );

  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _checkAndGoToLocation(); // Move camera once permissions are ready
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: _cameraPosition,
        //camera init view
        mapType: MapType.satellite,
        onMapCreated: (controller) {
          _completer.complete(controller);
        },
        onTap: _addMarker,
        markers: _markers,
        zoomControlsEnabled: true,
        compassEnabled: true,
        myLocationEnabled: true,
        // myLocationButtonEnabled: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _checkAndGoToLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }

  void _addMarker(LatLng position) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(position.toString()),
          position: position,
          infoWindow: const InfoWindow(title: "Pinned Location"),
        ),
      );
    });
  }

  Future<void> _checkAndGoToLocation() async {
    try {
      final position = await _determinePosition();
      final controller = await _completer.future;
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          16,
        ),
      );
    } catch (e) {
      return;
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, cannot request.',
      );
    }
    return await Geolocator.getCurrentPosition();
  }
}
