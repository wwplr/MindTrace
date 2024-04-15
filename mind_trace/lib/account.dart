import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mind_trace/reset.dart';
import 'package:page_transition/page_transition.dart';
import 'login.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  User user = FirebaseAuth.instance.currentUser!;
  final controller = TextEditingController();
  final controller2 = TextEditingController();
  final controller3 = TextEditingController();
  String passwordText = '';
  bool securedPassword = true;
  bool username = false;
  bool email = false;
  bool password = false;
  bool updating = false;
  bool updating2 = false;
  bool updating3 = false;
  bool isEmailVerified = false;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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
                        children: <Widget>[
                          Container(
                            width: width,
                            height: 0.28 * height,
                            margin: EdgeInsets.only(bottom: 0.1 * height),
                            decoration: BoxDecoration(
                                color: Color(0xFFC6F2FF),
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(60),
                                    bottomRight: Radius.circular(60)
                                )
                            ),
                            child: Container(
                                alignment: Alignment.topLeft,
                                margin: EdgeInsets.only(top: 0.125 * height, left: 0.075 * width, right: 0.2 * width),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                        user.displayName!,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontFamily: "Montserrat",
                                            fontSize: fontSize * 2.5,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.normal,
                                            letterSpacing: 0.5,
                                            color: Color(0xFF2A364E)
                                        )
                                    ),
                                    Text(
                                      user.email!,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontFamily: "Quicksand",
                                          fontSize: fontSize * 1.15,
                                          fontWeight: FontWeight.w600,
                                          fontStyle: FontStyle.normal,
                                          letterSpacing: 0.5,
                                          color: Color(0xFF2A364E)
                                      ),
                                    )
                                  ],
                                )
                            ),
                          ),
                          username ? Container(
                              width: width*0.8,
                              height: height*0.07,
                              decoration: BoxDecoration(
                                color: Color(0xFFFFF4D1),
                                borderRadius: BorderRadius.all(Radius.circular(width*0.03)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: width * 0.525,
                                    margin: EdgeInsets.only(bottom: height*0.01, right: width*0.025),
                                    child: Form(
                                        child: TextFormField(
                                          textCapitalization: TextCapitalization.words,
                                          controller: controller,
                                          enableSuggestions: false,
                                          autocorrect: false,
                                          style: TextStyle(
                                            fontSize: fontSize*1.2,
                                            fontFamily: "Quicksand",
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.5,
                                            color: Color(0xFF2A364E),
                                          ),
                                          maxLines: 1,
                                          cursorColor: Color(0xFF2A364E),
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.only(top: height*0.008, left: width*0.005),
                                            hintStyle: TextStyle(
                                                fontSize: fontSize*1.2,
                                                fontFamily: "Quicksand",
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: 0.5,
                                                color: Color(0xFF2A364E)
                                            ),
                                            hintText: 'Enter a new username',
                                            suffixIconColor: Color(0xFF2A364E),
                                            enabledBorder: const UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Color(0xFF2A364E)
                                              ),
                                            ),
                                          ),
                                        )
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async{
                                      if (controller.text.isNotEmpty) {
                                        setState(() {
                                          updating = true;
                                        });
                                        await user.updateDisplayName(controller.text);
                                        await user.reload();
                                        setState(() {
                                          user = FirebaseAuth.instance.currentUser!;
                                          username = false;
                                          controller.text = '';
                                          updating = false;
                                          print('Username updated');
                                        });
                                      } else {
                                        showDialog(
                                            barrierDismissible: false,
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                  backgroundColor: Colors.white,
                                                  content: Text(
                                                    'Please enter a new username.',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Color(0xFF2A364E),
                                                        fontSize: fontSize*1.3
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
                                    },
                                    child: updating ? SizedBox(
                                      width: width*0.06,
                                      height: width*0.06,
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF2A364E),
                                        strokeWidth: width*0.005,
                                      ),
                                    ) : Icon(
                                        Icons.check_rounded,
                                        color: Color(0xFF2A364E),
                                        size: width*0.06
                                    ),
                                  ),
                                  SizedBox(
                                    width: width*0.025,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        username = false;
                                        controller.text = '';
                                      });
                                    },
                                    child: Icon(
                                        Icons.close_rounded,
                                        color: Color(0xFF2A364E),
                                        size: width*0.06
                                    ),
                                  )
                                ],
                              )
                          ): GestureDetector(
                            onTap: () {
                              setState(() {
                                username = true;
                                email = false;
                                controller3.text = '';
                                securedPassword = true;
                              });
                              print(user.email);
                            },
                            child: Container(
                                width: width*0.8,
                                height: height*0.07,
                                decoration: BoxDecoration(
                                  color: Color(0xFFFFF4D1),
                                  borderRadius: BorderRadius.all(Radius.circular(width*0.03)),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: width*0.145,
                                    ),
                                    Icon(
                                      Icons.edit_outlined,
                                      color: Color(0xFF2A364E),
                                        size: width*0.06
                                    ),
                                    SizedBox(
                                      width: width*0.025,
                                    ),
                                    Text(
                                        'Change Username',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontFamily: "Quicksand",
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                            color: Color(0xFF2A364E),
                                            fontSize: fontSize * 1.5,
                                            height: 1.05
                                        )
                                    ),
                                  ],
                                )
                            ),
                          ),
                          email ? Container(
                              width: width*0.8,
                              height: height*0.07,
                              margin: EdgeInsets.only(top: height*0.025),
                              decoration: BoxDecoration(
                                color: Color(0xFFFFF4D1),
                                borderRadius: BorderRadius.all(Radius.circular(width*0.03)),
                              ),
                              child: password ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: width * 0.525,
                                    margin: EdgeInsets.only(bottom: height*0.01, right: width*0.025),
                                    child: Form(
                                        child: TextFormField(
                                          textCapitalization: TextCapitalization.none,
                                          obscureText: securedPassword,
                                          controller: controller3,
                                          enableSuggestions: false,
                                          enableInteractiveSelection: false,
                                          autocorrect: false,
                                          style: TextStyle(
                                            fontSize: fontSize*1.2,
                                            fontFamily: "Quicksand",
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.5,
                                            color: Color(0xFF2A364E),
                                          ),
                                          maxLines: 1,
                                          cursorColor: Color(0xFF2A364E),
                                          decoration: InputDecoration(
                                              contentPadding: EdgeInsets.only(top: height*0.0175, left: width*0.005),
                                              hintStyle: TextStyle(
                                                fontSize: fontSize*1.2,
                                                fontFamily: "Quicksand",
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: 0.5,
                                                color: Color(0xFF2A364E)
                                            ),
                                            hintText: 'Enter your password',
                                            suffixIconColor: Color(0xFF2A364E),
                                            suffixIcon: togglePassword(width),
                                            suffixStyle: TextStyle(
                                              height: 1
                                            ),
                                            enabledBorder: const UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Color(0xFF2A364E)
                                              ),
                                            ),
                                          ),
                                        )
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      if (controller3.text.isNotEmpty) {
                                        setState(() {
                                          updating3 = true;
                                        });
                                        try {
                                          AuthCredential credential = EmailAuthProvider.credential(
                                            email: user.email!,
                                            password: controller3.text,
                                          );
                                          await user.reauthenticateWithCredential(credential);
                                          setState(() {
                                            passwordText = controller3.text;
                                            password = false;
                                            updating3 = false;
                                            controller3.text = '';
                                            securedPassword = true;
                                          });
                                          print('Re-authenticated.');
                                        } catch (e) {
                                          setState(() {
                                            updating3 = false;
                                          });
                                          showDialog(
                                              barrierDismissible: false,
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                    backgroundColor: Colors.white,
                                                    content: Text(
                                                      'Your password is incorrect. Please try again.',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                          color: Color(0xFF2A364E),
                                                          fontSize: fontSize*1.2
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
                                          print('Wrong password: $e');
                                        }
                                      } else {
                                        showDialog(
                                            barrierDismissible: false,
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                  backgroundColor: Colors.white,
                                                  content: Text(
                                                    'Please enter your password.',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: Color(0xFF2A364E),
                                                        fontSize: fontSize*1.2
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
                                    },
                                    child: updating3 ? SizedBox(
                                      width: width*0.06,
                                      height: width*0.06,
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF2A364E),
                                        strokeWidth: width*0.005,
                                      ),
                                    ) : Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Color(0xFF2A364E),
                                        size: width*0.06
                                    ),
                                  ),
                                  SizedBox(
                                    width: width*0.025,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        email = false;
                                        securedPassword = true;
                                        controller2.text = '';
                                        controller3.text = '';
                                      });
                                    },
                                    child: Icon(
                                        Icons.close_rounded,
                                        color: Color(0xFF2A364E),
                                        size: width*0.06
                                    ),
                                  )
                                ],
                              ) : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: width * 0.525,
                                        margin: EdgeInsets.only(bottom: height*0.01, right: width*0.025),
                                        child: Form(
                                            child: TextFormField(
                                              textCapitalization: TextCapitalization.none,
                                              controller: controller2,
                                              enableSuggestions: false,
                                              autocorrect: false,
                                              keyboardType: TextInputType.emailAddress,
                                              style: TextStyle(
                                                fontSize: fontSize*1.2,
                                                fontFamily: "Quicksand",
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: 0.5,
                                                color: Color(0xFF2A364E),
                                              ),
                                              maxLines: 1,
                                              cursorColor: Color(0xFF2A364E),
                                              decoration: InputDecoration(
                                                contentPadding: EdgeInsets.only(top: height*0.008, left: width*0.005),
                                                hintStyle: TextStyle(
                                                    fontSize: fontSize*1.2,
                                                    fontFamily: "Quicksand",
                                                    fontWeight: FontWeight.w500,
                                                    letterSpacing: 0.5,
                                                    color: Color(0xFF2A364E)
                                                ),
                                                hintText: 'Enter a new email address',
                                                suffixIconColor: Color(0xFF2A364E),
                                                enabledBorder: const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Color(0xFF2A364E)
                                                  ),
                                                ),
                                              ),
                                            )
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          setState(() {
                                            updating2 = true;
                                          });
                                          if (controller2.text.isNotEmpty) {
                                            await user.verifyBeforeUpdateEmail(controller2.text);
                                            showDialog(
                                                barrierDismissible: false,
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                      backgroundColor: Colors.white,
                                                      content: Text(
                                                        'A verification link has been sent to ${controller2.text}. You will be automatically logged out and asked to log back in with your new email after verifying.',
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                            color: Color(0xFF2A364E),
                                                            fontSize: fontSize*1.3
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
                                                                      onPressed: () {
                                                                        FirebaseAuth.instance.signOut();
                                                                        Navigator.push(
                                                                            context,
                                                                            PageTransition(
                                                                              type: PageTransitionType.fade,
                                                                              child: Login(),
                                                                            )
                                                                        );
                                                                      },
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
                                          } else {
                                            showDialog(
                                                barrierDismissible: false,
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                      backgroundColor: Colors.white,
                                                      content: Text(
                                                        'Enter a new email address.',
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(
                                                            color: Color(0xFF2A364E),
                                                            fontSize: fontSize*1.3
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
                                        },
                                        child: updating2 ? SizedBox(
                                          width: width*0.06,
                                          height: width*0.06,
                                          child: CircularProgressIndicator(
                                            color: Color(0xFF2A364E),
                                            strokeWidth: width*0.005,
                                          ),
                                        ) : Icon(
                                            Icons.check_rounded,
                                            color: Color(0xFF2A364E),
                                            size: width*0.06
                                        ),
                                      ),
                                      SizedBox(
                                        width: width*0.025,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            email = false;
                                            controller2.text = '';
                                            controller3.text = '';
                                            securedPassword = true;
                                          });
                                        },
                                        child: Icon(
                                            Icons.close_rounded,
                                            color: Color(0xFF2A364E),
                                            size: width*0.06
                                        ),
                                      )
                                    ],
                                  )
                          ): GestureDetector(
                            onTap: () {
                              setState(() {
                                email = true;
                                password = true;
                                username = false;
                                controller.text = '';
                              });
                            },
                            child: Container(
                                width: width*0.8,
                                height: height*0.07,
                                margin: EdgeInsets.only(top: height*0.025),
                                decoration: BoxDecoration(
                                  color: Color(0xFFFFF4D1),
                                  borderRadius: BorderRadius.all(Radius.circular(width*0.03)),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: width*0.145,
                                    ),
                                    Icon(
                                      Icons.email_outlined,
                                      color: Color(0xFF2A364E),
                                      size: width*0.06
                                    ),
                                    SizedBox(
                                      width: width*0.065,
                                    ),
                                    Text(
                                        'Change Email',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontFamily: "Quicksand",
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                            color: Color(0xFF2A364E),
                                            fontSize: fontSize * 1.5,
                                            height: 1.05
                                        )
                                    ),
                                  ],
                                )
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  PageTransition(
                                    type: PageTransitionType.fade,
                                    child: Reset(),
                                  )
                              );
                              setState(() {
                                email = false;
                                username = false;
                                password = false;
                                securedPassword = true;
                                controller.text = '';
                                controller2.text = '';
                                controller3.text = '';
                              });
                            },
                            child: Container(
                                margin: EdgeInsets.only(top: height*0.025, bottom: height*0.1),
                                width: width*0.8,
                                height: height*0.07,
                                decoration: BoxDecoration(
                                  color: Color(0xFFFFF4D1),
                                  borderRadius: BorderRadius.all(Radius.circular(width*0.03)),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: width*0.145,
                                    ),
                                    Icon(
                                      Icons.lock_outline_rounded,
                                      color: Color(0xFF2A364E),
                                      size: width*0.06
                                    ),
                                    SizedBox(
                                      width: width*0.03,
                                    ),
                                    Text(
                                        'Change Password',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontFamily: "Quicksand",
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                            color: Color(0xFF2A364E),
                                            fontSize: fontSize * 1.5,
                                            height: 1.05
                                        )
                                    ),
                                  ],
                                )
                            ),
                          ),
                          ElevatedButton(
                              onPressed: () {
                                FirebaseAuth.instance.signOut();
                                Navigator.push(
                                    context,
                                    PageTransition(
                                      type: PageTransitionType.fade,
                                      child: Login(),
                                    )
                                );
                              },
                              child: Text(
                                  'Logout',
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
                        ]
                    )
                )
            )
        )
    );
  }

  Widget togglePassword(double width){
    return GestureDetector(
        onTap: (){
          setState(() {
            securedPassword = !securedPassword;
          });
        },
        child: securedPassword ? Icon(Icons.visibility, size: width*0.05) : Icon(Icons.visibility_off, size: width*0.05)
    );
  }
}