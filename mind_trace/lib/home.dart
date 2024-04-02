import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mind_trace/stacked_bar_chart.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final user = FirebaseAuth.instance.currentUser!;
  int touchedIndex = -1;
  final Color barBackgroundColor = Colors.transparent;
  final Color barColor = Colors.white;
  final Color touchedBarColor = Colors.blue;
  String mood = '';
  Map<int, List<int>> moodData = {};

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<Map<int, List<int>>> fetchData() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid.toString())
          .get();

      if (documentSnapshot.exists) {
        List<int> currentMoodSet = [];
        int setIndex = 0;

        // Assuming mood data is stored directly under the user document
        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;

        // Sort the data by keys (timestamps)
        List<String> sortedKeys = data.keys.toList()..sort();

        sortedKeys.forEach((key) {
          var value = data[key]; // Mood data for the current timestamp
          print('Timestamp: $key, Mood: $value');

          if (value == 'Start') {
            currentMoodSet = [];
          } else if (value == 'Finish') {
            moodData[setIndex++] = currentMoodSet;
          } else {
            currentMoodSet.add(getMoodValue(value));
          }
        });

        print('Fetched data: $moodData');
        return moodData;
      } else {
        print('User document does not exist.');
        return {};
      }
    } catch (error) {
      print('Error fetching data: $error');
      return {};
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
                        Map<int, List<int>> data = await fetchData();
                        setState(() {
                          moodData = data;
                        });
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
              SizedBox(
                height: height*0.3,
                width: width*0.9,
                child: StackedBarChart(
                    data: moodData,
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
                    onTap: (m) {
                      setState(() {
                        mood = m;
                      });
                    }
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: height * 0.02),
                child: SingleChildScrollView(
                  child: SizedBox(
                    width: width * 0.8,
                    height: height * 0.15,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0xFFFFF8EA),
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: width * 0.05, top: height * 0.01),
                            child: Text(
                              'Mood: $mood',
                              style: TextStyle(
                                fontSize: fontSize * 1.4,
                                fontFamily: 'Quicksand',
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: width * 0.05, top: height * 0.01),
                            child: Text(
                              'Categories: ',
                              style: TextStyle(
                                fontSize: fontSize * 1.4,
                                fontFamily: 'Quicksand',
                              ),
                            ),
                          ),
                        ],
                      ),
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
