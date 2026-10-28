import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'game_constants.dart';
import 'bird.dart';
import 'pipe.dart';

class GamePainter extends CustomPainter {
  final Bird bird;
  final List<PipePair> pipes;
  final double groundOffset;
  final double cloudOffset;
  final int score;
  final bool isPlaying;

  GamePainter({
    required this.bird,
    required this.pipes,
    required this.groundOffset,
    required this.cloudOffset,
    required this.score,
    required this.isPlaying,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Scaling matrix to fit our virtual coordinate space (360 x 640)
    final double scaleX = size.width / GameConstants.worldWidth;
    final double scaleY = size.height / GameConstants.worldHeight;
    canvas.save();
    canvas.scale(scaleX, scaleY);

    _drawSky(canvas);
    _drawClouds(canvas);
    _drawCityscape(canvas);
    _drawPipes(canvas);
    _drawGround(canvas);
    _drawBird(canvas);

    canvas.restore();
  }

  void _drawSky(Canvas canvas) {
    final Rect skyRect = Rect.fromLTWH(0, 0, GameConstants.worldWidth, GameConstants.worldHeight);
    final Paint skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF4EC0CA), Color(0xFF88D8E0)],
      ).createShader(skyRect);
    canvas.drawRect(skyRect, skyPaint);
  }

  void _drawClouds(Canvas canvas) {
    final Paint cloudPaint = Paint()..color = Colors.white.withOpacity(0.75);
    final double groundY = GameConstants.worldHeight - GameConstants.groundHeight;

    // Draw repeating clouds scrolling slowly
    for (int i = -1; i < 3; i++) {
      final double cx = (i * 220.0 - (cloudOffset % 220.0));
      final double cy = groundY - 140.0;

      canvas.drawCircle(Offset(cx + 30, cy + 10), 22, cloudPaint);
      canvas.drawCircle(Offset(cx + 55, cy), 30, cloudPaint);
      canvas.drawCircle(Offset(cx + 80, cy + 10), 24, cloudPaint);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(cx + 10, cy + 10, 95, 20),
          const Radius.circular(10),
        ),
        cloudPaint,
      );
    }
  }

  void _drawCityscape(Canvas canvas) {
    final double groundY = GameConstants.worldHeight - GameConstants.groundHeight;
    final Paint hillPaint = Paint()..color = const Color(0xFF67B55D).withOpacity(0.6);

    // Soft hills along the horizon
    for (int i = -1; i < 4; i++) {
      final double hx = i * 140.0;
      final Path path = Path()
        ..moveTo(hx, groundY)
        ..quadraticBezierTo(hx + 70, groundY - 45, hx + 140, groundY)
        ..close();
      canvas.drawPath(path, hillPaint);
    }

    // Bushes along the ground line
    final Paint bushPaint = Paint()..color = const Color(0xFF5AA650);
    for (int i = -1; i < 6; i++) {
      final double bx = i * 80.0;
      canvas.drawCircle(Offset(bx + 40, groundY - 4), 22, bushPaint);
    }
  }

  void _drawPipes(Canvas canvas) {
    final Paint pipeBodyPaint = Paint()..color = const Color(0xFF74BF2E);
    final Paint pipeBorderPaint = Paint()
      ..color = const Color(0xFF4F7E1E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    final Paint pipeHighlightPaint = Paint()..color = const Color(0xFF9CE659);
    final Paint pipeShadowPaint = Paint()..color = const Color(0xFF5A9922);

    const double capW = GameConstants.pipeWidth + 6.0;
    const double capH = 24.0;
    const double capInset = 3.0; // cap overhang

    for (final pipe in pipes) {
      // ===== TOP PIPE =====
      final Rect topRect = Rect.fromLTWH(
        pipe.x,
        0,
        GameConstants.pipeWidth,
        pipe.topHeight - capH,
      );
      final Rect topCap = Rect.fromLTWH(
        pipe.x - capInset,
        pipe.topHeight - capH,
        capW,
        capH,
      );

      // Body
      canvas.drawRect(topRect, pipeBodyPaint);
      canvas.drawRect(Rect.fromLTWH(pipe.x + 4, 0, 6, topRect.height), pipeHighlightPaint);
      canvas.drawRect(Rect.fromLTWH(pipe.x + GameConstants.pipeWidth - 8, 0, 6, topRect.height), pipeShadowPaint);
      canvas.drawRect(topRect, pipeBorderPaint);

      // Cap
      canvas.drawRect(topCap, pipeBodyPaint);
      canvas.drawRect(Rect.fromLTWH(topCap.left + 4, topCap.top, 6, capH), pipeHighlightPaint);
      canvas.drawRect(Rect.fromLTWH(topCap.right - 8, topCap.top, 6, capH), pipeShadowPaint);
      canvas.drawRect(topCap, pipeBorderPaint);

      // ===== BOTTOM PIPE =====
      final double botCapY = pipe.bottomY;
      final Rect botCap = Rect.fromLTWH(
        pipe.x - capInset,
        botCapY,
        capW,
        capH,
      );
      final double botBodyY = botCapY + capH;
      final double botBodyH = GameConstants.worldHeight - GameConstants.groundHeight - botBodyY;
      final Rect botRect = Rect.fromLTWH(
        pipe.x,
        botBodyY,
        GameConstants.pipeWidth,
        botBodyH,
      );

      // Body
      canvas.drawRect(botRect, pipeBodyPaint);
      canvas.drawRect(Rect.fromLTWH(pipe.x + 4, botBodyY, 6, botBodyH), pipeHighlightPaint);
      canvas.drawRect(Rect.fromLTWH(pipe.x + GameConstants.pipeWidth - 8, botBodyY, 6, botBodyH), pipeShadowPaint);
      canvas.drawRect(botRect, pipeBorderPaint);

      // Cap
      canvas.drawRect(botCap, pipeBodyPaint);
      canvas.drawRect(Rect.fromLTWH(botCap.left + 4, botCap.top, 6, capH), pipeHighlightPaint);
      canvas.drawRect(Rect.fromLTWH(botCap.right - 8, botCap.top, 6, capH), pipeShadowPaint);
      canvas.drawRect(botCap, pipeBorderPaint);
    }
  }

  void _drawGround(Canvas canvas) {
    final double groundY = GameConstants.worldHeight - GameConstants.groundHeight;

    // Dirt base
    final Rect groundRect = Rect.fromLTWH(
      0,
      groundY,
      GameConstants.worldWidth,
      GameConstants.groundHeight,
    );
    final Paint groundPaint = Paint()..color = const Color(0xFFDED895);
    canvas.drawRect(groundRect, groundPaint);

    // Diagonal stripes on ground
    final Paint stripePaint = Paint()
      ..color = const Color(0xFFC8B35A)
      ..strokeWidth = 3.0;

    const double stripeGap = 16.0;
    final double offset = groundOffset % stripeGap;
    for (double x = -stripeGap; x < GameConstants.worldWidth + stripeGap; x += stripeGap) {
      canvas.drawLine(
        Offset(x - offset, groundY + 14),
        Offset(x - offset - 10, groundY + 28),
        stripePaint,
      );
    }

    // Top grass strip
    final Rect grassRect = Rect.fromLTWH(0, groundY, GameConstants.worldWidth, 14);
    final Paint grassPaint = Paint()..color = const Color(0xFF73BF2E);
    canvas.drawRect(grassRect, grassPaint);

    // Grass border
    final Paint linePaint = Paint()
      ..color = const Color(0xFF558022)
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(0, groundY), Offset(GameConstants.worldWidth, groundY), linePaint);
    canvas.drawLine(Offset(0, groundY + 14), Offset(GameConstants.worldWidth, groundY + 14), linePaint);
  }

  void _drawBird(Canvas canvas) {
    canvas.save();
    canvas.translate(bird.x, bird.y);
    canvas.rotate(bird.angle);

    final Paint borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Body (Yellow oval)
    final Rect bodyRect = Rect.fromCenter(
      center: Offset.zero,
      width: GameConstants.birdWidth,
      height: GameConstants.birdHeight,
    );
    final Paint bodyPaint = Paint()..color = const Color(0xFFF7D02C);
    canvas.drawOval(bodyRect, bodyPaint);
    canvas.drawOval(bodyRect, borderPaint);

    // Belly highlight
    final Paint bellyPaint = Paint()..color = const Color(0xFFFBE47A);
    canvas.drawArc(bodyRect, 0.2, math.pi * 0.9, false, bellyPaint);

    // Eye (White circle + Black pupil)
    final Offset eyeOffset = const Offset(6, -4);
    final Paint eyeWhitePaint = Paint()..color = Colors.white;
    final Paint pupilPaint = Paint()..color = Colors.black;
    canvas.drawCircle(eyeOffset, 6.0, eyeWhitePaint);
    canvas.drawCircle(eyeOffset, 6.0, borderPaint);
    canvas.drawCircle(eyeOffset + const Offset(2.5, 0), 2.5, pupilPaint);
    // Eye shine
    canvas.drawCircle(eyeOffset + const Offset(1.5, -1.5), 1.0, Paint()..color = Colors.white);

    // Beak (Orange polygon)
    final Path beakPath = Path()
      ..moveTo(8, -1)
      ..lineTo(18, 3)
      ..lineTo(8, 7)
      ..close();
    final Paint beakPaint = Paint()..color = const Color(0xFFF85820);
    canvas.drawPath(beakPath, beakPaint);
    canvas.drawPath(beakPath, borderPaint);

    // Lip line
    canvas.drawLine(const Offset(8, 3), const Offset(17, 3), borderPaint);

    // Wing (Animated with wingFrame)
    double wingAngle = 0.0;
    if (bird.wingFrame == 0) {
      wingAngle = 0.3; // wing pointing down
    } else if (bird.wingFrame == 1) {
      wingAngle = 0.0; // wing horizontal
    } else {
      wingAngle = -0.4; // wing pointing up
    }

    canvas.save();
    canvas.translate(-4, 0);
    canvas.rotate(wingAngle);
    final Rect wingRect = Rect.fromCenter(
      center: const Offset(-2, 0),
      width: 15,
      height: 10,
    );
    final Paint wingPaint = Paint()..color = const Color(0xFFFFFFFF);
    canvas.drawOval(wingRect, wingPaint);
    canvas.drawOval(wingRect, borderPaint);
    canvas.restore();

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) => true;
}
