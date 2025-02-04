import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';
import 'layout_page.dart';
import 'connectivity_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'info_page.dart';
import 'package:workmanager/workmanager.dart';
import 'calendar_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<bool> checkFirstLaunch() async {
  final prefs = await SharedPreferences.getInstance();
  final bool isFirstTime = prefs.getBool('isFirstLaunch') ?? true;
  if (isFirstTime) {
    await prefs.setBool('isFirstLaunch', false);
  }
  return isFirstTime;
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == "fetchCalendar") {
      print("Background task running: Fetching calendar events...");
      await Firebase.initializeApp();
      await refreshEvents();
    }
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'wiserise',
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final bool isFirstLaunch = await checkFirstLaunch();

  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  FirebaseDatabase.instance.setPersistenceEnabled(false);
  ConnectivityService.instance.initialize();

  runApp(
    ConnectivityWrapper(
      navigatorKey: navigatorKey,
      child: MyApp(isFirstLaunch: isFirstLaunch),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isFirstLaunch;
  const MyApp({Key? key, required this.isFirstLaunch}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue,
            primary: Colors.blue),
        useMaterial3: true,
      ),
      home: isFirstLaunch ? InfoPage() : LayoutPage(),
    );
  }
}