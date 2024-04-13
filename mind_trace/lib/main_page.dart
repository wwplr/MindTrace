import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mind_trace/login.dart';
import 'home_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return const HomePage();
            } else {
              return const Login();
            }
          },
    );
  }
}
