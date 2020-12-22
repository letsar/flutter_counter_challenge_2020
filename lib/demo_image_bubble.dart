import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'common.dart';

class DemoImageBubble extends StatefulWidget {
  const DemoImageBubble({Key key}) : super(key: key);

  @override
  _DemoImageBubbleState createState() => _DemoImageBubbleState();
}

class _DemoImageBubbleState extends State<DemoImageBubble>
    with TickerProviderStateMixin {
  final Random random = Random();
  final List<ImageBubble> bubbles = <ImageBubble>[];

  void _incrementCounter() {
    setState(() {
      bubbles.add(ImageBubble(
        center: Offset(random.nextDouble(), random.nextDouble()),
        radius: (random.nextInt(50) + 20).toDouble(),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image bubble'),
      ),
      body: Stack(
        children: [
          ...bubbles,
          CounterText(counter: bubbles.length),
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

class ImageBubble extends StatefulWidget {
  const ImageBubble({
    Key key,
    @required this.center,
    @required this.radius,
  }) : super(key: key);

  final Offset center;
  final double radius;

  @override
  _ImageBubbleState createState() => _ImageBubbleState();
}

class _ImageBubbleState extends State<ImageBubble>
    with TickerProviderStateMixin {
  AnimationController centerController;
  AnimationController radiusController;
  Animation<Offset> center;
  Animation<double> radius;

  @override
  void initState() {
    super.initState();
    centerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    center = centerController.drive(RotationTween(widget.center, 0.01));
    radiusController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    radius = radiusController
        .drive(CurveTween(curve: Curves.ease))
        .drive(Tween(begin: 0, end: widget.radius));
  }

  @override
  void dispose() {
    centerController.dispose();
    radiusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: AnimatedBuilder(
        animation: center,
        builder: (_, child) {
          return CustomPaint(
            painter: ImageBubbleShadowPainter(center.value, radius.value),
            child: ClipOval(
              clipper: ImageBubbleClipper(center.value, radius.value),
              clipBehavior: Clip.hardEdge,
              child: CustomPaint(
                  foregroundPainter: ImageBubblePainter(
                    center.value,
                    radius.value,
                  ),
                  child: child),
            ),
          );
        },
        child: Image.asset(
          'assets/dash.jpg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class RotationTween extends Animatable<Offset> {
  const RotationTween(this.center, this.distance);

  final Offset center;
  final double distance;

  @override
  Offset transform(double t) {
    final direction = t * pi * 2;
    return Offset.fromDirection(direction, distance) + center;
  }
}

class ImageBubbleClipper extends CustomClipper<Rect> {
  const ImageBubbleClipper(this.center, this.radius);

  final Offset center;
  final double radius;

  @override
  Rect getClip(Size size) {
    final effectiveCenter =
        Offset(center.dx * size.width, center.dy * size.height);
    return Rect.fromCircle(center: effectiveCenter, radius: radius);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return true;
  }
}

class ImageBubbleShadowPainter extends CustomPainter {
  ImageBubbleShadowPainter(this.center, this.radius);
  final Offset center;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final effectiveCenter =
        Offset(center.dx * size.width, center.dy * size.height);
    final rect = Rect.fromCircle(center: effectiveCenter, radius: radius);

    const boxShadow = BoxShadow(
        blurRadius: 4, offset: Offset(2, 2), color: Color(0x80000000));
    final Paint paint = boxShadow.toPaint();
    final Rect bounds =
        rect.shift(boxShadow.offset).inflate(boxShadow.spreadRadius);

    canvas.drawCircle(
      bounds.center,
      bounds.shortestSide / 2.0,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class ImageBubblePainter extends CustomPainter {
  ImageBubblePainter(this.center, this.radius);
  final Offset center;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final effectiveCenter =
        Offset(center.dx * size.width, center.dy * size.height);
    final rect = Rect.fromCircle(center: effectiveCenter, radius: radius);

    canvas.drawCircle(
      effectiveCenter,
      radius,
      Paint()
        ..blendMode = BlendMode.overlay
        ..shader = const LinearGradient(colors: [Colors.black, Colors.white])
            .createShader(rect),
    );
    canvas.drawCircle(
      rect.topLeft + (rect.center - rect.topLeft) / 2,
      rect.longestSide / 6,
      Paint()
        ..color = const Color(0xCCFFFFFF)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          rect.longestSide * 0.1,
        ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
