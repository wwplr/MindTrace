import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'home_page.dart';

class Reset extends StatefulWidget {
  const Reset({super.key});

  @override
  State<Reset> createState() => _ResetState();
}

class _ResetState extends State<Reset> {
  final _passwordController = TextEditingController();
  final _passwordController2 = TextEditingController();
  final _currentPassword = TextEditingController();
  bool _securedPassword = true;
  bool _securedPassword2 = true;
  bool _securedPassword3 = true;
  Color colour = Color(0xFF2A364E);
  Color colour2 = Color(0xFF2A364E);
  Color colour3 = Color(0xFF2A364E);
  Color colour4 = Color(0xFF2A364E);
  final user = FirebaseAuth.instance.currentUser!;

  void checkValidation() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        Future.delayed(Duration(milliseconds: 600), () {
          Navigator.pop(ctx);
        });
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    if (
    _passwordController.text.isNotEmpty &&
        (!_passwordController.text.contains(RegExp('[A-Z]')) ||
            !_passwordController.text.contains(RegExp('[a-z]')) ||
            !_passwordController.text.contains(RegExp('[0-9]')) ||
            _passwordController.text.length < 8)
    ) {
      popup('Password is too weak.');
    }

    if (_passwordController.text.isNotEmpty &&
        _passwordController2.text.isNotEmpty &&
        _passwordController.text != _passwordController2.text &&
        _passwordController.text.contains(RegExp('[A-Z]')) &&
        _passwordController.text.contains(RegExp('[a-z]')) &&
        _passwordController.text.contains(RegExp('[0-9]')) &&
        _passwordController.text.length >= 8
    )
    {
      popup('Passwords do not match.');
    }

    if ((_passwordController.text.isEmpty &&
        _passwordController2.text.isNotEmpty) ||
        (_passwordController.text.isEmpty &&
            _passwordController2.text.isEmpty)
    ) {
      popup('Please enter your password.');
    }

    if (_passwordController2.text.isEmpty &&
        _passwordController.text.isNotEmpty) {
      popup('Please confirm your password.');
    }

    if (_currentPassword.text.isEmpty) {
      popup('Please enter your current password.');
    }

