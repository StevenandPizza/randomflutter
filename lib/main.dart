import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:async';
import 'dart:ui' show ImageFilter;
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RandomFlutterApp());
}

class _ThemeState extends InheritedWidget {
  final ThemeMode themeMode;
  final Color seedColor;
  final VoidCallback toggleTheme;
  final ValueChanged<Color> setSeedColor;

  const _ThemeState({
    required this.themeMode,
    required this.seedColor,
    required this.toggleTheme,
    required this.setSeedColor,
    required super.child,
  });

  static _ThemeState? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_ThemeState>();
  }

  @override
  bool updateShouldNotify(_ThemeState old) =>
    old.themeMode != themeMode || old.seedColor != seedColor;
}

class RandomFlutterApp extends StatefulWidget {
  const RandomFlutterApp({super.key});

  @override
  State<RandomFlutterApp> createState() => _RandomFlutterAppState();
}

class _RandomFlutterAppState extends State<RandomFlutterApp> {
  ThemeMode _themeMode = ThemeMode.light;
  Color _seedColor = Colors.blue;

  void _toggleTheme() => setState(() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  });

  void _setSeedColor(Color c) => setState(() => _seedColor = c);

  @override
  Widget build(BuildContext context) {
    return _ThemeState(
      themeMode: _themeMode,
      seedColor: _seedColor,
      toggleTheme: _toggleTheme,
      setSeedColor: _setSeedColor,
      child: MaterialApp(
        title: 'Random Anything',
        debugShowCheckedModeBanner: false,
        themeMode: _themeMode,
        theme: ThemeData(
          colorSchemeSeed: _seedColor,
          useMaterial3: true,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          colorSchemeSeed: _seedColor,
          useMaterial3: true,
          brightness: Brightness.dark,
        ),
        home: const SplashScreen(),
      ),
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
      backgroundColor: theme.scaffoldBackgroundColor,
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
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(status, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
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
    Color(0xFFFF6B6B),
    Color(0xFF4ECDC4),
    Color(0xFFFFE66D),
    Color(0xFF95E1D3),
    Color(0xFFDDA0DD),
    Color(0xFFF7A072),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (items.isEmpty) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final n = items.length;
    final sweep = 2 * pi / n;

    // Outer border
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius - 1, borderPaint);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(spinAngle);

    for (int i = 0; i < n; i++) {
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;
      final startAngle = i * sweep - pi / 2;
      canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: radius - 2), startAngle, sweep, true, paint);

      // Segment separator line
      final linePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..strokeWidth = 1.5;
      final angle = startAngle;
      canvas.drawLine(Offset.zero, Offset(cos(angle) * (radius - 2), sin(angle) * (radius - 2)), linePaint);

      // Text
      final textAngle = startAngle + sweep / 2;
      final textRadius = radius * 0.58;
      canvas.save();
      canvas.rotate(textAngle);
      canvas.translate(textRadius, 0);
      canvas.rotate(pi / 2);

      final text = items[i].length > 8 ? '${items[i].substring(0, 7)}..' : items[i];
      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 2)],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: radius * 0.45);
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }

    canvas.restore();

    // Outer ring accent
    final ringPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius - 2, ringPaint);

    // Center dot - outer white ring
    final outerDot = Paint()..color = Colors.white;
    canvas.drawCircle(center, 14, outerDot);

    // Center dot - inner gradient-like (dark)
    final innerDot = Paint()
      ..shader = RadialGradient(
        colors: [Colors.grey[300]!, Colors.grey[800]!],
      ).createShader(Rect.fromCircle(center: center, radius: 10));
    canvas.drawCircle(center, 10, innerDot);

    // Center highlight
    final highlight = Paint()..color = Colors.white.withValues(alpha: 0.4);
    canvas.drawCircle(Offset(center.dx - 2, center.dy - 3), 3, highlight);
  }

  @override
  bool shouldRepaint(WheelPainter old) => old.spinAngle != spinAngle || old.items != items;
}

