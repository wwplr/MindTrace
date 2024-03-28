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
  final user = FirebaseAuth.instance.currentUser!;
  int selectedIndex = 0;

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

    return PopScope(
        canPop: false,
        child: Scaffold(
            backgroundColor: Colors.white,
            bottomNavigationBar: CurvedNavigationBar(
              buttonBackgroundColor: Color(0xFFC6F2FF),
              iconPadding: 20,
              backgroundColor: Colors.white,
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
            body: pages[selectedIndex]
        )
    );
  }
}