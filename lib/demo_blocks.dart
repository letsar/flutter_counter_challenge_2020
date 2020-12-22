import 'dart:math';

import 'package:flutter/material.dart';

import 'common.dart';

class DemoBlocks extends StatefulWidget {
  const DemoBlocks({Key key}) : super(key: key);

  @override
  _DemoBlocksState createState() => _DemoBlocksState();
}

class _DemoBlocksState extends State<DemoBlocks> {
  static const blockCount = 5;
  final Random random = Random();
  final List<Offset> indices = <Offset>[];
  final List<int> lastIndices = List<int>.filled(blockCount, blockCount);

  void _incrementCounter() {
    final dx = random.nextInt(blockCount);
    final dy = (lastIndices[dx] - 1) % blockCount;
    lastIndices[dx] = dy;
    setState(() {
      indices.add(Offset(dx.toDouble(), dy.toDouble()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blocks'),
      ),
      body: LayoutBuilder(
        builder: (_, constraints) {
          final blockSize = Size(
            constraints.maxWidth / blockCount,
            constraints.maxHeight / blockCount,
          );

          return Stack(
            children: [
              for (int i = 0; i < indices.length; i++)
                Positioned.fill(
                  child: Block(
                    blockSize: blockSize,
                    endOffset: Offset(
                      indices[i].dx * blockSize.width,
                      indices[i].dy * blockSize.height,
                    ),
                  ),
                ),
              CounterText(counter: indices.length),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class Block extends StatefulWidget {
  const Block({
    Key key,
    this.blockSize,
    this.endOffset,
  }) : super(key: key);

  final Size blockSize;
  final Offset endOffset;

  @override
  _BlockState createState() => _BlockState();
}

class _BlockState extends State<Block> with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<Offset> offset;

  @override
  void initState() {
    super.initState();

    final endOffset = widget.endOffset;
    final blockHeight = widget.blockSize.height;
    final distance = blockHeight + endOffset.dy;
    final duration = (distance * 2).toInt();

    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: duration),
    )..forward();

    offset = controller.drive(
      Tween<Offset>(
        begin: Offset(endOffset.dx, -blockHeight),
        end: endOffset,
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BlockPainter(
        offset,
        widget.blockSize,
      ),
    );
  }
}

class BlockPainter extends CustomPainter {
  BlockPainter(
    this.offset,
    this.blockSize,
  ) : super(repaint: offset);

  final Animation<Offset> offset;
  final Size blockSize;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      offset.value & blockSize,
      Paint()
        ..color = Colors.white
        ..blendMode = BlendMode.difference,
    );
  }

  @override
  bool shouldRepaint(BlockPainter oldDelegate) => false;
}
