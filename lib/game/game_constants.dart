import 'package:flutter/material.dart';

class GameConstants {
  // World dimensions
  static const double worldWidth = 360.0;
  static const double worldHeight = 640.0;
  static const double groundHeight = 112.0;

  // Physics
  static const double gravity = 900.0; // px / s^2
  static const double jumpVelocity = -310.0; // px / s
  static const double maxFallSpeed = 450.0;

  // Bird
  static const double birdWidth = 34.0;
  static const double birdHeight = 24.0;
  static const double birdRadius = 15.0;

  // Pipes
  static const double pipeWidth = 52.0;
  static const double pipeGap = 135.0;
  static const double pipeSpeed = 140.0; // px / s
  static const double pipeSpawnInterval = 1.75; // seconds
  static const double minPipeTop = 60.0;

  // Visual Colors
  static const Color skyColor = Color(0xFF70C5CE);
  static const Color cloudColor = Color(0xFFE8F8F5);
  static const Color groundTopColor = Color(0xFF73BF2E);
  static const Color groundBodyColor = Color(0xFFDED895);
  static const Color groundStripeColor = Color(0xFFC8B35A);
  static const Color pipeBodyColor = Color(0xFF73BF2E);
  static const Color pipeBorderColor = Color(0xFF558022);
  static const Color pipeHighlightColor = Color(0xFF9CE659);
}
