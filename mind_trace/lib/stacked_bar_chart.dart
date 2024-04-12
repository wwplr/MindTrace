import 'package:flutter/material.dart';

class StackedBarChart extends StatefulWidget {
  final Map<int, List<int>> mood;
  final Map<int, List<String>> date;
  final Map<int, List<String>> time;
  final Map<int, List<String>> categories;
  final List<Color> colors;
  final double barWidth;
  final double maxHeight;
  final double maxWidth;
  final double barSpacing;
  final double borderRadius;
  final Color borderColor;
  final double borderWidth;
  final Function(String mood, String date, String time, String categories)? onTap;

  StackedBarChart({
    required this.mood,
    required this.date,
    required this.time,
    required this.categories,
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
  StackedBarChartState createState() => StackedBarChartState();
}

class StackedBarChartState extends State<StackedBarChart> {
  late List<List<Color?>> blockBorderColors;
  int? previousBlockIndex;
  int? previousInnerBlockIndex;
  final List<Widget> blocks = [];
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    initializeBlockBorderColors();
    resetTapPositions();
  }

  @override
  void didUpdateWidget(StackedBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mood != widget.mood) {
      initializeBlockBorderColors();
      resetTapPositions();
    }
  }

  void resetTapPositions() {
    previousBlockIndex = null;
    previousInnerBlockIndex = null;
  }

