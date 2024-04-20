import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_scatter/flutter_scatter.dart';

class WordCloud extends StatefulWidget {
  final List<Map<String, dynamic>> wordList;
  final Function(String, dynamic) onWordTap;

  WordCloud({Key? key, required this.wordList, required this.onWordTap})
      : super(key: key);

  @override
  _WordCloudState createState() => _WordCloudState();
}

class _WordCloudState extends State<WordCloud> {
  Map<String, bool> boldMap = {};
  Map<String, Color> colorMap = {};
  Map<String, bool> strokeMap = {};
  Map<String, bool> borderMap = {};

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double fontSize = width * 0.05;
    List<Color> colors = [
      Color(0xFF21918C),
      Color(0xFF49688D),
      Color(0xFF4F219F)
    ];
    int colorIndex = 0;

    if(widget.wordList.isEmpty) {
      return Container(
        alignment: Alignment.center,
        width: width*0.9,
        height: height*0.3,
        child: Text(
          'No data',
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: fontSize*1.2,
            fontWeight: FontWeight.w500
          ),
        ),
      );
    } else {
      double maxFontSize = fontSize * 3.45;
      double minFontSize = fontSize * 1.7;
      double fontSizeRange = maxFontSize - minFontSize;

      double maxValue = widget.wordList
          .map((word) => word['value'] as int)
          .reduce((a, b) => max(a, b))
          .toDouble();
      double minValue = widget.wordList
          .map((word) => word['value'] as int)
          .reduce((a, b) => min(a, b))
          .toDouble();

      return Center(
        child: FittedBox(
          child: Scatter(
            fillGaps: true,
            delegate: ArchimedeanSpiralScatterDelegate(ratio: 0.9),
            children: widget.wordList.map((word) {
              String wordText = word['word'] as String;
              int valueText = word['value'];
              double wordFontSize;
              if (maxValue == minValue) {
                wordFontSize = fontSize;
              } else {
                wordFontSize = minFontSize +
                    ((word['value'] - minValue) / (maxValue - minValue)) * fontSizeRange;
              }


              Color textColor = strokeMap[wordText] != null
                  ? colorMap[wordText] ?? colors[colorIndex]
                  : colors[colorIndex];

              Color borderColor =
              borderMap[wordText] ?? false ? Color(0xFF708090) : Colors.transparent;

              colorIndex = (colorIndex + 1) % colors.length;

              int shouldRotate(String word, int value) {
                if (value == maxValue.toInt()) {
                  return 0;
                }

                if (word.length >= 10 || (word.length < 10 && word.length >= 7 && value == maxValue)) {
                  return 0;
                } else if (word.length < 10 && word.length >= 7) {
                  return -1;
                } else if (word.length < 7 && word.length >= 3) {
                  return 0;
                } else {
                  return 1;
                }
              }

              return GestureDetector(
                onTap: () {
                  setState(() {
                    borderMap.forEach((key, value) {
                      borderMap[key] = false;
                    });
                    borderMap[wordText] = true;
                  });
                  widget.onWordTap(wordText, valueText.toString());
                },
                child: RotatedBox(
                  quarterTurns: shouldRotate(wordText, valueText),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: borderColor,
                        width: width*0.003,
                      ),
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(width*0.025),
                    ),
                    child: Text(
                      wordText,
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: wordFontSize,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    }
  }
}
