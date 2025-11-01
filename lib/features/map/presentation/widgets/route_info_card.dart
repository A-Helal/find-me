import 'package:find_me_and_my_theme/features/map/domain/entiities/route_info.dart';
import 'package:flutter/material.dart';

class RouteInfoCard extends StatelessWidget {
  final RouteInfo route;
  final VoidCallback onClear;

  const RouteInfoCard({
    super.key,
    required this.route,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Route Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onClear,
              ),
            ],
          ),
          const Divider(),
          Row(
            children: [
              const Icon(Icons.access_time, size: 20),
              const SizedBox(width: 8),
              Text(
                route.duration,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 24),
              const Icon(Icons.straighten, size: 20),
              const SizedBox(width: 8),
              Text(
                route.distance,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          if (route.summary.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'via ${route.summary}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }
}