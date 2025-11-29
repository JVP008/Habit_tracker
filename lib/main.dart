import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    hide AuthState; // Added Supabase import
import 'package:habit_tracker/app_state.dart';
import 'package:habit_tracker/src/core/di/injection.dart';
import 'package:habit_tracker/src/core/theme/neo_brutalist_border.dart';
import 'package:habit_tracker/src/core/widgets/neo_brutalist_button.dart';
import 'package:habit_tracker/src/core/widgets/color_picker_dialog.dart';
import 'package:uuid/uuid.dart' as uuid_gen;
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:habit_tracker/src/features/habits/widgets/betting_dialog.dart';
import 'package:habit_tracker/src/features/habits/widgets/proof_dialog.dart';
import 'package:habit_tracker/src/features/habits/widgets/fire_animation_dialog.dart';
import 'package:habit_tracker/src/features/leaderboard/shame_leaderboard_screen.dart';
import 'package:habit_tracker/src/features/wellbeing/screens/zen_radio_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  // TODO: Replace with your actual Supabase URL and Anon Key
  await Supabase.initialize(
    url: 'https://ynrqgrovylotztigcuvk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlucnFncm92eWxvdHp0aWdjdXZrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQzNDM1NDUsImV4cCI6MjA3OTkxOTU0NX0.vLTAl1nZiKEHjatGoOeu0ykkdIg73KJRU4m_ObvIJn4',
  );

  if (!kIsWeb) {
    await configureDependencies();
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ZenFlowAppState()),
        ChangeNotifierProvider(create: (_) => AuthState()),
      ],
      child: const ZenFlowLoFiApp(),
    ),
  );
}

class ZenFlowLoFiApp extends StatelessWidget {
  const ZenFlowLoFiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZenFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false, // DISABLE Material 3 to kill gray tinting!
        fontFamily: GoogleFonts.ibmPlexMono().fontFamily,
        // Lo-Fi Monochrome Wireframe theme
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFAFAFA), // Off-white
        primaryColor: const Color(0xFF2C2C2C), // Dark charcoal
        cardColor: Colors.transparent,
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF2C2C2C), // Black
          secondary: const Color(0xFF2C2C2C), // Black
          surface: Colors.white, // Pure white
          error: Colors.red,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: const Color(0xFF2C2C2C), // Black text
          onError: Colors.white,
          surfaceTint: Colors.transparent, // KILL THE TINT
        ),

        // Monochrome text theme
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            color: const Color(0xFF2C2C2C),
            fontSize: 28, // Slightly larger
            fontWeight: FontWeight.w800, // Extra bold
            letterSpacing: 1.5, // More spaced
          ),
          headlineMedium: TextStyle(
            // Added from previous theme to avoid undefined
            color: const Color(0xFF2C2C2C),
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
          titleLarge: TextStyle(
            // Added from previous theme
            color: const Color(0xFF2C2C2C),
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
          bodyLarge: TextStyle(
            color: const Color(0xFF4A4A4A),
            fontSize: 18, // Slightly larger
            fontWeight: FontWeight.w700, // Bold
            letterSpacing: 1.0,
          ),
          bodyMedium: TextStyle(
            color: const Color(0xFF6A6A6A),
            fontSize: 15, // Slightly larger
            fontWeight: FontWeight.w600, // Medium bold
            letterSpacing: 0.8,
          ),
          labelSmall: TextStyle(
            color: const Color(0xFF6A6A6A),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.8,
          ),
        ),

        // Wireframe button style with 3D Shadow Effect
        elevatedButtonTheme: ElevatedButtonThemeData(
          style:
              ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2C2C2C),
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                shadowColor: Colors.transparent,
                side: const BorderSide(color: Colors.black, width: 4.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ).copyWith(
                backgroundColor: WidgetStateProperty.all(Colors.white),
                surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
                overlayColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.pressed)) {
                    return Colors.black.withValues(alpha: 0.05);
                  }
                  return Colors.transparent;
                }),
              ),
        ),

        // Wireframe card style
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0, // Material elevation creates soft shadow, set to 0.
          shadowColor:
              Colors.transparent, // Shadow will be added via shape border.
          shape: NeoBrutalistBorder(
            side: const BorderSide(color: Colors.black, width: 3.0),
            borderRadius: BorderRadius.circular(8),
            shadowColor: Colors.black,
            shadowOffset: const Offset(6, 6), // Hard shadow offset down-right
            shadowBlurRadius: 0,
            shadowSpreadRadius: 0,
          ),
          margin: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 8,
          ), // Adjust margin for blocky feel
        ),

        // Input decoration
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          hoverColor: Colors.black.withValues(
            alpha: 0.05,
          ), // Subtle hover effect
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          labelStyle: const TextStyle(
            color: Color(0xFF2C2C2C),
            fontWeight: FontWeight.w600,
          ), // Flat, bold typography
          hintStyle: const TextStyle(
            color: Color(0xFF6A6A6A),
          ), // Subtle hint text
          border: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.black,
              width: 3.0,
            ), // Thick black border
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black, width: 3.0),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.black,
              width: 4.0,
            ), // Even thicker border on focus
            borderRadius: BorderRadius.circular(8),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red, width: 3.0),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red, width: 4.0),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      home: const LoFiSplashScreen(),
    );
  }
}

