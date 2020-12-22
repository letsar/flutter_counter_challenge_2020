import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'common.dart';

class DemoWave extends StatefulWidget {
  const DemoWave({Key key}) : super(key: key);

  @override
  _DemoWaveState createState() => _DemoWaveState();
}

class _DemoWaveState extends State<DemoWave> {
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
        title: const Text('Wave'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: _counter.toDouble()),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.bounceOut,
              builder: (_, double ratio, __) {
                return FractionallySizedBox(
                  heightFactor: (ratio / 100).clamp(0, 100).toDouble(),
                  alignment: Alignment.bottomCenter,
                  child: const Wave(
                    child: DifferenceMask(),
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

class Wave extends StatefulWidget {
  const Wave({
    Key key,
    @required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  _WaveState createState() => _WaveState();
}

class _WaveState extends State<Wave> with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<List<Offset>> waves;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: false);
    waves = controller.drive(WaveTween(100, 20));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: WaveClipper(waves),
      child: widget.child,
    );
  }
}

class WaveTween extends Animatable<List<Offset>> {
  WaveTween(this.count, this.height);

  final int count;
  final double height;
  static const twoPi = math.pi * 2;
  static const waveCount = 3;

  @override
  List<Offset> transform(double t) {
    return List<Offset>.generate(
      count,
      (i) {
        final ratio = i / (count - 1);
        final amplitude = 1 - (0.5 - ratio).abs() * 2;
        return Offset(
          ratio,
          amplitude * height * math.sin(waveCount * (ratio + t) * twoPi) +
              height * amplitude,
        );
      },
      growable: false,
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  WaveClipper(this.waves) : super(reclip: waves);

  Animation<List<Offset>> waves;

  @override
  Path getClip(Size size) {
    final width = size.width;
    final points = waves.value.map((o) => Offset(o.dx * width, o.dy)).toList();
    return Path()
      ..addPolygon(points, false)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(WaveClipper oldClipper) => false;
}

class DifferenceMask extends StatelessWidget {
  const DifferenceMask({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(
      painter: DifferencePainter(),
    );
  }
}

class DifferencePainter extends CustomPainter {
  const DifferencePainter() : super();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(DifferencePainter oldDelegate) => false;
}
