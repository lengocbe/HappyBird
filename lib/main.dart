import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'game/game_constants.dart';
import 'game/bird.dart';
import 'game/pipe.dart';
import 'game/game_painter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const FlappyBirdApp());
}

class FlappyBirdApp extends StatelessWidget {
  const FlappyBirdApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flappy Bird',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'sans-serif',
        brightness: Brightness.light,
      ),
      home: const GameScreen(),
    );
  }
}

enum PlayStatus { ready, playing, gameOver }

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  PlayStatus _status = PlayStatus.ready;
  final Bird _bird = Bird();
  final List<PipePair> _pipes = [];
  final math.Random _rng = math.Random();

  double _spawnTimer = 0.0;
  double _groundOffset = 0.0;
  double _cloudOffset = 0.0;
  double _totalTime = 0.0;

  int _score = 0;
  int _bestScore = 0;

  @override
  void initState() {
    super.initState();
    _bird.reset();
    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (_lastElapsed == Duration.zero) {
      _lastElapsed = elapsed;
      return;
    }
    double dt = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
    _lastElapsed = elapsed;

    // Cap delta time to prevent physics anomalies on frame drops
    if (dt > 0.05) dt = 0.05;

    _totalTime += dt;

    setState(() {
      if (_status == PlayStatus.ready) {
        _bird.hover(_totalTime);
        _groundOffset += GameConstants.pipeSpeed * dt;
        _cloudOffset += 18.0 * dt;
      } else if (_status == PlayStatus.playing) {
        _groundOffset += GameConstants.pipeSpeed * dt;
        _cloudOffset += 18.0 * dt;
        _bird.update(dt);

        // Pipe spawning
        _spawnTimer += dt;
        if (_spawnTimer >= GameConstants.pipeSpawnInterval) {
          _spawnTimer = 0.0;
          _pipes.add(PipePair.random(GameConstants.worldWidth + 20, _rng));
        }

        // Pipe movement & scoring
        for (final pipe in _pipes) {
          pipe.update(dt);

          if (!pipe.passed && pipe.x + GameConstants.pipeWidth < _bird.x) {
            pipe.passed = true;
            _score++;
            HapticFeedback.lightImpact();
          }
        }

        // Remove offscreen pipes
        _pipes.removeWhere((p) => p.isOffscreen());

        // Collision check
        final double groundLimit =
            GameConstants.worldHeight - GameConstants.groundHeight - GameConstants.birdRadius;
        if (_bird.y >= groundLimit) {
          _bird.y = groundLimit;
          _triggerGameOver();
        } else if (_bird.y - GameConstants.birdRadius <= 0) {
          _triggerGameOver();
        } else {
          for (final pipe in _pipes) {
            if (pipe.collidesWith(_bird)) {
              _triggerGameOver();
              break;
            }
          }
        }
      } else if (_status == PlayStatus.gameOver) {
        // Fall to the ground
        final double groundLimit =
            GameConstants.worldHeight - GameConstants.groundHeight - GameConstants.birdRadius;
        if (_bird.y < groundLimit) {
          _bird.velocity += GameConstants.gravity * dt;
          _bird.y += _bird.velocity * dt;
          if (_bird.y >= groundLimit) {
            _bird.y = groundLimit;
          }
        }
      }
    });
  }

  void _triggerGameOver() {
    HapticFeedback.heavyImpact();
    _status = PlayStatus.gameOver;
    if (_score > _bestScore) {
      _bestScore = _score;
    }
  }

  void _handleUserTap() {
    if (_status == PlayStatus.ready) {
      _status = PlayStatus.playing;
      _bird.flap();
      HapticFeedback.selectionClick();
    } else if (_status == PlayStatus.playing) {
      _bird.flap();
      HapticFeedback.selectionClick();
    }
  }

  void _restartGame() {
    setState(() {
      _bird.reset();
      _pipes.clear();
      _score = 0;
      _spawnTimer = 0.0;
      _status = PlayStatus.ready;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E272C),
      body: SafeArea(
        child: Center(
          child: AspectRatio(
            aspectRatio: GameConstants.worldWidth / GameConstants.worldHeight,
            child: Focus(
              autofocus: true,
              onKeyEvent: (node, event) {
                if (event is KeyDownEvent &&
                    (event.logicalKey == LogicalKeyboardKey.space ||
                     event.logicalKey == LogicalKeyboardKey.arrowUp)) {
                  if (_status == PlayStatus.gameOver) {
                    _restartGame();
                  } else {
                    _handleUserTap();
                  }
                  return KeyEventResult.handled;
                }
                return KeyEventResult.ignored;
              },
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _handleUserTap,
                child: Stack(
                  children: [
                    // Canvas Game View
                    Positioned.fill(
                      child: CustomPaint(
                        painter: GamePainter(
                          bird: _bird,
                          pipes: _pipes,
                          groundOffset: _groundOffset,
                          cloudOffset: _cloudOffset,
                          score: _score,
                          isPlaying: _status == PlayStatus.playing,
                        ),
                      ),
                    ),

                    // In-Game Score Display
                    if (_status == PlayStatus.playing)
                      Positioned(
                        top: 48,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Text(
                            '$_score',
                            style: TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  offset: const Offset(3, 3),
                                  color: Colors.black.withOpacity(0.8),
                                  blurRadius: 2,
                                ),
                                Shadow(
                                  offset: const Offset(-2, -2),
                                  color: Colors.black.withOpacity(0.8),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Ready / Tutorial Overlay
                    if (_status == PlayStatus.ready)
                      Positioned.fill(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 70),
                            _buildOutlineText(
                              'FLAPPY BIRD',
                              fontSize: 38,
                              color: const Color(0xFFF7D02C),
                            ),
                            const SizedBox(height: 110),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.touch_app, color: Colors.white, size: 28),
                                  SizedBox(width: 8),
                                  Text(
                                    'CHẠM ĐỂ BAY',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Game Over Dialog / Scoreboard
                    if (_status == PlayStatus.gameOver)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.35),
                          child: Center(
                            child: _buildGameOverBoard(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverBoard() {
    return Container(
      width: 290,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFDED895),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF558022), width: 4),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            offset: Offset(4, 6),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOutlineText('GAME OVER', fontSize: 32, color: const Color(0xFFE84118)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5EAC4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFC8B35A), width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMedal(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'ĐIỂM SỐ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8C531B),
                      ),
                    ),
                    Text(
                      '$_score',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2F3640),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'KỶ LỤC',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8C531B),
                      ),
                    ),
                    Text(
                      '$_bestScore',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFE84118),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF73BF2E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: Color(0xFF558022), width: 2),
              ),
              elevation: 4,
            ),
            onPressed: _restartGame,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.replay, size: 22),
                SizedBox(width: 8),
                Text(
                  'CHƠI LẠI',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedal() {
    IconData icon;
    Color color;
    String title;

    if (_score >= 30) {
      icon = Icons.military_tech;
      color = const Color(0xFFFFD700); // Gold
      title = 'Vàng';
    } else if (_score >= 20) {
      icon = Icons.military_tech;
      color = const Color(0xFFC0C0C0); // Silver
      title = 'Bạc';
    } else if (_score >= 10) {
      icon = Icons.military_tech;
      color = const Color(0xFFCD7F32); // Bronze
      title = 'Đồng';
    } else {
      icon = Icons.star_border;
      color = Colors.grey;
      title = 'Chưa có';
    }

    return Column(
      children: [
        const Text(
          'HUY CHƯƠNG',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8C531B),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
          ),
          child: Icon(icon, color: color, size: 36),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildOutlineText(
    String text, {
    required double fontSize,
    required Color color,
  }) {
    return Stack(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 5
              ..color = Colors.black,
          ),
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }
}
