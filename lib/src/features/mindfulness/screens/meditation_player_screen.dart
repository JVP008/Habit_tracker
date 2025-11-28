import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart' as rx;

import '../models/meditation_model.dart';

class MeditationPlayerScreen extends StatefulWidget {
  final Meditation meditation;

  const MeditationPlayerScreen({super.key, required this.meditation});

  @override
  State<MeditationPlayerScreen> createState() => _MeditationPlayerScreenState();
}

class _MeditationPlayerScreenState extends State<MeditationPlayerScreen>
    with SingleTickerProviderStateMixin { // Add mixin
  final AudioPlayer _audioPlayer = AudioPlayer();
  late Stream<Duration> _positionStream;
  late Stream<Duration> _bufferedPositionStream;
  late Stream<Duration?> _durationStream;
  late Stream<bool> _playerStateStream;
  bool _isPlaying = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
    _setupAudioStreams();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  Future<void> _initAudioPlayer() async {
    try {
      // For a real app, you would use the actual audio file from the meditation
      // For now, we'll simulate loading with a delay
      await Future.delayed(const Duration(seconds: 1));

      // In a real app, you would load the actual audio file:
      // await _audioPlayer.setAsset(widget.meditation.audioAsset);

      // Start playing automatically
      _togglePlayPause();
    } catch (e) {
      debugPrint('Failed to load audio: $e');
    }
  }

  void _setupAudioStreams() {
    _positionStream = _audioPlayer.positionStream;
    _bufferedPositionStream = _audioPlayer.bufferedPositionStream;
    _durationStream = _audioPlayer.durationStream;
    _playerStateStream = _audioPlayer.playerStateStream.map(
      (state) => state.playing,
    );

    // Listen for player state changes
    _playerStateStream.listen((isPlaying) {
      if (mounted) {
        setState(() {
          _isPlaying = isPlaying;
          if (isPlaying) {
            _animationController.repeat();
          } else {
            _animationController.stop();
          }
        });
      }
    });
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  Future<void> _seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'NOW PLAYING',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Album art/placeholder
                    _buildAlbumArt(context),

                    const SizedBox(height: 32),

                    // Meditation title and instructor
                    Text(
                      widget.meditation.title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'with ${widget.meditation.instructor}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                    ),

                    const SizedBox(height: 48),

                    // Progress bar
                    _buildProgressBar(),

                    const SizedBox(height: 48),

                    // Playback controls
                    _buildPlaybackControls(),

                    const Spacer(),

                    // Additional actions
                    _buildAdditionalActions(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumArt(BuildContext context) {
    return RotationTransition(
      turns: _animationController,
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.primary.withAlpha(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          image: const DecorationImage(
            image: AssetImage('assets/images/disk.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return StreamBuilder<_ProgressBarState>(
      stream:
          rx.CombineLatestStream.combine3<
            Duration,
            Duration,
            Duration?,
            _ProgressBarState
          >(
            _positionStream,
            _bufferedPositionStream,
            _durationStream,
            (position, bufferedPosition, duration) => _ProgressBarState(
              position: position,
              bufferedPosition: bufferedPosition,
              total: duration ?? Duration.zero,
            ),
          ),
      builder: (context, snapshot) {
        final state =
            snapshot.data ??
            _ProgressBarState(
              position: Duration.zero,
              bufferedPosition: Duration.zero,
              total: const Duration(minutes: 10),
            ); // Replaced widget.meditation.duration
        return Column(
          children: [
            // Progress bar
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Theme.of(context).colorScheme.primary,
                inactiveTrackColor: Colors.grey[300],
                thumbColor: Theme.of(context).colorScheme.primary,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              ),
              child: Slider(
                value: state.position.inMilliseconds.toDouble().clamp(
                  0.0,
                  state.total.inMilliseconds.toDouble(),
                ),
                min: 0,
                max: state.total.inMilliseconds.toDouble(),
                onChanged: (value) {
                  _seekTo(Duration(milliseconds: value.toInt()));
                },
              ),
            ),

            // Time indicators
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(state.position),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '-${_formatDuration(state.total - state.position)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlaybackControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous button
        IconButton(
          icon: const Icon(Icons.skip_previous),
          iconSize: 28,
          onPressed: () {
            // Skip back 15 seconds
            _audioPlayer.seek(
              _audioPlayer.position - const Duration(seconds: 15),
            );
          },
        ),

        const SizedBox(width: 24),

        // Play/Pause button
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withAlpha(76),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            iconSize: 32,
            onPressed: _togglePlayPause,
          ),
        ),

        const SizedBox(width: 24),

        // Next button
        IconButton(
          icon: const Icon(Icons.skip_next),
          iconSize: 28,
          onPressed: () {
            // Skip forward 15 seconds
            _audioPlayer.seek(
              _audioPlayer.position + const Duration(seconds: 15),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAdditionalActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Timer button
        IconButton(
          icon: const Icon(Icons.timer),
          onPressed: () {
            // Show timer picker
            _showTimerPicker(context);
          },
        ),

        // Favorite button
        IconButton(
          icon: const Icon(Icons.favorite_border),
          onPressed: () {
            // Toggle favorite
          },
        ),

        // Share button
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            // Share meditation
          },
        ),
      ],
    );
  }

  Future<void> _showTimerPicker(BuildContext context) async {
    final durations = [5, 10, 15, 20, 30, 45, 60];

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sleep Timer',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Stop playback after',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: durations.map((minutes) {
                return ActionChip(
                  label: Text('$minutes min'),
                  onPressed: () {
                    // Set timer
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Timer set for $minutes minutes'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
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
}

class _ProgressBarState {
  final Duration position;
  final Duration bufferedPosition;
  final Duration total;

  _ProgressBarState({
    required this.position,
    required this.bufferedPosition,
    required this.total,
  });

  _ProgressBarState toState() => this;
}
