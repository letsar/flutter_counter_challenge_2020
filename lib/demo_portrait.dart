// Credits to https://www.openprocessing.org/sketch/392202/

import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'common.dart';

class DemoPortrait extends StatefulWidget {
  const DemoPortrait({
    Key key,
  }) : super(key: key);

  @override
  _DemoPortraitState createState() => _DemoPortraitState();
}

class _DemoPortraitState extends State<DemoPortrait> {
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
        title: const Text('Painter'),
      ),
      body: Stack(
        fit: StackFit.expand,
        alignment: Alignment.topCenter,
        children: [
          Portrait(assetName: 'assets/tim_sneath.jpg', counter: _counter),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 100,
            child: CounterText(counter: _counter),
          ),
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

class Portrait extends StatefulWidget {
  const Portrait({
    Key key,
    @required this.assetName,
    @required this.counter,
  }) : super(key: key);

  final String assetName;
  final int counter;

  @override
  _PortraitState createState() => _PortraitState();
}

class _PortraitState extends State<Portrait> {
  final Random random = Random();
  ui.Image image;
  ByteData byteData;

  @override
  void initState() {
    super.initState();
    loadPixels();
  }

  @override
  void dispose() {
    image?.dispose();
    super.dispose();
  }

  Future<void> loadPixels() async {
    image?.dispose();
    final provider = ExactAssetImage(widget.assetName);
    final imageStream = provider.resolve(ImageConfiguration.empty);
    final completer = Completer<ui.Image>();
    ImageStreamListener imageStreamListener;
    imageStreamListener = ImageStreamListener((frame, _) {
      completer.complete(frame.image);
      imageStream.removeListener(imageStreamListener);
    });
    imageStream.addListener(imageStreamListener);
    image = await completer.future;
    byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final child = image == null
        ? const SizedBox.expand()
        : Stack(
            fit: StackFit.expand,
            children: [
              for (var i = 0; i < widget.counter; i++)
                PortaitPaint(
                  imgWidth: image.width,
                  imgHeight: image.height,
                  byteData: byteData,
                  random: random,
                  counter: i,
                ),
            ],
          );
    return Positioned.fill(child: child);
  }
}

class PortaitPaint extends StatelessWidget {
  const PortaitPaint({
    Key key,
    @required this.imgWidth,
    @required this.imgHeight,
    @required this.byteData,
    @required this.random,
    @required this.counter,
  }) : super(key: key);

  final int imgWidth;
  final int imgHeight;
  final ByteData byteData;
  final Random random;
  final int counter;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: PortraitPainter(
          imgWidth,
          imgHeight,
          byteData,
          random,
          counter,
        ),
      ),
    );
  }
}

class PortraitPainter extends CustomPainter {
  PortraitPainter(
    this.imgWidth,
    this.imgHeight,
    ByteData byteData,
    this.random,
    this.counter,
  ) : pixels = Pixels(byteData: byteData, width: imgWidth, height: imgHeight);

  final int imgWidth;
  final int imgHeight;
  final Random random;
  final int counter;
  final Pixels pixels;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final tdx = (width - imgWidth) / 2;
    final tdy = (height - imgHeight) / 2;

    void curve(
      double x1,
      double y1,
      double x2,
      double y2,
      double x3,
      double y3,
      double x4,
      double y4,
      double thickness,
      Color color,
    ) {
      final vertices = [
        Offset(x1, y1),
        Offset(x2, y2),
        Offset(x3, y3),
        Offset(x4, y4),
      ];
      final path = Path();
      path.moveTo(x2, y2);
      for (int i = 1; i + 2 < vertices.length; i++) {
        final v = vertices[i];
        final b = List<Offset>.filled(4, Offset.zero);
        b[0] = v;
        b[1] = v + (vertices[i + 1] - vertices[i - 1]) / 6;
        b[2] = vertices[i + 1] + (v - vertices[i + 2]) / 6;
        b[3] = vertices[i + 1];
        path.cubicTo(b[1].dx, b[1].dy, b[2].dx, b[2].dy, b[3].dx, b[3].dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = thickness
          ..color = color,
      );
    }

    void paintStroke(double length, Color color, int thickness) {
      final stepLength = length / 4;

      // Determines if the stroke is curved. A straight line is 0.
      double tangent1 = 0;
      double tangent2 = 0;

      final odds = random.nextDouble();

      if (odds < 0.7) {
        tangent1 = random.d(-length, length);
        tangent2 = random.d(-length, length);
      }

      curve(
        tangent1,
        -stepLength * 2,
        0,
        -stepLength,
        0,
        stepLength,
        tangent2,
        stepLength * 2,
        thickness.toDouble(),
        color,
      );
    }

    for (var y = 0; y < imgHeight; y++) {
      for (var x = 0; x < imgWidth; x++) {
        final odds = random.d(0, 2000).toInt();

        if (odds < 1) {
          final color = pixels.getColorAt(x, y).withAlpha(100);
          final tx = x + tdx;
          final ty = y + tdy;
          canvas.translate(tx, ty);

          if (counter < 20) {
            paintStroke(random.d(150, 250), color, random.d(20, 40).toInt());
          } else if (counter < 50) {
            paintStroke(random.d(75, 125), color, random.d(8, 12).toInt());
          } else if (counter < 300) {
            paintStroke(random.d(30, 60), color, random.d(1, 4).toInt());
          } else if (counter < 500) {
            paintStroke(random.d(5, 20), color, random.d(5, 15).toInt());
          } else {
            paintStroke(random.d(1, 10), color, random.d(1, 7).toInt());
          }

          canvas.translate(-tx, -ty);
        }
      }
    }
  }

  @override
  bool shouldRepaint(PortraitPainter oldDelegate) {
    return false;
  }
}
