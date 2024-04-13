import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'login.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  final user = FirebaseAuth.instance.currentUser!;

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
                            height: 0.3 * height,
                            margin: EdgeInsets.only(bottom: 0.3 * height),
                            decoration: BoxDecoration(
                                color: Color(0xFFC6F2FF),
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(60),
                                    bottomRight: Radius.circular(60)
                                )
                            ),
                            child: Container(
                                alignment: Alignment.topLeft,
                                margin: EdgeInsets.only(top: 0.12 * height, left: 0.075 * width, right: 0.2 * width),
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
}