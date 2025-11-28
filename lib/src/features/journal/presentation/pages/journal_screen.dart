import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glass_kit/glass_kit.dart' as glass_kit;
import '../../../../core/providers/auth_provider.dart';
import '../../providers/journal_provider.dart';
import '../../data/models/journal_entry_model.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: glass_kit.GlassContainer.clearGlass(
              height: 60,
              borderRadius: BorderRadius.circular(16),
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: const [
                  Tab(text: 'Entries'),
                  Tab(text: 'Write'),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: Consumer<JournalProvider>(
              builder: (context, journalProvider, _) {
                if (journalProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }
                return TabBarView(
                  controller: _tabController,
                  children: [
                    JournalEntriesTab(entries: journalProvider.entries),
                    WriteJournalTab(onSave: () => _tabController.animateTo(0)), // Switch to entries after save
                  ],
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}

class JournalEntriesTab extends StatelessWidget {
  final List<JournalEntryModel> entries;
  const JournalEntriesTab({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Center(
        child: Text("No journal entries yet. Start writing!", style: TextStyle(color: Colors.white70)),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: glass_kit.GlassContainer.clearGlass(
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.title,
                                    style: Theme.of(context)
                                        .textTheme.titleMedium
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${entry.createdAt.day}/${entry.createdAt.month}/${entry.createdAt.year}',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue.withAlpha((0.3 * 255).toInt()),
                              ),
                              child: Text(
                                entry.mood, // Emoji
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Content Preview
                        Text(
                          entry.content,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.white70),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 12),

                        // Footer
                        Row(
                          children: [
                            Icon(
                              entry.isPrivate ? Icons.lock : Icons.public,
                              color: Colors.white70,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              entry.isPrivate ? 'Private' : 'Public',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.white70),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.white54, size: 20),
                              onPressed: () {
                                Provider.of<JournalProvider>(context, listen: false).deleteEntry(entry.id!);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class WriteJournalTab extends StatefulWidget {
  final VoidCallback onSave;
  const WriteJournalTab({super.key, required this.onSave});

  @override
  State<WriteJournalTab> createState() => _WriteJournalTabState();
}

class _WriteJournalTabState extends State<WriteJournalTab> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedMood = '😊';
  bool _isPrivate = true;

  final List<String> _moods = [
    '😊',
    '😌',
    '😔',
    '🤔',
    '😴',
    '😤',
    '🎉',
    '😇',
    '🤗',
    '😎',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Title Input
          glass_kit.GlassContainer.clearGlass(
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Entry Title',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Mood Selector
          glass_kit.GlassContainer.clearGlass(
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How are you feeling?',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _moods.length,
                      itemBuilder: (context, index) {
                        final mood = _moods[index];
                        final isSelected = mood == _selectedMood;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedMood = mood),
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? Colors.white.withAlpha((0.3 * 255).toInt())
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white30,
                              ),
                            ),
                            child: Text(
                              mood,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Content Input
          glass_kit.GlassContainer.clearGlass(
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _contentController,
                style: const TextStyle(color: Colors.white),
                maxLines: 10,
                decoration: const InputDecoration(
                  hintText: 'Write your thoughts...',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Privacy Toggle
          glass_kit.GlassContainer.clearGlass(
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    _isPrivate ? Icons.lock : Icons.public,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isPrivate ? 'Private Entry' : 'Public Entry',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                    ),
                  ),
                  Switch(
                    value: _isPrivate,
                    onChanged: (value) => setState(() => _isPrivate = value),
                    thumbColor: WidgetStateProperty.all(Colors.white),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Save Button
          InkWell(
            onTap: _saveEntry,
            child: glass_kit.GlassContainer.clearGlass(
              width: double.infinity,
              height: 50,
              borderRadius: BorderRadius.circular(16),
              child: const Center(
                child: Text(
                  'Save Entry',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveEntry() {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in title and content')),
      );
      return;
    }

    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      final entry = JournalEntryModel(
        userId: user.id!,
        title: _titleController.text,
        content: _contentController.text,
        mood: _selectedMood,
        isPrivate: _isPrivate,
      );
      
      Provider.of<JournalProvider>(context, listen: false).addEntry(entry);
      
      _titleController.clear();
      _contentController.clear();
      widget.onSave();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Journal entry saved!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