class ZenFlowLoFiMainScreen extends StatefulWidget {
  const ZenFlowLoFiMainScreen({super.key});

  @override
  State<ZenFlowLoFiMainScreen> createState() => _ZenFlowLoFiMainScreenState();
}

class _ZenFlowLoFiMainScreenState extends State<ZenFlowLoFiMainScreen> {
  int _currentIndex = 0;

  void _toggleHabit(int index) {
    final app = context.read<ZenFlowAppState>();
    final habit = app.habits[index];

    if (habit.isBetActive && !habit.completed) {
      showDialog(
        context: context,
        builder: (context) => ProofDialog(
          onProofSubmitted: (path) {
            // Verify proof via service (mocked for now)
            // Then toggle
            app.toggleHabit(index);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Proof uploaded! Streak saved.')),
            );

            // Show Fire Animation
            showDialog(
              context: context,
              builder: (context) => const FireAnimationDialog(),
            );
          },
        ),
      );
    } else {
      app.toggleHabit(index);
    }
  }

  void _addHabit(String title, String frequency, int accentHex) {
    if (title.trim().isEmpty) return;
    final app = context.read<ZenFlowAppState>();
    app.addHabit(title.trim(), frequency, accentHex);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<ZenFlowAppState>();
    final screens = [
      LoFiDashboardScreen(habits: app.habits, onToggleHabit: _toggleHabit),
      LoFiHabitsScreen(
        habits: app.habits,
        onToggleHabit: _toggleHabit,
        onAddHabit: _addHabit,
        onEditHabit: (index, title, frequency, accentHex) =>
            context.read<ZenFlowAppState>().editHabit(
              index,
              title: title,
              frequency: frequency,
              accentHex: accentHex,
            ),
        onDeleteHabit: (index) =>
            context.read<ZenFlowAppState>().deleteHabit(index),
      ),
      const ShameLeaderboardScreen(),
      const LoFiChallengesScreen(),
      const LoFiJournalScreen(),
      const LoFiWellbeingScreen(),
      const LoFiProfileScreen(),
    ];
    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFBDBDBD), width: 1.5)),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLoFiNavItem(Icons.dashboard_outlined, 'Dashboard', 0),
              _buildLoFiNavItem(Icons.check_circle_outline, 'Habits', 1),
              _buildLoFiNavItem(Icons.warning_amber_rounded, 'Shame', 2),
              _buildLoFiNavItem(Icons.emoji_events_outlined, 'Challenges', 3),
              _buildLoFiNavItem(Icons.book_outlined, 'Journal', 4),
              _buildLoFiNavItem(Icons.favorite_outline, 'Wellbeing', 5),
              _buildLoFiNavItem(Icons.person_outline, 'Profile', 6),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoFiNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFF2C2C2C) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF2C2C2C)
                  : const Color(0xFF9A9A9A),
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: isSelected
                    ? const Color(0xFF2C2C2C)
                    : const Color(0xFF9A9A9A),
                fontWeight: isSelected ? FontWeight.w400 : FontWeight.w300,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoFiDashboardScreen extends StatelessWidget {
  const LoFiDashboardScreen({
    super.key,
    required this.habits,
    required this.onToggleHabit,
  });

  final List<HabitItem> habits;
  final void Function(int index) onToggleHabit;

  @override
  Widget build(BuildContext context) {
    final completed = habits.where((habit) => habit.completed).length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF2C2C2C),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFBDBDBD), width: 1.5),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'welcome back',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                      color: Color(0xFF2C2C2C),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildWireframeStat('current streak', '7 days'),
                  const SizedBox(height: 12),
                  _buildWireframeStat(
                    'habits today',
                    '$completed of ${habits.length}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const Text(
              'today\'s habits',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w300,
                color: Color(0xFF2C2C2C),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),

            // Habit list
            for (final entry in habits.asMap().entries.take(5))
              _buildWireframeHabit(entry.key, entry.value),
          ],
        ),
      ),
    );
  }

  Widget _buildWireframeStat(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w300,
            color: Color(0xFF6A6A6A),
            letterSpacing: 1,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF2C2C2C),
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildWireframeHabit(int index, HabitItem habit) {
    final accent = Color(habit.accentHex);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: habit.completed ? accent : const Color(0xFFD0D0D0),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: InkWell(
        onTap: () => onToggleHabit(index),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                border: Border.all(
                  color: habit.completed ? accent : const Color(0xFFD0D0D0),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
              child: habit.completed
                  ? Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                habit.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFF4A4A4A),
                  letterSpacing: 0.8,
                ),
              ),
            ),
            Text(
              habit.completed ? 'done' : 'pending',
              style: TextStyle(
                fontSize: 11,
                color: habit.completed ? accent : const Color(0xFF9A9A9A),
                fontWeight: FontWeight.w300,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoFiHabitsScreen extends StatelessWidget {
  const LoFiHabitsScreen({
    super.key,
    required this.habits,
    required this.onToggleHabit,
    required this.onAddHabit,
    required this.onEditHabit,
    required this.onDeleteHabit,
  });

  final List<HabitItem> habits;
  final void Function(int index) onToggleHabit;
  final void Function(String title, String frequency, int accentHex) onAddHabit;
  final void Function(
    int index,
    String? title,
    String? frequency,
    int? accentHex,
  )
  onEditHabit;
  final void Function(int index) onDeleteHabit;

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
      body: habits.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Color(0xFFBDBDBD),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Add your first habit!',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF6A6A6A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap + to get started',
                    style: TextStyle(fontSize: 14, color: Color(0xFF9A9A9A)),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFBDBDBD),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'active habits (${habits.length})',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                            color: Color(0xFF2C2C2C),
                            letterSpacing: 1.5,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                              color: Color(0xFF2C2C2C),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${habits.length}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2C2C2C),
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
                  for (final entry in habits.asMap().entries)
                    _buildLoFiHabitItem(context, entry.key, entry.value),
                ],
              ),
            ),
    );
  }

  Widget _buildLoFiHabitItem(BuildContext context, int index, HabitItem habit) {
    final accent = Color(habit.accentHex);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: accent.withValues(alpha: 0.6), width: 1.5),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, 4),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => onToggleHabit(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: accent, width: 1.5),
                borderRadius: BorderRadius.circular(4),
                color: habit.completed
                    ? accent.withValues(alpha: 0.15)
                    : Colors.transparent,
              ),
              alignment: Alignment.center,
              child: Icon(
                habit.completed
                    ? Icons.check_circle
                    : Icons.check_circle_outline,
                color: habit.completed ? Colors.black : accent,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF2C2C2C),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${habit.frequency} • ${habit.streakLabel}',
                  style: TextStyle(
                    fontSize: 11,
                    color: accent,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: habit.completed ? 'undo' : 'complete',
                onPressed: () => onToggleHabit(index),
                icon: Icon(
                  habit.completed ? Icons.undo : Icons.playlist_add_check,
                  color: accent,
                  size: 18,
                ),
              ),
              IconButton(
                tooltip: 'edit',
                onPressed: () => _showEditHabitDialog(context, index, habit),
                icon: const Icon(Icons.edit, color: Colors.black, size: 18),
              ),
              IconButton(
                tooltip: 'delete',
                onPressed: () => _confirmDelete(context, index, habit.title),
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.black,
                  size: 18,
                ),
              ),
              if (!habit.isBetActive)
                IconButton(
                  tooltip: 'bet streak',
                  onPressed: () => _showBettingDialog(context, index),
                  icon: const Icon(
                    Icons.monetization_on_outlined,
                    color: Colors.black,
                    size: 18,
                  ),
                )
              else
                Tooltip(
                  message: 'Bet Active: ₹${habit.betAmount}',
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          color: Colors.orange,
                          size: 18,
                        ),
                        Text(
                          '₹${habit.betAmount.toInt()}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    String frequency = 'daily';
    int chosenAccent = 0xFF4CAF50; // Default green

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFFFAFAFA),
          title: const Text(
            'add new habit',
            style: TextStyle(
              color: Color(0xFF2C2C2C),
              fontWeight: FontWeight.w300,
              letterSpacing: 1.5,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'enter habit name...',
                  hintStyle: TextStyle(color: Color(0xFF9A9A9A)),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: frequency,
                decoration: const InputDecoration(labelText: 'frequency'),
                items: const [
                  DropdownMenuItem(value: 'daily', child: Text('daily')),
                  DropdownMenuItem(value: 'weekly', child: Text('weekly')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    frequency = value;
                  }
                },
              ),
              const SizedBox(height: 16),
              // Color Picker Button
              GestureDetector(
                onTap: () async {
                  final Color? selectedColor = await showDialog<Color>(
                    context: context,
                    builder: (context) =>
                        ColorPickerDialog(initialColor: Color(chosenAccent)),
                  );
                  if (selectedColor != null) {
                    setDialogState(
                      () => chosenAccent = selectedColor.toARGB32(),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(chosenAccent),
                    border: Border.all(color: Colors.black, width: 3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.palette,
                        color: Color(chosenAccent).computeLuminance() > 0.5
                            ? Colors.black
                            : Colors.white,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'pick color',
                        style: TextStyle(
                          color: Color(chosenAccent).computeLuminance() > 0.5
                              ? Colors.black
                              : Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
            NeoBrutalistButton(
              onPressed: () {
                if (controller.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name your habit first.')),
                  );
                  return;
                }
                onAddHabit(controller.text, frequency, chosenAccent);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('"${controller.text.trim()}" added.')),
                );
              },
              backgroundColor: Colors.black,
              child: const Text(
                'create',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBettingDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => BettingDialog(
        onPlaceBet: (amount, supervisor, phone) {
          context.read<ZenFlowAppState>().placeBet(
            index,
            amount,
            supervisor,
            phone,
          );
        },
      ),
    );
  }

  void _showEditHabitDialog(BuildContext context, int index, HabitItem habit) {
    final TextEditingController controller = TextEditingController(
      text: habit.title,
    );
    String frequency = habit.frequency;
    int chosenAccent = habit.accentHex;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFFFAFAFA),
          title: const Text(
            'edit habit',
            style: TextStyle(
              color: Color(0xFF2C2C2C),
              fontWeight: FontWeight.w300,
              letterSpacing: 1.5,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'habit name',
                  hintStyle: TextStyle(color: Color(0xFF9A9A9A)),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: frequency,
                decoration: const InputDecoration(labelText: 'frequency'),
                items: const [
                  DropdownMenuItem(value: 'daily', child: Text('daily')),
                  DropdownMenuItem(value: 'weekly', child: Text('weekly')),
                ],
                onChanged: (value) {
                  if (value != null) frequency = value;
                },
              ),
              const SizedBox(height: 16),
              // Color Picker Button
              GestureDetector(
                onTap: () async {
                  final Color? selectedColor = await showDialog<Color>(
                    context: context,
                    builder: (context) =>
                        ColorPickerDialog(initialColor: Color(chosenAccent)),
                  );
                  if (selectedColor != null) {
                    setDialogState(
                      () => chosenAccent = selectedColor.toARGB32(),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(chosenAccent),
                    border: Border.all(color: Colors.black, width: 3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.palette,
                        color: Color(chosenAccent).computeLuminance() > 0.5
                            ? Colors.black
                            : Colors.white,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Choose Color',
                        style: TextStyle(
                          color: Color(chosenAccent).computeLuminance() > 0.5
                              ? Colors.black
                              : Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                onEditHabit(
                  index,
                  controller.text.trim(),
                  frequency,
                  chosenAccent,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Habit updated.')));
              },
              child: const Text('save'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int index, String title) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFFAFAFA),
        title: const Text('delete habit'),
        content: Text('remove “$title”?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('cancel'),
          ),
          TextButton(
            onPressed: () {
              onDeleteHabit(index);
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Habit deleted.')));
            },
            child: const Text('delete'),
          ),
        ],
      ),
    );
  }
}

// Placeholder screens for other tabs
class LoFiChallengesScreen extends StatelessWidget {
  const LoFiChallengesScreen({super.key});

  static const List<Map<String, dynamic>> _challengeData = [
    {
      'title': '7-day focus sprint',
      'description': 'Complete three deep-work blocks daily.',
      'progress': 0.65,
      'members': 24,
      'accent': Color(0xFF00BCD4), // Vibrant cyan - VISIBLE!
    },
    {
      'title': 'hydrate & thrive',
      'description': 'Drink 8 glasses of water each day.',
      'progress': 0.4,
      'members': 18,
      'accent': Color(0xFF9C27B0), // Vibrant purple - VISIBLE!
    },
    {
      'title': 'mindful evenings',
      'description': 'Log a gratitude note before bedtime.',
      'progress': 0.8,
      'members': 32,
      'accent': Color(0xFFE91E63), // Vibrant pink - VISIBLE!
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Challenges'),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF2C2C2C),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            for (final challenge in _challengeData)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildChallengeCard(context, challenge),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFBDBDBD), width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'weekly challenges',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF2C2C2C),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Join a focus sprint or start your own ritual to stay accountable.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF6A6A6A),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 16),
          NeoBrutalistButton(
            onPressed: () => _startChallengeFlow(context),
            child: const Text('create custom challenge'),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(BuildContext context, Map<String, dynamic> data) {
    final Color accent = data['accent'] as Color;
    final double progress = data['progress'] as double;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: accent.withValues(alpha: 0.6), width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data['title'] as String,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2C2C2C),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data['description'] as String,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6A6A6A),
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 6,
            decoration: BoxDecoration(
              border: Border.all(color: accent, width: 1.5),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(color: accent.withValues(alpha: 0.8)),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).round()}% complete • ${data['members']} members',
                style: TextStyle(
                  fontSize: 11,
                  color: accent,
                  letterSpacing: 0.6,
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () =>
                        _showChallengeDetails(context, data['title'] as String),
                    child: const Text('details'),
                  ),
                  const SizedBox(width: 8),
                  NeoBrutalistButton(
                    onPressed: () =>
                        _acknowledgeAction(context, 'Joined ${data['title']}'),
                    child: const Text('join'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _startChallengeFlow(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFAFAFA),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'launch a ritual',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2C2C2C),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Pick a habit, set its duration, invite friends, and ZenFlow will keep everyone on track.',
              style: TextStyle(fontSize: 13, color: Color(0xFF6A6A6A)),
            ),
            const SizedBox(height: 16),
            NeoBrutalistButton(
              onPressed: () {
                Navigator.pop(context);
                _acknowledgeAction(
                  context,
                  'Custom challenge template created.',
                );
              },
              child: const Text('generate template'),
            ),
          ],
        ),
      ),
    );
  }

  void _showChallengeDetails(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFFAFAFA),
        title: Text(title),
        content: const Text(
          'Track streaks, cheer teammates, and unlock pastel badges for consistent wins.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('close'),
          ),
          NeoBrutalistButton(
            onPressed: () {
              Navigator.pop(context);
              _acknowledgeAction(context, 'Reminder set for challenge.');
            },
            child: const Text('set reminder'),
          ),
        ],
      ),
    );
  }

  void _acknowledgeAction(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

class LoFiJournalScreen extends StatefulWidget {
  const LoFiJournalScreen({super.key});

  @override
  State<LoFiJournalScreen> createState() => _LoFiJournalScreenState();
}

class _LoFiJournalScreenState extends State<LoFiJournalScreen> {
  final TextEditingController _entryController = TextEditingController();
  final List<Map<String, String>> _entries = [
    {
      'title': 'slow morning clarity',
      'time': '08:05',
      'excerpt': 'Breathed deeply for 7 minutes and noticed shoulders relax.',
    },
    {
      'title': 'midday reset',
      'time': '13:20',
      'excerpt':
          'Walked outside, heard city hum soften. Energy climbed back up.',
    },
  ];

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF2C2C2C),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuickEntryCard(context),
            const SizedBox(height: 24),
            const Text(
              'recent reflections',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2C2C2C),
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            for (final entry in _entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildEntryCard(context, entry),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickEntryCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFBDBDBD), width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'micro-journal',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2C2C2C),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Capture a thought in one sentence. ZenFlow keeps the timeline tidy.',
            style: TextStyle(fontSize: 12, color: Color(0xFF6A6A6A)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _entryController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'write what you noticed...',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveQuickEntry,
                  child: const Text('save reflection'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextButton(
                  onPressed: () => _entryController.clear(),
                  child: const Text('clear'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(BuildContext context, Map<String, String> entry) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFBDBDBD), width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                entry['title']!,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2C2C2C),
                ),
              ),
              Text(
                entry['time']!,
                style: const TextStyle(fontSize: 12, color: Color(0xFF6A6A6A)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            entry['excerpt']!,
            style: const TextStyle(fontSize: 12, color: Color(0xFF4A4A4A)),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _viewEntry(context, entry),
                child: const Text('view'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => _favoriteEntry(entry['title']!),
                child: const Text('favorite'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _saveQuickEntry() {
    final text = _entryController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a sentence before saving.')),
      );
      return;
    }
    setState(() {
      _entries.insert(0, {
        'title': 'quick note',
        'time': TimeOfDay.now().format(context),
        'excerpt': text,
      });
    });
    _entryController.clear();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Reflection saved.')));
  }

  void _viewEntry(BuildContext context, Map<String, String> entry) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFFAFAFA),
        title: Text(entry['title']!),
        content: Text(entry['excerpt']!),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _favoriteEntry(entry['title']!);
            },
            child: const Text('favorite'),
          ),
        ],
      ),
    );
  }

  void _favoriteEntry(String title) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('“$title” pinned to highlights.')));
  }
}

