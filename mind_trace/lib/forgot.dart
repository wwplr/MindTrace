import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'home_page.dart';
import 'login.dart';

class Forgot extends StatefulWidget {
  const Forgot({super.key});

  @override
  State<Forgot> createState() => _ForgotState();
}

class _ForgotState extends State<Forgot> {
  final _emailController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;
  String email = '';

  void checkValidation() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        Future.delayed(Duration(milliseconds: 1250), () {
          Navigator.pop(ctx);
        });
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      if (_emailController.text.isNotEmpty) {
        setState(() {
          email = _emailController.text;
        });
        await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text);
        popup2();
        await Future.delayed(Duration(seconds: 3));
        Navigator.pop(context);
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.fade,
            child: Login(),
          ),
        );
      } else {
        Navigator.pop(context);
        popup('Please enter your email.');
      }
    } on FirebaseAuthException {
      Navigator.pop(context);
      popup('Email address not found. Please enter a valid one.');
    }
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

  Future<void> popup2() async {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double fontSize = width * 0.04;

    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            content: Container(
              height: height*0.052,
              child: Text(
                'A password reset link has been sent to your email.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Quicksand',
                    color: Color(0xFF2A364E),
                    fontSize: fontSize
                )
              ),
            ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)
              ),
              insetPadding: EdgeInsets.only(right: fontSize*3, left: fontSize*3),
              actions: [
                Center(
                    child: Icon(
                      size: width*0.1,
                      Icons.mark_email_read_outlined,
                      color: Colors.black,
                    )
                )
              ]
          );
        },
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double fontSize = width * 0.04;

    return PopScope(
        canPop: false,
        child: Scaffold(
            backgroundColor: Color(0xFFC6F2FF),
            floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
            floatingActionButton: IconButton(
              icon: Icon(
                  Icons.arrow_back,
                  color: Color(0xFF2A364E)
              ),
              onPressed: () => Navigator.pop(context),
            ),
            body: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.topLeft,
                      margin: EdgeInsets.only(top: (0.15*height), left: (0.15*width)),
                      child: Text(
                          'Forgot Password',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontFamily: "Montserrat",
                              fontSize: fontSize*2.5,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.normal,
                              height: 1.2,
                              letterSpacing: width*0.001,
                              color: Color(0xFF2A364E)
                          )
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.only(top: height*0.05, left: (0.125*width), right: (0.125*width)),
                        child: Text(
                          "We'll send a password reset link to the email address you enter below.",
                          style: TextStyle(
                            fontSize: fontSize*0.9,
                            fontFamily: 'Quicksand',
                          ),
                        )
                    ),
                    Container (
                        margin: EdgeInsets.only(top: height*0.015, left: (0.09*width), right: (0.09*width)),
                        height: 0.25*height,
                        decoration: BoxDecoration(
                            color: Color(0xFFFFF8EA),
                            borderRadius: BorderRadius.all(Radius.circular(30))
                        ),
                        child: Center(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                      margin: EdgeInsets.only(left: (0.1*width), right: (0.1*width)),
                                      child: Form(
                                          child: TextFormField(
                                            controller: _emailController,
                                            enableSuggestions: false,
                                            enableInteractiveSelection: false,
                                            style: TextStyle(
                                                fontSize: fontSize,
                                                fontFamily: "Quicksand",
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: 0.5,
                                                color: Color(0xFF2A364E)
                                            ),
                                            maxLines: 1,
                                            cursorColor: Color(0xFF2A364E),
                                            decoration: InputDecoration(
                                              hintText: 'Email address',
                                              hintStyle: TextStyle(
                                                  fontSize: fontSize,
                                                  fontFamily: "Quicksand",
                                                  fontWeight: FontWeight.w500,
                                                  letterSpacing: 0.5,
                                                  color: Color(0xFF2A364E)
                                              ),
                                              suffixIconColor: Color(0xFF2A364E),
                                              enabledBorder: const UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Color(0xFF2A364E)
                                                ),
                                              ),
                                            ),
                                          )
                                      )
                                  ),
                                  Container(
                                      margin: EdgeInsets.only(top: height*0.045),
                                      child: ElevatedButton(
                                          onPressed: () {
                                            checkValidation();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            fixedSize: Size(0.35*width, 0.055*height),
                                            backgroundColor: Color(0xFFA986E4),
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(100)
                                            ),
                                            elevation: 2.0,
                                          ),
                                          child: Text('Reset',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontFamily: "Quicksand",
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0.5,
                                                  color: Colors.white,
                                                  fontSize: fontSize*1.25,
                                                  height: 1
                                              )
                                          )
                                      )
                                  ),
                                ]
                            )
                        )
                    )
                  ],
                )
            )
        )
    );
  }
}