    if ((_currentPassword.text.isEmpty ||
        _passwordController.text.isEmpty &&
        _passwordController2.text.isEmpty) ||
        (_passwordController.text.isEmpty &&
            _passwordController2.text.isEmpty)||
        (_passwordController.text.isEmpty &&
            _passwordController2.text.isEmpty)
    ) {
      popup('Please enter your information.');
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

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            content: Container(
              height: height*0.05,
              child: Center(
                child: Text(
                  'Your password has been reset.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Quicksand',
                      color: Color(0xFF2A364E),
                      fontSize: fontSize
                  ),
                ),
              )
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)
            ),
            insetPadding: EdgeInsets.only(right: (0.1*width), left: (0.1*width)),
          );
        }
    );
    await Future.delayed(Duration(seconds: 2));

    Navigator.pop(context);
  }

  Future<void> changePassword(String currentPassword, String newPassword, String email) async {
    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      await user.updatePassword(newPassword);
      await popup2();
      print('Password changed successfully.');
      Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.fade,
            child: HomePage(),
          )
      );
    } catch (e) {
      popup('Your current password is incorrect. Please try again.');
      print('Error changing password: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double fontSize = width * 0.04;

    return PopScope(
        canPop: false,
        child: Scaffold(
            floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
            floatingActionButton: IconButton(
              icon: Icon(
                  Icons.arrow_back,
                  color: Color(0xFF2A364E)
              ),
              onPressed: () => Navigator.pop(context),
            ),
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
                child: Center(
                  child: Stack(
                      children: <Widget>[
                        Positioned(
                            top: 0,
                            child: Container(
                              width: width,
                              height: 0.65*height,
                              margin: EdgeInsets.only(bottom: (0.3*height)),
                              decoration: BoxDecoration(
                                  color: Color(0xFFC6F2FF),
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(90),
                                      bottomRight: Radius.circular(90)
                                  )
                              ),
                              child: Container(
                                  alignment: Alignment.topLeft,
                                  margin: EdgeInsets.only(top: (0.15*height), left: (0.15*width)),
                                  child: Text(
                                      'Change \nPassword',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontFamily: "Montserrat",
                                          fontSize: fontSize*2.5,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.normal,
                                          height: 1.2,
                                          letterSpacing: 0.25,
                                          color: Color(0xFF2A364E)
                                      )
                                  )
                              ),
                            )
                        ),
                        Container (
                            margin: EdgeInsets.only(bottom: 0, top: (0.325*height), left: (0.09*width), right: (0.09*width)),
                            height: 0.55*height,
                            decoration: BoxDecoration(
                                color: Color(0xFFFFF8EA),
                                borderRadius: BorderRadius.all(Radius.circular(30))
                            ),
                            child: Center(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                          padding: EdgeInsets.only(left: (0.1*width), right: (0.1*width)),
                                          child: Form(
                                              child: TextFormField(
                                                controller: _currentPassword,
                                                obscureText: _securedPassword3,
                                                enableSuggestions: false,
                                                enableInteractiveSelection: false,
                                                autocorrect: false,
                                                style: TextStyle(
                                                    fontSize: fontSize*1,
                                                    fontFamily: "Quicksand",
                                                    fontWeight: FontWeight.w500,
                                                    letterSpacing: 0.5,
                                                    color: Color(0xFF2A364E)
                                                ),
                                                maxLines: 1,
                                                cursorColor: Color(0xFF2A364E),
                                                decoration: InputDecoration(
                                                  contentPadding: EdgeInsets.only(top: height*0.015, left: width*0.005),
                                                  hintText: 'Current Password',
                                                  hintStyle: TextStyle(
                                                      fontSize: fontSize,
                                                      fontFamily: "Quicksand",
                                                      fontWeight: FontWeight.w500,
                                                      letterSpacing: 0.5,
                                                      color: Color(0xFF2A364E)
                                                  ),
                                                  suffixIcon: togglePassword3(),
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
                                          padding: EdgeInsets.only(left: (0.1*width), right: (0.1*width), top: (0.02*height)),
                                          child: Form(
                                              child: TextFormField(
                                                controller: _passwordController,
                                                obscureText: _securedPassword,
                                                enableSuggestions: false,
                                                enableInteractiveSelection: false,
                                                autocorrect: false,
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
                                                  contentPadding: EdgeInsets.only(top: height*0.015, left: width*0.005),
                                                  hintText: 'Password',
                                                  hintStyle: TextStyle(
                                                      fontSize: fontSize,
                                                      fontFamily: "Quicksand",
                                                      fontWeight: FontWeight.w500,
                                                      letterSpacing: 0.5,
                                                      color: Color(0xFF2A364E)
                                                  ),
                                                  suffixIcon: togglePassword(),
                                                  suffixIconColor: Color(0xFF2A364E),
                                                  enabledBorder: const UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Color(0xFF2A364E)
                                                    ),
                                                  ),
                                                ),
                                                onChanged: (value) {
                                                  setState(() {
                                                    value = _passwordController.text;
                                                    if (value.contains(RegExp('[A-Z]'))) {
                                                      colour = Colors.green.shade700;
                                                    } else {
                                                      colour = Colors.red.shade900;
                                                    }

                                                    if (value.contains(RegExp('[a-z]'))) {
                                                      colour2 = Colors.green.shade700;
                                                    } else {
                                                      colour2 = Colors.red.shade900;
                                                    }

                                                    if (value.contains(RegExp('[0-9]'))) {
                                                      colour3 = Colors.green.shade700;
                                                    } else {
                                                      colour3 = Colors.red.shade900;
                                                    }

                                                    if (value.length >= 8) {
                                                      colour4 = Colors.green.shade700;
                                                    } else {
                                                      colour4 = Colors.red.shade900;
                                                    }
                                                  });
                                                },
                                              )
                                          )
                                      ),
                                      Container(
                                          padding: EdgeInsets.only(left: (0.1*width), right: (0.1*width), top: (0.02*height)),
                                          child: Form(
                                              child: TextFormField(
                                                controller: _passwordController2,
                                                obscureText: _securedPassword2,
                                                enableSuggestions: false,
                                                enableInteractiveSelection: false,
                                                autocorrect: false,
                                                style: TextStyle(
                                                    fontSize: fontSize*1,
                                                    fontFamily: "Quicksand",
                                                    fontWeight: FontWeight.w500,
                                                    letterSpacing: 0.5,
                                                    color: Color(0xFF2A364E)
                                                ),
                                                maxLines: 1,
                                                cursorColor: Color(0xFF2A364E),
                                                decoration: InputDecoration(
                                                  contentPadding: EdgeInsets.only(top: height*0.015, left: width*0.005),
                                                  hintText: 'Confirm Password',
                                                  hintStyle: TextStyle(
                                                      fontSize: fontSize,
                                                      fontFamily: "Quicksand",
                                                      fontWeight: FontWeight.w500,
                                                      letterSpacing: 0.5,
                                                      color: Color(0xFF2A364E)
                                                  ),
                                                  suffixIcon: togglePassword2(),
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
                                      Container (
                                          margin: EdgeInsets.only(top: (0.05*height), left: (0.1*width)),
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'An uppercase character',
                                            style: TextStyle(
                                                fontSize: fontSize*0.85,
                                                fontFamily: "Quicksand",
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: 0.5,
                                                color: colour
                                            ),
                                          )
                                      ),
                                      Container (
                                          margin: EdgeInsets.only(top: (0.005*height), left: (0.1*width)),
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'A lowercase character',
                                            style: TextStyle(
                                                fontSize: fontSize*0.85,
                                                fontFamily: "Quicksand",
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: 0.5,
                                                color: colour2
                                            ),
                                          )
                                      ),
                                      Container (
                                          margin: EdgeInsets.only(top: (0.005*height), left: (0.1*width)),
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'A number',
                                            style: TextStyle(
                                                fontSize: fontSize*0.85,
                                                fontFamily: "Quicksand",
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: 0.5,
                                                color: colour3
                                            ),
                                          )
                                      ),
                                      Container (
                                          margin: EdgeInsets.only(top: (0.005*height), left: (0.1*width)),
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'At least 8 characters',
                                            style: TextStyle(
                                                fontSize: fontSize*0.85,
                                                fontFamily: "Quicksand",
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: 0.5,
                                                color: colour4
                                            ),
                                          )
                                      ),
                                      Container(
                                          margin: EdgeInsets.only(top: (0.05*height)),
                                          child: ElevatedButton(
                                              onPressed: () async {
                                                final email = FirebaseAuth.instance.currentUser!;

                                                if (_passwordController.text != _passwordController2.text ||
                                                    !_passwordController.text.contains(RegExp('[A-Z]')) ||
                                                    !_passwordController.text.contains(RegExp('[a-z]')) ||
                                                    !_passwordController.text.contains(RegExp('[0-9]')) ||
                                                    _passwordController.text.length < 8 ||
                                                    _passwordController.text.isEmpty ||
                                                    _passwordController2.text.isEmpty)
                                                {
                                                  checkValidation();
                                                } else {
                                                  await changePassword(_currentPassword.text, _passwordController2.text, email.email!);
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                fixedSize: Size(0.45*width, 0.06*height),
                                                backgroundColor: Color(0xFF49688D),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(100)
                                                ),
                                                elevation: 2.0,
                                              ),
                                              child: Text('Change',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontFamily: "Quicksand",
                                                    fontWeight: FontWeight.w500,
                                                    letterSpacing: 0.5,
                                                    color: Colors.white,
                                                    fontSize: fontSize*1.4,
                                                  )
                                              )
                                          )
                                      ),
                                    ]
                                )
                            )
                        )
                      ]
                  ),
                )
            )
        )
    );
  }

  Widget togglePassword(){
    return IconButton(
        onPressed: (){
          setState(() {
            _securedPassword = !_securedPassword;
          });
        },
        icon: _securedPassword ? const Icon(Icons.visibility) : const Icon(Icons.visibility_off)
    );
  }

  Widget togglePassword2(){
    return IconButton(
        onPressed: (){
          setState(() {
            _securedPassword2 = !_securedPassword2;
          });
        },
        icon: _securedPassword2 ? const Icon(Icons.visibility) : const Icon(Icons.visibility_off)
    );
  }
  Widget togglePassword3(){
    return IconButton(
        onPressed: (){
          setState(() {
            _securedPassword3 = !_securedPassword3;
          });
        },
        icon: _securedPassword3 ? const Icon(Icons.visibility) : const Icon(Icons.visibility_off)
    );
  }
}