  void initializeBlockBorderColors() {
    if (widget.mood.isEmpty) {
      blockBorderColors = [];
    } else {
      blockBorderColors = List.generate(widget.mood.length, (index) {
        return List.generate(widget.mood[index]!.length, (innerIndex) => null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mood.isEmpty) {
      return Container(
      );
    }

    final maxTotalMoodChanges = widget.mood.values.map((e) => e.length).reduce((value, element) => value > element? value : element);
    final blockHeight = (widget.maxHeight / maxTotalMoodChanges) - widget.maxHeight/13;
    final totalChartWidth = (widget.barWidth * widget.mood.length) + widget.barSpacing * (widget.mood.length - 1);
    double width = MediaQuery.of(context).size.width;
    double fontSize = width * 0.03;

    return (widget.mood.length >= 6) ? Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(left: widget.barWidth),
          child: Column(
            verticalDirection: VerticalDirection.up,
            children: List.generate(
                maxTotalMoodChanges,
                    (index) {
                  if (index == maxTotalMoodChanges - 1) {
                    return Container(
                      margin: EdgeInsets.only(top: blockHeight/1.8, bottom: blockHeight),
                      child: Text(
                          'End',
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Quicksand',
                              fontWeight: FontWeight.w500,
                              fontSize: fontSize*1.15
                          )
                      ),
                    );
                  } else if (index == 0) {
                    return Container(
                      child: Text(
                          'Start',
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Quicksand',
                              fontWeight: FontWeight.w500,
                              fontSize: fontSize*1.15
                          )
                      ),
                    );
                  } else {
                    return Container(
                      margin: EdgeInsets.only(bottom: blockHeight),
                      child: Text(
                          '${index * 20} min',
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Quicksand',
                              fontWeight: FontWeight.w500,
                              fontSize: fontSize*1.15
                          )
                      ),
                    );
                  }
                }
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: 0),
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: widget.maxWidth*0.075),
                    child: SizedBox(
                        width: totalChartWidth,
                        height: widget.maxHeight,
                        child: GestureDetector(
                          onTapDown: (TapDownDetails details) {
                            handleBlockTap(details, true);
                          },
                          onTapCancel: () {
                            setState(() {
                              initializeBlockBorderColors();
                              previousBlockIndex = null;
                              previousInnerBlockIndex = null;
                            });
                          },
                          child: Container(
                            child: CustomPaint(
                              painter: BarChartPainter(
                                mood: widget.mood,
                                date: widget.date,
                                time: widget.time,
                                categories: widget.categories,
                                colors: widget.colors,
                                barWidth: widget.barWidth,
                                barSpacing: widget.barSpacing,
                                borderRadius: widget.borderRadius,
                                borderColor: widget.borderColor,
                                borderWidth: widget.borderWidth,
                                blockBorderColors: blockBorderColors,
                                previousBlockIndex: previousBlockIndex,
                                previousInnerBlockIndex: previousInnerBlockIndex,
                              ),
                            ),
                          ),
                        )
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: widget.maxHeight/30, left: widget.maxWidth*0.105),
                    child: Row(
                      children: List.generate(
                          widget.mood.length,
                              (index) {
                            if (index == 0) {
                              return Container(
                                child: Text(
                                    (index + 1).toString(),
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'Quicksand',
                                        fontWeight: FontWeight.w500,
                                        fontSize: fontSize*1.15
                                    )
                                ),
                              );
                            } else {
                              return Container(
                                margin: EdgeInsets.only(left: widget.barWidth*1.48),
                                child: Text(
                                    (index + 1).toString(),
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'Quicksand',
                                        fontWeight: FontWeight.w500,
                                        fontSize: fontSize*1.15
                                    )
                                ),
                              );
                            }
                          }
                      ),
                    ),
                  ),
                ],
              )
          ),
        )
      ],
    ) : Stack (
      children: [
        Container(
          margin: EdgeInsets.only(left: widget.barWidth),
          child: Column(
            verticalDirection: VerticalDirection.up,
            children: List.generate(
                maxTotalMoodChanges,
                    (index) {
                  if (index == maxTotalMoodChanges - 1) {
                    return Container(
                      margin: EdgeInsets.only(top: blockHeight/1.75, bottom: blockHeight),
                      child: Text(
                          'End',
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Quicksand',
                              fontWeight: FontWeight.w500,
                              fontSize: fontSize*1.15
                          )
                      ),
                    );
                  } else if (index == 0) {
                    return Container(
                      child: Text(
                          'Start',
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Quicksand',
                              fontWeight: FontWeight.w500,
                              fontSize: fontSize*1.15
                          )
                      ),
                    );
                  } else {
                    return Container(
                      margin: EdgeInsets.only(bottom: blockHeight),
                      child: Text(
                          '${index * 20} min',
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Quicksand',
                              fontWeight: FontWeight.w500,
                              fontSize: fontSize*1.15
                          )
                      ),
                    );
                  }
                }
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              child: SizedBox(
                  width: widget.maxWidth,
                  height: widget.maxHeight,
                  child: GestureDetector(
                    onTapDown: (TapDownDetails details) {
                      handleTap(details, true);
                    },
                    onTapCancel: () {
                      setState(() {
                        initializeBlockBorderColors();
                        previousBlockIndex = null;
                        previousInnerBlockIndex = null;
                      });
                    },
                    child: Container(
                      child: CustomPaint(
                        painter: BarChartPainter(
                          mood: widget.mood,
                          date: widget.date,
                          time: widget.time,
                          categories: widget.categories,
                          colors: widget.colors,
                          barWidth: widget.barWidth,
                          barSpacing: widget.barSpacing,
                          borderRadius: widget.borderRadius,
                          borderColor: widget.borderColor,
                          borderWidth: widget.borderWidth,
                          blockBorderColors: blockBorderColors,
                          previousBlockIndex: previousBlockIndex,
                          previousInnerBlockIndex: previousInnerBlockIndex,
                        ),
                      ),
                    ),
                  )
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: widget.maxHeight/30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                    widget.mood.length,
                        (index) {
                      if (index == 0) {
                        return Container(
                          child: Text(
                              (index + 1).toString(),
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Quicksand',
                                  fontWeight: FontWeight.w500,
                                  fontSize: fontSize*1.15
                              )
                          ),
                        );
                      } else {
                        return Container(
                          margin: EdgeInsets.only(left: widget.barWidth*1.48),
                          child: Text(
                              (index + 1).toString(),
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Quicksand',
                                  fontWeight: FontWeight.w500,
                                  fontSize: fontSize*1.15
                              )
                          ),
                        );
                      }
                    }
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }


  void handleTap(TapDownDetails details, bool isPressed) {
    setState(() {
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final tapPosition = renderBox.globalToLocal(details.globalPosition);

      final totalBarsWidth = widget.mood.length * widget.barWidth;
      final totalSpacing = (widget.mood.length - 1) * widget.barSpacing;
      final totalWidth = totalBarsWidth + totalSpacing;
      final barStartPosition = (widget.maxWidth - totalWidth) / 2;

      final maxTotalMoodChanges = widget.mood.values.map((e) => e.length).reduce((value, element) => value > element? value : element);
      final blockHeight = widget.maxHeight / maxTotalMoodChanges;

      for (int blockIndex = 0; blockIndex < widget.mood.length; blockIndex++) {
          final moodChanges = widget.mood[blockIndex]?? [];
        final startX = barStartPosition + (blockIndex * (widget.barWidth + widget.barSpacing)) + (widget.barWidth * 0.75);
        final endX = startX + widget.barWidth;

        for (int innerBlockIndex = 0; innerBlockIndex < moodChanges.length; innerBlockIndex++) {
          final startY = widget.maxHeight - (innerBlockIndex + 1) * blockHeight;
          final endY = startY + blockHeight;

          if (tapPosition.dx >= startX && tapPosition.dx <= endX && tapPosition.dy >= startY && tapPosition.dy <= endY) {
            if (previousBlockIndex!= null && previousInnerBlockIndex!= null) {
              blockBorderColors[previousBlockIndex!][previousInnerBlockIndex!] = null;
            }
            blockBorderColors[blockIndex][innerBlockIndex] = isPressed? widget.colors[moodChanges[innerBlockIndex] - 1] : widget.borderColor;
            previousBlockIndex = blockIndex;
            previousInnerBlockIndex = innerBlockIndex;
            print(blockBorderColors);
            print("Handling block tap at blockIndex: $blockIndex, innerBlockIndex: $innerBlockIndex");
            if (widget.onTap!= null) {
              final moodValue = moodChanges[innerBlockIndex];
              final mood = getMood(moodValue);
              final date = getDate(blockIndex, innerBlockIndex);
              final time = getTime(blockIndex, innerBlockIndex);
              final category = getCategories(blockIndex, innerBlockIndex);
              widget.onTap!(mood, date, time, category);
            }
          }
        }
      }
    });
  }

  void handleBlockTap(TapDownDetails details, bool isPressed) {
    setState(() {
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final tapPosition = renderBox.globalToLocal(details.globalPosition);

      final maxTotalMoodChanges = widget.mood.values.map((e) => e.length).reduce((value, element) => value > element ? value : element);
      final blockHeight = widget.maxHeight / maxTotalMoodChanges;

      final maxInnerBlocks = widget.mood[widget.mood.length - 1]!.length;

      final startX = ((widget.barWidth + (widget.mood.length) * widget.barSpacing)) / 2;
      final startY = widget.maxHeight - (maxInnerBlocks * blockHeight);

      final relativePosition = Offset(tapPosition.dx - startX + scrollController.offset, tapPosition.dy - startY);

      final blockIndex = ((relativePosition.dx - widget.barWidth / 2) / (widget.barWidth + widget.barSpacing)).floor();
      final relativeY = widget.maxHeight - tapPosition.dy;
      final innerBlockIndex = (relativeY / blockHeight).floor();

      print("Handling block tap at blockIndex: $blockIndex, innerBlockIndex: $innerBlockIndex");

      if (blockIndex >= 0 && blockIndex < blockBorderColors.length && innerBlockIndex >= 0 && innerBlockIndex < blockBorderColors[blockIndex].length) {
        if (previousBlockIndex!= null && previousInnerBlockIndex!= null) {
          blockBorderColors[previousBlockIndex!][previousInnerBlockIndex!] = null;
        }
        blockBorderColors[blockIndex][innerBlockIndex] = isPressed? widget.colors[widget.mood[blockIndex]![innerBlockIndex] - 1] : widget.borderColor;
        previousBlockIndex = blockIndex;
        previousInnerBlockIndex = innerBlockIndex;
        if (widget.onTap!= null) {
          final moodValue = widget.mood[blockIndex]?[innerBlockIndex];
          final mood = getMood(moodValue!);
          final date = getDate(blockIndex, innerBlockIndex);
          final time = getTime(blockIndex, innerBlockIndex);
          final category = getCategories(blockIndex, innerBlockIndex);
          widget.onTap!(mood, date, time, category);
        }
      }
    });
  }

  String getMood(int moodValue) {
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

  String getDate(int blockIndex, int innerBlockIndex) {
    final moodChanges = widget.mood[blockIndex] ?? [];
    if (innerBlockIndex >= 0 && innerBlockIndex < moodChanges.length) {
      final dateList = widget.date[blockIndex];
      final date = dateList?[innerBlockIndex];
      return date ?? '';
    }
    return '';
  }

  String getTime(int blockIndex, int innerBlockIndex) {
    final moodChanges = widget.mood[blockIndex] ?? [];
    if (innerBlockIndex >= 0 && innerBlockIndex < moodChanges.length) {
      final timeList = widget.time[blockIndex];
      final time = timeList?[innerBlockIndex];
      return time ?? '';
    }
    return '';
  }

  String getCategories(int blockIndex, int innerBlockIndex) {
    final moodChanges = widget.mood[blockIndex] ?? [];
    if (innerBlockIndex >= 0 && innerBlockIndex < moodChanges.length) {
      final categoryList = widget.categories[blockIndex];
      var categories = categoryList?[innerBlockIndex];
      categories = categories?.replaceAll('[', '').replaceAll(']', '');
      return categories ?? '';
    }
    return '';
  }
}

