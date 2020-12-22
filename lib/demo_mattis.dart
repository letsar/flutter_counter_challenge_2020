import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'common.dart';

class DemoMattis extends StatefulWidget {
  const DemoMattis({
    Key key,
  }) : super(key: key);

  @override
  _DemoMattisState createState() => _DemoMattisState();
}

class _DemoMattisState extends State<DemoMattis> {
  static const colors = <Color>[
    Color(0xFFFF2964),
    Color(0xFF32FF3A),
    Color(0xFF4255FF)
  ];
  Random random = Random();
  static const cols = 25;
  static const rows = 25;
  static const xUnit = 1 / cols;
  static const yUnit = 1 / rows;
  final List<int> indexes = List<int>.generate(cols * rows, (index) => index);
  final List<MattisBlock> blocks = <MattisBlock>[];
  final List<Balloon> balloons = <Balloon>[];

  void _incrementCounter() {
    if (indexes.isNotEmpty) {
      final index = indexes.removeAt(random.nextInt(indexes.length));
      final col = (index % cols) / cols;
      final row = (index ~/ rows) / rows;
      final x = col + xUnit / 2;
      final y = row + yUnit / 2;
      setState(() {
        blocks.add(MattisBlock(
          key: ValueKey(blocks.length),
          center: Offset(x, y),
          sizeRatio: const Size(xUnit, yUnit),
        ));
        balloons.add(
          Balloon(
            key: ValueKey(balloons.length),
            x: x,
            color: colors[random.nextInt(colors.length)],
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Happy Birthday'),
      ),
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          ...blocks,
          ...balloons,
          CounterText(counter: blocks.length),
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

class Balloon extends StatefulWidget {
  const Balloon({
    Key key,
    this.color,
    this.x,
  }) : super(key: key);

  final double x;
  final Color color;

  @override
  _BalloonState createState() => _BalloonState();
}

class _BalloonState extends State<Balloon> with SingleTickerProviderStateMixin {
  AnimationController yController;
  Animation<double> y;

  @override
  void initState() {
    super.initState();
    yController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();
    y = yController
        .drive(CurveTween(curve: Curves.ease))
        .drive(Tween(begin: 1, end: 0));
  }

  @override
  void dispose() {
    yController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        foregroundPainter: BalloonPainter(widget.x, y, widget.color),
      ),
    );
  }
}

class MattisBlock extends StatefulWidget {
  const MattisBlock({
    Key key,
    this.center,
    this.sizeRatio,
  }) : super(key: key);

  final Offset center;
  final Size sizeRatio;

  @override
  _MattisBlockState createState() => _MattisBlockState();
}

class _MattisBlockState extends State<MattisBlock>
    with SingleTickerProviderStateMixin {
  AnimationController scaleController;
  Animation<double> scale;

  @override
  void initState() {
    super.initState();
    scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
    scale = scaleController.drive(CurveTween(curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ClipPath(
        clipper: MattisClipper(scale, widget.center, widget.sizeRatio),
        child: Image.asset(
          'assets/mattis.jpeg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class MattisClipper extends CustomClipper<Path> {
  MattisClipper(this.scale, this.center, this.sizeRatio) : super(reclip: scale);

  final Animation<double> scale;
  final Offset center;
  final Size sizeRatio;

  @override
  Path getClip(Size size) {
    final width = sizeRatio.width * size.width * scale.value;
    final height = sizeRatio.height * size.height * scale.value;
    final rect = Rect.fromCenter(
      center: Offset(
        center.dx * size.width,
        center.dy * size.height,
      ),
      width: width,
      height: height,
    );
    return Path()..addRect(rect);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class BalloonPainter extends CustomPainter {
  BalloonPainter(this.x, this.y, this.color) : super(repaint: y);

  final double x;
  final Animation<double> y;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(
      Offset.zero & size,
      Paint()..blendMode = BlendMode.lighten,
    );
    final dx = x * size.width;
    final dy = map(y.value, 1, 0, size.height + 10, -85);
    final rect = Rect.fromCenter(
      center: Offset(dx, dy),
      width: 60,
      height: 75,
    );

    final bottom = rect.bottomCenter.dy;
    final points = [
      Offset(dx, bottom - 10),
      Offset(dx - 5, bottom + 10),
      Offset(dx + 5, bottom + 10),
    ];

    final path = Path()..addPolygon(points, true);
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(path, Paint()..color = const Color(0x33000000));

    canvas.drawOval(
      rect,
      Paint()
        ..color = color
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 5),
    );

    canvas.drawCircle(
      rect.topLeft + const Offset(20, 20),
      rect.longestSide / 6,
      Paint()
        ..color = const Color(0xCCFFFFFF)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          rect.longestSide * 0.1,
        ),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
