import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

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
  bool isSubmitted = false;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);

      // Now you have the file, you can send it to Python
      await sendToPython(file);
    } else {
      print("User canceled file picking");
    }
  }

  Future<void> sendToPython(File file) async {
    String pythonScriptUrl = 'http://127.0.0.1:5000/';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // Create a multipart request
      var request = http.MultipartRequest('POST', Uri.parse(pythonScriptUrl));

      // Attach the file to the request
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

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
                    fontSize: fontSize
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
                      SizedBox(
                        width: width * 0.8,
                        height: height * 0.3,
                        child: DecoratedBox(
                            decoration: BoxDecoration(
                                color: Color(0xFFC9B4ED),
                                borderRadius: BorderRadius.all(Radius.circular(30))
                            ),
                            child: Column(
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
                                            margin: EdgeInsets.only(top: height*0.025),
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
                                    margin: EdgeInsets.only(top: height*0.025),
                                    child: ElevatedButton (
                                        onPressed: () async {
                                          if (isSelected==true || isSelected2==true || isSelected3==true) {
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(user.uid.toString())
                                                .set({formatTimestamp(Timestamp.now()).toString(): selectedEmoji},
                                                SetOptions(merge: true)
                                            );
                                            isSubmitted = true;
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
                              ],
                            )
                        ),// Empty container to occupy the space
                      ),
                      Container(
                          margin: EdgeInsets.only(top: height*0.05),
                          child: ElevatedButton (
                              onPressed: () async {
                                await pickFile();
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
                          margin: EdgeInsets.only(top: (0.05*height)),
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
                      )
                    ]
                )
            )
        )
    );
  }
}