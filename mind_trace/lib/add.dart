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
                      Container(
                          child: ElevatedButton (
                              onPressed: () async {
                                await pickFile();
                                print('Click');
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