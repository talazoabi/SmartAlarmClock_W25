import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:analog_clock/analog_clock.dart';
import 'dart:async';
import 'settings_page.dart';
import 'weather_service.dart';
import 'info_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Timer _timer;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _days = ['Monday', 'Tuesday', 'Wednesday',
      'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final _months = ['January', 'February', 'March', 'April',
      'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

    final _currDay = _currentTime.weekday;
    final _currDate = _currentTime.day;
    final _currMonth = _currentTime.month;

    final _currDayString = _days[_currDay - 1];
    final _currMonthString = _months[_currMonth - 1];

    final _hour = _currentTime.hour.toString().padLeft(2, '0');
    final _minute = _currentTime.minute.toString().padLeft(2, '0');
    final _second = _currentTime.second.toString().padLeft(2, '0');

    bool isDay = _currentTime.hour >= 6 && _currentTime.hour < 17;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.lightBlue[50],
          title: Text(
            'Home',
            style: TextStyle(
              color: Colors.black,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              onPressed: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => InfoPage())
                );
              },
              icon: Icon(Icons.info_outline_rounded, color: Colors.blueGrey),
            ),
            IconButton(
              onPressed: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage())
                );
              },
              icon: Icon(Icons.settings, color: Colors.blueGrey),
            ),
          ],
        ),
        body: Center(
          child: Column(
            children: [
              const SizedBox(height: 60.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StreamBuilder<DatabaseEvent>(
                    stream: FirebaseDatabase.instance
                        .ref('/App/Settings/showSeconds')
                        .onValue,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                        final bool showSeconds = snapshot.data!.snapshot.value as bool;
                        return Text(
                          showSeconds ? '$_hour:$_minute:$_second' : '$_hour:$_minute',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 45.0,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }
                      return Text(
                        '$_hour:$_minute',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 45.0,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 5.0),
                  Icon(
                    isDay ? Icons.wb_sunny : Icons.nights_stay,
                    size: 50,
                    color: isDay? Colors.yellow[600] : Colors.blue[900],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('$_currDayString, $_currMonthString $_currDate',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 25.0,
                    ),
                  ),
                ],
              ),
              WeatherScreen(),
              const SizedBox(height: 20.0),
              AnalogClock(
                width: 330.0,
                height: 350.0,
                hourHandColor: Colors.black,
                minuteHandColor: Colors.black,
                secondHandColor: Colors.red,
                showSecondHand: true,
                showDigitalClock: false,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.lightBlue[50],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey, offset: Offset(0, 4), blurRadius: 6,
                      )
                    ]
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}