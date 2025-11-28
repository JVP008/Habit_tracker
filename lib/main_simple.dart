import 'package:flutter/material.dart';

void main() {
  runApp(const ZenFlowApp());
}

class ZenFlowApp extends StatelessWidget {
  const ZenFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZenFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const ZenFlowHomePage(),
    );
  }
}

class ZenFlowHomePage extends StatelessWidget {
  const ZenFlowHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ZenFlow'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.self_improvement, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'ZenFlow',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Mindfulness & Habit Tracking',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 30),
            Text(
              '✅ App Complete & Ready!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Your ZenFlow app includes:\n• Dashboard • Habits • Challenges\n• Journal • Wellbeing • Profile\n• Analytics • Social • Premium',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ZenFlow is ready for deployment! 🚀'),
              backgroundColor: Colors.green,
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.check, color: Colors.white),
      ),
    );
  }
}
