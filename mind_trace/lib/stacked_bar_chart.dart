import 'package:flutter/material.dart';

class StackedBarChart extends StatefulWidget {
  final Map<int, List<int>> data;
  final List<Color> colors;
  final double barWidth;
  final double maxHeight;
  final double maxWidth;
  final double barSpacing;
  final double borderRadius;
  final Color borderColor;
  final double borderWidth;
  final Function(String mood)? onTap;

  StackedBarChart({
    required this.data,
    required this.colors,
    required this.barWidth,
    required this.maxHeight,
    required this.maxWidth,
    required this.barSpacing,
    required this.borderRadius,
    required this.borderColor,
    required this.borderWidth,
    this.onTap,
  });

  @override
  _StackedBarChartState createState() => _StackedBarChartState();
}

class _StackedBarChartState extends State<StackedBarChart> {
  late List<List<Color?>> _blockBorderColors;
  int? _previousBlockIndex;
  int? _previousInnerBlockIndex;

  @override
  void initState() {
    super.initState();
    _initializeBlockBorderColors();
  }

  void _initializeBlockBorderColors() {
    _blockBorderColors = List.generate(widget.data.length, (index) {
      return List.generate(widget.data[index]!.length, (innerIndex) => null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        _handleTap(details, true);
      },
      onTapCancel: () {
        setState(() {
          _initializeBlockBorderColors();
          _previousBlockIndex = null;
          _previousInnerBlockIndex = null;
        });
      },
      child: Container( // Wrap CustomPaint with Container
        width: widget.maxWidth, // Set width
        height: widget.maxHeight, // Set height
        child: CustomPaint(
          painter: BarChartPainter(
            data: widget.data,
            colors: widget.colors,
            barWidth: widget.barWidth,
            barSpacing: widget.barSpacing,
            borderRadius: widget.borderRadius,
            borderColor: widget.borderColor,
            borderWidth: widget.borderWidth,
            blockBorderColors: _blockBorderColors,
            previousBlockIndex: _previousBlockIndex,
            previousInnerBlockIndex: _previousInnerBlockIndex,
          ),
        ),
      ),
    );
  }

  void _handleTap(TapDownDetails details, bool isPressed) {
    setState(() {
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final tapPosition = renderBox.globalToLocal(details.globalPosition);

      final totalBarsWidth = widget.data.length * widget.barWidth;
      final totalSpacing = (widget.data.length - 1) * widget.barSpacing;
      final totalWidth = totalBarsWidth + totalSpacing;
      final barStartPosition = (widget.maxWidth - totalWidth) / 2;

      final maxTotalMoodChanges = widget.data.values.map((e) => e.length).reduce((value, element) => value > element ? value : element);
      final blockHeight = widget.maxHeight / maxTotalMoodChanges;

      final blockIndex = ((tapPosition.dx - barStartPosition) / (widget.barWidth + widget.barSpacing)).floor();
      final innerBlockIndex = ((widget.maxHeight - tapPosition.dy) / blockHeight).floor();

      if (blockIndex >= 0 && blockIndex < widget.data.length && innerBlockIndex >= 0) {
        if (_previousBlockIndex != null && _previousInnerBlockIndex != null) {
          _blockBorderColors[_previousBlockIndex!][_previousInnerBlockIndex!] = null;
        }
        // Update blockBorderColors with new values based on tap
        _blockBorderColors[blockIndex][innerBlockIndex] = isPressed ? widget.colors[widget.data[blockIndex]![innerBlockIndex] - 1] : null;
        _previousBlockIndex = blockIndex;
        _previousInnerBlockIndex = innerBlockIndex;
        // Trigger onTap callback if provided
        if (widget.onTap != null) {
          final moodValue = widget.data[blockIndex]![innerBlockIndex];
          final mood = _getMood(moodValue);
          widget.onTap!(mood);
        }
      }
    });
  }

  String _getMood(int moodValue) {
    switch (moodValue) {
      case 1:
        return 'Low';
      case 2:
        return 'OK';
      case 3:
        return 'High';
      default:
        return 'Undefined';
    }
  }
}

class BarChartPainter extends CustomPainter {
  final Map<int, List<int>?> data;
  final List<Color> colors;
  final double barWidth;
  final double barSpacing;
  final double borderRadius;
  final Color borderColor;
  final double borderWidth;
  final List<List<Color?>> blockBorderColors;
  final int? previousBlockIndex;
  final int? previousInnerBlockIndex;

