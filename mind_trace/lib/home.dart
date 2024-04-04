import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:mind_trace/stacked_bar_chart.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final user = FirebaseAuth.instance.currentUser!;
  String mood = '';
  String timestamp = '';
  String categories = '';
  Map<int, List<int>> moodData = {};
  Map<int, List<String>> timestamps = {};
  Map<int, List<String>> categoriesList = {};

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  String convertTimestamp(String timestamp) {
    DateFormat inputFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    DateTime ts = inputFormat.parse(timestamp);

    DateFormat outputFormat = DateFormat('E, d MMM hh:mm:ss a');

    return outputFormat.format(ts);
  }


  Future<void> fetchData() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid.toString())
          .get();

      if (documentSnapshot.exists) {
        List<int> currentMoodSet = [];
        List<String> currentTimestamps = [];
        List<String> currentCategories = [];
        int setIndex = 0;
        Map<int, List<int>> newMoodData = {};
        Map<int, List<String>> newTimestamps = {};
        Map<int, List<String>> newCategories = {};

        List<Map<String, dynamic>> data = (documentSnapshot.data() as Map<String, dynamic>).entries.map((entry) => {
          'timestamp': entry.key,
          'moods': entry.value[0],
          'categories': entry.value[1]
        }).toList();

        List<String> sortedTimestamps = data.map((entry) => entry['timestamp'].toString()).toList()..sort();

        for (String timestamp in sortedTimestamps) {
          var entry = data.firstWhere((entry) => entry['timestamp'].toString() == timestamp);

          String mood = entry['moods'];
          String categories = entry['categories'];

          String ts = convertTimestamp(timestamp);

          if (mood == 'Start') {
            currentMoodSet = [];
            currentTimestamps = [];
            currentCategories = [];
          } else if (mood == 'Finish') {
            newMoodData[setIndex] = currentMoodSet;
            newTimestamps[setIndex] = currentTimestamps;
            newCategories[setIndex] = currentCategories;
            setIndex++;
          } else {
            currentMoodSet.add(getMoodValue(mood));
            currentCategories.add('[$categories]');
            currentTimestamps.add(ts);
          }
        }

        print('Fetched data: $newMoodData');
        print('Fetched timestamps: $newTimestamps');

        setState(() {
          moodData = newMoodData;
          timestamps = newTimestamps;
          categoriesList = newCategories;
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
        return 0; // Handle unknown mood values
    }
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
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                //margin: EdgeInsets.only(top: height*0.1),
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
                      text: 'High',
                      color: Colors.green,
                      space: 0.01 * width,
                      fontSize: fontSize * 1.3,
                      width: 0.015 * width,
                      height: 0.015 * width,
                    ),
                    SizedBox(width: 0.05 * width),
                    buildLegend(
                      text: 'OK',
                      color: Colors.yellow,
                      space: 0.01 * width,
                      fontSize: fontSize * 1.3,
                      width: 0.015 * width,
                      height: 0.015 * width,
                    ),
                    SizedBox(width: 0.05 * width),
                    buildLegend(
                      text: 'Low',
                      color: Colors.red,
                      space: 0.01 * width,
                      fontSize: fontSize * 1.3,
                      width: 0.015 * width,
                      height: 0.015 * width,
                    ),
                  ],
                ),
              ),
              Container(
                  margin: EdgeInsets.only(bottom: height*0.02),
                  alignment: Alignment.center,
                  child: ElevatedButton(
                      onPressed: () async {
                        await fetchData();
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size((0.25*width), (0.02*height)),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)
                        ),
                        elevation: 2.0,
                      ),
                      child: Text(
                          'Generate',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Color(0xFF2A364E),
                              fontSize: fontSize,
                              fontWeight: FontWeight.w400
                          )
                      )
                  )
              ),
              Container(
                child: StackedBarChart(
                    height: height,
                    width: width,
                    data: moodData,
                    timestamps: timestamps,
                    categories: categoriesList,
                    colors: [
                      Colors.red,
                      Colors.yellow,
                      Colors.green,
                    ],
                    barWidth: width*0.06,
                    maxHeight: height*0.3,
                    maxWidth: width*0.9,
                    barSpacing: width*0.05,
                    borderRadius: 20,
                    borderColor: Colors.white,
                    borderWidth: width*0.0025,
                    onTap: (m, ts, c) {
                      setState(() {
                        mood = m;
                        timestamp = ts;
                        categories = c.toString();
                      });
                    }
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: height * 0.02),
                child: SizedBox(
                    width: width * 0.85,
                    height: height * 0.17,
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
                                        text: 'Timestamp:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600
                                        ),
                                      ),
                                      TextSpan(text: ' $timestamp')
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
                                  TextSpan(text: ' $mood')
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
                                        text: 'Categories:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextSpan(text: ' $categories')
                                    ]
                                )
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
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