// ============================================================
// GLASS CARD WIDGET
// ============================================================
class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double blur;
  final double? height;
  final double? width;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(16),
    this.blur = 12,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          height: height,
          width: width,
          padding: padding,
          decoration: BoxDecoration(
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
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
  bool _soundEnabled = true;

  // Numbers state
  List<int> availableNumbers = [];
  List<int> drawnNumbers = [];
  final TextEditingController maxInputCtrl = TextEditingController(text: '');

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

  late final AnimationController _springCtrl;

  @override
  void initState() {
    super.initState();
    _initSounds();
    _springCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _springCtrl.forward();
  }

  void _springTap() {
    _springCtrl.reset();
    _springCtrl.forward();
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
    if (!_soundsReady || !_soundEnabled) return;
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(name));
    } catch (_) {}
  }

  void _haptic() => HapticFeedback.lightImpact();

  @override
  void dispose() {
    maxInputCtrl.dispose();
    namesInputCtrl.dispose();
    wheelInputCtrl.dispose();
    teamNamesCtrl.dispose();
    teamCountCtrl.dispose();
    _audioPlayer.dispose();
    _springCtrl.dispose();
    super.dispose();
  }

  void _setupNumbers() {
    final val = maxInputCtrl.text;
    if (val.isNotEmpty && int.tryParse(val) != null && int.parse(val) > 0) {
      _playSound('click.ogg');
      _haptic();
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
    _haptic();
    _springTap();
    final chosen = availableNumbers[_random.nextInt(availableNumbers.length)];
    _startAnimation('number', chosen);
  }

  void _setupNames() {
    final raw = namesInputCtrl.text;
    final names = raw.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (names.isNotEmpty) {
      _playSound('click.ogg');
      _haptic();
      setState(() => availableNames = names);
    }
  }

  void _drawName() {
    if (availableNames.isEmpty || isAnimating) return;
    _playSound('click.ogg');
    _haptic();
    _springTap();
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
        _haptic();
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
    _haptic();
    _springTap();
    setState(() {
      wheelItems = items;
      isSpinning = true;
      wheelResult = 'SPINNING...';
    });

    final winnerIdx = _random.nextInt(items.length);
    final n = items.length;
    final anglePerItem = 2 * pi / n;
    final winnerAngle = winnerIdx * anglePerItem + anglePerItem / 2;
    final target = (2 * pi * _random.nextInt(4) + 4 * pi) - winnerAngle;

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
        _haptic();
        Future.delayed(const Duration(milliseconds: 100), () => _playSound('win.ogg'));
      } else {
        final eased = 1 - pow(1 - elapsed, 3).toDouble();
        setState(() => spinAngle = startAngle + (target - startAngle) * eased);
      }
    });
  }

  void _splitTeams() {
    _playSound('click.ogg');
    _haptic();
    _springTap();
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

  // ----- Bottom Sheet Helpers -----
  void _showInputSheet({
    required String title,
    required String hintText,
    required TextEditingController controller,
    required VoidCallback onDone,
    bool multiLine = true,
    String buttonText = 'Done',
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: multiLine ? 8 : 1,
                autofocus: true,
                keyboardType: multiLine ? TextInputType.multiline : TextInputType.number,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: hintText,
                  filled: true,
                  fillColor: Theme.of(ctx).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    onDone();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text(buttonText, style: const TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _label(int i) {
    return switch (i) {
      0 => 'Numbers',
      1 => 'Names',
      2 => 'Wheel',
      3 => 'Teams',
      _ => 'Settings',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tabs = [
      _buildNumbersTab(theme),
      _buildNamesTab(theme),
      _buildWheelTab(theme),
      _buildTeamsTab(theme),
      _buildSettingsTab(theme),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.elasticOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: KeyedSubtree(key: ValueKey(_currentTab), child: tabs[_currentTab]),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: theme.dividerColor, width: 1)),
          color: theme.cardColor,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentTab,
          onTap: (i) => setState(() => _currentTab = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: theme.cardColor,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: theme.colorScheme.onSurfaceVariant,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          elevation: 0,
          items: List.generate(5, (i) => BottomNavigationBarItem(
            icon: Icon(tabIcons[i]),
            label: _label(i),
          )),
        ),
      ),
    );
  }

  final List<IconData> tabIcons = [
    Icons.numbers,
    Icons.people,
    Icons.sync,
    Icons.group,
    Icons.settings,
  ];

  // ----- NUMBERS TAB -----
  Widget _buildNumbersTab(ThemeData theme) {
    final primary = theme.colorScheme.primary;
    final grad = [primary.withValues(alpha: 0.15), theme.colorScheme.surface.withValues(alpha: 0)];
    return Container(
      key: const ValueKey('tab_numbers'),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: grad),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            children: [
              Text('LUCKY NUMBERS', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: primary)),
              const SizedBox(height: 12),
              GlassCard(
                blur: 16,
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                child: Column(
                  children: [
                    SizedBox(
                      height: 120,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Text(animatingNumber, style: TextStyle(fontSize: 120, fontWeight: FontWeight.bold, color: primary)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      availableNumbers.isEmpty ? 'Tap SET to start' : 'Remaining: ${availableNumbers.length}',
                      style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: availableNumbers.isNotEmpty && !isAnimating ? _drawNumber : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('DRAW NOW', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 10),
              GlassCard(
                blur: 12,
                borderRadius: 14,
                padding: const EdgeInsets.all(12),
                child: SingleChildScrollView(
                  child: Text(
                    drawnNumbers.isEmpty ? 'History appears here...' : drawnNumbers.reversed.join(', '),
                    style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => _showInputSheet(
                    title: 'Set Max Number',
                    hintText: 'Enter max number',
                    controller: maxInputCtrl,
                    onDone: _setupNumbers,
                    multiLine: false,
                    buttonText: 'SET',
                  ),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Enter Numbers', style: TextStyle(fontSize: 15)),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    side: BorderSide(color: primary.withValues(alpha: 0.4)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ----- NAMES TAB -----
  Widget _buildNamesTab(ThemeData theme) {
    final primary = theme.colorScheme.primary;
    final grad = [primary.withValues(alpha: 0.15), theme.colorScheme.surface.withValues(alpha: 0)];
    return Container(
      key: const ValueKey('tab_names'),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: grad),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Text('RANDOM PICKER', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: primary)),
              const SizedBox(height: 16),
              Expanded(
                flex: 3,
                child: GlassCard(
                  borderRadius: 16,
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: namesInputCtrl,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      hintText: 'Enter names\n(One per line)',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
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
                    backgroundColor: primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('LOAD LIST', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                flex: 2,
                child: GlassCard(
                  borderRadius: 16,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.contain,
                        child: Text(animatingName, style: theme.textTheme.headlineMedium?.copyWith(color: primary, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        availableNames.isEmpty ? 'Waiting for names...' : 'Remaining: ${availableNames.length}',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: availableNames.isNotEmpty && !isAnimating ? _drawName : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('PICK SOMEONE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----- WHEEL TAB -----
  Widget _buildWheelTab(ThemeData theme) {
    final primary = theme.colorScheme.primary;
    final grad = [primary.withValues(alpha: 0.15), theme.colorScheme.surface.withValues(alpha: 0)];
    return Container(
      key: const ValueKey('tab_wheel'),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: grad),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
          child: Column(
            children: [
              Text('SPIN THE WHEEL', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: primary)),
              const SizedBox(height: 6),
              Expanded(
                flex: 2,
                child: GlassCard(
                  borderRadius: 14,
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: wheelInputCtrl,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      hintText: 'Enter items (one per line)',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final size = min(constraints.maxWidth * 0.88, constraints.maxHeight * 0.88);
                      return Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          // The wheel
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: CustomPaint(
                              size: Size(size, size),
                              painter: WheelPainter(items: wheelItems, spinAngle: spinAngle),
                            ),
                          ),
                          // Pointer triangle at top
                          Positioned(
                            top: -2,
                            child: Icon(Icons.arrow_drop_down, size: 42, color: primary),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 4),
              GlassCard(
                borderRadius: 12,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  wheelResult,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(color: primary, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isSpinning ? null : _spinWheel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text(isSpinning ? 'SPINNING...' : 'SPIN NOW!', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----- TEAMS TAB -----
  Widget _buildTeamsTab(ThemeData theme) {
    final primary = theme.colorScheme.primary;
    final grad = [primary.withValues(alpha: 0.15), theme.colorScheme.surface.withValues(alpha: 0)];
    return Container(
      key: const ValueKey('tab_teams'),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: grad),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Text('TEAM SPLITTER', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: primary)),
              const SizedBox(height: 16),
              Expanded(
                flex: 3,
                child: GlassCard(
                  borderRadius: 16,
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: teamNamesCtrl,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      hintText: 'Enter player names\n(One per line)',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GlassCard(
                      borderRadius: 14,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: TextField(
                        controller: teamCountCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Number of teams',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _splitTeams,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: const Text('SPLIT', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                flex: 4,
                child: GlassCard(
                  borderRadius: 14,
                  padding: const EdgeInsets.all(12),
                  child: SingleChildScrollView(
                    child: Text(teamResult, style: theme.textTheme.bodyMedium),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----- SETTINGS TAB -----
  Widget _buildSettingsTab(ThemeData theme) {
    final themeState = _ThemeState.of(context);
    if (themeState == null) return const SizedBox();
    final isDark = themeState.themeMode == ThemeMode.dark;
    final seed = themeState.seedColor;
    final primary = theme.colorScheme.primary;
    final grad = [primary.withValues(alpha: 0.15), theme.colorScheme.surface.withValues(alpha: 0)];

    const colorOptions = [
      Colors.blue,
      Colors.purple,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
      Colors.cyan,
      Colors.amber,
    ];

    return Container(
      key: const ValueKey('tab_settings'),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: grad),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text('SETTINGS', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: primary)),
              const SizedBox(height: 20),
              // Games section
              Text('GAMES', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: primary)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GlassCard(
                      borderRadius: 16,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: InkWell(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _CoinFlipPage())),
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          children: [
                            Icon(Icons.monetization_on, size: 40, color: Colors.amber.shade600),
                            const SizedBox(height: 8),
                            Text('Coin Flip', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassCard(
                      borderRadius: 16,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: InkWell(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _DiceRollerPage())),
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          children: [
                            Icon(Icons.casino, size: 40, color: Colors.red.shade400),
                            const SizedBox(height: 8),
                            Text('Dice Roller', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              GlassCard(
                borderRadius: 16,
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Dark Mode'),
                      subtitle: const Text('Toggle dark theme'),
                      value: isDark,
                      onChanged: (_) => themeState.toggleTheme(),
                      secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: primary),
                    ),
                    Divider(height: 1, indent: 16, endIndent: 16, color: theme.dividerColor),
                    SwitchListTile(
                      title: const Text('Sound Effects'),
                      subtitle: const Text('Enable/disable sounds'),
                      value: _soundEnabled,
                      onChanged: (v) => setState(() => _soundEnabled = v),
                      secondary: Icon(_soundEnabled ? Icons.volume_up : Icons.volume_off, color: primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Theme Color', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: colorOptions.map((c) {
                  final selected = seed.toARGB32() == c.toARGB32();
                  return GestureDetector(
                    onTap: () => themeState.setSeedColor(c),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: selected ? Border.all(color: isDark ? Colors.white : theme.colorScheme.surface, width: 3) : null,
                        boxShadow: selected
                            ? [BoxShadow(color: c.withValues(alpha: 0.5), blurRadius: 12, spreadRadius: 2)]
                            : [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
                      ),
                      child: selected ? Icon(Icons.check, color: isDark ? Colors.white : Colors.white, size: 24) : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// COIN PAINTER — realistic gold coin
// ============================================================
class _CoinPainter extends CustomPainter {
  final double angle;
  final double spin;

  _CoinPainter({required this.angle, this.spin = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final faceScale = max(cos(angle).abs(), 0.035);
    final sideScale = sin(angle).abs();
    final isHeads = cos(angle) >= 0;
    final thickness = radius * 0.12;

    // Drop shadow
    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(center.dx + 2, center.dy + 3), radius, shadow);

    // Rotate the entire coin around its centre so it spins/tumbles in the air.
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(spin);
    canvas.translate(-center.dx, -center.dy);

    // Projected metal edge. This remains visible when the coin turns sideways.
    final edgeRect = Rect.fromCenter(
      center: center,
      width: 2 * radius * faceScale + thickness * sideScale,
      height: 2 * radius,
    );
    final edge = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: const [
          Color(0xFFF4D77B),
          Color(0xFF9C6A16),
          Color(0xFFD6A934),
          Color(0xFF70480B),
        ],
        stops: const [0.0, 0.35, 0.65, 1.0],
      ).createShader(edgeRect);
    canvas.drawOval(edgeRect, edge);

    // Keep the face artwork upright instead of mirroring the back face.
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(faceScale, 1);
    canvas.translate(-center.dx, -center.dy);

    final faceRadius = radius - thickness * 0.5;

    // Outer rim (raised edge)
    final rimOuter = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        colors: const [
          Color(0xFFBF8F3F),
          Color(0xFFE8C76A),
          Color(0xFFF2D785),
          Color(0xFFD4A84B),
          Color(0xFFBF8F3F),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: faceRadius));
    canvas.drawCircle(center, faceRadius, rimOuter);

    // Inner rim step
    final rimInner = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        colors: const [
          Color(0xFFA67B2E),
          Color(0xFFD4A84B),
          Color(0xFFE8C76A),
          Color(0xFFC49A3C),
          Color(0xFFA67B2E),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: faceRadius - 3));
    canvas.drawCircle(center, faceRadius - 3, rimInner);

    // Main face with gold gradient
    final face = Paint()
      ..shader = RadialGradient(
        focal: const Alignment(-0.15, -0.2),
        focalRadius: 0.3,
        colors: isHeads
            ? [const Color(0xFFFFE082), const Color(0xFFF2C94C), const Color(0xFFD4A017), const Color(0xFFB8860B)]
            : [const Color(0xFFF7DC6F), const Color(0xFFE8B830), const Color(0xFFC4941A), const Color(0xFFA0760A)],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: faceRadius - 5));
    canvas.drawCircle(center, faceRadius - 5, face);

    // Edge dots (coin ridge texture)
    final dot = Paint()..color = const Color(0xFFA67B2E).withValues(alpha: 0.4);
    for (int i = 0; i < 36; i++) {
      final a = i * 2 * pi / 36;
      final dx = center.dx + (faceRadius - 7) * cos(a);
      final dy = center.dy + (faceRadius - 7) * sin(a);
      canvas.drawCircle(Offset(dx, dy), 0.8, dot);
    }

    // Inner fine ring
    final fineRing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = const Color(0xFFA67B2E).withValues(alpha: 0.5);
    canvas.drawCircle(center, faceRadius - 12, fineRing);

    // Center text — H or T
    final textPainter = TextPainter(
      text: TextSpan(
        text: isHeads ? 'H' : 'T',
        style: TextStyle(
          fontSize: radius * 0.75,
          color: const Color(0xFF6B4E1B),
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );

    // Top "RANDOM" arc text
    final topPainter = TextPainter(
      text: TextSpan(
        text: 'RANDOM',
        style: TextStyle(
          fontSize: radius * 0.12,
          color: const Color(0xFF8B6914),
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    topPainter.paint(
      canvas,
      Offset(center.dx - topPainter.width / 2, center.dy - radius * 0.6),
    );

    // Glossy sheen overlay
    final gloss = Paint()
      ..shader = RadialGradient(
        focal: const Alignment(-0.35, -0.35),
        focalRadius: 0.1,
        colors: [Colors.white.withValues(alpha: 0.35), Colors.white.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, gloss);

    canvas.restore(); // face scale
    canvas.restore(); // spin

  }

  @override
  bool shouldRepaint(_CoinPainter old) => old.angle != angle || old.spin != spin;
}

// ============================================================
// DICE CUBE PAINTER (projected six-face 3D cube)
// ============================================================
class _CubePoint {
  final double x;
  final double y;
  final double z;

  const _CubePoint(this.x, this.y, this.z);
}

class _CubeFace {
  final List<int> indices;
  final int number;
  final _CubePoint center;
  final _CubePoint horizontal;
  final _CubePoint vertical;
  final _CubePoint normal;

  const _CubeFace({
    required this.indices,
    required this.number,
    required this.center,
    required this.horizontal,
    required this.vertical,
    required this.normal,
  });
}

double _lerp(double start, double end, double t) => start + (end - start) * t;

class _DicePainter extends CustomPainter {
  final double rx;
  final double ry;
  final double rz;

  _DicePainter({required this.rx, required this.ry, required this.rz});

  static const _vertices = [
    _CubePoint(-1, -1, -1),
    _CubePoint(1, -1, -1),
    _CubePoint(1, 1, -1),
    _CubePoint(-1, 1, -1),
    _CubePoint(-1, -1, 1),
    _CubePoint(1, -1, 1),
    _CubePoint(1, 1, 1),
    _CubePoint(-1, 1, 1),
  ];

  // Opposite faces add up to seven, like a real die.
  static const _faces = [
    _CubeFace(
      indices: [4, 5, 6, 7],
      number: 1,
      center: _CubePoint(0, 0, 1),
      horizontal: _CubePoint(1, 0, 0),
      vertical: _CubePoint(0, 1, 0),
      normal: _CubePoint(0, 0, 1),
    ),
    _CubeFace(
      indices: [0, 3, 2, 1],
      number: 6,
      center: _CubePoint(0, 0, -1),
      horizontal: _CubePoint(-1, 0, 0),
      vertical: _CubePoint(0, 1, 0),
      normal: _CubePoint(0, 0, -1),
    ),
    _CubeFace(
      indices: [0, 4, 7, 3],
      number: 2,
      center: _CubePoint(-1, 0, 0),
      horizontal: _CubePoint(0, 0, 1),
      vertical: _CubePoint(0, 1, 0),
      normal: _CubePoint(-1, 0, 0),
    ),
    _CubeFace(
      indices: [1, 2, 6, 5],
      number: 5,
      center: _CubePoint(1, 0, 0),
      horizontal: _CubePoint(0, 0, -1),
      vertical: _CubePoint(0, 1, 0),
      normal: _CubePoint(1, 0, 0),
    ),
    _CubeFace(
      indices: [0, 1, 5, 4],
      number: 4,
      center: _CubePoint(0, -1, 0),
      horizontal: _CubePoint(1, 0, 0),
      vertical: _CubePoint(0, 0, 1),
      normal: _CubePoint(0, -1, 0),
    ),
    _CubeFace(
      indices: [3, 2, 6, 7],
      number: 3,
      center: _CubePoint(0, 1, 0),
      horizontal: _CubePoint(1, 0, 0),
      vertical: _CubePoint(0, 0, -1),
      normal: _CubePoint(0, 1, 0),
    ),
  ];

  static const _pipPositions = {
    1: [Offset(0, 0)],
    2: [Offset(-0.55, 0.55), Offset(0.55, -0.55)],
    3: [Offset(-0.55, 0.55), Offset(0, 0), Offset(0.55, -0.55)],
    4: [
      Offset(-0.55, 0.55), Offset(0.55, 0.55),
      Offset(-0.55, -0.55), Offset(0.55, -0.55),
    ],
    5: [
      Offset(-0.55, 0.55), Offset(0.55, 0.55), Offset(0, 0),
      Offset(-0.55, -0.55), Offset(0.55, -0.55),
    ],
    6: [
      Offset(-0.55, 0.62), Offset(0.55, 0.62),
      Offset(-0.55, 0), Offset(0.55, 0),
      Offset(-0.55, -0.62), Offset(0.55, -0.62),
    ],
  };

  _CubePoint _rotate(_CubePoint point) {
    final cosX = cos(rx);
    final sinX = sin(rx);
    final cosY = cos(ry);
    final sinY = sin(ry);
    final cosZ = cos(rz);
    final sinZ = sin(rz);

    final y1 = point.y * cosX - point.z * sinX;
    final z1 = point.y * sinX + point.z * cosX;
    final x2 = point.x * cosY + z1 * sinY;
    final z2 = -point.x * sinY + z1 * cosY;
    final x3 = x2 * cosZ - y1 * sinZ;
    final y3 = x2 * sinZ + y1 * cosZ;
    return _CubePoint(x3, y3, z2);
  }

  Offset _project(_CubePoint point, Offset center, double scale) {
    const focalLength = 4.6;
    final perspective = focalLength / (focalLength - point.z);
    return Offset(
      center.dx + point.x * scale * perspective,
      center.dy - point.y * scale * perspective,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = min(size.width, size.height) * 0.31;

    // Ground shadow gives the cube a stable position in space.
    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawOval(
      Rect.fromCenter(
        center: center + const Offset(0, 42),
        width: scale * 1.9,
        height: scale * 0.45,
      ),
      shadow,
    );

    final transformedVertices = _vertices.map(_rotate).toList();
    final orderedFaces = _faces.map((face) {
      final transformedCenter = _rotate(face.center);
      final transformedNormal = _rotate(face.normal);
      return (
        face: face,
        depth: transformedCenter.z,
        normal: transformedNormal,
      );
    }).toList()
      ..sort((a, b) => a.depth.compareTo(b.depth));

    for (final item in orderedFaces) {
      final face = item.face;
      final points = face.indices
          .map((index) => _project(transformedVertices[index], center, scale))
          .toList();
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final point in points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      path.close();

      final light = (0.70 + max(0.0, item.normal.z) * 0.30).clamp(0.0, 1.0).toDouble();
      final faceColor = Color.lerp(const Color(0xFFBFC6CE), Colors.white, light)!;
      canvas.drawPath(path, Paint()..color = faceColor);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = const Color(0xFF6B737C).withValues(alpha: 0.8),
      );

      // Hidden faces are covered by faces painted later in depth order.
      if (item.normal.z < -0.12) continue;

      final pipPoints = _pipPositions[face.number] ?? const <Offset>[];
      for (final pip in pipPoints) {
        final local = _CubePoint(
          face.center.x + face.horizontal.x * pip.dx + face.vertical.x * pip.dy,
          face.center.y + face.horizontal.y * pip.dx + face.vertical.y * pip.dy,
          face.center.z + face.horizontal.z * pip.dx + face.vertical.z * pip.dy,
        );
        final transformed = _rotate(local);
        final pipCenter = _project(transformed, center, scale);
        final perspective = 4.6 / (4.6 - transformed.z);
        final pipRadius = scale * 0.105 * perspective;

        canvas.drawCircle(
          pipCenter + const Offset(1.2, 1.5),
          pipRadius * 1.08,
          Paint()..color = Colors.black.withValues(alpha: 0.28),
        );
        canvas.drawCircle(
          pipCenter,
          pipRadius,
          Paint()
            ..shader = RadialGradient(
              focal: const Alignment(-0.25, -0.25),
              colors: const [Color(0xFF555B62), Color(0xFF121417)],
            ).createShader(Rect.fromCircle(center: pipCenter, radius: pipRadius)),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_DicePainter old) => old.rx != rx || old.ry != ry || old.rz != rz;
}

// ============================================================
// COIN FLIP PAGE
// ============================================================
class _CoinFlipPage extends StatefulWidget {
  const _CoinFlipPage();

  @override
  State<_CoinFlipPage> createState() => _CoinFlipPageState();
}

class _CoinFlipPageState extends State<_CoinFlipPage> with TickerProviderStateMixin {
  late AnimationController _ctrl;
  bool _isFlipping = false;
  bool _isHeads = true;
  int _spinTurns = 0;
  String _result = 'Tap to Flip';
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
  }

  void _flip() {
    if (_isFlipping) return;
    _isHeads = _random.nextBool();
    _spinTurns = 2 + _random.nextInt(4);
    setState(() { _isFlipping = true; _result = 'Flipping...'; });
    _ctrl.forward(from: 0).then((_) {
      setState(() {
        _isFlipping = false;
        _result = _isHeads ? 'HEADS' : 'TAILS';
      });
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Coin Flip'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             AnimatedBuilder(
                animation: _ctrl,
                builder: (context, _) {
                 final t = _ctrl.value;
                 // Four full half-turns plus the selected final face.
                final totalAngle = 4 * pi + (_isHeads ? 0 : pi);
                final angle = t * totalAngle;
                // Parabolic vertical arc: coin rises and falls.
                final tossY = -170 * 4 * t * (1 - t);
                // Wobble — slight X tilt that peaks mid‑flight
                final wobble = sin(t * pi) * 0.15;
                // Spin around Z so the coin tumbles horizontally in the air.
                final spin = t * _spinTurns * 2 * pi;
                return SizedBox(
                  width: 170,
                  height: 170,
                  child: Transform.translate(
                    offset: Offset(0, tossY),
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateX(wobble),
                      child: CustomPaint(
                        size: const Size(170, 170),
                        painter: _CoinPainter(angle: angle, spin: spin),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Text(_result, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: primary)),
            const SizedBox(height: 28),
            SizedBox(
              width: 180,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isFlipping ? null : _flip,
                icon: Icon(_isFlipping ? Icons.hourglass_top : Icons.monetization_on),
                label: Text(_isFlipping ? '...' : 'FLIP!', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// DICE ROLLER PAGE
// ============================================================
class _DiceRollerPage extends StatefulWidget {
  const _DiceRollerPage();

  @override
  State<_DiceRollerPage> createState() => _DiceRollerPageState();
}

class _DiceRollerPageState extends State<_DiceRollerPage> with TickerProviderStateMixin {
  int _result = 1;
  int _pendingResult = 1;
  bool _isRolling = false;
  final _random = Random();
  late AnimationController _rollCtrl;
  double _rx = 0;
  double _ry = 0;
  double _rz = 0;
  double _startRx = 0;
  double _startRy = 0;
  double _startRz = 0;
  double _targetRx = 0;
  double _targetRy = 0;
  double _targetRz = 0;

  static const _faceAngles = <int, List<double>>{
    1: [0, 0],
    6: [0, pi],
    2: [0, pi / 2],
    5: [0, -pi / 2],
    4: [-pi / 2, 0],
    3: [pi / 2, 0],
  };

  @override
  void initState() {
    super.initState();
    _rollCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1250));
  }

  void _roll() {
    if (_isRolling) return;
    _pendingResult = _random.nextInt(6) + 1;
    final base = _faceAngles[_pendingResult]!;
    final currentTurnsX = max(0, (_rx / (2 * pi)).floor());
    final currentTurnsY = max(0, (_ry / (2 * pi)).floor());
    final currentTurnsZ = max(0, (_rz / (2 * pi)).floor());
    _startRx = _rx;
    _startRy = _ry;
    _startRz = _rz;
    _targetRx = base[0] + (currentTurnsX + 3 + _random.nextInt(3)) * 2 * pi;
    _targetRy = base[1] + (currentTurnsY + 3 + _random.nextInt(3)) * 2 * pi;
    _targetRz = (currentTurnsZ + 2 + _random.nextInt(2)) * 2 * pi;
    setState(() => _isRolling = true);
    _rollCtrl.forward(from: 0).then((_) {
      if (!mounted) return;
      setState(() {
        _rx = _targetRx;
        _ry = _targetRy;
        _rz = _targetRz;
        _result = _pendingResult;
        _isRolling = false;
      });
    });
  }

  @override
  void dispose() {
    _rollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Dice Roller'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             AnimatedBuilder(
              animation: _rollCtrl,
              builder: (context, _) {
                final progress = Curves.easeOutCubic.transform(_rollCtrl.value);
                final rx = _lerp(_startRx, _targetRx, progress);
                final ry = _lerp(_startRy, _targetRy, progress);
                final rz = _lerp(_startRz, _targetRz, progress);
                return SizedBox(
                  width: 170,
                  height: 170,
                  child: CustomPaint(
                    size: const Size(170, 170),
                    painter: _DicePainter(rx: rx, ry: ry, rz: rz),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                'Result: $_result'.toUpperCase(),
                key: ValueKey(_result),
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: primary),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 200,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isRolling ? null : _roll,
                icon: Icon(_isRolling ? Icons.hourglass_top : Icons.casino),
                label: Text(_isRolling ? 'Rolling...' : 'ROLL!', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
