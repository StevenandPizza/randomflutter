import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RandomFlutterApp());
}

class RandomFlutterApp extends StatelessWidget {
  const RandomFlutterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RandomSteven',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      home: const SplashScreen(),
    );
  }
}

// ============================================================
// SPLASH SCREEN
// ============================================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double progress = 0;
  String status = 'Initializing application...';

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  void _startLoading() {
    Future.delayed(const Duration(milliseconds: 800), () {
      const messages = [
        'Optimizing performance...',
        'Synchronizing data...',
        'Ready to launch!',
      ];
      for (int i = 0; i < 100; i++) {
        Future.delayed(Duration(milliseconds: i * 40), () {
          if (mounted) {
            setState(() {
              progress = (i + 1) / 100;
              if (i == 30) status = messages[0];
              if (i == 62) status = messages[1];
              if (i == 87) status = messages[2];
            });
          }
          if (i == 99) {
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const MainScreen()),
                );
              }
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icon.png', width: 140, height: 140),
            const SizedBox(height: 40),
            SizedBox(
              width: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey[200],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(status, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// WHEEL PAINTER
// ============================================================
class WheelPainter extends CustomPainter {
  final List<String> items;
  final double spinAngle;

  WheelPainter({required this.items, required this.spinAngle});

  static const colors = [
    Color(0xFFE64C4C),
    Color(0xFF3399CC),
    Color(0xFFE6B800),
    Color(0xFF33AA55),
    Color(0xFF9955BB),
    Color(0xFFE67A33),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (items.isEmpty) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final n = items.length;
    final sweep = 2 * pi / n;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(spinAngle);

    for (int i = 0; i < n; i++) {
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;
      final startAngle = i * sweep - pi / 2;
      canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: radius), startAngle, sweep, true, paint);

      final textAngle = startAngle + sweep / 2;
      final textRadius = radius * 0.6;
      canvas.save();
      canvas.rotate(textAngle);
      canvas.translate(textRadius, 0);
      canvas.rotate(pi / 2);

      final textPainter = TextPainter(
        text: TextSpan(
          text: items[i].length > 8 ? '${items[i].substring(0, 7)}..' : items[i],
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: radius * 0.5);
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }

    canvas.restore();

    final dotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset.zero, 12, dotPaint);
    dotPaint.color = Colors.grey[800]!;
    canvas.drawCircle(Offset.zero, 8, dotPaint);
  }

  @override
  bool shouldRepaint(WheelPainter old) => old.spinAngle != spinAngle || old.items != items;
}

// ============================================================
// MAIN SCREEN WITH TAB NAVIGATION
// ============================================================
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _currentTab = 0;
  final _audioPlayer = AudioPlayer();
  final _random = Random();
  bool _soundsReady = false;

  // Numbers state
  List<int> availableNumbers = [];
  List<int> drawnNumbers = [];
  final TextEditingController maxInputCtrl = TextEditingController();

  // Names state
  List<String> availableNames = [];
  final TextEditingController namesInputCtrl = TextEditingController();

  // Wheel state
  List<String> wheelItems = [];
  final TextEditingController wheelInputCtrl = TextEditingController();
  double spinAngle = 0;
  bool isSpinning = false;
  String wheelResult = 'TAP SPIN';

  // Teams state
  final TextEditingController teamNamesCtrl = TextEditingController();
  final TextEditingController teamCountCtrl = TextEditingController();
  String teamResult = 'Results will appear here...';

  // Animation
  bool isAnimating = false;
  String animatingNumber = '?';
  String animatingName = 'Who is next?';
  int _animatingCount = 0;

  final List<Color> tabColors = [
    Colors.blue,
    const Color(0xFF7B2D8E),
    Colors.green,
    Colors.deepOrange,
  ];

  @override
  void initState() {
    super.initState();
    _initSounds();
  }

  Future<void> _initSounds() async {
    try {
      await _audioPlayer.setSource(AssetSource('click.ogg'));
      await _audioPlayer.setSource(AssetSource('spin.ogg'));
      await _audioPlayer.setSource(AssetSource('win.ogg'));
      _soundsReady = true;
    } catch (_) {}
  }

  Future<void> _playSound(String name) async {
    if (!_soundsReady) return;
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(name));
    } catch (_) {}
  }

  @override
  void dispose() {
    maxInputCtrl.dispose();
    namesInputCtrl.dispose();
    wheelInputCtrl.dispose();
    teamNamesCtrl.dispose();
    teamCountCtrl.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _setupNumbers() {
    final val = maxInputCtrl.text;
    if (val.isNotEmpty && int.tryParse(val) != null && int.parse(val) > 0) {
      _playSound('click.ogg');
      setState(() {
        availableNumbers = List.generate(int.parse(val), (i) => i + 1);
        drawnNumbers = [];
        animatingNumber = '?';
      });
    }
  }

  void _drawNumber() {
    if (availableNumbers.isEmpty || isAnimating) return;
    _playSound('click.ogg');
    final chosen = availableNumbers[_random.nextInt(availableNumbers.length)];
    _startAnimation('number', chosen);
  }

  void _setupNames() {
    final raw = namesInputCtrl.text;
    final names = raw.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (names.isNotEmpty) {
      _playSound('click.ogg');
      setState(() => availableNames = names);
    }
  }

  void _drawName() {
    if (availableNames.isEmpty || isAnimating) return;
    _playSound('click.ogg');
    final chosen = availableNames[_random.nextInt(availableNames.length)];
    _startAnimation('name', chosen);
  }

  void _startAnimation(String type, dynamic chosen) {
    setState(() => isAnimating = true);
    _animatingCount = 0;

    Timer.periodic(const Duration(milliseconds: 50), (t) {
      _animatingCount++;
      if (_animatingCount % 2 == 0) _playSound('spin.ogg');

      setState(() {
        if (type == 'number') {
          animatingNumber = availableNumbers[_random.nextInt(availableNumbers.length)].toString();
        } else {
          animatingName = availableNames[_random.nextInt(availableNames.length)];
        }
      });

      if (_animatingCount >= 20) {
        t.cancel();
        if (type == 'number') {
          setState(() {
            availableNumbers.remove(chosen);
            drawnNumbers.add(chosen as int);
            animatingNumber = chosen.toString();
            isAnimating = false;
          });
        } else {
          setState(() {
            availableNames.remove(chosen);
            animatingName = chosen as String;
            isAnimating = false;
          });
        }
        Future.delayed(const Duration(milliseconds: 100), () => _playSound('win.ogg'));
      }
    });
  }

  void _spinWheel() {
    if (isSpinning) return;
    final raw = wheelInputCtrl.text;
    final items = raw.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (items.length < 2) {
      setState(() => wheelResult = 'Min 2 items!');
      return;
    }
    _playSound('click.ogg');
    setState(() {
      wheelItems = items;
      isSpinning = true;
      wheelResult = 'SPINNING...';
    });

    final winnerIdx = _random.nextInt(items.length);
    final n = items.length;
    final anglePerItem = 2 * pi / n;
    final winnerAngle = winnerIdx * anglePerItem;
    final target = spinAngle + (2 * pi * _random.nextInt(4) + 4 * pi) + winnerAngle;

    Future.delayed(const Duration(milliseconds: 150), () => _playSound('spin.ogg'));

    final duration = const Duration(milliseconds: 4000);
    final start = DateTime.now();
    final startAngle = spinAngle;

    Timer.periodic(const Duration(milliseconds: 16), (t) {
      final elapsed = DateTime.now().difference(start).inMilliseconds / duration.inMilliseconds;
      if (elapsed >= 1) {
        t.cancel();
        setState(() {
          spinAngle = target % (2 * pi);
          isSpinning = false;
          wheelResult = items[winnerIdx];
        });
        Future.delayed(const Duration(milliseconds: 100), () => _playSound('win.ogg'));
      } else {
        final eased = 1 - pow(1 - elapsed, 3).toDouble();
        setState(() => spinAngle = startAngle + (target - startAngle) * eased);
      }
    });
  }

  void _splitTeams() {
    _playSound('click.ogg');
    final raw = teamNamesCtrl.text;
    final names = raw.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final countStr = teamCountCtrl.text;
    if (names.isEmpty || int.tryParse(countStr) == null) return;
    final count = int.parse(countStr);
    names.shuffle();
    final teams = List.generate(count, (_) => <String>[]);
    for (int i = 0; i < names.length; i++) {
      teams[i % count].add(names[i]);
    }
    final buf = StringBuffer();
    for (int i = 0; i < count; i++) {
      buf.writeln('Team ${i + 1}:');
      for (final name in teams[i]) {
        buf.writeln('  • $name');
      }
      buf.writeln();
    }
    setState(() => teamResult = buf.toString().trim());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: IndexedStack(
        index: _currentTab,
        children: [
          _buildNumbersTab(theme),
          _buildNamesTab(theme),
          _buildWheelTab(theme),
          _buildTeamsTab(theme),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFE0E3E8), width: 1)),
          color: Colors.white,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentTab,
          onTap: (i) => setState(() => _currentTab = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: tabColors[_currentTab],
          unselectedItemColor: Colors.grey[400],
          selectedFontSize: 11,
          unselectedFontSize: 11,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.numbers), label: 'Numbers'),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Names'),
            BottomNavigationBarItem(icon: Icon(Icons.sync), label: 'Wheel'),
            BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Teams'),
          ],
        ),
      ),
    );
  }

  Widget _buildNumbersTab(ThemeData theme) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Column(
          children: [
            Text('LUCKY NUMBERS', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: maxInputCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter max number',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.blue.withValues(alpha: 0.3))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.blue.withValues(alpha: 0.3))),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _setupNumbers,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: const Text('SET'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(animatingNumber, style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: Colors.blue)),
                    const SizedBox(height: 16),
                    Text(
                      availableNumbers.isEmpty ? 'Tap SET to start' : 'Remaining: ${availableNumbers.length}',
                      style: const TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: availableNumbers.isNotEmpty && !isAnimating ? _drawNumber : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                ),
                child: const Text('DRAW NOW', style: TextStyle(fontSize: 17)),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                padding: const EdgeInsets.all(10),
                child: SingleChildScrollView(
                  child: Text(
                    drawnNumbers.isEmpty ? 'History appears here...' : drawnNumbers.reversed.join(', '),
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNamesTab(ThemeData theme) {
    final purple = const Color(0xFF7B2D8E);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Text('RANDOM PICKER', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: purple)),
            const SizedBox(height: 16),
            Expanded(
              flex: 3,
              child: TextField(
                controller: namesInputCtrl,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: 'Enter names\n(One per line)',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: purple.withValues(alpha: 0.3))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: purple.withValues(alpha: 0.3))),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _setupNames,
                style: ElevatedButton.styleFrom(
                  backgroundColor: purple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: const Text('LOAD LIST'),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              flex: 2,
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(animatingName, style: theme.textTheme.headlineMedium?.copyWith(color: purple, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text(
                      availableNames.isEmpty ? 'Waiting for names...' : 'Remaining: ${availableNames.length}',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: availableNames.isNotEmpty && !isAnimating ? _drawName : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: purple,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                ),
                child: const Text('PICK SOMEONE', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWheelTab(ThemeData theme) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
        child: Column(
          children: [
            Text('SPIN THE WHEEL', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 8),
            Expanded(
              flex: 3,
              child: TextField(
                controller: wheelInputCtrl,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: 'Enter items (one per line)',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.green.withValues(alpha: 0.3))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.green.withValues(alpha: 0.3))),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              flex: 3,
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final s = min(constraints.maxWidth * 0.7, constraints.maxHeight * 0.85);
                    final size = min(s, 200.0);
                    return Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: CustomPaint(
                            size: Size(size, size),
                            painter: WheelPainter(items: wheelItems, spinAngle: spinAngle),
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, size: 36, color: Colors.black87),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(wheelResult, style: theme.textTheme.titleLarge?.copyWith(color: Colors.green, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isSpinning ? null : _spinWheel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                ),
                child: Text(isSpinning ? 'SPINNING...' : 'SPIN NOW!', style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamsTab(ThemeData theme) {
    final orange = Colors.deepOrange;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Text('TEAM SPLITTER', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: orange)),
            const SizedBox(height: 16),
            Expanded(
              flex: 3,
              child: TextField(
                controller: teamNamesCtrl,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: 'Enter player names\n(One per line)',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: orange.withValues(alpha: 0.3))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: orange.withValues(alpha: 0.3))),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: teamCountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Number of teams',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: orange.withValues(alpha: 0.3))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: orange.withValues(alpha: 0.3))),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _splitTeams,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: const Text('SPLIT'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              flex: 4,
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SingleChildScrollView(
                    child: Text(teamResult, style: theme.textTheme.bodyMedium),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
