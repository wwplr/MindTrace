import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int touchedIndex = -1;
  final Color barBackgroundColor = Colors.transparent;
  final Color barColor = Colors.blue;
  final Color touchedBarColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double fontSize = width * 0.03;
    return PopScope(
        canPop: false,
        child: Scaffold(
            body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      AspectRatio(
                        aspectRatio: 1,
                        child: Stack(
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'Mood Insights',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: fontSize*2,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Quicksand"
                                  ),
                                ),
                                Container (
                                  margin: EdgeInsets.only(top: 0.02*height),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      buildLegend(
                                          text: 'High',
                                          color: Colors.green,
                                          space: 0.01*width,
                                          fontSize: fontSize*1.2,
                                          width: 0.015*width,
                                          height: 0.015*width
                                      ),
                                      SizedBox(width: 0.05*width),
                                      buildLegend(
                                          text: 'OK',
                                          color: Colors.yellow,
                                          space: 0.01*width,
                                          fontSize: fontSize*1.2,
                                          width: 0.015*width,
                                          height: 0.015*width
                                      ),
                                      SizedBox(width: 0.05*width),
                                      buildLegend(
                                          text: 'Low',
                                          color: Colors.red,
                                          space: 0.01*width,
                                          fontSize: fontSize*1.2,
                                          width: 0.015*width,
                                          height: 0.015*width
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                    child: Container (
                                      margin: EdgeInsets.only(top: 0.05*height),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        child: BarChart(
                                          mainBarData(),
                                        ),
                                      ),
                                    )
                                )
                              ],
                            ),
                          ],
                        ),
                      )
                    ]
                )
            )
        )
    );
  }

  static const mainItems = <int, List<double>>{
    0: [3, 2, 3],
    1: [2, 1, 2, 3],
    2: [2, 2, 3, 2],
    3: [2, 2, 3],
    4: [3, 2, 3, 3],
    5: [3, 1, 2, 2],
    6: [2, 2, 3, 2],
  };

  Color getMoodColor(double value) {
    if (value == 1) {
      return Colors.red; // Low
    } else if (value == 2) {
      return Colors.yellow; // OK
    } else if (value == 3) {
      return Colors.green; // High
    } else {
      return Colors.white; // Default or undefined
    }
  }

  BarChartGroupData makeGroupData(
      int x,
      List<double> moodValues,
      {
        bool isTouched = false,
        List<int> showTooltips = const [],
      }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: isTouched ? moodValues.length.toDouble() + 1 : moodValues.length.toDouble(),
          width: 22,
          rodStackItems: rodStackItemsList(moodValues, 22),
          borderSide: isTouched
              ? BorderSide(color: touchedBarColor)
              : const BorderSide(color: Colors.white, width: 0),
        )
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartRodStackItem> rodStackItemsList(List<double> moodValues, double width) {
    double currentHeight = 0;

    return moodValues.map((value) {
      final rodStackItem = BarChartRodStackItem(
        currentHeight,
        currentHeight + 1,
        getMoodColor(value),
        BorderSide(
          color: Colors.white,
          width: 1.0,
        ),
      );
      currentHeight += 1;
      return rodStackItem;
    }).toList();
  }

  BarChartData mainBarData() {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.blueGrey,
          tooltipHorizontalAlignment: FLHorizontalAlignment.center,
          tooltipMargin: 5,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
              'Categories',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            );
          },
        ),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              touchedIndex = -1;
              return;
            }
            touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: getTitles,
            reservedSize: 38,
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: mainItems.entries.map(
            (e) => makeGroupData(
          e.key,
          e.value,
        ),
      ).toList(),
      gridData: const FlGridData(show: false),
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = const Text('Time', style: style);
        break;
      case 1:
        text = const Text('Time', style: style);
        break;
      case 2:
        text = const Text('Time', style: style);
        break;
      case 3:
        text = const Text('Time', style: style);
        break;
      case 4:
        text = const Text('Time', style: style);
        break;
      case 5:
        text = const Text('Time', style: style);
        break;
      case 6:
        text = const Text('Time', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: text,
    );
  }

  Widget buildLegend({
    required String text,
    required Color color,
    required double space,
    required double fontSize,
    required double width,
    required double height

  }) =>
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          SizedBox(width: space),
          Text(
            text,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontFamily: "Quicksand",
              fontSize: fontSize,
            ),
          ),
        ],
      );
}