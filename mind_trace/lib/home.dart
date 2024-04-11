import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:mind_trace/stacked_bar_chart.dart';
import 'package:timezone/timezone.dart' as tz;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final user = FirebaseAuth.instance.currentUser!;
  String moodText = '';
  String dateText = '';
  String timeText = '';
  String categoriesText = '';
  String generate = 'Click generate to view your mood insights.';
  Map<int, List<int>> moodList = {};
  Map<int, List<String>> dateList = {};
  Map<int, List<String>> timeList = {};
  Map<int, List<String>> categoryList = {};
  DateTime date = DateTime.now();
  String noDataText = '';
  bool noData = false;
  bool noCategory = false;
  bool barPressed = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  String convertDate(String timestamp) {
    DateFormat inputFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    DateTime date = inputFormat.parse(timestamp);

    DateFormat outputFormat = DateFormat('E, d MMMM yyyy');

    return outputFormat.format(date);
  }

  String convertTime(String timestamp) {
    DateFormat inputFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    DateTime time = inputFormat.parse(timestamp);

    DateFormat outputFormat = DateFormat('hh:mm:ss a');

    return outputFormat.format(time);
  }

  String convertTimestamp(String timestamp) {
    DateFormat inputFormat = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
    DateTime ts = inputFormat.parse(timestamp);

    DateFormat outputFormat = DateFormat('yyyy-MM-dd');
    return outputFormat.format(ts);
  }


  Future<void> fetchData(String selectedDate) async {
    DateTime parsedDate = DateTime.parse(selectedDate);

    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid.toString())
          .get();

      if (documentSnapshot.exists) {
        List<int> currentMoods = [];
        List<String> currentDate = [];
        List<String> currentTime = [];
        List<String> currentCategories = [];
        int setIndex = 0;
        Map<int, List<int>> newMoods = {};
        Map<int, List<String>> newDates = {};
        Map<int, List<String>> newTimes = {};
        Map<int, List<String>> newCategories = {};

        List<Map<String, dynamic>> data = (documentSnapshot.data() as Map<
            String,
            dynamic>).entries.map((entry) =>
        {
          'timestamp': entry.key,
          'moods': entry.value[0],
          'categories': entry.value[1]
        }).toList();

        List<String> filteredData = data.where((entry) {
          DateTime entryDate = DateTime.parse(entry['timestamp']);
          return entryDate.year == parsedDate.year &&
              entryDate.month == parsedDate.month &&
              entryDate.day == parsedDate.day;
        })
            .map((entry) => entry['timestamp'].toString())
            .toList()
          ..sort();

        if (filteredData.isNotEmpty) {
          for (String timestamp in filteredData) {
            var entry = data.firstWhere((entry) =>
            entry['timestamp'].toString() == timestamp);

            String mood = entry['moods'];
            String category = entry['categories'];
            String date = convertDate(timestamp);
            String time = convertTime(timestamp);

            if (mood == 'Start') {
              currentMoods = [];
              currentDate = [];
              currentTime = [];
              currentCategories = [];
            } else if (mood == 'Finish') {
              newMoods[setIndex] = currentMoods;
              newDates[setIndex] = currentDate;
              newTimes[setIndex] = currentTime;
              newCategories[setIndex] = currentCategories;
              setIndex++;
            } else {
              currentMoods.add(getMoodValue(mood));
              currentDate.add(date);
              currentTime.add(time);
              if (category.isEmpty) {
                noCategory = true;
                print('No categories found, please upload your browsing history.');
                noDataText = 'No categories found, please upload your browsing history.';
                currentCategories.add('No categories found, please upload your browsing history.');
              } else {
                currentCategories.add('[$category]');
              }
            }
          }
        } else {
          setState(() {
            noData = true;
            noDataText = 'No data found for the selected date.';
            moodText = 'No data logged';
            dateText = 'No data logged';
            timeText = 'No data logged';
            categoriesText = 'No data logged';
          });
        }

        print('Fetched data: $newMoods');
        print('Fetched dates: $newDates');
        print('Fetched times: $newTimes');
        print('Fetched categories: $newCategories');

        setState(() {
          moodList = newMoods;
          dateList = newDates;
          timeList = newTimes;
          categoryList = newCategories;
        });
      } else {
        print('User document does not exist.');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  int getMoodValue(String mood) {
    switch (mood) {
      case 'Low':
        return 1;
      case 'OK':
        return 2;
      case 'High':
        return 3;
      default:
        return 0;
    }
  }

  Future<void> getDatePicker(double height, double width) async {
    double containerHeight = height * 0.31;
    containerHeight = containerHeight > height ? height : containerHeight;

    setState(() {
      date = tz.TZDateTime.from(DateTime.now(), tz.local);
    });

    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            height: containerHeight,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.only(left: width*0.025, top: height*0.01, bottom: height*0.01),
                        decoration: BoxDecoration(
                          color: Color(0xFFF8F8F8),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Cancel',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: width * 0.04,
                              fontWeight: FontWeight.normal,
                              color: Color(0xFF0062CC),
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.topRight,
                          padding: EdgeInsets.only(right: width*0.025, top: height*0.01, bottom: height*0.01),
                          decoration: BoxDecoration(
                            color: Color(0xFFF8F8F8),
                          ),
                          child: GestureDetector(
                            onTap: () async {
                              Navigator.pop(context);
                              String convertedDate = convertTimestamp(date.toString());
                              print('Selected data: $convertedDate');
                              setState(() {
                                //reset
                                moodText = '';
                                dateText = '';
                                timeText = '';
                                categoriesText = '';
                                noCategory = false;
                                noData = false;
                                barPressed = false;
                                generate = 'Sessions';
                              });
                              await fetchData(convertTimestamp(date.toString()));
                            },
                            child: Text(
                              'Done',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: width * 0.04,
                                fontWeight: FontWeight.normal,
                                color: Color(0xFF0062CC),
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      )
                  ],
                ),
                SizedBox(
                  height: containerHeight - 50,
                  child: CupertinoDatePicker(
                    showDayOfWeek: true,
                    mode: CupertinoDatePickerMode.date,
                    onDateTimeChanged: (value) {
                      setState(() {
                        date = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double fontSize = width * 0.03;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: height*0.1),
                  child: Text(
                    'Mood Progression',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: fontSize * 2,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Quicksand",
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: height*0.02, bottom: height*0.02),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildLegend(
                        text: 'Low',
                        color: Colors.red,
                        space: 0.01 * width,
                        fontSize: fontSize * 1.5,
                        width: 0.02 * width,
                        height: 0.02 * width,
                      ),
                      SizedBox(width: 0.05 * width),
                      buildLegend(
                        text: 'OK',
                        color: Colors.yellow.shade600,
                        space: 0.01 * width,
                        fontSize: fontSize * 1.5,
                        width: 0.02 * width,
                        height: 0.02 * width,
                      ),
                      SizedBox(width: 0.05 * width),
                      buildLegend(
                        text: 'High',
                        color: Colors.green,
                        space: 0.01 * width,
                        fontSize: fontSize * 1.5,
                        width: 0.02 * width,
                        height: 0.02 * width,
                      ),
                    ],
                  ),
                ),
                noData ? Container(
                  child: Text(
                    noDataText,
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Quicksand',
                        fontSize: fontSize*1.15
                    ),
                  ),
                ) : Container(
                  child: Column(
                    children: [
                      StackedBarChart(
                          mood: moodList,
                          date: dateList,
                          time: timeList,
                          categories: categoryList,
                          colors: [
                            Colors.red,
                            Colors.yellow.shade600,
                            Colors.green,
                          ],
                          barWidth: width*0.065,
                          maxHeight: height*0.3,
                          maxWidth: width*0.9,
                          barSpacing: width*0.05,
                          borderRadius: width*0.047,
                          borderColor: Colors.white,
                          borderWidth: width*0.0025,
                          onTap: (m, d, t, c) {
                            setState(() {
                              moodText = m;
                              dateText = d;
                              timeText = t;
                              categoriesText = c.toString();
                              barPressed = true;
                            });
                          }
                      ),
                      Container(
                          margin: EdgeInsets.only(top: height*0.01),
                          child: Text(
                            generate,
                            style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Quicksand',
                                fontSize: fontSize*1.15
                            ),
                          )
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: height * 0.02),
                  child: SizedBox(
                    width: width * 0.85,
                    height: height * 0.21,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0xFFFFF8EA),
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: width * 0.04, right: width * 0.04),
                            child: RichText(
                                text: TextSpan(
                                    style: TextStyle(
                                        fontSize: fontSize * 1.4,
                                        fontFamily: 'Quicksand',
                                        color: Colors.black,
                                        letterSpacing: width*0.0006
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Date:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600
                                        ),
                                      ),
                                      TextSpan(text: ' $dateText')
                                    ]
                                )
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: width * 0.04, right: width * 0.04, top: height * 0.01),
                            child: RichText(
                                text: TextSpan(
                                    style: TextStyle(
                                        fontSize: fontSize * 1.4,
                                        fontFamily: 'Quicksand',
                                        color: Colors.black,
                                        letterSpacing: width*0.0006
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Time:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600
                                        ),
                                      ),
                                      TextSpan(text: ' $timeText')
                                    ]
                                )
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: width * 0.04, right: width * 0.04, top: height * 0.01),
                            child: RichText(
                                text: TextSpan(
                                    style: TextStyle(
                                        fontSize: fontSize * 1.4,
                                        fontFamily: 'Quicksand',
                                        color: Colors.black,
                                        letterSpacing: width*0.0006
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Mood:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600
                                        ),
                                      ),
                                      TextSpan(text: ' $moodText')
                                    ]
                                )
                            ),
                          ),
                          Row(
                            children: [
                              Flexible(
                                child: Container(
                                  margin: EdgeInsets.only(left: width * 0.04, right: width * 0.04, top: height * 0.01),
                                  child: RichText(
                                      overflow: TextOverflow.visible,
                                      text: TextSpan(
                                          style: TextStyle(
                                              fontSize: fontSize * 1.4,
                                              fontFamily: 'Quicksand',
                                              color: Colors.black,
                                              letterSpacing: width*0.0006
                                          ),
                                          children: [
                                            TextSpan(
                                              text: 'Categories:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            TextSpan(
                                                text: ' $categoriesText',
                                                style: TextStyle(
                                                    color: noCategory ? Colors.red : Colors.black
                                                )
                                            ),
                                          ]
                                      )
                                  ),
                                ),
                              ),
                              (noCategory && barPressed) ? Container(
                                  margin: EdgeInsets.only(right: width*0.03),
                                  child: Tooltip(
                                    margin: EdgeInsets.only(left: width*0.3, right: width*0.1),
                                    showDuration: Duration(seconds: 10),
                                    triggerMode: TooltipTriggerMode.tap,
                                    decoration: BoxDecoration(
                                        color: Colors.grey.shade700,
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                    textStyle: TextStyle(
                                        fontFamily: 'Quicksand',
                                        fontSize: fontSize*1.2,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white
                                    ),
                                    message: 'Go to the + page and follow the instructions.',
                                    child: Icon(
                                      Icons.info,
                                      color: Colors.black,
                                    ),
                                  )
                              ) : Container(),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                    margin: EdgeInsets.only(top: height*0.02),
                    alignment: Alignment.center,
                    child: ElevatedButton(
                        onPressed: () async {
                          await getDatePicker(height, width);
                        },
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size((0.35*width), (0.055*height)),
                          backgroundColor: Color(0xFFA986E4),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(width*0.055)
                          ),
                          elevation: 2.0,
                        ),
                        child: Text(
                            'Generate',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Quicksand',
                                fontSize: fontSize*1.4,
                                fontWeight: FontWeight.w600
                            )
                        )
                    )
                ),
                SizedBox(
                    width: width,
                    height: height*0.15
                )
              ],
            )
        ),
      ),
    );
  }

  Widget buildLegend({
    required String text,
    required Color color,
    required double space,
    required double fontSize,
    required double width,
    required double height,
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
