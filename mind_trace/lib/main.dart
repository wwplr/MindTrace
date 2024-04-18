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
DateTime afternoonScheduledDateTime = DateTime(now.year, now.month, now.day, 13, 00);
DateTime eveningScheduledDateTime = DateTime(now.year, now.month, now.day, 22, 00);

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await flutterNotification.initialiseNotifications();

  if (afternoonScheduledDateTime.isBefore(now)) {
    afternoonScheduledDateTime = afternoonScheduledDateTime.add(Duration(days: 1));
  }
  await flutterNotification.scheduleNotification(
    id: 1,
    title: 'Mind Trace',
    body: "Are you on TikTok? Don't forget to log your mood.",
    scheduledNotificationDateTime: afternoonScheduledDateTime,
  );

  // Evening Notification
  if (eveningScheduledDateTime.isBefore(now)) {
    eveningScheduledDateTime = eveningScheduledDateTime.add(Duration(days: 1));
  }
  await flutterNotification.scheduleNotification(
    id: 2,
    title: 'Mind Trace',
    body: "Are you on TikTok? Don't forget to log your mood.",
    scheduledNotificationDateTime: eveningScheduledDateTime,
  );

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
    return
      MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return MediaQuery(
            child: child!,
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
          );
        },
        theme: ThemeData(),
        home: const MainPage(),
    );
  }
}
