import 'package:flutter/material.dart';
import '../models/academic_performance.dart';

class CorrelationChart extends StatelessWidget {
  final PerformanceCorrelation correlation;
  final Color color;

  const CorrelationChart({
    super.key,
    required this.correlation,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (correlation.dataPoints.isEmpty) {
      return const Center(child: Text('No data available for visualization'));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trend Visualization',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(height: 200, child: _buildScatterPlot()),
            const SizedBox(height: 12),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildScatterPlot() {
    // Simple scatter plot representation
    final points = correlation.dataPoints.take(10).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Grid background
            CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: GridPainter(color: color),
            ),
            // Data points
            ...points.asMap().entries.map((entry) {
              final index = entry.key;

              // Normalize values to fit in the chart
              final x = (index / points.length) * constraints.maxWidth;
              final y = constraints.maxHeight * 0.8; // Placeholder positioning

              return Positioned(
                left: x - 4,
                top: y - 4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }).toList(),
            // Trend line indicator
            if (correlation.correlationCoefficient.abs() > 0.2)
              CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: TrendLinePainter(
                  isPositive: correlation.isPositive,
                  color: color,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          'Data Points (${correlation.dataPoints.length} total)',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        if (correlation.correlationCoefficient.abs() > 0.2) ...[
          const SizedBox(width: 16),
          Container(width: 20, height: 2, color: color),
          const SizedBox(width: 8),
          Text(
            'Trend Line',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ],
    );
  }
}

class GridPainter extends CustomPainter {
  final Color color;

  GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 0.5;

    // Draw horizontal grid lines
    for (var i = 0; i <= 4; i++) {
      final y = (size.height / 4) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw vertical grid lines
    for (var i = 0; i <= 4; i++) {
      final x = (size.width / 4) * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TrendLinePainter extends CustomPainter {
  final bool isPositive;
  final Color color;

  TrendLinePainter({required this.isPositive, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final startX = size.width * 0.1;
    final endX = size.width * 0.9;

    final startY = isPositive ? size.height * 0.8 : size.height * 0.2;
    final endY = isPositive ? size.height * 0.2 : size.height * 0.8;

    canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
