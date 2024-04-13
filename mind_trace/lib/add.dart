import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mind_trace/slider.dart';
import 'dart:async';
import 'dart:io';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;
import 'notification.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimerProvider extends ChangeNotifier {
  late Timer _timer;
  bool _isSubmitted = false;
  bool _start = true;
  bool _continued = false;
  bool _sending = false;
  bool _isNotificationScheduled = false;
  bool get isSubmitted => _isSubmitted;
  bool get start => _start;
  bool get continued => _continued;
  Timer get timer => _timer;
  bool get isNotifiedScheduled => _isNotificationScheduled;
  bool get sending => _sending;

  void setStart(bool value) {
    _start = value;
    notifyListeners();
  }

  void setContinue(bool value) {
    _continued = value;
    notifyListeners();
  }

  void setSubmit(bool value) {
    _isSubmitted = value;
    _continued = false;
    notifyListeners();
  }

  void setNotification(bool value) {
    _isNotificationScheduled = value;
    notifyListeners();
  }

  void setSending(bool value) {
    _sending = value;
    notifyListeners();
  }

  void stopTimer() {
    _timer.cancel();
    notifyListeners();
  }
  @override
  void dispose() {
    super.dispose();
  }
}

class Add extends StatefulWidget {
  const Add({Key? key}) : super(key: key);

  @override
  State<Add> createState() => _AddState();
}

