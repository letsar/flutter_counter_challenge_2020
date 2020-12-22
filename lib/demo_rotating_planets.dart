// Credits to https://twitter.com/beesandbombs/status/1329468633723101187?s=20

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'common.dart';

class DemoRotatingPlanets extends StatefulWidget {
  const DemoRotatingPlanets({
    Key key,
  }) : super(key: key);

  @override
  _DemoRotatingPlanetsState createState() => _DemoRotatingPlanetsState();
}

class _DemoRotatingPlanetsState extends State<DemoRotatingPlanets>
    with TickerProviderStateMixin {
  static const colors = <Color>[
    Color(0xFFFF2964),
    Color(0xFF32FF3A),
    Color(0xFF4255FF)
  ];
  final math.Random random = math.Random();
  final List<double> radii = <double>[];

  void _incrementCounter() {
    setState(() {
      radii.add(random.nextInt(20) + 10.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rotating planets')),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          for (int i = 0; i < radii.length; i++)
            Positioned.fill(
              child: TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: radii[i]),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeIn,
                builder: (_, double radius, __) {
                  return RotatingBubble(
                    random: random,
                    radius: radius,
                    color: colors[i % colors.length],
                  );
                },
              ),
            ),
          CounterText(counter: radii.length),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class RotatingBubble extends StatefulWidget {
  const RotatingBubble({
    Key key,
    @required this.random,
    @required this.radius,
    @required this.color,
  }) : super(key: key);

  final math.Random random;
  final double radius;
  final Color color;

  @override
  _RotatingBubbleState createState() => _RotatingBubbleState();
}

class _RotatingBubbleState extends State<RotatingBubble>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  double dy;
  double margin;
  double radiusFactor;

  @override
  void initState() {
    super.initState();
    final random = widget.random;
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    dy = map(random.nextDouble(), 0.3, 0.7);
    margin = map(random.nextDouble(), 0.1, 0.3);
    radiusFactor = random.nextDouble() + 1.5;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: RotatingBubblePainter(
        controller,
        dy,
        widget.radius,
        radiusFactor,
        widget.color,
        margin,
      ),
    );
  }
}

class RotatingBubblePainter extends CustomPainter {
  RotatingBubblePainter(
    this.animation,
    this.dy,
    this.radius,
    this.radiusFactor,
    this.color,
    this.margin,
  ) : super(repaint: animation);

  final Animation<double> animation;
  final double dy;
  final double radius;
  final double radiusFactor;
  final Color color;
  final double margin;

  @override
  void paint(Canvas canvas, Size size) {
    final curve = Curves.easeInOutSine;

    final t = curve.transform(animation.value);
    final y = size.height * dy;
    final x = lerpDouble(margin, 1 - margin, t) * size.width;
    final center = Offset(x, y);
    final factor = animation.status == AnimationStatus.forward
        ? radiusFactor
        : 1 / radiusFactor;
    final effectiveRadus = RadiusCurve(radius, radius * factor).transform(t);
    final opacity = animation.status == AnimationStatus.forward
        ? 1.0
        : const RadiusCurve(1, 0.3).transform(t);
    canvas.drawCircle(
      center,
      effectiveRadus,
      Paint()
        ..blendMode = BlendMode.lighten
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 10)
        ..color = color.withOpacity(opacity),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

double map(double x, double minOut, double maxOut) {
  return x * (maxOut - minOut) + minOut;
}

class RadiusCurve extends Animatable<double> {
  const RadiusCurve(this.small, this.big);

  final double small;
  final double big;

  @override
  double transform(double t) {
    if (t <= 0.5) {
      return lerpDouble(small, big, t);
    } else {
      return lerpDouble(big, small, t);
    }
  }
}
