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
// COIN PAINTER
// ============================================================
class _CoinPainter extends CustomPainter {
  final bool isHeads;

  _CoinPainter({required this.isHeads});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer edge shadow
    final edgeShadow = Paint()
      ..shader = RadialGradient(
        colors: [Colors.black.withValues(alpha: 0), Colors.black.withValues(alpha: 0.15)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, edgeShadow);

    // Main body
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        focal: const Alignment(-0.2, -0.3),
        colors: isHeads
            ? [const Color(0xFFFFF3E0), const Color(0xFFFFB74D), const Color(0xFFF57C00)]
            : [const Color(0xFFE8EAF6), const Color(0xFF9FA8DA), const Color(0xFF5C6BC0)],
      ).createShader(Rect.fromCircle(center: center, radius: radius - 2));
    canvas.drawCircle(center, radius - 2, bodyPaint);

    // Inner border ring
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    final ringRect = Rect.fromCircle(center: center, radius: radius - 8);
    ringPaint.shader = LinearGradient(
      colors: [Colors.white.withValues(alpha: 0.6), Colors.white.withValues(alpha: 0.1)],
    ).createShader(ringRect);
    canvas.drawCircle(center, radius - 8, ringPaint);

    // Small dots around the ring (coin edge texture)
    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.3);
    for (int i = 0; i < 24; i++) {
      final a = i * 2 * pi / 24;
      final dx = center.dx + (radius - 14) * cos(a);
      final dy = center.dy + (radius - 14) * sin(a);
      canvas.drawCircle(Offset(dx, dy), 1.5, dotPaint);
    }

    // Center text
    final textPainter = TextPainter(
      text: TextSpan(
        text: isHeads ? '\u2605' : '\u2663',
        style: TextStyle(
          fontSize: radius * 0.55,
          color: isHeads ? const Color(0xFFE65100) : const Color(0xFF283593),
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2 - radius * 0.1));

    // Denomination text
    final valPainter = TextPainter(
      text: TextSpan(
        text: isHeads ? '1' : '2',
        style: TextStyle(
          fontSize: radius * 0.25,
          color: isHeads ? const Color(0xFFBF360C) : const Color(0xFF1A237E),
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    valPainter.paint(canvas, Offset(center.dx - valPainter.width / 2, center.dy + radius * 0.25));

    // Glossy highlight
    final glossPaint = Paint()
      ..shader = RadialGradient(
        focal: const Alignment(-0.4, -0.4),
        colors: [Colors.white.withValues(alpha: 0.4), Colors.white.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, glossPaint);
  }

  @override
  bool shouldRepaint(_CoinPainter old) => old.isHeads != isHeads;
}

// ============================================================
// DICE FACE PAINTER
// ============================================================
class _DicePainter extends CustomPainter {
  final int value;

  _DicePainter({required this.value});

  static const _dotPositions = {
    1: [Offset(0.5, 0.5)],
    2: [Offset(0.75, 0.25), Offset(0.25, 0.75)],
    3: [Offset(0.75, 0.25), Offset(0.5, 0.5), Offset(0.25, 0.75)],
    4: [Offset(0.25, 0.25), Offset(0.75, 0.25), Offset(0.25, 0.75), Offset(0.75, 0.75)],
    5: [Offset(0.25, 0.25), Offset(0.75, 0.25), Offset(0.5, 0.5), Offset(0.25, 0.75), Offset(0.75, 0.75)],
    6: [Offset(0.25, 0.25), Offset(0.75, 0.25), Offset(0.25, 0.5), Offset(0.75, 0.5), Offset(0.25, 0.75), Offset(0.75, 0.75)],
  };

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final margin = w * 0.08;

    // Shadow
    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(2, 3, w, h), Radius.circular(w * 0.18)), shadow);

    // White body
    final body = Paint()
      ..color = const Color(0xFFFAFAFA)
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [const Color(0xFFFFFFFF), const Color(0xFFE0E0E0)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    final rrect = RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), Radius.circular(w * 0.18));
    canvas.drawRRect(rrect, body);

    // Inner border
    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.black.withValues(alpha: 0.1);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(1.5, 1.5, w - 3, h - 3), Radius.circular(w * 0.16)),
      border,
    );

    // Dots
    final dotR = w * 0.08;
    final dotPaint = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFF424242), const Color(0xFF212121)],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: dotR));

    final positions = _dotPositions[value] ?? [];
    for (final pos in positions) {
      final dx = margin + pos.dx * (w - 2 * margin);
      final dy = margin + pos.dy * (h - 2 * margin);
      canvas.drawCircle(Offset(dx, dy), dotR, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_DicePainter old) => old.value != value;
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
                final angle = _ctrl.value * pi;
                final showHeads = angle < pi / 2;
                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.002)
                    ..rotateY(angle),
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 170,
                    height: 170,
                    child: CustomPaint(
                      size: const Size(170, 170),
                      painter: _CoinPainter(isHeads: showHeads),
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

class _DiceRollerPageState extends State<_DiceRollerPage> {
  int _result = 1;
  int _sides = 6;
  bool _isRolling = false;
  final _random = Random();

  static const _sideOptions = [4, 6, 8, 10, 12, 20];

  void _roll() {
    if (_isRolling) return;
    setState(() => _isRolling = true);
    int count = 0;
    Timer.periodic(const Duration(milliseconds: 70), (t) {
      count++;
      setState(() => _result = _random.nextInt(_sides) + 1);
      if (count > 18) {
        t.cancel();
        setState(() => _isRolling = false);
      }
    });
  }

  String _diceLabel(int sides, int val) {
    if (sides == 4) return 'D4: $val';
    if (sides == 8) return 'D8: $val';
    if (sides == 10) return 'D10: $val';
    if (sides == 12) return 'D12: $val';
    if (sides == 20) return 'D20: $val';
    return 'D6: $val';
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
            AnimatedScale(
              scale: _isRolling ? 1.08 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: _sides == 6
                  ? SizedBox(
                      width: 130,
                      height: 130,
                      child: CustomPaint(
                        size: const Size(130, 130),
                        painter: _DicePainter(value: _result),
                      ),
                    )
                  : Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [const Color(0xFFFFFFFF), const Color(0xFFE0E0E0)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 10, offset: const Offset(2, 4)),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '$_result',
                          style: TextStyle(
                            fontSize: 52,
                            color: const Color(0xFF424242),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 24),
            Text(_diceLabel(_sides, _result),
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: primary)),
            const SizedBox(height: 28),
            SizedBox(
              width: 200,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isRolling ? null : _roll,
                icon: Icon(_isRolling ? Icons.hourglass_top : Icons.casino),
                label: Text(_isRolling ? 'Rolling...' : 'ROLL!', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text('Select Dice', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _sideOptions.map((n) {
                final selected = _sides == n;
                return ChoiceChip(
                  label: Text('D$n', style: TextStyle(
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    color: selected ? theme.colorScheme.onPrimary : null,
                  )),
                  selected: selected,
                  selectedColor: primary,
                  onSelected: _isRolling ? null : (v) => setState(() { _sides = n; _result = 1; }),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