class BarChartPainter extends CustomPainter {
  final Map<int, List<int>?> mood;
  final Map<int, List<String>> date;
  final Map<int, List<String>> time;
  final Map<int, List<String>> categories;
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
    required this.mood,
    required this.date,
    required this.time,
    required this.categories,
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
    final totalBarsWidth = mood.length * barWidth;
    final totalSpacing = (mood.length - 1) * barSpacing;
    final totalWidth = totalBarsWidth + totalSpacing;
    final barStartPosition = (size.width - totalWidth) / 2;

    double startX = barStartPosition;
    double startY = size.height;

    for (int day = 0; day < mood.length; day++) {
      final moodChanges = mood[day] ?? [];
      final totalMoodChanges = moodChanges.length;

      for (int i = 0; i < totalMoodChanges; i++) {
        final paint = Paint()
          ..color = getColor(moodChanges[i]);
        final borderPaint = Paint();
        if (day >= 0 && day < blockBorderColors.length && i >= 0 && i < blockBorderColors[day].length) {
          borderPaint
            ..style = PaintingStyle.stroke
            ..color = blockBorderColors[day][i] ?? borderColor
            ..strokeWidth = borderWidth * 1.5;
        } else {
          borderPaint
            ..style = PaintingStyle.stroke
            ..color = borderColor
            ..strokeWidth = borderWidth * 1.5;
        }

        final maxTotalMoodChanges =
        mood.values.map((e) => e!.length).reduce((value, element) => value > element ? value : element);
        final blockHeight = size.height / maxTotalMoodChanges;

        Rect rect;
        if (totalMoodChanges == 1) {
          rect = Rect.fromLTRB(
            startX,
            startY - blockHeight,
            startX + barWidth,
            startY,
          );
          final RRect rRect = RRect.fromRectAndCorners(
            rect,
            topLeft: Radius.circular(borderRadius),
            topRight: Radius.circular(borderRadius),
            bottomRight: Radius.circular(borderRadius),
            bottomLeft: Radius.circular(borderRadius),
          );
          canvas.drawRRect(rRect, paint);
          canvas.drawRRect(rRect, borderPaint);
        } else if (i == 0 && totalMoodChanges > 1) {
          rect = Rect.fromLTRB(
            startX,
            startY - blockHeight,
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
            startY - blockHeight * (i + 1),
            startX + barWidth,
            startY - blockHeight * i,
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
            startY - blockHeight * (i + 1),
            startX + barWidth,
            startY - blockHeight * i,
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