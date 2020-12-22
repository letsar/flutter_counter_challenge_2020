import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CounterText extends StatelessWidget {
  const CounterText({
    Key key,
    @required this.counter,
  }) : super(key: key);

  final int counter;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'You have pushed the button this many times:',
            style: Theme.of(context).textTheme.bodyText1.copyWith(
                  foreground: Paint()
                    ..blendMode = BlendMode.difference
                    ..color = Colors.white,
                ),
          ),
          Text(
            '$counter',
            style: Theme.of(context).textTheme.headline2.copyWith(
                  // Comment on web.
                  foreground: Paint()
                    ..blendMode = BlendMode.difference
                    ..color = Colors.white,
                ),
          ),
        ],
      ),
    );
  }
}

double map(double x, double minIn, double maxIn, double minOut, double maxOut) {
  return (x - minIn) * (maxOut - minOut) / (maxIn - minIn) + minOut;
}

final Random _random = Random();

double randNextD(double max) => _random.nextDouble() * max;
int randNextI(int max) => _random.nextInt(max);
double randD(double min, double max) => _random.d(min, max);
int randI(int min, int max) => _random.i(min, max);

extension RandomExtension on Random {
  double d(double min, double max) {
    return nextDouble() * (max - min) + min;
  }

  int i(int min, int max) {
    return nextInt(max - min) + min;
  }
}

class Pixels {
  const Pixels({
    @required this.byteData,
    @required this.width,
    @required this.height,
  });

  final ByteData byteData;
  final int width;
  final int height;

  Color getColorAt(int x, int y) {
    final offset = 4 * (x + y * width);
    final rgba = byteData.getUint32(offset);
    final a = rgba & 0xFF;
    final rgb = rgba >> 8;
    final argb = (a << 24) + rgb;
    return Color(argb);
  }
}
