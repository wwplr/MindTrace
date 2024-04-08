import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:mind_trace/home_page.dart';
import 'package:mind_trace/signup.dart';
import 'package:page_transition/page_transition.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _securedPassword = true;

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();


  void check() async {
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

    if (_usernameController.text.isEmpty && _passwordController.text.isNotEmpty) {
      popup('Please enter your username');
    } else if (_usernameController.text.isNotEmpty && _passwordController.text.isEmpty){
      popup('Please enter your password');
    }

    if (_usernameController.text.isEmpty && _passwordController.text.isEmpty) {
      popup('Please enter your username and password');
    }

  }

  void login() async {
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
      if (_usernameController.text.isNotEmpty && _passwordController.text.isNotEmpty)
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _usernameController.text.trim(),
          password: _passwordController.text.trim(),
        );
      Navigator.pop(context);
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          child: HomePage(),
        ),
      );
    } on FirebaseAuthException {
      Navigator.pop(context);
      popup('Incorrect email or password');
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

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3))
        .then((value) => {FlutterNativeSplash.remove()}
    );

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
            backgroundColor: Colors.white,
            body: SingleChildScrollView (
                child: Center(
                    child: Stack(
                        alignment: Alignment.center,
                        children: <Widget> [
                          Positioned (
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
                                child: Column(
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(top: (0.08*height), bottom: (0.02*height)),
                                        alignment: Alignment.topCenter,
                                        child: Image(
                                          image: const AssetImage("assets/images/icon1.png"),
                                          height: height * 0.2,
                                        ),
                                      ),
                                      Container(
                                          alignment: Alignment.topLeft,
                                          margin: EdgeInsets.only(left: (0.15*width)),
                                          child: Text(
                                              'Login',
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  fontFamily: "Montserrat",
                                                  fontSize: fontSize*3,
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle: FontStyle.normal,
                                                  height: 1.75,
                                                  letterSpacing: 0.5,
                                                  color: Color(0xFF2A364E)
                                              )
                                          )
                                      )
                                    ]
                                )
                            ),
                          ),
                          Positioned (
                              child: Container(
                                  margin: EdgeInsets.only(top: (0.4*height), left: (0.09*width), right: (0.09*width)),
                                  height: 0.55*height,
                                  decoration: BoxDecoration(
                                      color: Color(0xFFFFF8EA),
                                      borderRadius: BorderRadius.all(Radius.circular(30))
                                  ),
                                  child: Center (
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                              margin: EdgeInsets.only(left: (0.1*width), right: (0.1*width)),
                                              child: Form(
                                                  child: TextFormField(
                                                    style:  TextStyle(
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
                                                      hintText: 'Username',
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
                                              margin: EdgeInsets.only(left: (0.1*width), right: (0.1*width), top: (0.03*height)),
                                              child: Form(
                                                  child: TextFormField(
                                                    controller: _passwordController,
                                                    obscureText: _securedPassword,
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
                                                    keyboardType: TextInputType.text,
                                                    textInputAction: TextInputAction.done,
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
                                                  )
                                              )
                                          ),
                                          Container(
                                              margin: EdgeInsets.only(top: (0.05*height), bottom: (0.12*height)),
                                              child: ElevatedButton(
                                                  onPressed: () {
                                                    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
                                                      check();
                                                    } else {
                                                      login();
                                                    }
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    fixedSize: Size(0.45*width, 0.06*height),
                                                    backgroundColor: Color(0xFFA986E4),
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(100)
                                                    ),
                                                    elevation: 2.0,
                                                  ),
                                                  child: Text('Login',
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
                                          Container(
                                                    margin: EdgeInsets.only(bottom: (0.01*height)),
                                                    child: Text(
                                                        "Don't have an account?",
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                            fontFamily: "Quicksand",
                                                            fontWeight: FontWeight.w500,
                                                            fontSize: fontSize*1.25,
                                                            fontStyle: FontStyle.normal,
                                                            height: 1.75,
                                                            letterSpacing: 0.75,
                                                            color: Colors.black
                                                        )
                                                    )
                                                ),
                                                Container(
                                                    child: ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.push(
                                                            context,
                                                            PageTransition(
                                                              type: PageTransitionType.fade,
                                                              child: SignUp(),
                                                            ),
                                                          );
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          fixedSize: Size(0.35*width, 0.06*height),
                                                          backgroundColor: Color(0xFF49688D),
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(100)
                                                          ),
                                                          elevation: 2.0,
                                                        ),
                                                        child: Text(
                                                            'Sign Up',
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                              fontFamily: "Quicksand",
                                                              fontWeight: FontWeight.w600,
                                                              letterSpacing: 0.5,
                                                              color: Colors.white,
                                                              fontSize: fontSize*1.5,
                                                            )
                                                        )
                                                    )
                                                ),
                                        ],
                                      )
                                  )
                              )
                          )
                        ]
                    )
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
}