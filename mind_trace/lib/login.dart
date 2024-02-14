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

  void login() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    try {
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
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      popup();
    }
  }

  void popup() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
              content: const Text(
                'Incorrect email or password',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 16
                ),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)
              ),
              insetPadding: const EdgeInsets.only(right: 50, left: 50),
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
                                fixedSize: const Size(70, 35),
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                elevation: 2.0,
                              ),
                              child: const Text(
                                  'OK',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.deepPurple,
                                      fontSize: 15,
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
    return PopScope(
        canPop: false,
        child: Scaffold(
            body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.4, 1.0],
                    colors: [
                      Color(0xFFA97DE6),
                      Color(0xFF83AFFA)
                    ],
                  ),
                ),
                child: Center(
                    child: SingleChildScrollView(
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
                        child: Column(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(top: (0.1*height)),
                                child: Image(
                                  image: const AssetImage("assets/images/book.png"),
                                  height: height * 0.15,
                                ),
                              ),
                              Container(
                                  alignment: Alignment.topLeft,
                                  margin: EdgeInsets.only(top: (0.05*height), bottom: (0.05*height), left: (0.15*width)),
                                  child: const Text(
                                      'Login',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontFamily: "Montserrat",
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.normal,
                                          height: 1.75,
                                          letterSpacing: 0.5,
                                          color: Colors.white
                                      )
                                  )
                              ),
                              Container(
                                  padding: EdgeInsets.only(left: (0.15*width), right: (0.15*width)),
                                  child: Form(
                                      child: TextFormField(
                                        style: const TextStyle(
                                            color: Colors.white
                                        ),
                                        controller: _usernameController,
                                        maxLines: 1,
                                        cursorColor: Colors.white,
                                        decoration: const InputDecoration(
                                          hintText: 'Username',
                                          hintStyle: TextStyle(
                                              color: Colors.white
                                          ),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white
                                            ),
                                          ),
                                        ),
                                      )
                                  )
                              ),Container(
                                  padding: EdgeInsets.only(left: (0.15*width), right: (0.15*width), top: (0.03*height)),
                                  child: Form(
                                      child: TextFormField(
                                        controller: _passwordController,
                                        obscureText: _securedPassword,
                                        style: const TextStyle(
                                            color: Colors.white
                                        ),
                                        maxLines: 1,
                                        keyboardType: TextInputType.text,
                                        textInputAction: TextInputAction.done,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp('[A-Za-z0-9]')
                                          )
                                        ],
                                        cursorColor: Colors.white,
                                        decoration: InputDecoration(
                                          hintText: 'Password',
                                          hintStyle: const TextStyle(
                                              color: Colors.white
                                          ),
                                          suffixIcon: togglePassword(),
                                          suffixIconColor: Colors.white,
                                          enabledBorder: const UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white
                                            ),
                                          ),
                                        ),
                                      )
                                  )
                              ),
                              Container(
                                  margin: EdgeInsets.only(top: (0.05*height), bottom: (0.15*height)),
                                  child: ElevatedButton(
                                      onPressed: () {
                                        login();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        fixedSize: const Size(200, 55),
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(100)
                                        ),
                                        elevation: 2.0,
                                      ),
                                      child: const Text('Login',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Color(0xFFB38AEE),
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500
                                          )
                                      )
                                  )
                              ),
                              Container(
                                  margin: EdgeInsets.only(bottom: (0.01*height)),
                                  child: const Text(
                                      "Don't have an account?",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontStyle: FontStyle.normal,
                                          height: 1.75,
                                          letterSpacing: 0.75,
                                          color: Colors.white
                                      )
                                  )
                              ),
                              Container(
                                  margin: EdgeInsets.only(bottom: (0.01*height)),
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
                                        fixedSize: const Size(160, 50),
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(100)
                                        ),
                                        elevation: 2.0,
                                      ),
                                      child: const Text(
                                          'Sign Up',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Color(0xFFB38AEE),
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500
                                          )
                                      )
                                  )
                              ),
                            ]
                        )
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