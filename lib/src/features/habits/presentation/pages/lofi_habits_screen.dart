import 'package:flutter/material.dart';

class LoFiHabitsScreen extends StatelessWidget {
  const LoFiHabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habits'),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF2C2C2C),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_outlined, color: Color(0xFF2C2C2C)),
            onPressed: () => _showAddHabitDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD0D0D0), width: 1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'active habits',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: Color(0xFF2C2C2C),
                      letterSpacing: 1.5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFA8DADC), width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '12',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w300,
                        color: Color(0xFFA8DADC), // Pastel muted blue
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            const Text(
              'your habits',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w300,
                color: Color(0xFF2C2C2C),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            
            // Habit items
            ...List.generate(6, (index) => _buildLoFiHabitItem(
              ['morning meditation', 'exercise', 'read for 30 mins', 'drink 8 glasses', 'journal', 'no social media'][index],
              ['daily', 'daily', 'daily', 'daily', 'daily', 'daily'][index],
              ['7 day streak', '3 day streak', '14 day streak', '21 day streak', '2 day streak', '5 day streak'][index],
              [
                const Color(0xFFB8A9C9), // Pastel purple
                const Color(0xFFA8DADC), // Pastel blue
                const Color(0xFFF1E4E8), // Pastel pink
                const Color(0xFFE8E4F1), // Pastel lavender
                const Color(0xFFE4F1E8), // Pastel mint
                const Color(0xFFF1E8E4), // Pastel peach
              ][index],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildLoFiHabitItem(String title, String frequency, String streak, Color accentColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: accentColor.withAlpha((0.5 * 255).toInt()), width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          // Icon with pastel color
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: accentColor, width: 1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              Icons.check_circle_outline,
              color: accentColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF2C2C2C),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$frequency • $streak',
                  style: TextStyle(
                    fontSize: 11,
                    color: accentColor,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: accentColor,
            size: 16,
          ),
        ],
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFAFAFA),
        title: const Text(
          'add new habit',
          style: TextStyle(
            color: Color(0xFF2C2C2C),
            fontWeight: FontWeight.w300,
            letterSpacing: 1.5,
          ),
        ),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'enter habit name...',
            hintStyle: TextStyle(color: Color(0xFF9A9A9A)),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFD0D0D0)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'cancel',
              style: TextStyle(
                color: Color(0xFF6A6A6A),
                fontWeight: FontWeight.w300,
                letterSpacing: 1,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'add',
              style: TextStyle(
                fontWeight: FontWeight.w300,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
