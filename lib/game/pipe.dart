import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'game_constants.dart';
import 'bird.dart';

class PipePair {
  double x;
  double topHeight;
  bool passed = false;

  PipePair({required this.x, required this.topHeight});

  static PipePair random(double startX, math.Random rng) {
    const double playHeight = GameConstants.worldHeight - GameConstants.groundHeight;
    const double maxTop = playHeight - GameConstants.pipeGap - GameConstants.minPipeTop;
    final double h = GameConstants.minPipeTop +
        rng.nextDouble() * (maxTop - GameConstants.minPipeTop);
    return PipePair(x: startX, topHeight: h);
  }

  void update(double dt) {
    x -= GameConstants.pipeSpeed * dt;
  }

  bool isOffscreen() {
    return x + GameConstants.pipeWidth < 0;
  }

  double get bottomY => topHeight + GameConstants.pipeGap;

  Rect get topRect => Rect.fromLTWH(
        x,
        0,
        GameConstants.pipeWidth,
        topHeight,
      );

  Rect get bottomRect => Rect.fromLTWH(
        x,
        bottomY,
        GameConstants.pipeWidth,
        GameConstants.worldHeight - GameConstants.groundHeight - bottomY,
      );

  bool collidesWith(Bird bird) {
    // Bird hitbox circle
    final double bx = bird.x;
    final double by = bird.y;
    const double r = GameConstants.birdRadius - 2;

    return _circleIntersectsRect(bx, by, r, topRect) ||
        _circleIntersectsRect(bx, by, r, bottomRect);
  }

  bool _circleIntersectsRect(double cx, double cy, double r, Rect rect) {
    final double closestX = cx.clamp(rect.left, rect.right);
    final double closestY = cy.clamp(rect.top, rect.bottom);
    final double dx = cx - closestX;
    final double dy = cy - closestY;
    return (dx * dx + dy * dy) < (r * r);
  }
}
