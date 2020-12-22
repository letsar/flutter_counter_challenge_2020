// Icons made by <a href="https://www.flaticon.com/authors/freepik" title="Freepik">Freepik</a> from <a href="https://www.flaticon.com/" title="Flaticon"> www.flaticon.com</a>
// https://www.flaticon.com/free-icon/volcano_1497529import

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'common.dart';

class DemoVolcano extends StatefulWidget {
  const DemoVolcano({
    Key key,
  }) : super(key: key);

  @override
  _DemoVolcanoState createState() => _DemoVolcanoState();
}

class _DemoVolcanoState extends State<DemoVolcano>
    with TickerProviderStateMixin {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Volcano')),
      backgroundColor: const Color(0xFF2DB2FF),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Sky(),
          for (int i = 0; i < _counter; i++) Eruption(count: i + 1),
          Volcano(onTap: _incrementCounter),
          const Grass(),
          Counter(count: _counter),
        ],
      ),
    );
  }
}

class LavaParticle {
  LavaParticle({
    this.mass,
    this.initialVelocity,
    this.initialPosition,
  });

  final double mass;
  final Offset initialVelocity;
  final Offset initialPosition;
  Offset velocity;
  Offset position;
}

class Eruption extends StatefulWidget {
  const Eruption({
    Key key,
    this.count,
  }) : super(key: key);

  final int count;

  @override
  _EruptionState createState() => _EruptionState();
}

class _EruptionState extends State<Eruption>
    with SingleTickerProviderStateMixin {
  final math.Random random = math.Random();
  final List<LavaParticle> particles = <LavaParticle>[];
  AnimationController controller;

  @override
  void initState() {
    super.initState();

    for (var i = 0; i < widget.count; i++) {
      final mass = map(random.nextDouble(), 0, 1, 3, 6);
      final velocityX = map(random.nextDouble(), 0, 1, -10, 10);
      final velocityY = map(random.nextDouble(), 0, 1, -200, -50);
      final positionX = map(random.nextDouble(), 0, 1, 0.4, 0.6);
      particles.add(
        LavaParticle(
          mass: mass,
          initialVelocity: Offset(velocityX, velocityY),
          initialPosition: Offset(positionX, 0.6),
        ),
      );
    }

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: EruptionPainter(
          controller,
          particles,
        ),
      ),
    );
  }
}

class EruptionPainter extends CustomPainter {
  EruptionPainter(this.animation, this.particles)
      : random = math.Random(),
        super(repaint: animation);

  final Animation<double> animation;
  final List<LavaParticle> particles;
  final math.Random random;
  double dt = 0.1;
  static final colorTween = ColorTween(
    begin: const Color(0xFFDB4B38),
    end: const Color(0xFF732F13),
  );

  @override
  void paint(Canvas canvas, Size size) {
    final opacity = 1 - animation.value;
    final count = particles.length;
    final color = colorTween.transform(animation.value);

    for (int i = 0; i < count; i++) {
      final particle = particles[i];
      final radius = particle.mass * 3;

      if (particle.position == null || opacity == 1) {
        final position = particle.initialPosition;
        particle.position = Offset(
          position.dx * size.width,
          position.dy * size.height,
        );
        particle.velocity = Offset(
          particle.initialVelocity.dx,
          particle.initialVelocity.dy,
        );
      }

      final Offset force = Offset(0, particle.mass * 9.81);
      final Offset acceleration = force / particle.mass;
      particle.velocity += acceleration * dt;
      particle.position += particle.velocity * dt;
      canvas.drawCircle(
        particle.position,
        radius,
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class Counter extends StatelessWidget {
  const Counter({
    Key key,
    this.count,
  }) : super(key: key);

  final int count;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      left: 0,
      right: 0,
      child: Text(
        '$count',
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .headline1
            .copyWith(foreground: Paint()..color = Colors.white),
      ),
    );
  }
}

class Sky extends StatefulWidget {
  const Sky({
    Key key,
  }) : super(key: key);

  @override
  _SkyState createState() => _SkyState();
}

class _SkyState extends State<Sky> with TickerProviderStateMixin {
  AnimationController skyController;
  AnimationController sunController;
  Animation<double> sunAnimation;
  Animation<Color> skyAnimation;

  @override
  void initState() {
    super.initState();
    skyController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat(reverse: true);
    sunController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 80),
    )..repeat();
    skyAnimation = skyController.drive(ColorTween(
      begin: Colors.blue,
      end: Colors.blueGrey.shade900,
    ));
    sunAnimation = sunController.drive(Tween(
      begin: 3 * math.pi / 2,
      end: 7 * math.pi / 2,
    ));
  }

  @override
  void dispose() {
    skyController.dispose();
    sunController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: SkyPainter(skyAnimation, sunAnimation),
      ),
    );
  }
}

class SkyPainter extends CustomPainter {
  const SkyPainter(this.skyAnimation, this.sunAnimation)
      : super(repaint: skyAnimation);

  final Animation<Color> skyAnimation;
  final Animation<double> sunAnimation;

  static const sunColor = Color(0xFFFFC471);
  static const moonColor = Color(0xFFFFFFFF);
  static const sunRadius = 100.0;
  static const moonRadius = 75.0;

  @override
  void paint(Canvas canvas, Size size) {
    // Sky color.
    canvas.drawColor(skyAnimation.value, BlendMode.src);

    final halfWidth = size.width / 2;
    final distance = 2 / 4 * size.height;

    // Sun.
    final sunCenter = Offset.fromDirection(
          sunAnimation.value,
          distance,
        ) +
        Offset(halfWidth, size.height);
    canvas.drawCircle(
      sunCenter,
      sunRadius,
      Paint()
        ..color = sunColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 50),
    );

    // Moon.
    final moonCenter = Offset.fromDirection(
          sunAnimation.value + math.pi,
          distance,
        ) +
        Offset(halfWidth, size.height);

    canvas.drawCircle(
      moonCenter,
      moonRadius,
      Paint()
        ..color = moonColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 50),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class Volcano extends StatelessWidget {
  const Volcano({
    Key key,
    @required this.onTap,
  }) : super(key: key);

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: onTap,
        child: Image.asset('assets/volcano.png'),
      ),
    );
  }
}

class Grass extends StatelessWidget {
  const Grass({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: 50,
      child: CustomPaint(painter: GrassPainter()),
    );
  }
}

class GrassPainter extends CustomPainter {
  const GrassPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF00B673);
    final width = size.width;
    final height = size.height;
    final halfHeight = height / 2;

    canvas.drawRect(
      Offset(0, halfHeight) & Size(size.width, halfHeight),
      paint,
    );
    canvas.drawCircle(Offset(0, height), 50, paint);
    canvas.drawCircle(Offset(width * 0.3, halfHeight), 40, paint);
    canvas.drawCircle(Offset(width * 0.4, halfHeight), 20, paint);
    canvas.drawCircle(Offset(width * 0.7, height), 70, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
