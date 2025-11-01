import 'package:find_me_and_my_theme/features/map/domain/entiities/place.dart';
import 'package:find_me_and_my_theme/features/map/presentation/cubit/maps_cubit.dart';
import 'package:flutter/material.dart';

class DestinationDialog extends StatelessWidget {
  final Place place;
  final Function(TravelMode) onGetDirections;

  const DestinationDialog({
    super.key,
    required this.place,
    required this.onGetDirections,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.place, color: Colors.red, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        place.address,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Get directions by:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTravelModeButton(
                  context,
                  TravelMode.driving,
                  onGetDirections,
                ),
                _buildTravelModeButton(
                  context,
                  TravelMode.walking,
                  onGetDirections,
                ),
                _buildTravelModeButton(
                  context,
                  TravelMode.bicycling,
                  onGetDirections,
                ),
                _buildTravelModeButton(
                  context,
                  TravelMode.transit,
                  onGetDirections,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTravelModeButton(
    BuildContext context,
    TravelMode mode,
    Function(TravelMode) onTap,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap(mode);
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(mode.icon, color: Colors.blue, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            mode.displayName,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
