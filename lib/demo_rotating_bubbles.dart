import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'common.dart';

class DemoRotatingBubbles extends StatefulWidget {
  const DemoRotatingBubbles({
    Key key,
  }) : super(key: key);

  @override
  _DemoRotatingBubblesState createState() => _DemoRotatingBubblesState();
}

class _DemoRotatingBubblesState extends State<DemoRotatingBubbles>
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
      radii.add(random.nextInt(25) + 12.5);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rotating bubbles')),
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
  Animation<double> angle;
  double shift;

  static const double twoPi = math.pi * 2;

  @override
  void initState() {
    super.initState();
    final random = widget.random;
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: random.nextInt(1200) + 800),
    )..repeat();
    final startAngle = random.nextDouble() * twoPi;
    final endAngle = startAngle + (twoPi * (random.nextBool() ? 1 : -1));
    angle = controller.drive(Tween(begin: startAngle, end: endAngle));

    shift = random.nextDouble() / 10 + 1;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: RotatingBubblePainter(angle, shift, widget.radius, widget.color),
    );
  }
}

class RotatingBubblePainter extends CustomPainter {
  RotatingBubblePainter(
    this.angle,
    this.shift,
    this.radius,
    this.color,
  ) : super(repaint: angle);

  final Animation<double> angle;
  final double shift;
  final double radius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final appCenter = size.center(Offset.zero);
    final bigRadius = size.width / 2.7;
    final center =
        (Offset.fromDirection(angle.value, bigRadius * shift)) + appCenter;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..blendMode = BlendMode.lighten
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
