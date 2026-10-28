import 'dart:math' as math;
import 'game_constants.dart';

class Bird {
  double x = GameConstants.worldWidth * 0.28;
  double y = (GameConstants.worldHeight - GameConstants.groundHeight) * 0.5;
  double velocity = 0.0;
  double angle = 0.0;

  double wingTimer = 0.0;
  int wingFrame = 0; // 0 = down, 1 = mid, 2 = up

  void reset() {
    x = GameConstants.worldWidth * 0.28;
    y = (GameConstants.worldHeight - GameConstants.groundHeight) * 0.5;
    velocity = 0.0;
    angle = 0.0;
    wingTimer = 0.0;
    wingFrame = 0;
  }

  void flap() {
    velocity = GameConstants.jumpVelocity;
    wingFrame = 2; // Wing flaps upward immediately
  }

  void update(double dt) {
    // Apply gravity
    velocity += GameConstants.gravity * dt;
    if (velocity > GameConstants.maxFallSpeed) {
      velocity = GameConstants.maxFallSpeed;
    }

    y += velocity * dt;

    // Smooth rotation calculation
    if (velocity < 0) {
      // Tilting up
      angle = -0.35; // ~ -20 degrees
    } else {
      // Tilting down progressively
      double fallFactor = (velocity / GameConstants.maxFallSpeed).clamp(0.0, 1.0);
      angle = -0.35 + fallFactor * (math.pi / 2 + 0.35);
    }

    // Wing flapping animation
    wingTimer += dt;
    if (wingTimer >= 0.08) {
      wingTimer = 0.0;
      wingFrame = (wingFrame + 1) % 3;
    }
  }

  // Hovering idle animation before game starts
  void hover(double totalTime) {
    y = (GameConstants.worldHeight - GameConstants.groundHeight) * 0.5 +
        math.sin(totalTime * 4.0) * 8.0;
    velocity = 0.0;
    angle = 0.0;

    wingTimer += 0.016;
    if (wingTimer >= 0.12) {
      wingTimer = 0.0;
      wingFrame = (wingFrame + 1) % 3;
    }
  }
}
