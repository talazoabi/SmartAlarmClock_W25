import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  DatabaseReference databaseReference =
  FirebaseDatabase.instance.ref().child('App/Settings');

  late double _brightness;
  late double _volume;
  late bool _autoBrightness;
  late bool _showSeconds;
  late bool _lightModeEnabled;
  String? _selectedLanguage;
  String? _selectedRingtone;
  String? _selectedLightColor;

  final LanguageList = ["English", "Hebrew", "Arabic"];
  final RingtoneList = ["Ringtone 1", "Ringtone 2", "Ringtone 3", "Ringtone 4", "Ringtone 5"];
  final LightColors = {
    "Red": Colors.red,
    "Green": Colors.green,
    "Blue": Colors.blue,
    "Pink": Colors.pink,
    "Orange": Colors.orange,
  };

  @override
  void initState() {
    super.initState();
    _brightness = 5.0;
    _volume = 10.0;
    _autoBrightness = false;
    _showSeconds = false;
    _lightModeEnabled = false;
    _selectedLanguage = LanguageList[0];
    _selectedRingtone = RingtoneList[0];
    _selectedLightColor = "White";

    loadData();
  }

  Future<void> loadData() async {
    try {
      DatabaseEvent event = await databaseReference.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        Map<dynamic, dynamic> settingsData = snapshot.value as Map<dynamic, dynamic>;

        setState(() {
          _brightness = (settingsData['Brightness'] as num).toDouble();
          _volume = (settingsData['Volume'] as num).toDouble();
          _autoBrightness = settingsData['autoBrightness'] as bool;
          _showSeconds = settingsData['showSeconds'] as bool;
          _lightModeEnabled = settingsData['lightEnabled'] as bool;
          _selectedLanguage = settingsData['Language'] as String;
          _selectedRingtone = settingsData['Ringtone'] as String;
          _selectedLightColor = settingsData['Color'] as String? ?? "White";
        });
      }
    } catch (error) {
      print('Error loading data: $error');
    }
  }

  void _updateFirebaseDatabase() {
    double normalizedBrightness = _brightness.clamp(0.0, 10.0);
    double normalizedVolume = _volume.clamp(0.0, 20.0);

    int roundedBrightness = normalizedBrightness.round();
    int roundedVolume = normalizedVolume.round();

    databaseReference.set({
      'Brightness': roundedBrightness,
      'Volume': roundedVolume,
      'autoBrightness': _autoBrightness,
      'showSeconds': _showSeconds,
      'lightEnabled': _lightModeEnabled,
      'Color': _lightModeEnabled ? _selectedLightColor : "White",
      'Language': _selectedLanguage,
      'Ringtone': _selectedRingtone,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.lightBlue[50],
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25.0),
                  color: Colors.lightBlue[50],
                ),
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        ' Volume',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.volume_up_sharp,
                            size: 30, color: Colors.black),
                        Expanded(
                          child: Slider(
                            activeColor: Colors.lightBlueAccent,
                            inactiveColor: Colors.blueGrey,
                            min: 0,
                            max: 20,
                            value: _volume,
                            onChanged: (value) {
                              setState(() {
                                _volume = value;
                              });
                            },
                            onChangeEnd: (_) {
                              _updateFirebaseDatabase();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25.0),
                  color: Colors.lightBlue[50],
                ),
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        " Brightness",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.brightness_6_outlined,
                            size: 30, color: Colors.black),
                        Expanded(
                          child: Slider(
                            activeColor: Colors.lightBlueAccent,
                            inactiveColor: Colors.blueGrey,
                            min: 0,
                            max: 10,
                            value: _brightness,
                            onChanged: (value) {
                              setState(() {
                                _brightness = value;
                              });
                            },
                            onChangeEnd: (_) {
                              _updateFirebaseDatabase();
                            },
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                        color: Colors.blueGrey, thickness: 1.5, height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          ' Auto Brightness',
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Transform.scale(
                            scale: 1,
                            child: Switch(
                                value: _autoBrightness,
                                onChanged: (value) {
                                  setState(() {
                                    _autoBrightness = value;
                                  });
                                  _updateFirebaseDatabase();
                                },
                                activeColor: Colors.grey[100],
                                activeTrackColor: Colors.lightBlueAccent,
                                inactiveTrackColor: Colors.grey[200],
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap
                            )
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25.0),
                  color: Colors.lightBlue[50],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Language',
                      style: TextStyle(
                          fontSize: 22,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: DropdownButton<String>(
                        dropdownColor: Colors.white,
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black,
                          size: 25,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedLanguage = newValue!;
                          });
                          _updateFirebaseDatabase();
                        },
                        style: const TextStyle(
                            fontSize: 21,
                            color: Colors.black
                        ),
                        value: _selectedLanguage,
                        // Set the selected value
                        items: const [
                          DropdownMenuItem<String>(
                            value: "English",
                            child: Text("English"),
                          ),
                          DropdownMenuItem<String>(
                            value: "Hebrew",
                            child: Text("Hebrew"),
                          ),
                          DropdownMenuItem<String>(
                            value: "Arabic",
                            child: Text("Arabic"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25.0),
                  color: Colors.lightBlue[50],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Ringtone',
                      style: TextStyle(
                          fontSize: 22,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: DropdownButton<String>(
                        dropdownColor: Colors.white,
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black,
                          size: 25,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedRingtone = newValue!;
                          });
                          _updateFirebaseDatabase();
                        },
                        style: const TextStyle(
                            fontSize: 21,
                            color: Colors.black
                        ),
                        value: _selectedRingtone,
                        items: const [
                          DropdownMenuItem<String>(
                            value: "Ringtone 1",
                            child: Text("Ringtone 1"),
                          ),
                          DropdownMenuItem<String>(
                            value: "Ringtone 2",
                            child: Text("Ringtone 2"),
                          ),
                          DropdownMenuItem<String>(
                            value: "Ringtone 3",
                            child: Text("Ringtone 3"),
                          ),
                          DropdownMenuItem<String>(
                            value: "Ringtone 4",
                            child: Text("Ringtone 4"),
                          ),
                          DropdownMenuItem<String>(
                            value: "Ringtone 5",
                            child: Text("Ringtone 5"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25.0),
                  color: Colors.lightBlue[50],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        " Show Seconds",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Transform.scale(
                        scale: 1,
                        child: Switch(
                            value: _showSeconds,
                            onChanged: (value) {
                              setState(() {
                                _showSeconds = value;
                              });
                              _updateFirebaseDatabase();
                            },
                            activeColor: Colors.grey[100],
                            activeTrackColor: Colors.lightBlueAccent,
                            inactiveTrackColor: Colors.grey[200],
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap
                        )
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25.0),
                  color: Colors.lightBlue[50],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Light Mode',
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Switch(
                          value: _lightModeEnabled,
                          onChanged: (value) {
                            setState(() {
                              _lightModeEnabled = value;
                              if (!value) _selectedLightColor = "White";
                            });
                            _updateFirebaseDatabase();
                          },
                          activeColor: Colors.grey[100],
                          activeTrackColor: Colors.lightBlueAccent,
                          inactiveTrackColor: Colors.grey[200],
                        ),
                      ],
                    ),
                    if (_lightModeEnabled)
                      Wrap(
                        spacing: 10,
                        children: LightColors.keys.map((color) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedLightColor = color;
                              });
                              _updateFirebaseDatabase();
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: LightColors[color],
                                shape: BoxShape.circle,
                                border: _selectedLightColor == color
                                    ? Border.all(color: Colors.black, width: 3)
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}