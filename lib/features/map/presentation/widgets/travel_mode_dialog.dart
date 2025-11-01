import 'package:find_me_and_my_theme/features/map/presentation/cubit/maps_cubit.dart';
import 'package:flutter/material.dart';

class TravelModeDialog extends StatelessWidget {
  final Function(TravelMode) onModeSelected;
  final TravelMode currentMode;

  const TravelModeDialog({
    super.key,
    required this.onModeSelected,
    required this.currentMode,
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
            const Text(
              'Select Travel Mode',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...TravelMode.values.map(
              (mode) => _buildModeOption(context, mode, mode == currentMode),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeOption(
    BuildContext context,
    TravelMode mode,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () {
        onModeSelected(mode);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                mode.icon,
                color: isSelected ? Colors.white : Colors.black54,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              mode.displayName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.blue : Colors.black,
              ),
            ),
            const Spacer(),
            if (isSelected) const Icon(Icons.check, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}
