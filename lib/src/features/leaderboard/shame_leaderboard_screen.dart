import 'package:flutter/material.dart';

class ShameLeaderboardScreen extends StatelessWidget {
  const ShameLeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final List<Map<String, dynamic>> shamedUsers = [
      {
        'name': 'Alex D.',
        'habit': 'Morning Gym',
        'amount': 500,
        'time': '2h ago',
      },
      {
        'name': 'Sarah K.',
        'habit': 'Read 30m',
        'amount': 1000,
        'time': '5h ago',
      },
      {'name': 'Mike R.', 'habit': 'No Sugar', 'amount': 200, 'time': '1d ago'},
      {
        'name': 'Emily W.',
        'habit': 'Code Daily',
        'amount': 100,
        'time': '1d ago',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('WALL OF SHAME'),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF2C2C2C),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontFamily: 'IBM Plex Mono',
          fontWeight: FontWeight.w900,
          fontSize: 20,
          color: Colors.black,
          letterSpacing: 1.5,
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: shamedUsers.length,
        itemBuilder: (context, index) {
          final user = shamedUsers[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.red, width: 2),
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(4, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      '#${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Missed "${user['habit']}"',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6A6A6A),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '-₹${user['amount']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      user['time'],
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF9A9A9A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
