import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mind_trace/slider.dart';
import 'dart:async';
import 'dart:io';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class TimerProvider extends ChangeNotifier {
  late Timer _timer;
  bool _isSubmitted = false;
  bool _start = true;
  bool _continued = false;
  bool get isSubmitted => _isSubmitted;
  bool get start => _start;
  bool get continued => _continued;
  Timer get timer => _timer;

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

class _AddState extends State<Add> {
  final user = FirebaseAuth.instance.currentUser!;
  String result = '';
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


  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<void> pickFile(double fontSize) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);

      await sendToPython(file, fontSize);
    } else {
      print("User canceled file picking");
    }
  }

  Future<void> sendToPython(File file, double fontSize) async {
    String pythonScriptUrl = 'http://16.170.236.95:5000/';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
            backgroundColor: Colors.white,
            content: Text(
                "This might take a few minutes. Please don't leave the app.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color(0xFF2A364E),
                    fontSize: fontSize*1.45,
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.w600
                )
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)
            ),
            insetPadding: EdgeInsets.only(right: (3*fontSize), left: (3*fontSize)),
            actions: [
              Center(
                  child: CircularProgressIndicator()
              )
            ]
        );
      },
    );

    try {
      // Create a multipart request
      var request = http.MultipartRequest('POST', Uri.parse(pythonScriptUrl))
        ..fields['timestamp_r'] = '2024-01-23 12:11:49'
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      // Send the request
      var response = await request.send();

      // Handle the response from the Python script
      if (response.statusCode == 200) {
        String pythonResponse = await response.stream.bytesToString();
        setState(() {
          result = pythonResponse;
        });
        Navigator.pop(context);
      } else {
        Navigator.pop(context);
        print('Failed to communicate with Python server. Status code: ${response.statusCode}');
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

  void popup() {
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
                'Please select an option.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF2A364E),
                  fontSize: fontSize,
                  fontFamily: 'Quicksand',
                ),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)
              ),
              insetPadding: EdgeInsets.only(right: (0.1*width), left: (0.1*width)),
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
                                      fontWeight: FontWeight.w400
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
                    fixedSize: Size(0.3 * width, 0.045 * height),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)
                    ),
                    elevation: 2.0,
                  )
              )
          ),
          Container(
            margin: EdgeInsets.only(top: height*0.025, bottom:height*0.025),
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
                        .set({formatTimestamp(Timestamp.now()).toString(): 'Finish'},
                        SetOptions(merge: true)
                    );
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
                    fixedSize: Size(0.28 * width, 0.04 * height),
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
                          .set({formatTimestamp(Timestamp.now()).toString(): selectedEmoji},
                          SetOptions(merge: true)
                      );
                      Provider.of<TimerProvider>(context, listen: false).setSubmit(true);
                    } else {
                      popup();
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
                    if (startTimestamp != null) {
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
                    }
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
                        .set({formatTimestamp(startTimestamp).toString(): 'Start'},
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
                child: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(top: height*0.1),
                            child: SizedBox(
                              width: width * 0.8,
                              height: height * 0.3,
                              child: DecoratedBox(
                                  decoration: BoxDecoration(
                                      color: Color(0xFFC9B4ED),
                                      borderRadius: BorderRadius.all(Radius.circular(30))
                                  ),
                                  child: Provider.of<TimerProvider>(context).start ? moodBox2(context, fontSize, width, height) : moodBox(context, fontSize, width, height)
                              ),
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.only(top: height*0.05),
                              child: Column(
                                children: [
                                  Container(
                                      margin: EdgeInsets.only(left: width*0.125, right: width*0.125),
                                      child: Text(
                                        "Tap the 'i' icon to see how to download your TikTok browsing history.",
                                      )
                                  )
                                ],
                              )
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                  margin: EdgeInsets.only(top: height*0.02),
                                  child: ElevatedButton (
                                      onPressed: () async {
                                        await pickFile(fontSize);
                                      },
                                      child: Text(
                                          'Choose File',
                                          style: TextStyle(
                                            fontFamily: "Quicksand",
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                            color: Colors.white,
                                            fontSize: fontSize * 1.6,
                                          )
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        fixedSize: Size(0.45 * width, 0.06 * height),
                                        backgroundColor: Color(0xFF49688D),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(100)
                                        ),
                                        elevation: 2.0,
                                      )
                                  )
                              ),
                              Container(
                                margin: EdgeInsets.only(top: height * 0.02, left: width * 0.02),
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
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                              margin: EdgeInsets.only(top: (0.03*height)),
                              child: Text(
                                  'Result: $result',
                                  style: TextStyle(
                                    fontFamily: "Quicksand",
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                    color: Colors.black,
                                    fontSize: fontSize * 1.6,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.clip
                              )
                          ),
                        ]
                    )
                )
            )
        )
    );
  }
}