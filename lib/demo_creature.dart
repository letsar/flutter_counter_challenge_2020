// Credits to https://gist.github.com/beesandbombs/6f3e6fb723f50b080916816ae8e561e3

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'common.dart';

class DemoCreature extends StatefulWidget {
  const DemoCreature({
    Key key,
  }) : super(key: key);

  @override
  _DemoCreatureState createState() => _DemoCreatureState();
}

class _DemoCreatureState extends State<DemoCreature>
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
      appBar: AppBar(title: const Text('Creature')),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          for (int i = 0; i < _counter; i++)
            Positioned.fill(
              child: TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeIn,
                builder: (_, double opacity, __) {
                  return CustomPaint(
                    painter: CreaturePainter(
                      controller,
                      addPointAnimation,
                      i,
                      colors[i % colors.length].withOpacity(opacity),
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

class CreaturePainter extends CustomPainter {
  CreaturePainter(
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
  final n = 300;

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    final halfWidth = size.width / 2;
    final halfHeight = size.height / 2;
    final q = twoPi * index / count;
    canvas.translate(halfWidth, halfHeight);
    if (index > 0 && count > 2) {
      canvas.rotate(
          twoPi * (index / (count - 1)) * (count - addAnimation.value) / count);
    } else {
      canvas.rotate(q);
    }

    List<Offset> computeOffsets(int length) {
      final offsets = <Offset>[];
      for (var i = 0; i < n; i++) {
        final qq = i / (n - 1);
        final r = map(math.cos(twoPi * qq), 1, -1, 0, 42) * math.sqrt(qq);
        final th = 12 * twoPi * qq - 4 * twoPi * t - q;
        final x = r * math.cos(th);
        final y = -(halfWidth - 10) * qq + r * math.sin(th);
        final tw = math.pi / 10 * math.sin(twoPi * t - math.pi * qq);
        final xx = x * math.cos(tw) + y * math.sin(tw);
        final yy = y * math.cos(tw) - x * math.sin(tw);

        offsets.add(Offset(xx, yy));
      }
      return offsets;
    }

    final offsets = computeOffsets(count);

    final path = Path()..addPolygon(offsets, false);
    canvas.drawPath(
      path,
      Paint()
        ..blendMode = BlendMode.lighten
        ..color = color
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 10),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
