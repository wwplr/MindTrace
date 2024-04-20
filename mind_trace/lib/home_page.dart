import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'home.dart';
import 'account.dart';
import 'add.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;
  int selectedIndex = 1;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 2500))
        .then((value) => {FlutterNativeSplash.remove()}
    );

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void bottomNavBar(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  final List<Widget> pages = [
    Home(),
    Add(),
    Account()
  ];

  @override
  Widget build(BuildContext context){
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return PopScope(
        canPop: false,
        child: Stack(
              children: [
                pages[selectedIndex],
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                    ),
                    child: CurvedNavigationBar(
                      buttonBackgroundColor: Color(0xFFC6F2FF),
                      iconPadding: width*0.047,
                      height: height*0.085,
                      backgroundColor: Colors.transparent,
                      color: Color(0xFFC6F2FF),
                      animationDuration: Duration(milliseconds: 400),
                      index: selectedIndex,
                      onTap: bottomNavBar,
                      items: [
                        CurvedNavigationBarItem (
                          child: Icon(Icons.bar_chart),
                        ),
                        CurvedNavigationBarItem (
                          child: Icon(Icons.add),
                        ),
                        CurvedNavigationBarItem (
                          child: Icon(Icons.person),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
        )
    );
  }
}