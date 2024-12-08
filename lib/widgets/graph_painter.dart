import 'package:flutter/material.dart';
import '../models/graph_node.dart';

class GraphPainter extends CustomPainter {
  final GraphNode node;

  GraphPainter({required this.node});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint circlePaint = Paint()
      ..color = const Color(0xFF3641AD)
      ..style = PaintingStyle.fill;

    final Paint linePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0;

    // Adjust Parent Unit position to make edge vertical
    final Offset parentCenter = Offset(size.width / 2, 100); // Shifted left
    final Offset fatherCenter = Offset(parentCenter.dx - 50, parentCenter.dy);
    final Offset motherCenter = Offset(parentCenter.dx + 50, parentCenter.dy);

    // Draw Parent Unit
    canvas.drawCircle(fatherCenter, 20, circlePaint);
    canvas.drawCircle(motherCenter, 20, circlePaint);
    canvas.drawLine(fatherCenter, motherCenter, linePaint);

    _drawLabel(canvas, node.fatherName ?? 'N/A', fatherCenter);
    _drawLabel(canvas, node.motherName ?? 'N/A', motherCenter);

    // Draw Primary Unit (NodeName and SpouseName)
    final Offset primaryNodeCenter = Offset(parentCenter.dx + 50, parentCenter.dy + 100);
    final Offset nodeCenter = Offset(primaryNodeCenter.dx - 50, primaryNodeCenter.dy);
    final Offset spouseCenter = Offset(primaryNodeCenter.dx + 50, primaryNodeCenter.dy);

    canvas.drawCircle(nodeCenter, 20, circlePaint);
    canvas.drawCircle(spouseCenter, 20, circlePaint);
    canvas.drawLine(nodeCenter, spouseCenter, linePaint);

    _drawLabel(canvas, node.nodeName, nodeCenter);
    _drawLabel(canvas, node.spouseName ?? 'N/A', spouseCenter);

    // Connection from Parent Unit to Primary Unit (ends on top of NodeName node)
    final Offset verticalStartToPrimary = parentCenter;
    final Offset verticalEndToNodeName = Offset(nodeCenter.dx, nodeCenter.dy - 20);
    canvas.drawLine(verticalStartToPrimary, verticalEndToNodeName, linePaint);

    // Children Nodes
    final double childY = primaryNodeCenter.dy + 100;
    final double childSpacing = 100.0;

    for (int i = 0; i < node.children.length; i++) {
      final double childX = primaryNodeCenter.dx - ((node.children.length - 1) * childSpacing / 2) + (i * childSpacing);
      final Offset childCenter = Offset(childX, childY);

      canvas.drawCircle(childCenter, 20, circlePaint);
      _drawLabel(canvas, node.children[i], childCenter);

      // Stepwise connection to children
      final Offset verticalStart = primaryNodeCenter;
      final Offset verticalEnd = Offset(primaryNodeCenter.dx, primaryNodeCenter.dy + 40);
      final Offset horizontalEnd = Offset(childX, verticalEnd.dy);
      final Offset finalVerticalEnd = Offset(childX, childY - 20);

      canvas.drawLine(verticalStart, verticalEnd, linePaint); // Vertical segment
      canvas.drawLine(verticalEnd, horizontalEnd, linePaint); // Horizontal segment
      canvas.drawLine(horizontalEnd, finalVerticalEnd, linePaint); // Final vertical segment
    }
  }

  void _drawLabel(Canvas canvas, String label, Offset center) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(color: Colors.white, fontSize: 14),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(minWidth: 0, maxWidth: 100);
    textPainter.paint(canvas, Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
