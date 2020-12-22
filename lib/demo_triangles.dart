// Credits to Richard Adams: https://github.com/RichardCubed/flutter_demo_3d
import 'dart:math';

import 'package:flutter/material.dart' hide Matrix4;
import 'package:flutter/rendering.dart' hide Matrix4;
import 'package:flutter/services.dart' show rootBundle;
import 'package:vector_math/vector_math.dart' hide Colors;

class DemoTriangles extends StatefulWidget {
  const DemoTriangles({Key key}) : super(key: key);

  @override
  _DemoTrianglesState createState() => _DemoTrianglesState();
}

class _DemoTrianglesState extends State<DemoTriangles>
    with TickerProviderStateMixin {
  final Random random = Random();
  final List<int> availableIndices = List.generate(768, (index) => index);
  List<AnimationController> visibleFaces;
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    visibleFaces = List.generate(
      768,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    visibleFaces.forEach((x) {
      x.dispose();
    });
    super.dispose();
  }

  void _incrementCounter() {
    if (availableIndices.isNotEmpty) {
      visibleFaces[availableIndices
              .removeAt(random.nextInt(availableIndices.length))]
          .forward();
    }
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final counterWidget = Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Triangles'),
      ),
      body: Stack(
        children: [
          counterWidget,
          ScratchDetector(
            fallbackChild: counterWidget,
            child: Brain(visibleFaces: visibleFaces, counter: _counter),
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

class Brain extends StatefulWidget {
  const Brain({
    Key key,
    @required this.visibleFaces,
    @required this.counter,
  }) : super(key: key);

  final List<Animation<double>> visibleFaces;
  final int counter;

  @override
  _BrainState createState() => _BrainState();
}

class _BrainState extends State<Brain> with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> rotationY;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    rotationY = controller.drive(Tween(begin: 0, end: 360));
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Object3D(
            path: 'assets/brain.obj',
            zoom: 30,
            rotationY: rotationY,
            visibleFaces: widget.visibleFaces,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'You have pushed the button this many times:',
                style: Theme.of(context).textTheme.bodyText1.copyWith(
                    foreground: Paint()
                      ..blendMode = BlendMode.exclusion
                      ..color = Colors.white),
              ),
              Text(
                '${widget.counter}',
                style: Theme.of(context).textTheme.headline4.copyWith(
                    foreground: Paint()
                      ..blendMode = BlendMode.exclusion
                      ..color = Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Object3D extends StatefulWidget {
  const Object3D({
    Key key,
    @required this.path,
    @required this.zoom,
    @required this.rotationY,
    @required this.visibleFaces,
  }) : super(key: key);

  final String path;
  final double zoom;
  final Animation<double> rotationY;
  final List<Animation<double>> visibleFaces;

  @override
  _Object3DState createState() => _Object3DState();
}

class _Object3DState extends State<Object3D> {
  double angleX = 0;
  double angleZ = 0;
  double zoom = 0;

  Model model;

  @override
  void initState() {
    super.initState();
    rootBundle.loadString(widget.path).then((value) {
      setState(() {
        model = Model();
        model.loadFromString(value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ObjectPainter(
        model,
        angleX,
        widget.rotationY,
        angleZ,
        widget.zoom,
        widget.visibleFaces,
      ),
    );
  }
}

/*
 *  To render our 3D model we'll need to implement the CustomPainter interface and
 *  handle drawing to the canvas ourselves.
 *  https://api.flutter.dev/flutter/rendering/CustomPainter-class.html
 */
class _ObjectPainter extends CustomPainter {
  _ObjectPainter(
    this.model,
    this.angleX,
    this.angleY,
    this.angleZ,
    this._zoom,
    this.visibleFaces,
  )   : camera = Vector3.zero(),
        light = Vector3(0, 0, 100),
        vertices = <Vector3>[],
        super(repaint: angleY);

  double _viewPortX;
  double _viewPortY;
  final double _zoom;

  final List<Vector3> vertices;
  final Model model;
  final Vector3 camera;
  final Vector3 light;

  final double angleX;
  final Animation<double> angleY;
  final double angleZ;
  final List<Animation<double>> visibleFaces;

  Vector3 _calcVertex(Vector3 vertex) {
    final trans = Matrix4.translationValues(_viewPortX, _viewPortY, 1);
    trans.scale(_zoom, -_zoom);
    trans.rotateX(degreeToRadian(angleX));
    trans.rotateY(degreeToRadian(angleY.value));
    trans.rotateZ(degreeToRadian(angleZ));
    return trans.transform3(vertex);
  }

  void _drawFace(Canvas canvas, List<int> face, Color color) {
    // Reference the rotated vertices
    final v1 = vertices[face[0] - 1];
    final v2 = vertices[face[1] - 1];
    final v3 = vertices[face[2] - 1];

    // Calculate the surface normal
    final normalVector = normalVector3(v1, v2, v3);

    // Calculate the lighting
    final normalizedLight = Vector3.copy(light).normalized();
    final jnv = Vector3.copy(normalVector).normalized();
    final normal = scalarMultiplication(jnv, normalizedLight);
    final brightness = normal.clamp(0.0, 1.0);

    // Assign a lighting color
    final r = (brightness * color.red).toInt();
    final g = (brightness * color.green).toInt();
    final b = (brightness * color.blue).toInt();

    final paint = Paint();
    paint.color = Color.fromARGB(color.alpha, r, g, b);
    paint.style = PaintingStyle.fill;

    // Paint the face
    final path = Path();
    path.moveTo(v1.x, v1.y);
    path.lineTo(v2.x, v2.y);
    path.lineTo(v3.x, v3.y);
    path.lineTo(v1.x, v1.y);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // If we've not loaded the model then there's nothing to render
    if (model == null) {
      return;
    }

    _viewPortX ??= size.width / 2;
    _viewPortY ??= size.height / 2;

    // Rotate and translate the vertices
    vertices.clear();
    for (int i = 0; i < model.vertices.length; i++) {
      vertices.add(_calcVertex(Vector3.copy(model.vertices[i])));
    }

    // Sort
    final sorted = <Order>[];
    for (int i = 0; i < model.faces.length; i++) {
      final face = model.faces[i];
      sorted.add(Order(
        index: i,
        order: zIndex(
          vertices[face[0] - 1],
          vertices[face[1] - 1],
          vertices[face[2] - 1],
        ),
      ));
    }
    sorted.sort((Order a, Order b) => a.order.compareTo(b.order));

    // Render
    for (int i = 0; i < sorted.length; i++) {
      final index = sorted[i].index;
      final face = model.faces[index];
      final opacity = visibleFaces[index].value;
      final color = model.colors[index].withOpacity(opacity);
      _drawFace(canvas, face, color);
    }
  }

  @override
  bool shouldRepaint(_ObjectPainter old) {
    return true;
  }
}

class Order {
  const Order({
    @required this.index,
    @required this.order,
  });
  final int index;
  final double order;
}

class Model {
  final List<Vector3> vertices = <Vector3>[];
  final List<List<int>> faces = <List<int>>[];
  final List<Color> colors = <Color>[];
  final Map<String, Color> materials = <String, Color>{
    'frontal': const Color(0xffffba08),
    'occipital': const Color(0xfffaa307),
    'parietal': const Color(0xfff48c06),
    'temporal': const Color(0xffe85d04),
    'cerebellum': const Color(0xffdc2f02),
    'stem': const Color(0xffd00000),
  };

  void loadFromString(String string) {
    String material;
    final List<String> lines = string.split('\n');
    lines.forEach((line) {
      // Parse a vertex
      if (line.startsWith('v ')) {
        final values = line.substring(2).split(' ');
        vertices.add(Vector3(
          double.parse(values[0]),
          double.parse(values[1]),
          double.parse(values[2]),
        ));
      }
      // Parse a material reference
      else if (line.startsWith('usemtl ')) {
        material = line.substring(7);
      }
      // Parse a face
      else if (line.startsWith('f ')) {
        final values = line.substring(2).split(' ');
        faces.add(List.from(<int>[
          int.parse(values[0].split('/')[0]),
          int.parse(values[1].split('/')[0]),
          int.parse(values[2].split('/')[0]),
        ]));
        colors.add(materials[material]);
      }
    });
  }
}

Vector3 normalVector3(Vector3 v1, Vector3 v2, Vector3 v3) {
  final s1 = Vector3.copy(v2);
  s1.sub(v1);
  final s3 = Vector3.copy(v2);
  s3.sub(v3);

  return Vector3(
    (s1.y * s3.z) - (s1.z * s3.y),
    (s1.z * s3.x) - (s1.x * s3.z),
    (s1.x * s3.y) - (s1.y * s3.x),
  );
}

double scalarMultiplication(Vector3 v1, Vector3 v2) {
  return (v1.x * v2.x) + (v1.y * v2.y) + (v1.z * v2.z);
}

double degreeToRadian(double degree) {
  return degree * (pi / 180.0);
}

double zIndex(Vector3 p1, Vector3 p2, Vector3 p3) {
  return (p1.z + p2.z + p3.z) / 3;
}

class ScratchDetector extends StatefulWidget {
  const ScratchDetector({
    Key key,
    @required this.child,
    @required this.fallbackChild,
  }) : super(key: key);

  final Widget child;
  final Widget fallbackChild;

  @override
  _ScratchDetectorState createState() => _ScratchDetectorState();
}

class _ScratchDetectorState extends State<ScratchDetector> {
  final List<Offset> points = <Offset>[];

  void addPoint(Offset point) {
    setState(() {
      points.add(point);
    });
  }

  @override
  Widget build(BuildContext context) {
    final child = points.isEmpty
        ? widget.fallbackChild
        : ClipPath(
            clipper: ScratchClipper(points),
            child: widget.child,
          );

    return Positioned.fill(
      child: GestureDetector(
        onPanStart: (details) => addPoint(details.localPosition),
        onPanUpdate: (details) => addPoint(details.localPosition),
        child: child,
      ),
    );
  }
}

class ScratchClipper extends CustomClipper<Path> {
  ScratchClipper(this.points);
  final List<Offset> points;

  @override
  Path getClip(Size size) {
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      path.addOval(Rect.fromCircle(center: points[i], radius: 20));
    }
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