  BarChartPainter({
    required this.data,
    required this.colors,
    required this.barWidth,
    required this.barSpacing,
    required this.borderRadius,
    required this.borderColor,
    required this.borderWidth,
    required this.blockBorderColors,
    required this.previousBlockIndex,
    required this.previousInnerBlockIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final totalBarsWidth = data.length * barWidth;
    final totalSpacing = (data.length - 1) * barSpacing;
    final totalWidth = totalBarsWidth + totalSpacing;
    final barStartPosition = (size.width - totalWidth) / 2;

    double startX = barStartPosition;
    double startY = size.height;

    for (int day = 0; day < data.length; day++) {
      final moodChanges = data[day] ?? [];
      final totalMoodChanges = moodChanges.length;

      for (int i = 0; i < totalMoodChanges; i++) {
        final paint = Paint()
          ..color = getColor(moodChanges[i]);
        final borderPaint = Paint()
          ..style = PaintingStyle.stroke
          ..color = blockBorderColors[day][i] ?? borderColor
          ..strokeWidth = blockBorderColors[day][i] != null ? borderWidth * 3 : borderWidth;

        // if (day < blockBorderColors.length && i < blockBorderColors[day].length) {
        //   // If the value is not null, use it; otherwise, fallback to borderColor
        //   borderPaint.color = blockBorderColors[day][i] ?? borderColor;
        // } else {
        //   // Handle the case where the indices are out of range
        //   // or the value at the specified indices is null
        //   borderPaint.color = borderColor; // Fallback to a default color
        // }
        //
        // if (blockBorderColors.length > day && blockBorderColors[day] != null) {
        //   if (blockBorderColors[day].length > i && blockBorderColors[day][i] != null) {
        //     borderPaint.strokeWidth = borderWidth * 3;
        //   } else {
        //     borderPaint.strokeWidth = borderWidth;
        //   }
        // } else {
        //   borderPaint.strokeWidth = borderWidth;
        // }

        print('day: $day, i: $i, blockBorderColors.length: ${blockBorderColors.length}');

        final maxTotalMoodChanges =
        data.values.map((e) => e!.length).reduce((value, element) => value > element ? value : element);
        final barHeight = size.height / maxTotalMoodChanges;

        Rect rect;
        if (i == 0 && totalMoodChanges > 1) {
          rect = Rect.fromLTRB(
            startX,
            startY - barHeight,
            startX + barWidth,
            startY,
          );
          final RRect rRect = RRect.fromRectAndCorners(
            rect,
            bottomRight: Radius.circular(borderRadius),
            bottomLeft: Radius.circular(borderRadius),
          );
          canvas.drawRRect(rRect, paint);
          canvas.drawRRect(rRect, borderPaint);
        } else if (i == totalMoodChanges - 1 && totalMoodChanges > 1) {
          rect = Rect.fromLTRB(
            startX,
            startY - barHeight * (i + 1),
            startX + barWidth,
            startY - barHeight * i,
          );
          final RRect rRect = RRect.fromRectAndCorners(
            rect,
            topLeft: Radius.circular(borderRadius),
            topRight: Radius.circular(borderRadius),
          );
          canvas.drawRRect(rRect, paint);
          canvas.drawRRect(rRect, borderPaint);
        } else {
          rect = Rect.fromLTRB(
            startX,
            startY - barHeight * (i + 1),
            startX + barWidth,
            startY - barHeight * i,
          );
          canvas.drawRect(rect, paint);
          canvas.drawRect(rect, borderPaint);
        }
      }
      startX += barWidth + barSpacing;
    }
  }

  Color getColor(int? moodValue) {
    if (moodValue == null) return Colors.white;
    switch (moodValue) {
      case 1:
        return colors[0];
      case 2:
        return colors[1];
      case 3:
        return colors[2];
      default:
        return Colors.white;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
