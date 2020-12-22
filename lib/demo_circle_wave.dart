// Credits to https://dribbble.com/shots/1698964-Circle-wave-II

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'common.dart';

class DemoCircleWave extends StatefulWidget {
  const DemoCircleWave({
    Key key,
  }) : super(key: key);

  @override
  _DemoCircleWaveState createState() => _DemoCircleWaveState();
}

class _DemoCircleWaveState extends State<DemoCircleWave>
    with TickerProviderStateMixin {
  static const colors = <Color>[
    Color(0xFFFF2964),
    Color(0xFF32FF3A),
    Color(0xFF4255FF)
  ];
  AnimationController controller;
  AnimationController addPointController;
  Animation<double> addPointAnimation;
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      upperBound: 2,
      duration: const Duration(seconds: 10),
    )..repeat();
    addPointController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    addPointAnimation =
        addPointController.drive(CurveTween(curve: Curves.ease));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
      addPointController.forward(from: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Circle wave')),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          for (int i = 0; i < 3; i++)
            Positioned.fill(
              child: TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeIn,
                builder: (_, double opacity, __) {
                  return CustomPaint(
                    painter: CircleWavePainter(
                      controller,
                      addPointAnimation,
                      i,
                      colors[i].withOpacity(opacity),
                      _counter,
                    ),
                  );
                },
              ),
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

class CircleWavePainter extends CustomPainter {
  CircleWavePainter(
    this.animation,
    this.addAnimation,
    this.index,
    this.color,
    this.count,
  ) : super(repaint: animation);
  final Animation<double> animation;
  final Animation<double> addAnimation;
  final int index;
  final Color color;
  final int count;

  static const halfPi = math.pi / 2;
  static const twoPi = math.pi * 2;
  final n = 7;

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    final halfWidth = size.width / 2;
    final halfHeight = size.height / 2;
    final q = index * halfPi;

    List<Offset> computeOffsets(int length) {
      final offsets = <Offset>[];
      for (var i = 0; i < length; i++) {
        final th = i * twoPi / length;
        double os = map(math.cos(th - twoPi * t), -1, 1, 0, 1);
        os = 0.125 * math.pow(os, 2.75);
        final r = 165 * (1 + os * math.cos(n * th + 1.5 * twoPi * t + q));
        offsets.add(Offset(
            r * math.sin(th) + halfWidth, -r * math.cos(th) + halfHeight));
      }
      return offsets;
    }

    final offsets = computeOffsets(count);

    if (count > 1 && addAnimation.value < 1) {
      final t = addAnimation.value;
      final oldOffsets = computeOffsets(count - 1);
      for (var i = 0; i < count - 1; i++) {
        offsets[i] = Offset.lerp(oldOffsets[i], offsets[i], t);
      }
      offsets[count - 1] = Offset.lerp(
        oldOffsets[count - 2],
        offsets[count - 1],
        t,
      );
    }

    final path = Path()..addPolygon(offsets, true);
    canvas.drawPath(
      path,
      Paint()
        ..blendMode = BlendMode.lighten
        ..color = color
        ..strokeWidth = 8
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