class LoFiWellbeingScreen extends StatefulWidget {
  const LoFiWellbeingScreen({super.key});

  @override
  State<LoFiWellbeingScreen> createState() => _LoFiWellbeingScreenState();
}

class _LoFiWellbeingScreenState extends State<LoFiWellbeingScreen> {
  double _calmLevel = 0.7;
  double _energyLevel = 0.5;
  bool _breathSessionEnabled = false;
  late AudioPlayer _audioPlayer;
  String? _selectedFile;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.onDurationChanged.listen((d) {
      setState(() => _duration = d);
    });
    _audioPlayer.onPositionChanged.listen((p) {
      setState(() => _position = p);
    });
    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() => _isPlaying = state == PlayerState.playing);
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );
    if (result != null) {
      setState(() => _selectedFile = result.files.single.path);
    }
  }

  void _play() async {
    if (_selectedFile != null) {
      await _audioPlayer.play(DeviceFileSource(_selectedFile!));
    }
  }

  void _pause() async {
    await _audioPlayer.pause();
  }

  void _seek(double value) async {
    await _audioPlayer.seek(Duration(seconds: value.toInt()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wellbeing'),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF2C2C2C),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMoodCard(context),
            const SizedBox(height: 24),
            _buildRoutineCard(context),
            const SizedBox(height: 24),
            _buildSupportActions(context),
            const SizedBox(height: 24),
            _buildMusicPlayerCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFBDBDBD), width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'daily check-in',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2C2C2C),
            ),
          ),
          const SizedBox(height: 12),
          _buildSliderRow('calm level', _calmLevel, (value) {
            setState(() => _calmLevel = value);
          }),
          const SizedBox(height: 12),
          _buildSliderRow('energy level', _energyLevel, (value) {
            setState(() => _energyLevel = value);
          }),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _logWellbeing,
            child: const Text('log mood snapshot'),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderRow(
    String label,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6A6A6A),
                letterSpacing: 0.8,
              ),
            ),
            Text(
              '${(value * 10).round()}/10',
              style: const TextStyle(fontSize: 12, color: Color(0xFF2C2C2C)),
            ),
          ],
        ),
        Slider(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF2C2C2C),
          inactiveColor: const Color(0xFFBDBDBD),
        ),
      ],
    );
  }

  Widget _buildRoutineCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFBDBDBD), width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'wind-down routine',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2C2C2C),
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'guided breath session',
              style: TextStyle(fontSize: 13),
            ),
            subtitle: const Text('3 minutes • pastel teal pulses'),
            value: _breathSessionEnabled,
            activeThumbColor: const Color(0xFF2C2C2C),
            onChanged: (value) {
              setState(() => _breathSessionEnabled = value);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    value
                        ? 'Breath reminder scheduled.'
                        : 'Breath reminder paused.',
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _launchRoutine,
            child: const Text('start guided steps'),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFBDBDBD), width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'support vault',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2C2C2C),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildSupportChip(
                context,
                'share progress',
                Icons.share_outlined,
              ),
              _buildSupportChip(context, 'text a friend', Icons.sms_outlined),
              _buildSupportChip(
                context,
                'launch zen radio',
                Icons.radio_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSupportChip(BuildContext context, String label, IconData icon) {
    return GestureDetector(
      onTap: () => _onSupportAction(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF2C2C2C), width: 1.5),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF2C2C2C)),
            const SizedBox(width: 8),
            Text(label.toLowerCase()),
          ],
        ),
      ),
    );
  }

  void _logWellbeing() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Mood logged: calm ${(_calmLevel * 10).round()}/10 • energy ${(_energyLevel * 10).round()}/10',
        ),
      ),
    );
  }

  void _launchRoutine() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Guided wind-down launched.')));
  }

  void _onSupportAction(String label) {
    if (label == 'launch zen radio') {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const ZenRadioScreen()));
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label activated.')));
  }

  Widget _buildMusicPlayerCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFBDBDBD), width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'local music player',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2C2C2C),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _pickFile,
            child: const Text('pick mp3 file'),
          ),
          if (_selectedFile != null) ...[
            const SizedBox(height: 12),
            Text(
              'Selected: ${_selectedFile!.split('/').last}',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  onPressed: _isPlaying ? _pause : _play,
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                ),
                Expanded(
                  child: Slider(
                    value: _position.inSeconds.toDouble(),
                    max: _duration.inSeconds.toDouble(),
                    onChanged: _seek,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class LoFiProfileScreen extends StatefulWidget {
  const LoFiProfileScreen({super.key});

  @override
  State<LoFiProfileScreen> createState() => _LoFiProfileScreenState();
}

class _LoFiProfileScreenState extends State<LoFiProfileScreen> {
  bool _notificationsEnabled = true;
  bool _publicProfile = false;
  String _userName = 'jayes lankesh';
  String _userBio = 'lo-fi architect • since 2024';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF2C2C2C),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIdentityCard(),
            const SizedBox(height: 24),
            _buildPreferenceCard(),
            const SizedBox(height: 24),
            _buildActionGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentityCard() {
    final auth = context.watch<AuthState>();
    final name = auth.displayName ?? 'Guest User';
    final initials = name.isNotEmpty
        ? name.split(' ').take(2).map((e) => e[0].toUpperCase()).join()
        : 'GU';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFBDBDBD), width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF2C2C2C), width: 1.5),
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  auth.email ?? 'No email',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6A6A6A),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'lo-fi architect • since 2024',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6A6A6A)),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _showEditProfileDialog,
            child: const Text('edit'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _userName);
    final bioController = TextEditingController(text: _userBio);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFAFAFA),
        title: const Text(
          'edit profile',
          style: TextStyle(
            color: Color(0xFF2C2C2C),
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'name',
                hintText: 'Enter your name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: bioController,
              decoration: const InputDecoration(
                labelText: 'bio',
                hintText: 'Enter your bio',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _userName = nameController.text.trim();
                _userBio = bioController.text.trim();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully!')),
              );
            },
            child: const Text('save'),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFBDBDBD), width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('habit nudges'),
            subtitle: const Text('Receive low-key reminders'),
            value: _notificationsEnabled,
            activeThumbColor: const Color(0xFF2C2C2C),
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
              _showActionMessage(
                value ? 'Nudges enabled.' : 'Nudges disabled.',
              );
            },
          ),
          const Divider(),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('public showcase'),
            subtitle: const Text('Share streaks with community'),
            value: _publicProfile,
            activeThumbColor: const Color(0xFF2C2C2C),
            onChanged: (value) {
              setState(() => _publicProfile = value);
              _showActionMessage(
                value ? 'Profile visible to friends.' : 'Profile hidden.',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid() {
    final actions = [
      {'label': 'export insights', 'icon': Icons.download_outlined},
      {'label': 'sync calendar', 'icon': Icons.calendar_today_outlined},
      {'label': 'contact coach', 'icon': Icons.support_agent},
    ];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFBDBDBD), width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'quick actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2C2C2C),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final action in actions)
                GestureDetector(
                  onTap: () => _showActionMessage('${action['label']} tapped'),
                  child: Container(
                    width: 150,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF2C2C2C),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          action['icon'] as IconData,
                          size: 18,
                          color: const Color(0xFF2C2C2C),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          (action['label'] as String).toLowerCase(),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showActionMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class LoFiSplashScreen extends StatefulWidget {
  const LoFiSplashScreen({super.key});

  @override
  State<LoFiSplashScreen> createState() => _LoFiSplashScreenState();
}

class _LoFiSplashScreenState extends State<LoFiSplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      final authed = context.read<AuthState>().isRegistered;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => authed
              ? const ZenFlowLoFiMainScreen()
              : const LoFiRegisterScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.95, end: 1.0),
          duration: const Duration(milliseconds: 900),
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xFF2C2C2C),
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'ZenFlow',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2C2C2C),
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'lo-fi focus, high vibes',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6A6A6A),
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      backgroundColor: const Color(0xFFFAFAFA),
    );
  }
}

