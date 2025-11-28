import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:habit_tracker/src/core/widgets/neo_brutalist_button.dart';

class FireAnimationDialog extends StatelessWidget {
  const FireAnimationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 3),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(8, 8), blurRadius: 0),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'STREAK SAVED!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),

            // Lottie Animation
            // Using a placeholder or assuming 'assets/fire.json' exists.
            // If not found, it will show an error or empty space, so we handle errors.
            SizedBox(
              height: 200,
              width: 200,
              child: Lottie.asset(
                'assets/loading.json', // Placeholder: Replace with 'assets/fire.json'
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.local_fire_department,
                    size: 100,
                    color: Colors.orange,
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              'You kept the fire alive.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),

            NeoBrutalistButton(
              onPressed: () => Navigator.pop(context),
              backgroundColor: Colors.black,
              child: const Text('NICE', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
