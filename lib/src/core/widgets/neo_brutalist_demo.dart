import 'package:flutter/material.dart';
import 'package:habit_tracker/src/core/widgets/neo_brutalist_button.dart';
import 'package:habit_tracker/src/core/widgets/neo_brutalist_text_field.dart';

/// Demo screen showcasing the NeoBrutalist components
class NeoBrutalistDemo extends StatelessWidget {
  const NeoBrutalistDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text('NeoBrutalist Demo'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Neobrutalist 3D Components',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Text Fields
            const NeoBrutalistTextField(
              labelText: 'Name',
              hintText: 'Enter your name',
            ),
            const SizedBox(height: 20),

            const NeoBrutalistTextField(
              labelText: 'Email',
              hintText: 'Enter your email',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 32),

            // Button
            NeoBrutalistButton(
              width: double.infinity,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Button pressed! Watch the 3D push effect!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('ENTER ZENFLOW'),
            ),

            const SizedBox(height: 40),

            const Text(
              'Features:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '• Thick black borders (4-6px)\n'
              '• Sharp 3D shadow effect\n'
              '• Smooth push-down animation on press\n'
              '• Retro neobrutalism aesthetic',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6A6A6A),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
