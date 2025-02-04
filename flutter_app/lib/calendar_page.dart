import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:workmanager/workmanager.dart';

class CalendarPage extends StatefulWidget {
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> with WidgetsBindingObserver {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['https://www.googleapis.com/auth/calendar.readonly']);
  bool _signedIn = false;
  List<dynamic> _events = [];
  bool _loading = false;

  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref().child('App/googleEvents');

  @override
  void initState() {
    super.initState();
    _checkSignInStatus();
    WidgetsBinding.instance.addObserver(this);
    _startAutoRefresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _startAutoRefresh() {
    Workmanager().registerPeriodicTask(
      "fetch_calendar_events",
      "fetchCalendar",
      frequency: Duration(minutes: 15),
      initialDelay: Duration(minutes: 1),
    );
  }

  Future<void> _checkSignInStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final signedIn = prefs.getBool('signedIn') ?? false;
    if (signedIn) {
      setState(() {
        _signedIn = true;
      });
      await _signInAndFetchCalendar();
    }
  }

  Future<void> _signInAndFetchCalendar() async {
    setState(() {
      _loading = true;
    });

    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account != null) {
        final GoogleSignInAuthentication auth = await account.authentication;
        final String accessToken = auth.accessToken!;

        final response = await http.get(
          Uri.parse('https://www.googleapis.com/calendar/v3/calendars/primary/events'),
          headers: {
            'Authorization': 'Bearer $accessToken'
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final List<dynamic> fetchedEvents = data['items'] ?? [];
          final futureEvents = fetchedEvents.where((event) {
            final start = event['start']?['dateTime'] ?? event['start']?['date'];
            return start != null && _isEventInTheFuture(start);
          }).toList();

          setState(() {
            _events = futureEvents;
            _signedIn = true;
          });

          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('signedIn', true);
          _syncEventsWithFirebase(futureEvents);
        }
      }
    } catch (e) {
      print('Error during sign-in or fetching events: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _signOut() async {
    await _googleSignIn.signOut();
    setState(() {
      _signedIn = false;
      _events.clear();
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('signedIn', false);
  }

  Future<void> _syncEventsWithFirebase(List<dynamic> googleCalendarEvents) async {
    try {
      final snapshot = await databaseReference.get();
      final Map<String, dynamic> firebaseEvents =
      snapshot.value != null ? Map<String, dynamic>.from(snapshot.value as Map) : {};

      final googleEventIds = googleCalendarEvents.map((event) => event['id']).toSet();

      for (final firebaseEventId in firebaseEvents.keys) {
        if (!googleEventIds.contains(firebaseEventId)) {
          await databaseReference.child(firebaseEventId).remove();
        }
      }

      for (var event in googleCalendarEvents) {
        final eventId = event['id'];

        final String? start = event['start']?['dateTime'] ?? event['start']?['date'];
        if (start == null || !_isEventInTheFuture(start)) {
          await databaseReference.child(eventId).remove();
          continue;
        }

        final DateTime startDateTime = DateTime.parse(event['start']['dateTime']);
        final DateTime endDateTime = DateTime.parse(event['end']['dateTime']);

        String formattedDate = DateFormat('ddMMyy').format(startDateTime);
        String formattedTime = DateFormat('HH:mm').format(startDateTime);

        final Duration duration = endDateTime.difference(startDateTime);
        final String formattedDuration = "${duration.inHours}h ${duration.inMinutes % 60}m";

        final eventData = {
          'Id': eventId,
          'Summary': event['summary'] ?? '',
          'Date': formattedDate,
          'Start': formattedTime,
          'Duration': formattedDuration,
        };

        await databaseReference.child(eventId).set(eventData);
      }
    } catch (e) {
      print('Error syncing events with Firebase: $e');
    }
  }

  bool _isEventInTheFuture(String startDateTime) {
    final DateTime eventDateTime = DateTime.parse(startDateTime);
    return eventDateTime.isAfter(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.lightBlue[50],
        title: Text(
          'Google Calendar Events',
          style: TextStyle(
            color: Colors.black,
            fontSize: 23.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (!_signedIn)
            IconButton(
              icon: Icon(Icons.login, color: Colors.blueGrey),
              onPressed: _signInAndFetchCalendar,
            ),
          if (_signedIn)
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.blueGrey),
              onPressed: _signInAndFetchCalendar, // Trigger immediate refresh
            ),
          if (_signedIn)
            IconButton(
              icon: Icon(Icons.exit_to_app, color: Colors.blueGrey),
              onPressed: _signOut,
            ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _signedIn
          ? _events.isEmpty
          ? Center(child: Text(
        'No upcoming events available.',
        style: TextStyle(fontSize: 18, color: Colors.black),
      ),
      )
          : ListView.builder(
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];

          final String summary = event['summary'] ?? '';

          final DateTime startDateTime = DateTime.parse(event['start']['dateTime']);
          final DateTime endDateTime = DateTime.parse(event['end']['dateTime']);

          String formattedDate = DateFormat('dd/MM/yy').format(startDateTime);
          String formattedTime = DateFormat('HH:mm').format(startDateTime);

          // Calculate duration
          final Duration duration = endDateTime.difference(startDateTime);
          final String formattedDuration = "${duration.inHours}h ${duration.inMinutes % 60}m";

          return Card(
            color: Colors.lightBlue[50],
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    summary,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.blueGrey),
                      SizedBox(width: 8),
                      Text(
                        formattedDate,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.blueGrey),
                      SizedBox(width: 8),
                      Text(
                        formattedTime,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      SizedBox(width: 16),
                      Icon(Icons.timer, size: 16, color: Colors.blueGrey),
                      SizedBox(width: 8),
                      Text(
                        formattedDuration,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      )
          : Center(
        child: Text(
          'Please sign in to fetch events.',
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
      ),
    );
  }
}

Future<void> refreshEvents() async {
  print("Fetching calendar events in background...");
  GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['https://www.googleapis.com/auth/calendar.readonly']);

  try {
    final GoogleSignInAccount? account = await googleSignIn.signInSilently();
    if (account != null) {
      final GoogleSignInAuthentication auth = await account.authentication;
      final String accessToken = auth.accessToken!;

      final response = await http.get(
        Uri.parse('https://www.googleapis.com/calendar/v3/calendars/primary/events'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> fetchedEvents = data['items'] ?? [];
        final futureEvents = fetchedEvents.where((event) {
          final start = event['start']?['dateTime'] ?? event['start']?['date'];
          return start != null && DateTime.parse(start).isAfter(DateTime.now());
        }).toList();

        final DatabaseReference databaseReference = FirebaseDatabase.instance.ref().child('App/googleEvents');
        try {
          final snapshot = await databaseReference.get();
          final Map<String, dynamic> firebaseEvents =
          snapshot.value != null ? Map<String, dynamic>.from(snapshot.value as Map) : {};

          final googleEventIds = futureEvents.map((event) => event['id']).toSet();

          for (final firebaseEventId in firebaseEvents.keys) {
            if (!googleEventIds.contains(firebaseEventId)) {
              await databaseReference.child(firebaseEventId).remove();
            }
          }

          for (var event in futureEvents) {
            final eventId = event['id'];

            final String? start = event['start']?['dateTime'] ?? event['start']?['date'];
            if (start == null || !DateTime.parse(start).isAfter(DateTime.now())) {
              await databaseReference.child(eventId).remove();
              continue;
            }

            final DateTime startDateTime = DateTime.parse(event['start']['dateTime']);
            final DateTime endDateTime = DateTime.parse(event['end']['dateTime']);

            String formattedDate = DateFormat('ddMMyy').format(startDateTime);
            String formattedTime = DateFormat('HH:mm').format(startDateTime);

            final Duration duration = endDateTime.difference(startDateTime);
            final String formattedDuration = "${duration.inHours}h ${duration.inMinutes % 60}m";

            final eventData = {
              'Id': eventId,
              'Summary': event['summary'] ?? '',
              'Date': formattedDate,
              'Start': formattedTime,
              'Duration': formattedDuration,
            };

            await databaseReference.child(eventId).set(eventData);
          }
        } catch (e) {
          print('Error syncing events with Firebase: $e');
        }
        print("✅ Successfully fetched and stored calendar events.");
      }
    }
  } catch (e) {
    print('Error fetching events in background: $e');
  }
}