class _AddState extends State<Add> with WidgetsBindingObserver {
  final user = FirebaseAuth.instance.currentUser!;
  late File file;
  String result = '';
  String categories = '';
  List<String> resultList = [];
  String selectedEmoji = '';
  Color iconColor = Colors.grey.shade800;
  Color iconColor2 = Colors.grey.shade800;
  Color iconColor3 = Colors.grey.shade800;
  Color circleColor = Colors.white60;
  Color circleColor2 = Colors.white60;
  Color circleColor3 = Colors.white60;
  bool isSelected = false;
  bool isSelected2 = false;
  bool isSelected3 = false;
  bool yesClicked = false;
  late Timestamp startTimestamp;
  Map<int, List<String>> timestampList = {};
  Map<int, List<String>> moodList = {};
  Map<int, List<List<String>>> categoryList = {};
  bool isDialogOpen = false;
  bool loopCompleted = false;
  bool updated = false;
  bool done = false;
  final flutterNotification = FlutterNotification();
  late SharedPreferences preferences;
  late DateTime lastUploaded;
  String lastUploadedText = '';
  late String tsToPython;
  String username = '';
  String uploadText = '';

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    final currentUser = FirebaseAuth.instance.currentUser;
    username = currentUser != null ? currentUser.displayName ?? '' : '';
    WidgetsBinding.instance.addObserver(this);
    loadLastUploaded();
  }

  Future<void> loadLastUploaded() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc('${user.uid}last_uploaded')
        .get();

    if (documentSnapshot.exists) {
      String data = documentSnapshot['lastUploaded'];
      setState(() {
        lastUploadedText = data;
      });
      print(data);
    } else {
      setState(() {
        lastUploadedText = '';
      });
      print('No data');
    }
  }

  void saveLastUploaded(DateTime time) async {
    lastUploadedText = DateFormat('E, MMMM d \'at\' h:mm a').format(time);
    await FirebaseFirestore.instance
        .collection('users')
        .doc('${user.uid}last_uploaded')
        .set({'lastUploaded': lastUploadedText});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  String extractFirstName(String displayName) {
    List<String> nameParts = displayName.split(' ');
    return nameParts.isNotEmpty ? nameParts[0] : '';
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    print('App Lifecycle State: $state');

    final logMoodTime = tz.TZDateTime.now(tz.local).add(Duration(minutes: 20));
    if (Provider.of<TimerProvider>(context, listen: false).isNotifiedScheduled == false &&
        Provider.of<TimerProvider>(context, listen: false).isSubmitted == true &&
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.paused) {
      print('Scheduling...');
      await flutterNotification.scheduleNotification(
        id: 4,
        title: 'MindTrace',
        body: "It's time to log your mood!",
        scheduledNotificationDateTime: logMoodTime,
      );
      setState(() {
        Provider.of<TimerProvider>(context, listen: false).setNotification(true);
      });
    }
  }

  Future<void> pickFile(double fontSize, double width, double height) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      file = File(result.files.single.path!);

      await fetchData(fontSize, width, height);
    } else {
      print("User canceled file picking");
    }
  }

  Future<void> checkIcon(double fontSize, double width, double height) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return SizedBox(
            width: width*0.7,
            height: height*0.4,
            child: AlertDialog(
                backgroundColor: Colors.white,
                content: Text(
                    uploadText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color(0xFF2A364E),
                        fontSize: fontSize*1.45,
                        fontFamily: 'Quicksand',
                        fontWeight: FontWeight.w500
                    )
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)
                ),
                insetPadding: EdgeInsets.only(right: fontSize*3, left: fontSize*3),
                actions: [
                  Center(
                      child: Icon(
                        size: width*0.2,
                        Icons.check_circle_outline_rounded,
                        color: Colors.green,
                      )
                  )
                ]
            )
        );
      },
    );

    setState(() {
      lastUploaded = DateTime.now();
    });

    saveLastUploaded(lastUploaded);

    await Future.delayed(Duration(seconds: 2));
    Navigator.pop(context);

    final scheduledTime = tz.TZDateTime.now(tz.local).add(Duration(seconds: 1));
    if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.paused) {
      await flutterNotification.scheduleNotification(
        id: 3,
        title: 'MindTrace',
        body: "The file has been successfully uploaded.",
        scheduledNotificationDateTime: scheduledTime,
      );
    }
  }

  Future<void> fetchData(double fontSize, double width, double height) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return SizedBox(
            width: width*0.7,
            height: height*0.4,
            child: AlertDialog(
                backgroundColor: Colors.white,
                content: Text("This process may take a few minutes. Please do not leave the app.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color(0xFF2A364E),
                        fontSize: fontSize*1.45,
                        fontFamily: 'Quicksand',
                        fontWeight: FontWeight.w500
                    )
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)
                ),
                insetPadding: EdgeInsets.only(right: fontSize*3, left: fontSize*3),
                actions: [
                  Center(
                      child: CircularProgressIndicator()
                  )
                ]
            )
        );
      },
    );

    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid.toString())
          .get();

      if (documentSnapshot.exists) {
        int setIndex = 0;
        List<String> currentTimestamps = [];
        List<String> currentMoods = [];
        List<List<String>> currentCategories = [];
        Map<int, List<String>> newTimestamps = {};
        Map<int, List<String>> newMoods = {};
        Map<int, List<List<String>>> newCategories = {};

        List<Map<String, dynamic>> data = (documentSnapshot.data() as Map<String, dynamic>).entries.map((entry) => {
          'timestamp': entry.key,
          'moods': entry.value[0],
          'categories': entry.value[1]
        }).toList();

        if (data.isEmpty) {
          await Future.delayed(Duration(seconds: 2));
          Navigator.pop(context);
          popup('Please log your mood before uploading.');
          print('Delay');
        } else {
          List<String> sortedTimestamps = data.map((entry) => entry['timestamp'].toString()).toList()..sort();

          for (String timestamp in sortedTimestamps) {
            var entry = data.firstWhere((entry) => entry['timestamp'].toString() == timestamp);

            String mood = entry['moods'];
            String category = entry['categories'];

            if (mood == 'Start') {
              currentTimestamps = [];
              currentCategories = [];
              currentMoods = [];
            } else if (mood == 'Finish') {
              newTimestamps[setIndex] = currentTimestamps;
              newCategories[setIndex] = currentCategories;
              newMoods[setIndex] = currentMoods;
              setIndex++;
            } else {
              currentTimestamps.add(timestamp);
              currentMoods.add(mood);

              if (category.isEmpty) {
                tsToPython = timestamp;
                await sendToPython();
                currentCategories.add(resultList);

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid.toString())
                    .update({
                  timestamp: [mood, result],
                });
                updated = true;
                uploadText = "File uploaded successfully.";

                print('Fetched categories: $result');
                resultList = [];
              } else {
                loopCompleted = true;
                updated = true;
                await Future.delayed(Duration(seconds: 2));
                uploadText = "The data is already up to date.";
              }
            }
          };

          if (sortedTimestamps.length - (2 * setIndex) == currentCategories.length) {
            loopCompleted = true;
          }

          if (loopCompleted && updated) {
            setState(() {
              timestampList = newTimestamps;
              moodList = newMoods;
              categoryList = newCategories;
              loopCompleted = false;
              updated = false;
            });
            Navigator.pop(context);
            await checkIcon(fontSize, width, height);
            print('All timestamps: $timestampList');
            print('All categories: $categoryList');
          }
        }
      } else {
        print('User document does not exist.');
        Navigator.pop(context);
        await Future.delayed(Duration(seconds: 2));
        popup('Please log your mood before uploading.');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  Future<void> sendToPython() async {
    Provider.of<TimerProvider>(context, listen: false).setSending(true);

    String pythonScriptUrl = 'http://16.170.236.95:5000/';
    try {
      print('Timestamp sent: $tsToPython');
      var request = http.MultipartRequest('POST', Uri.parse(pythonScriptUrl))
        ..fields['timestamp_r'] = tsToPython
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      // Send the request
      var response = await request.send();

      // Handle the response from the Python script
      if (response.statusCode == 200) {
        String pythonResponse = await response.stream.bytesToString();
        setState(() {
          result = pythonResponse;
          resultList.add(result);
        });
        Provider.of<TimerProvider>(context, listen: false).setSending(false);
      } else {
        print('Failed to communicate with Python server. Status code: ${response
            .statusCode}');
      }
    } catch (e) {
      print('Error sending file to Python server: $e');
    }
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedDateTime = '${dateTime.year.toString().padLeft(4, '0')}-'
        '${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}:'
        '${dateTime.second.toString().padLeft(2, '0')}';
    return formattedDateTime;
  }

  void popup(String message) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double fontSize = width * 0.04;

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
              backgroundColor: Colors.white,
              content: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF2A364E),
                  fontSize: fontSize,
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.w500
                ),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(width*0.047)
              ),
              insetPadding: EdgeInsets.only(right: (0.15*width), left: (0.15*width)),
              actions: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          alignment: Alignment.center,
                          child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                fixedSize: Size((0.19*width), (0.02*height)),
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                elevation: 2.0,
                              ),
                              child: Text(
                                  'OK',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Color(0xFF2A364E),
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.normal
                                  )
                              )
                          )
                      )
                    ]
                )
              ]
          );
        }
    );
  }

  Widget moodBox(BuildContext context, double fontSize, double width, double height) {
    if (Provider.of<TimerProvider>(context).isSubmitted == true) {
      iconColor = Colors.grey.shade800;
      iconColor2 = Colors.grey.shade800;
      iconColor3 = Colors.grey.shade800;
      circleColor = Colors.white60;
      circleColor2 = Colors.white60;
      circleColor3 = Colors.white60;
      isSelected = false;
      isSelected2 = false;
      isSelected3 = false;

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              child: ElevatedButton (
                  onPressed: () {
                    Provider.of<TimerProvider>(context, listen: false).setSubmit(false);
                    Provider.of<TimerProvider>(context, listen: false).setStart(false);
                    Provider.of<TimerProvider>(context, listen: false).setContinue(true);
                  },
                  child: Text(
                      'Continue',
                      style: TextStyle(
                        fontFamily: "Quicksand",
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: Color(0xFF49688D),
                        fontSize: fontSize * 1.4,
                      )
                  ),
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(width*0.35, height*0.048),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)
                    ),
                    elevation: 2.0,
                  )
              )
          ),
          Container(
              margin: EdgeInsets.only(top: height*0.002),
              child: Text(
                  "Keep watching TikTok and\n return to log mood later.",
                  style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.w500,
                      fontSize: fontSize,
                      color: Colors.grey.shade700,
                      height: 1
                  )
              )
          ),
          Container(
            margin: EdgeInsets.only(top: height*0.02, bottom:height*0.025),
            child: Text(
              'OR',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: fontSize * 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
              child: ElevatedButton (
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid.toString())
                        .set({formatTimestamp(Timestamp.now()).toString(): [
                      'Finish',
                      ''
                    ]},
                        SetOptions(merge: true)
                    );

                    await flutterNotification.cancelNotification(4);
                    Provider.of<TimerProvider>(context, listen: false).setSubmit(false);
                    Provider.of<TimerProvider>(context, listen: false).setStart(true);
                  },
                  child: Text(
                      'Finish',
                      style: TextStyle(
                        fontFamily: "Quicksand",
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: Color(0xFF49688D),
                        fontSize: fontSize * 1.4,
                      )
                  ),
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(0.3 * width, 0.045 * height),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)
                    ),
                    elevation: 2.0,
                  )
              )
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              child: Column(
                children: <Widget>[
                  Text(
                      'How are you feeling?',
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: fontSize*1.5,
                        fontWeight: FontWeight.w500,
                      )
                  ),
                  Container(
                      width: width*0.8,
                      height: height*0.11,
                      margin: EdgeInsets.only(top: height*0.02),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  AnimatedContainer(
                                    duration: Duration(milliseconds: 300),
                                    width: isSelected ? width * 0.14 : width * 0.12,
                                    height: isSelected ? width * 0.14 : width * 0.12,
                                    decoration: ShapeDecoration(
                                      color: circleColor,
                                      shape: CircleBorder(),
                                    ),
                                    child: IconButton(
                                      isSelected: isSelected,
                                      icon: const Icon(Icons.sentiment_very_dissatisfied),
                                      iconSize: isSelected ? width * 0.1 : width * 0.08,
                                      color: iconColor,
                                      onPressed: () {
                                        setState(() {
                                          isSelected = true;
                                          isSelected2 = false;
                                          isSelected3 = false;
                                          selectedEmoji = 'Low';
                                          iconColor = Colors.white;
                                          iconColor2 = Colors.grey.shade800;
                                          iconColor3 = Colors.grey.shade800;
                                          circleColor = Colors.deepPurple;
                                          circleColor2 = Colors.white60;
                                          circleColor3 = Colors.white60;
                                        });
                                      },
                                    ),
                                  ),
                                  Text(
                                    'Low',
                                    style: TextStyle(
                                      fontSize: fontSize * 1.2,
                                      fontFamily: 'Quicksand',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(width: width * 0.1),
                              Column(
                                children: [
                                  AnimatedContainer(
                                    duration: Duration(milliseconds: 300),
                                    width: isSelected2 ? width * 0.14 : width * 0.12,
                                    height: isSelected2 ? width * 0.14 : width * 0.12,
                                    decoration: ShapeDecoration(
                                      color: circleColor2,
                                      shape: CircleBorder(),
                                    ),
                                    child: IconButton(
                                      isSelected: isSelected2,
                                      icon: Icon(Icons.sentiment_neutral),
                                      iconSize: isSelected2 ? width * 0.1 : width * 0.08,
                                      color: iconColor2,
                                      splashColor: Colors.grey,
                                      onPressed: () {
                                        setState(() {
                                          isSelected = false;
                                          isSelected2 = true;
                                          isSelected3 = false;
                                          selectedEmoji = 'OK';
                                          iconColor = Colors.grey.shade800;
                                          iconColor2 = Colors.white;
                                          iconColor3 = Colors.grey.shade800;
                                          circleColor = Colors.white60;
                                          circleColor2 = Colors.deepPurple;
                                          circleColor3 = Colors.white60;
                                        });
                                      },
                                    ),
                                  ),
                                  Text(
                                    'OK',
                                    style: TextStyle(
                                      fontSize: fontSize * 1.2,
                                      fontFamily: 'Quicksand',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(width: width * 0.1),
                              Column(
                                children: [
                                  AnimatedContainer(
                                    duration: Duration(milliseconds: 300),
                                    width: isSelected3 ? width * 0.14 : width * 0.12,
                                    height: isSelected3 ? width * 0.14 : width * 0.12,
                                    decoration: ShapeDecoration(
                                      color: circleColor3,
                                      shape: CircleBorder(),
                                    ),
                                    child: IconButton(
                                      isSelected: isSelected3,
                                      icon: Icon(Icons.sentiment_very_satisfied),
                                      iconSize: isSelected3 ? width * 0.1 : width * 0.08,
                                      color: iconColor3,
                                      onPressed: () {
                                        setState(() {
                                          isSelected = false;
                                          isSelected2 = false;
                                          isSelected3 = true;
                                          selectedEmoji = 'High';
                                          iconColor = Colors.grey.shade800;
                                          iconColor2 = Colors.grey.shade800;
                                          iconColor3 = Colors.white;
                                          circleColor = Colors.white60;
                                          circleColor2 = Colors.white60;
                                          circleColor3 = Colors.deepPurple;
                                        });
                                      },
                                    ),
                                  ),
                                  Text(
                                    'High',
                                    style: TextStyle(
                                      fontSize: fontSize * 1.2,
                                      fontFamily: 'Quicksand',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                ],
                              )
                            ],
                          )
                        ],
                      )
                  ),
                ],
              )
          ),
          Container(
              margin: EdgeInsets.only(top: height*0.02),
              child: ElevatedButton (
                  onPressed: () async {
                    if (isSelected==true || isSelected2==true || isSelected3==true) {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid.toString())
                          .set({formatTimestamp(Timestamp.now()).toString(): [
                        selectedEmoji,
                        ''
                      ]},
                          SetOptions(merge: true)
                      );
                      await flutterNotification.cancelNotification(4);
                      setState(() {
                        Provider.of<TimerProvider>(context, listen: false).setSubmit(true);
                        Provider.of<TimerProvider>(context, listen: false).setNotification(false);
                      });
                    } else {
                      popup('Please select an option.');
                    }
                  },
                  child: Text(
                      'Submit',
                      style: TextStyle(
                        fontFamily: "Quicksand",
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: Color(0xFF49688D),
                        fontSize: fontSize * 1.4,
                      )
                  ),
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(0.28 * width, 0.04 * height),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)
                    ),
                    elevation: 2.0,
                  )
              )
          ),
          Container(
              margin: EdgeInsets.only(top: height*0.005),
              child: GestureDetector(
                  onTap: () {
                    if (Provider.of<TimerProvider>(context, listen: false).continued == true){
                      Provider.of<TimerProvider>(context, listen: false).setSubmit(true);
                    } else {
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid.toString())
                          .update({formatTimestamp(startTimestamp).toString(): FieldValue.delete()})
                          .then((_) {
                        print("Entry deleted successfully.");
                      })
                          .catchError((error) {
                        print("Failed to delete entry: $error");
                      });
                      Provider.of<TimerProvider>(context, listen: false).setStart(true);
                    }
                  },
                  child: Text(
                      'Cancel',
                      style: TextStyle(
                          fontSize: fontSize*1.2,
                          fontFamily: 'Quicksand',
                          decoration: TextDecoration.underline
                      )
                  )
              )
          )
        ],
      );
    }
  }

  Widget moodBox2(BuildContext context, double fontSize, double width, double height) {
    iconColor = Colors.grey.shade800;
    iconColor2 = Colors.grey.shade800;
    iconColor3 = Colors.grey.shade800;
    circleColor = Colors.white60;
    circleColor2 = Colors.white60;
    circleColor3 = Colors.white60;
    isSelected = false;
    isSelected2 = false;
    isSelected3 = false;
    Provider.of<TimerProvider>(context).isSubmitted == false;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Are you watching TikTok?',
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: fontSize * 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
            margin: EdgeInsets.only(top: height*0.025),
            child: ElevatedButton (
                onPressed: () async {
                  startTimestamp = Timestamp.now();
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid.toString())
                      .set({formatTimestamp(startTimestamp).toString(): [
                    'Start',
                    ''
                  ]},
                      SetOptions(merge: true)
                  );
                  Provider.of<TimerProvider>(context, listen: false).setStart(false);
                },
                child: Text(
                    'Yes',
                    style: TextStyle(
                      fontFamily: "Quicksand",
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: Color(0xFF49688D),
                      fontSize: fontSize * 1.6,
                    )
                ),
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(0.28 * width, 0.045 * height),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)
                  ),
                  elevation: 2.0,
                )
            )
        ),
      ],
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
            body: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(top: height*0.09, right: width * 0.2),
                        child: DecoratedBox(
                              decoration: BoxDecoration(
                                  color: Color(0xFFD9F6FF),
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(width*0.08),
                                      bottomRight: Radius.circular(width*0.08)
                                  )
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                      height: height*0.0125
                                  ),
                                  Container(
                                    margin: EdgeInsets.symmetric(horizontal: width*0.04),
                                    alignment: Alignment.topLeft,
                                    child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: RichText(
                                        text: TextSpan(
                                          style: TextStyle(
                                            letterSpacing: width*0.0006,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: 'Hello,',
                                              style: TextStyle(
                                                fontSize: fontSize * 2.5,
                                                color: Colors.black,
                                                fontFamily: 'Quicksand',
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            TextSpan(
                                              text: ' ${extractFirstName(username)}!',
                                              style: TextStyle(
                                                fontSize: fontSize * 2.5,
                                                color: Color(0xFF2A364E),
                                                fontFamily: 'PaytoneOne',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                      margin: EdgeInsets.only(left: width*0.04),
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                          "Time to track your mood!",
                                          style: TextStyle(
                                              fontFamily: 'Quicksand',
                                              fontWeight: FontWeight.w500,
                                              fontSize: fontSize,
                                              color: Colors.grey.shade700
                                          )
                                      )
                                  ),
                                  SizedBox(
                                      height: height*0.02
                                  )
                                ],
                          ),
                        ),
                      ),
                      Container(
                          alignment: Alignment.topLeft,
                          margin: EdgeInsets.only(top: height*0.03, bottom: height*0.01, left: width*0.075),
                          child: Text(
                              'Log your mood',
                              style: TextStyle(
                                  fontFamily: 'Quicksand',
                                  fontWeight: FontWeight.w500,
                                  fontSize: fontSize*1.1,
                                  color: Colors.grey.shade700
                              )
                          )
                      ),
                      Container(
                        child: SizedBox(
                          width: width * 0.85,
                          height: height * 0.3,
                          child: DecoratedBox(
                              decoration: BoxDecoration(
                                  color: Color(0xFFC9B4ED),
                                  borderRadius: BorderRadius.all(Radius.circular(width*0.08))
                              ),
                              child: Provider.of<TimerProvider>(context).start ? moodBox2(context, fontSize, width, height) : moodBox(context, fontSize, width, height)
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.only(top: height*0.03, left: width*0.075),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                                child: Text(
                                    'Upload TikTok browsing history',
                                    style: TextStyle(
                                        fontFamily: 'Quicksand',
                                        fontWeight: FontWeight.w500,
                                        fontSize: fontSize*1.1,
                                        color: Colors.grey.shade700
                                    )
                                )
                            ),
                            SizedBox(
                                width: width*0.01
                            ),
                            Container(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageTransition(
                                      type: PageTransitionType.fade,
                                      child: TSlider(),
                                    ),
                                  );
                                },
                                child: Icon(
                                    Icons.info,
                                    color: Colors.grey.shade700,
                                    size: width*0.05
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: height*0.01),
                        child: SizedBox(
                          width: width * 0.85,
                          height: height * 0.3,
                          child: DecoratedBox(
                              decoration: BoxDecoration(
                                  color: Color(0xFFFFE0DB),
                                  borderRadius: BorderRadius.all(Radius.circular(width*0.08))
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                      child: Column(
                                        children: [
                                          Container(
                                              margin: EdgeInsets.only(left: width*0.1, right: width*0.1),
                                              child: Text(
                                                "Tap the 'i' icon to see how to download your TikTok browsing history.",
                                              )
                                          )
                                        ],
                                      )
                                  ),
                                  Container(
                                      margin: EdgeInsets.only(top: height*0.03, bottom: height*0.03),
                                      alignment: Alignment.center,
                                      child: ElevatedButton (
                                          onPressed: () async {
                                            await pickFile(fontSize, width, height);
                                          },
                                          child: Text(
                                              'Upload File',
                                              style: TextStyle(
                                                fontFamily: "Quicksand",
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.5,
                                                color: Color(0xFF2A364E),
                                                fontSize: fontSize * 1.4,
                                              )
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            fixedSize: Size(0.4 * width, 0.055 * height),
                                            backgroundColor: Color(0xFFFFF8EA),
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(100)
                                            ),
                                            elevation: 2.0,
                                          )
                                      )
                                  ),
                                  Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                          'Last uploaded: $lastUploadedText',
                                          style: TextStyle(
                                              fontFamily: 'Quicksand',
                                              fontSize: fontSize*1.1,
                                              color: Colors.grey.shade700
                                          )
                                      )
                                  ),
                                ],
                              )
                          ),
                        ),
                      ),
                      SizedBox(
                          width: width,
                          height: height*0.15
                      )
                    ]
                )
            )
        )
    );
  }
}