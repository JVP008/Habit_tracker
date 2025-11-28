import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class ZenRadioScreen extends StatefulWidget {
  const ZenRadioScreen({super.key});

  @override
  State<ZenRadioScreen> createState() => _ZenRadioScreenState();
}

class _ZenRadioScreenState extends State<ZenRadioScreen>
    with TickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  late AnimationController _rotationController;
  late AnimationController _vibrationController;
  bool _isFileLoaded = false;
  String _trackName = "No Vinyl Loaded";
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  // Tonearm animation
  // 0.0 = Rest position (off record)
  // 0.15 = Playing position (on record)
  double _tonearmAngle = 0.0;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // Rotates the vinyl
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // Drives the physics simulation loop
    _vibrationController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 1,
      ), // Loop duration doesn't matter much for continuous physics
    );

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlaying = state == PlayerState.playing;
        if (_isPlaying) {
          _rotationController.repeat();
          _vibrationController.repeat();
          _tonearmAngle = 0.15; // Move arm to record
        } else {
          _rotationController.stop();
          _vibrationController.stop();
          _tonearmAngle = 0.0; // Move arm to rest
        }
      });
    });

    _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });

    _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _rotationController.stop();
          _vibrationController.stop();
          _tonearmAngle = 0.0;
          _position = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _rotationController.dispose();
    _vibrationController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        withData: kIsWeb,
      );

      if (result != null) {
        setState(() {
          _trackName = result.files.single.name;
          _isPlaying = false;
          _rotationController.stop();
          _vibrationController.stop();
          _tonearmAngle = 0.0;
        });

        if (kIsWeb) {
          final bytes = result.files.single.bytes;
          if (bytes != null) {
            await _audioPlayer.setSource(BytesSource(bytes));
            _isFileLoaded = true;
          }
        } else {
          final path = result.files.single.path;
          if (path != null) {
            await _audioPlayer.setSource(DeviceFileSource(path));
            _isFileLoaded = true;
          }
        }
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading file: $e')));
      }
    }
  }

  Future<void> _togglePlay() async {
    if (!_isFileLoaded) {
      _pickFile();
      return;
    }

    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF2C2C2C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'zen radio',
          style: TextStyle(
            color: Color(0xFF2C2C2C),
            fontWeight: FontWeight.w300,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // The Record Player Area
          Expanded(child: Center(child: _buildTurntable())),

          // Controls & Info
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildTurntable() {
    return Container(
      width: 340,
      height: 340,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The Record
          Positioned(
            left: 20,
            top: 20,
            bottom: 20,
            right: 20,
            child: AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationController.value * 2 * math.pi,
                  child: child,
                );
              },
              child: _buildVinylRecord(),
            ),
          ),

          // The Tonearm Pivot Base (Top Right)
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE0E0E0),
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),

          // The Tonearm
          Positioned(
            top: 50, // Pivot center Y
            right: 50, // Pivot center X
            child: AnimatedBuilder(
              animation: _vibrationController,
              builder: (context, child) {
                double vibration = 0.0;
                if (_isPlaying) {
                  // SIMULATED AUDIO PHYSICS
                  // We use the current time to generate a complex waveform that mimics music.
                  // Real vinyl grooves cause the needle to move based on amplitude.

                  final now = DateTime.now().millisecondsSinceEpoch / 1000.0;

                  // 1. Base Beat (Kick drum simulation) - ~120 BPM (2Hz)
                  final beat = math.sin(now * 2 * math.pi * 2);

                  // 2. Rhythm/Groove (Hi-hats/Mids) - Faster oscillation
                  final groove = math.sin(now * 2 * math.pi * 4) * 0.5;

                  // 3. Random "Noise" (Texture/Surface noise)
                  final noise = (math.Random().nextDouble() - 0.5) * 0.2;

                  // 4. "Swell" Envelope (Simulates phrasing/dynamics over 5 seconds)
                  final swell = (math.sin(now * 0.2) + 1) / 2; // 0.0 to 1.0

                  // Combine them:
                  // The 'beat' provides the main pulse.
                  // The 'groove' adds complexity.
                  // The 'swell' makes it loud and soft over time.
                  // 'noise' adds grit.

                  final energy = (beat + groove + noise) * swell;

                  // Scale it down to a realistic physical movement range (radians)
                  // 0.015 radians is visible but subtle enough to be realistic
                  vibration = energy * 0.015;
                }

                return Transform.rotate(
                  angle: _tonearmAngle + vibration,
                  alignment: Alignment.topCenter,
                  child: Transform.translate(
                    offset: const Offset(-15, 0), // Adjust to center pivot
                    child: _buildTonearm(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVinylRecord() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1A1A1A),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Grooves (Subtler)
          for (int i = 1; i <= 6; i++)
            Container(
              margin: EdgeInsets.all(i * 20.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.03),
                  width: 1,
                ),
              ),
            ),
          // Label
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFF5252),
              border: Border.all(color: Colors.white, width: 3),
            ),
            alignment: Alignment.center,
            child: const Text(
              'ZEN',
              style: TextStyle(
                fontFamily: 'Courier',
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
          // Spindle Hole
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF0F0F0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTonearm() {
    return SizedBox(
      width: 30,
      height: 220,
      child: CustomPaint(painter: TonearmPainter()),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _trackName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C2C2C),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            _isPlaying ? 'spinning...' : 'paused',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6A6A6A),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                iconSize: 40,
                icon: const Icon(Icons.skip_previous_outlined),
                color: const Color(0xFF2C2C2C),
                onPressed: () {},
              ),
              const SizedBox(width: 24),
              GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF2C2C2C),
                      width: 2,
                    ),
                    color: _isPlaying
                        ? const Color(0xFF2C2C2C)
                        : Colors.transparent,
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 32,
                    color: _isPlaying ? Colors.white : const Color(0xFF2C2C2C),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              IconButton(
                iconSize: 40,
                icon: const Icon(Icons.folder_open_outlined),
                color: const Color(0xFF2C2C2C),
                onPressed: _pickFile,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_duration.inSeconds > 0)
            Slider(
              value: _position.inSeconds.toDouble().clamp(
                0,
                _duration.inSeconds.toDouble(),
              ),
              max: _duration.inSeconds.toDouble(),
              activeColor: const Color(0xFF2C2C2C),
              inactiveColor: const Color(0xFFE0E0E0),
              onChanged: (value) {
                _audioPlayer.seek(Duration(seconds: value.toInt()));
              },
            ),
        ],
      ),
    );
  }
}

class TonearmPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2C2C2C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Pivot is at top center (size.width / 2, 0)
    final pivotX = size.width / 2;

    // Draw Pivot
    canvas.drawCircle(Offset(pivotX, 0), 12, paint..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(pivotX, 0), 4, Paint()..color = Colors.white);

    // Reset paint for arm
    paint
      ..color = const Color(0xFF2C2C2C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Arm Path
    path.moveTo(pivotX, 0);
    // Slight curve or angle
    path.lineTo(pivotX, size.height - 40); // Main shaft
    path.lineTo(pivotX - 15, size.height - 10); // Head angle

    canvas.drawPath(path, paint);

    // Cartridge Head
    final headRect = Rect.fromCenter(
      center: Offset(pivotX - 15, size.height - 10),
      width: 20,
      height: 30,
    );
    canvas.drawRect(headRect, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
