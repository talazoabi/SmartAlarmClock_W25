import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class WeatherService {
  final String apiKey = '********************************';
  final String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<Map<String, dynamic>> fetchWeather(String city) async {
    final Uri url = Uri.parse('$baseUrl?q=$city&appid=$apiKey&units=metric');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch weather data');
    }
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic>? _weatherData;
  bool _isLoading = false;
  DatabaseReference databaseReference = FirebaseDatabase.instance.ref().child('App/Weather');

  void _getWeather() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _weatherService.fetchWeather('Haifa');
      setState(() {
        _weatherData = data;
      });

      if (_weatherData != null){
        int roundedTemp = _weatherData!['main']['temp'].round();
        await databaseReference.set(roundedTemp);
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Weather in Haifa : ',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.0,
          ),
        ),
        if (_isLoading)
          Transform.scale(
          scale: 0.5,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), // Custom color
          ),
         ),
        if (_weatherData != null && !_isLoading)
          Text(
            '${_weatherData!['main']['temp'].round()}°C',
            style: TextStyle(fontSize: 18),
          ),
      ],
    );
  }
}
