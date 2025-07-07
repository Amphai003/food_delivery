import 'package:flutter/material.dart';
import 'dart:math' as math;

class RaysPainter extends CustomPainter {
  // We'll use a very dark, slightly desaturated blue for the "rays"
  // This will blend better with the existing dark blue/purple gradient header.
  final Color baseColor;

  RaysPainter({this.baseColor = const Color(0xFF282a43)}); // A dark desaturated blue

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Overall very faint, large radial gradient for a soft general haze
    final Paint subtleHazePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          baseColor.withOpacity(0.0),    // Fully transparent
          baseColor.withOpacity(0.01),   // Extremely faint inner glow
          baseColor.withOpacity(0.0),    // Fade out to transparent
        ],
        stops: [0.0, 0.4, 1.0],
        radius: 0.9, // Make it cover a wide area
        center: Alignment.topLeft, // Still originating from top-left
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Offset.zero & size, subtleHazePaint);

    // 2. Faint, irregular shapes (blobs/curves) with even lower opacity
    // These should be almost indistinguishable, just adding some texture.
    final Paint abstractShapePaint = Paint();

    // Shape 1: A very subtle, large, and wide curved blob
    Path path1 = Path()
      ..moveTo(size.width * 0.0, size.height * 0.5); // Start from left middle
    path1.quadraticBezierTo(
      size.width * 0.4, size.height * 0.0, // Control point
      size.width * 0.8, size.height * 0.2, // End point
    );
    path1.quadraticBezierTo(
      size.width * 0.5, size.height * 0.6, // Another control point to close it off-screen
      size.width * 0.0, size.height * 0.5, // Close back to start
    );
    path1.close();

    abstractShapePaint.shader = LinearGradient(
      colors: [
        baseColor.withOpacity(0.0),
        baseColor.withOpacity(0.008), // Even lower opacity
        baseColor.withOpacity(0.0),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(path1.getBounds());
    canvas.drawPath(path1, abstractShapePaint);

    // Shape 2: Another subtle, elongated shape, slightly diagonal
    Path path2 = Path()
      ..moveTo(size.width * 0.2, size.height * 0.0); // Start from top
    path2.quadraticBezierTo(
      size.width * 0.9, size.height * 0.3,
      size.width * 0.7, size.height * 0.9,
    );
    path2.quadraticBezierTo(
      size.width * 0.4, size.height * 0.6,
      size.width * 0.2, size.height * 0.0,
    );
    path2.close();

    abstractShapePaint.shader = LinearGradient(
      colors: [
        baseColor.withOpacity(0.0),
        baseColor.withOpacity(0.006), // Very, very low opacity
        baseColor.withOpacity(0.0),
      ],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    ).createShader(path2.getBounds());
    canvas.drawPath(path2, abstractShapePaint);

    // 3. Tiny, almost invisible circular/elliptical smudges
    final Paint smudgePaint = Paint();
    smudgePaint.shader = RadialGradient(
      colors: [
        baseColor.withOpacity(0.0),
        baseColor.withOpacity(0.005), // Extremely low opacity
        baseColor.withOpacity(0.0),
      ],
      stops: [0.0, 0.5, 1.0],
      radius: 0.5,
    ).createShader(Rect.fromCircle(center: Offset(size.width * 0.15, size.height * 0.75), radius: 20));
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.75), 20, smudgePaint);

    smudgePaint.shader = RadialGradient(
      colors: [
        baseColor.withOpacity(0.0),
        baseColor.withOpacity(0.007),
        baseColor.withOpacity(0.0),
      ],
      stops: [0.0, 0.5, 1.0],
      radius: 0.5,
    ).createShader(Rect.fromCircle(center: Offset(size.width * 0.8, size.height * 0.1), radius: 15));
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.1), 15, smudgePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}