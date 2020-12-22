import 'dart:math';

import 'package:flutter/material.dart';

import 'common.dart';

class DemoDisks extends StatefulWidget {
  const DemoDisks({Key key}) : super(key: key);

  @override
  _DemoDisksState createState() => _DemoDisksState();
}

class _DemoDisksState extends State<DemoDisks> {
  final Random random = Random();
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disks'),
      ),
      body: Stack(
        children: [
          for (int i = 0; i < _counter; i++)
            Positioned.fill(
              child: Disk(random: random),
            ),
          CounterText(counter: _counter),
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

class Disk extends StatefulWidget {
  const Disk({
    Key key,
    @required this.random,
  }) : super(key: key);

  final Random random;

  @override
  _DiskState createState() => _DiskState();
}

class _DiskState extends State<Disk> with SingleTickerProviderStateMixin {
  AnimationController controller;
  double radius;
  CenterTween centerTween;

  @override
  void initState() {
    super.initState();
    final random = widget.random;
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    radius = random.nextDouble() * 50 + 25;

    final candidates = [
      Offset(random.nextDouble(), -0.1),
      Offset(random.nextDouble(), 1.1),
      Offset(-0.1, random.nextDouble()),
      Offset(1.1, random.nextDouble()),
    ];

    final start = candidates.removeAt(random.nextInt(candidates.length));
    final end = candidates.removeAt(random.nextInt(candidates.length));

    centerTween = CenterTween(start, end, random.nextDouble());
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: radius),
      duration: const Duration(seconds: 1),
      curve: Curves.elasticOut,
      builder: (_, double effectiveRadius, __) {
        return CustomPaint(
          painter: DiskPainter(controller, centerTween, effectiveRadius),
        );
      },
    );
  }
}

class CenterTween extends Animatable<Offset> {
  const CenterTween(this.begin, this.end, this.shift)
      : translation = begin - end;

  final Offset begin;
  final Offset end;
  final double shift;
  final Offset translation;

  @override
  Offset transform(double t) {
    return begin + (end - begin) * ((t + shift) % 1);
  }
}

class DiskPainter extends CustomPainter {
  const DiskPainter(
    this.animation,
    this.centerTween,
    this.radius,
  ) : super(repaint: animation);

  final Animation<double> animation;
  final double radius;
  final CenterTween centerTween;

  @override
  void paint(Canvas canvas, Size size) {
    final ratioCenter = centerTween.evaluate(animation);
    final center = Offset(
      ratioCenter.dx * size.width,
      ratioCenter.dy * size.height,
    );
    final translation = Offset(
      centerTween.translation.dx * size.width,
      centerTween.translation.dy * size.height,
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white
        ..blendMode = BlendMode.difference,
    );
    canvas.drawCircle(
      center + translation,
      radius,
      Paint()
        ..color = Colors.white
        ..blendMode = BlendMode.difference,
    );
  }

  @override
  bool shouldRepaint(DiskPainter oldDelegate) => oldDelegate.radius != radius;
}
