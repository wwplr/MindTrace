import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mind_trace/home_page.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool _securedPassword = true;
  bool _securedPassword2 = true;
  Color colour = Colors.white;
  Color colour2 = Colors.white;
  Color colour3 = Colors.white;
  Color colour4 = Colors.white;

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordController2 = TextEditingController();

  void checkValidation() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        Future.delayed(Duration(milliseconds: 800), () {
          Navigator.pop(ctx);
        });
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    if (!_passwordController.text.contains(RegExp('[A-Z]')) ||
        !_passwordController.text.contains(RegExp('[a-z]')) ||
        !_passwordController.text.contains(RegExp('[0-9]')) ||
        _passwordController.text.length < 8)
    {
      popup('Password is too weak.');
    }

    if (_passwordController.text != _passwordController2.text) {
      popup('Password does not match.');
    }
  }

  void signup() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
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
        Navigator.pop(context);

        Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage())
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

  void popup(String message) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
              content: Text(
                message,
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
    return PopScope(
        canPop: false,
        child: Scaffold(
            floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
            floatingActionButton: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.3, 1.0],
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
                                  alignment: Alignment.topLeft,
                                  margin: EdgeInsets.only(bottom: (0.05*height), left: (0.15*width)),
                                  child: const Text(
                                      'Create \nAccount',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontFamily: "Montserrat",
                                          fontSize: 35,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.normal,
                                          height: 1.2,
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
                                        maxLines: 1,
                                        cursorColor: Colors.white,
                                        decoration: const InputDecoration(
                                          hintText: 'Name',
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
                              ),
                              Container(
                                  padding: EdgeInsets.only(left: (0.15*width), right: (0.15*width), top: (0.02*height)),
                                  child: Form(
                                      child: TextFormField(
                                        style: const TextStyle(
                                            color: Colors.white
                                        ),
                                        controller: _usernameController,
                                        maxLines: 1,
                                        cursorColor: Colors.white,
                                        decoration: const InputDecoration(
                                          hintText: 'Email',
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
                              ),
                              Container(
                                  padding: EdgeInsets.only(left: (0.15*width), right: (0.15*width), top: (0.02*height)),
                                  child: Form(
                                      child: TextFormField(
                                        controller: _passwordController,
                                        obscureText: _securedPassword,
                                        enableSuggestions: false,
                                        enableInteractiveSelection: false,
                                        autocorrect: false,
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
                                  padding: EdgeInsets.only(left: (0.15*width), right: (0.15*width), top: (0.02*height)),
                                  child: Form(
                                      child: TextFormField(
                                        controller: _passwordController2,
                                        obscureText: _securedPassword2,
                                        enableSuggestions: false,
                                        enableInteractiveSelection: false,
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
                                          hintText: 'Confirm Password',
                                          hintStyle: const TextStyle(
                                              color: Colors.white
                                          ),
                                          suffixIcon: togglePassword2(),
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
                              Container (
                                margin: EdgeInsets.only(top: (0.03*height), left: (0.15*width)),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'An uppercase character',
                                  style: TextStyle(
                                      color: colour
                                  ),
                                )
                              ),
                              Container (
                                  margin: EdgeInsets.only(top: (0.005*height), left: (0.15*width)),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'A lowercase character',
                                    style: TextStyle(
                                        color: colour2
                                    ),
                                  )
                              ),
                              Container (
                                  margin: EdgeInsets.only(top: (0.005*height), left: (0.15*width)),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'A number',
                                    style: TextStyle(
                                        color: colour3
                                    ),
                                  )
                              ),
                              Container (
                                  margin: EdgeInsets.only(top: (0.005*height), left: (0.15*width)),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'At least 8 characters',
                                    style: TextStyle(
                                        color: colour4
                                    ),
                                  )
                              ),
                              Container(
                                  margin: EdgeInsets.only(top: (0.05*height)),
                                  child: ElevatedButton(
                                      onPressed: () {
                                        if (_passwordController.text != _passwordController2.text ||
                                            !_passwordController.text.contains(RegExp('[A-Z]')) ||
                                            !_passwordController.text.contains(RegExp('[a-z]')) ||
                                            !_passwordController.text.contains(RegExp('[0-9]')) ||
                                            _passwordController.text.length < 8)
                                        {
                                          checkValidation();
                                        } else {
                                          signup();
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        fixedSize: const Size(200, 55),
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(100)
                                        ),
                                        elevation: 2.0,
                                      ),
                                      child: const Text('Sign Up',
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