class LoFiRegisterScreen extends StatefulWidget {
  const LoFiRegisterScreen({super.key});

  @override
  State<LoFiRegisterScreen> createState() => _LoFiRegisterScreenState();
}

class _LoFiRegisterScreenState extends State<LoFiRegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF2C2C2C),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF2C2C2C), width: 1.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Let’s sketch your profile. No passwords, just a name and email to personalize your flow.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4A4A4A),
                  letterSpacing: 0.6,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            NeoBrutalistButton(
              width: double.infinity,
              onPressed: () async {
                final name = _nameCtrl.text.trim();
                final email = _emailCtrl.text.trim();
                if (name.isEmpty || email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please add your name and email.'),
                    ),
                  );
                  return;
                }
                try {
                  final userId = uuid_gen.Uuid().v4();
                  if (!kIsWeb) {
                    // Create user in local database (native platforms)
                    final db = getIt.databaseService.db;
                    final now = DateTime.now().millisecondsSinceEpoch;
                    await db.insert('users', {
                      'id': userId,
                      'display_name': name,
                      'email': email,
                      'streak_days': 0,
                      'completed_challenges': 0,
                      'created_at': now,
                      'updated_at': now,
                    });
                  }

                  if (!context.mounted) return;
                  await context.read<AuthState>().register(
                    name: name,
                    email: email,
                    id: userId,
                  );
                  if (!context.mounted) return;
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const ZenFlowLoFiMainScreen(),
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Registration failed: $e')),
                  );
                }
              },
              child: const Text('enter zenflow'),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFFAFAFA),
    );
  }
}
