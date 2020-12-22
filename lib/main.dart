import 'package:flutter/material.dart';

import 'demo_blocks.dart';
import 'demo_circle_wave.dart';
import 'demo_creature.dart';
import 'demo_disks.dart';
import 'demo_image_bubble.dart';
import 'demo_mattis.dart';
import 'demo_particles.dart';
import 'demo_portrait.dart';
import 'demo_rotating_bubbles.dart';
import 'demo_rotating_planets.dart';
import 'demo_triangles.dart';
import 'demo_volcano.dart';
import 'demo_wave.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const Demos(),
    );
  }
}

class Demos extends StatelessWidget {
  const Demos({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter Apps'),
      ),
      body: ListView(
        children: [
          Tile(label: 'Blocks', builder: () => const DemoBlocks()),
          Tile(label: 'Disks', builder: () => const DemoDisks()),
          Tile(label: 'Wave', builder: () => const DemoWave()),
          Tile(label: 'Circle wave', builder: () => const DemoCircleWave()),
          Tile(label: 'Bubbles', builder: () => const DemoRotatingBubbles()),
          Tile(label: 'Planets', builder: () => const DemoRotatingPlanets()),
          Tile(label: 'Creature', builder: () => const DemoCreature()),
          Tile(label: 'Volcano', builder: () => const DemoVolcano()),
          Tile(label: 'ImageBubble', builder: () => const DemoImageBubble()),
          Tile(label: 'Triangles', builder: () => const DemoTriangles()),
          Tile(label: 'Mattis', builder: () => const DemoMattis()),
          Tile(label: 'Portrait', builder: () => const DemoPortrait()),
          Tile(label: 'Particles', builder: () => const DemoParticles()),
        ],
      ),
    );
  }
}

class Tile extends StatelessWidget {
  const Tile({
    Key key,
    this.label,
    this.builder,
  }) : super(key: key);

  final String label;
  final Widget Function() builder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: OutlinedButton(
        onPressed: () {
          Navigator.push<void>(
            context,
            MaterialPageRoute(builder: (_) => builder()),
          );
        },
        child: Text(label),
      ),
    );
  }
}
