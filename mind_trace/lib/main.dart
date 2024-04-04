import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:mind_trace/main_page.dart';
import 'package:provider/provider.dart';
import 'add.dart';
import 'firebase_options.dart';
import 'notification.dart';

final flutterNotification = FlutterNotification();
final DateTime now = DateTime.now();
DateTime scheduledDateTime = DateTime(now.year, now.month, now.day, 14, 0);

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await flutterNotification.initialiseNotifications();

  if (scheduledDateTime.isAfter(now)) {
    await flutterNotification.scheduleNotification(
      id: 1,
      title: 'MindTrace',
      body: "Are you on TikTok? Don't forget to log your mood.",
      scheduledNotificationDateTime: scheduledDateTime,
    );
  } else {
    scheduledDateTime = scheduledDateTime.add(Duration(days: 1)); // Increment the date by one day
    scheduledDateTime = DateTime(scheduledDateTime.year, scheduledDateTime.month, scheduledDateTime.day, 18, 51); // Set the time to 6:51 PM
    await flutterNotification.scheduleNotification(
      id: 1,
      title: 'MindTrace',
      body: "Are you on TikTok? Don't forget to log your mood.",
      scheduledNotificationDateTime: scheduledDateTime,
    );
  }

  runApp(
    ChangeNotifierProvider<TimerProvider>(
      create: (context) => TimerProvider(),
      child: App(),
    ),
  );
}


class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      home: const MainPage(),
    );
  }
}
