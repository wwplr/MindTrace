import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mind_trace/home_page.dart';
import 'package:page_transition/page_transition.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool _securedPassword = true;
  bool _securedPassword2 = true;
  Color colour = Color(0xFF2A364E);
  Color colour2 = Color(0xFF2A364E);
  Color colour3 = Color(0xFF2A364E);
  Color colour4 = Color(0xFF2A364E);
  late String name;

  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordController2 = TextEditingController();

  bool isEmailVerified = false;

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

    if (_nameController.text.isNotEmpty &&
        _usernameController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        (!_passwordController.text.contains(RegExp('[A-Z]')) ||
            !_passwordController.text.contains(RegExp('[a-z]')) ||
            !_passwordController.text.contains(RegExp('[0-9]')) ||
            _passwordController.text.length < 8)
    ) {
      popup('Password is too weak.');
    }

    if (_nameController.text.isNotEmpty &&
        _usernameController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
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

    if (_nameController.text.isEmpty &&
        _passwordController.text.isNotEmpty &&
        _passwordController2.text.isNotEmpty &&
        _usernameController.text.isNotEmpty
    ) {
      popup('Please enter your name.');
    }

    if (_usernameController.text.isEmpty &&
        _nameController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _passwordController2.text.isNotEmpty
    ) {
      popup('Please enter your email address.');
    }

    if (_nameController.text.isEmpty &&
        _passwordController.text.isNotEmpty &&
        _passwordController2.text.isNotEmpty &&
        _usernameController.text.isEmpty
    ) {
      popup('Please enter your name and email address.');
    }

    if ((_passwordController.text.isEmpty &&
        _usernameController.text.isNotEmpty &&
        _nameController.text.isNotEmpty &&
        _passwordController2.text.isNotEmpty) ||
        (_passwordController.text.isEmpty &&
            _usernameController.text.isNotEmpty &&
            _nameController.text.isNotEmpty &&
            _passwordController2.text.isEmpty)
    ) {
      popup('Please enter your password.');
    }

    if (_passwordController2.text.isEmpty &&
        _passwordController.text.isNotEmpty &&
        _usernameController.text.isNotEmpty &&
        _nameController.text.isNotEmpty
    ) {
      popup('Please confirm your password.');
    }

    if ((_nameController.text.isEmpty &&
        _passwordController.text.isEmpty &&
        _passwordController2.text.isEmpty &&
        _usernameController.text.isEmpty) ||
        (_nameController.text.isNotEmpty &&
            _passwordController.text.isEmpty &&
            _passwordController2.text.isEmpty &&
            _usernameController.text.isEmpty)||
        (_nameController.text.isEmpty &&
            _passwordController.text.isEmpty &&
            _passwordController2.text.isEmpty &&
            _usernameController.text.isNotEmpty)
    ) {
      popup('Please enter your information.');
    }
  }

  void signup() async {
    double width = MediaQuery.of(context).size.width;
    double fontSize = width * 0.04;

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                'Verify your email',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color(0xFF2A364E),
                    fontSize: fontSize * 1.2
                ),
              ),
              content: Text(
                'A verification email has been sent to ${_usernameController.text}',
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
                Center(
                    child: isEmailVerified ? Icon(
                      size: width*0.2,
                      Icons.check_circle_outline_rounded,
                      color: Colors.green,
                    ) : CircularProgressIndicator()
                )
              ]
          );
        }
    );

    try {
      if (_passwordController.text == _passwordController2.text &&
          _passwordController.text.contains(RegExp('[A-Z]')) &&
          _passwordController.text.contains(RegExp('[a-z]')) &&
          _passwordController.text.contains(RegExp('[0-9]')) &&
          _passwordController.text.length >= 8)
      {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _usernameController.text,
          password: _passwordController.text,
        );

        final user = FirebaseAuth.instance.currentUser!;
        await user.updateDisplayName(name);

        await FirebaseAuth.instance.currentUser?.sendEmailVerification();
        await checkEmailVerified();
        Navigator.pop(context);
        await checkIcon();

        Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.fade,
              child: HomePage(),
            )
        );
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      if (e.code == 'invalid-email') {
        popup('Invalid email address.');
      }

      if (e.code == 'email-already-in-use') {
        popup('Email address already in use.');
      } else if (e.code == 'weak-password') {
        popup('Password is too weak.');
      }
    }
  }

  Future<void> checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser?.reload();
    if (FirebaseAuth.instance.currentUser!.emailVerified) {
      setState(() {
        isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
      });
    } else {
      Future.delayed(Duration(seconds: 3));
      await checkEmailVerified();
    }
  }

  Future<void> checkIcon() async {
    double width = MediaQuery.of(context).size.width;
    double fontSize = width * 0.04;

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
      return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Email Verified',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Color(0xFF2A364E),
                fontSize: fontSize * 1.2
            ),
          ),
          content: Text(
            'Your email address was successfully verified.',
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
            Center(
                child: Icon(
                  size: width*0.2,
                  Icons.check_circle_outline_rounded,
                  color: Colors.green,
                )
            )
          ]
      );
    }
    );

    await Future.delayed(Duration(seconds: 3));

    Navigator.pop(context);
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

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double fontSize = width * 0.03;

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
                            height: 0.75*height,
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
                                margin: EdgeInsets.only(top: (0.12*height), left: (0.15*width)),
                                child: Text(
                                    'Create \nAccount',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontFamily: "Montserrat",
                                        fontSize: fontSize*2.75,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.normal,
                                        height: 1.2,
                                        letterSpacing: 0.5,
                                        color: Color(0xFF2A364E)
                                    )
                                )
                            ),
                          )
                      ),
                      Positioned(
                          child: Container (
                              margin: EdgeInsets.only(bottom: 0, top: (0.25*height), left: (0.09*width), right: (0.09*width)),
                              height: 0.65*height,
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
                                                  style: TextStyle(
                                                      fontSize: fontSize*1.3,
                                                      fontFamily: "Quicksand",
                                                      fontWeight: FontWeight.w500,
                                                      letterSpacing: 0.5,
                                                      color: Color(0xFF2A364E)
                                                  ),
                                                  controller: _nameController,
                                                  maxLines: 1,
                                                  cursorColor: Color(0xFF2A364E),
                                                  decoration: InputDecoration(
                                                    hintText: 'Name',
                                                    hintStyle: TextStyle(
                                                        fontSize: fontSize*1.3,
                                                        fontFamily: "Quicksand",
                                                        fontWeight: FontWeight.w500,
                                                        letterSpacing: 0.5,
                                                        color: Color(0xFF2A364E),
                                                    ),
                                                    enabledBorder: UnderlineInputBorder(
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
                                                  textCapitalization: TextCapitalization.none,
                                                  autocorrect: false,
                                                  keyboardType: TextInputType.emailAddress,
                                                  style: TextStyle(
                                                      fontSize: fontSize*1.3,
                                                      fontFamily: "Quicksand",
                                                      fontWeight: FontWeight.w500,
                                                      letterSpacing: 0.5,
                                                      color: Color(0xFF2A364E)
                                                  ),
                                                  controller: _usernameController,
                                                  maxLines: 1,
                                                  cursorColor: Color(0xFF2A364E),
                                                  decoration: InputDecoration(
                                                    hintText: 'Email',
                                                    hintStyle: TextStyle(
                                                        fontSize: fontSize*1.3,
                                                        fontFamily: "Quicksand",
                                                        fontWeight: FontWeight.w500,
                                                        letterSpacing: 0.5,
                                                        color: Color(0xFF2A364E)
                                                    ),
                                                    enabledBorder: UnderlineInputBorder(
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
                                                      fontSize: fontSize*1.3,
                                                      fontFamily: "Quicksand",
                                                      fontWeight: FontWeight.w500,
                                                      letterSpacing: 0.5,
                                                      color: Color(0xFF2A364E)
                                                  ),
                                                  maxLines: 1,
                                                  cursorColor: Color(0xFF2A364E),
                                                  decoration: InputDecoration(
                                                    hintText: 'Password',
                                                    hintStyle: TextStyle(
                                                        fontSize: fontSize*1.3,
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
                                                  style: TextStyle(
                                                      fontSize: fontSize*1.3,
                                                      fontFamily: "Quicksand",
                                                      fontWeight: FontWeight.w500,
                                                      letterSpacing: 0.5,
                                                      color: Color(0xFF2A364E)
                                                  ),
                                                  maxLines: 1,
                                                  cursorColor: Color(0xFF2A364E),
                                                  decoration: InputDecoration(
                                                    hintText: 'Confirm Password',
                                                    hintStyle: TextStyle(
                                                        fontSize: fontSize*1.3,
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
                                                  fontSize: fontSize*1.1,
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
                                                  fontSize: fontSize*1.1,
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
                                                  fontSize: fontSize*1.1,
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
                                                  fontSize: fontSize*1.1,
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
                                                onPressed: () {
                                                  name = _nameController.text;
                                                  if (_passwordController.text != _passwordController2.text ||
                                                      !_passwordController.text.contains(RegExp('[A-Z]')) ||
                                                      !_passwordController.text.contains(RegExp('[a-z]')) ||
                                                      !_passwordController.text.contains(RegExp('[0-9]')) ||
                                                      _passwordController.text.length < 8 ||
                                                      _nameController.text.isEmpty ||
                                                      _passwordController.text.isEmpty ||
                                                      _passwordController2.text.isEmpty ||
                                                      _usernameController.text.isEmpty)
                                                  {
                                                    checkValidation();
                                                  } else {
                                                    signup();
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
                                                child: Text('Sign Up',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontFamily: "Quicksand",
                                                      fontWeight: FontWeight.w600,
                                                      letterSpacing: 0.5,
                                                      color: Colors.white,
                                                      fontSize: fontSize*1.75,
                                                    )
                                                )
                                            )
                                        ),
                                      ]
                                  )
                              )
                          )
                      )
                    ],
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
}