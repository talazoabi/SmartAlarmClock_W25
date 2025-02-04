import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';

class AlarmsPage extends StatefulWidget {
  @override
  State<AlarmsPage> createState() => _AlarmsPageState();
}

class _AlarmsPageState extends State<AlarmsPage> {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref()
      .child('App/Alarms');


  void addAlarm(Alarm newAlarm) {
    final newAlarmRef = databaseReference.push();

    newAlarmRef.set({
      'Id': newAlarmRef.key,
      'Time': DateFormat('HH:mm').format(newAlarm.Time),
      'Label': newAlarm.Label,
      'selectedDays': newAlarm.selectedDays,
      'isEnabled': newAlarm.isEnabled ? "true" : "false",
    });
  }

  void updateAlarm(Alarm editedAlarm) {
    databaseReference.child(editedAlarm.Id).update({
      'Time': DateFormat('HH:mm').format(editedAlarm.Time),
      'Label': editedAlarm.Label,
      'selectedDays': editedAlarm.selectedDays,
      'isEnabled': editedAlarm.isEnabled ? "true" : "false",
    });
  }

  Future<void> showAlarmConfigPopup(BuildContext context,
      {Alarm? alarm}) async {
    final editedAlarm = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: Text(alarm == null ? 'Add Alarm' : 'Edit Alarm'),
            content: AlarmConfigForm(alarm: alarm),
          ),
        );
      },
    );

    if (editedAlarm != null) {
      if (alarm == null) {
        addAlarm(editedAlarm as Alarm);
      } else {
        updateAlarm(editedAlarm as Alarm);
      }
    }
  }

  String getFormattedDays(Map<String, bool>? selectedDays, DateTime alarmTime) {
    if (selectedDays == null ||
        selectedDays.values.every((isSelected) => !isSelected)) {
      final now = DateTime.now();
      DateTime nearestDate;

      if (alarmTime.hour < now.hour ||
          (alarmTime.hour == now.hour && alarmTime.minute <= now.minute)) {
        nearestDate = DateTime(
            now.year, now.month, now.day + 1, alarmTime.hour, alarmTime.minute);
      } else {
        nearestDate = DateTime(
            now.year, now.month, now.day, alarmTime.hour, alarmTime.minute);
      }

      return DateFormat('EEE, MMM d').format(
          nearestDate);
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.lightBlue[50],
        title: Text(
          'Alarms',
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => showAlarmConfigPopup(context),
            icon: Icon(Icons.add, color: Colors.blueGrey),
          ),
        ],
      ),
      body: StreamBuilder<DataSnapshot>(
        stream: databaseReference.onValue.map((event) => event.snapshot),
        builder: (context, AsyncSnapshot<DataSnapshot> snapshot) {
          if (snapshot.hasData && snapshot.data?.value != null){
            Map<dynamic, dynamic> alarms =
            Map<dynamic, dynamic>.from(snapshot.data!.value as Map);

            List<Map<dynamic, dynamic>> alarmsList = alarms.values
                .map<Map<dynamic, dynamic>>(
                    (alarm) => alarm as Map<dynamic, dynamic>)
                .toList();

            return ListView.builder(
              itemCount: alarmsList.length,
              itemBuilder: (context, index) {
                var alarm = alarmsList[index];
                final bool isEnabled = alarm['isEnabled'].toLowerCase() == 'true';
                DateTime time = _stringToTime(alarm['Time']);
                String timeStr = alarm['Time'];
                Map<String, bool> selectedDays = Map<String, bool>.from(alarm['selectedDays']);
                String? label = alarm['Label'];
                String id = alarm['Id'];

                return GestureDetector(
                  onTap: () => showAlarmConfigPopup(context, alarm: mapToAlarm(alarm)),
                  child: Dismissible(
                      key: Key(id),
                      onDismissed: (direction) {
                        databaseReference.child(id).remove();
                      },
                    background: Container(
                      color: Colors.red,
                      child: Icon(Icons.delete, color: Colors.white),
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                    ),
                    child: Card(
                      color: Colors.lightBlue[50],
                      elevation: 4,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (label != null && label.isNotEmpty)
                              Text(
                                label,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: isEnabled ? Colors.black : Colors.grey,
                                ),
                              ),
                            if(label == null)
                              SizedBox(height: 5,),
                            Text(
                              timeStr,
                              style: TextStyle(
                                fontSize: 30,
                                color: isEnabled ? Colors.black : Colors.grey,
                                fontWeight: FontWeight.bold,
                              )
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                if (selectedDays?.values.any((isSelected) => isSelected) ?? false)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: List.generate(7, (index){
                                      final dayAbbr = ['S', 'M', 'T', 'W', 'T', 'F', 'S'][index];
                                      final isSelected = selectedDays?[
                                      ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'][index]] ??
                                        false;

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            isSelected ?
                                                Icon(Icons.circle, size: 4,
                                                  color: isSelected & isEnabled ? Colors.blue : Colors.grey)
                                                  : SizedBox(height: 4),
                                            const SizedBox(height: 2),
                                            Text(
                                              dayAbbr,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: isSelected? FontWeight.bold : FontWeight.normal,
                                                color: isSelected & isEnabled ? Colors.blue : Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ),
                                if(!(selectedDays?.values.any((isSelected) => isSelected) ?? false))
                                  Text(
                                    getFormattedDays(selectedDays, time),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isEnabled ? Colors.blue : Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(width: 8),
                            Switch(
                                value: isEnabled,
                                onChanged: (value) {
                                  databaseReference.child(id).update({
                                    'isEnabled': isEnabled ? "false" : "true",
                                  });
                                }
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(
              child: Text(
                'No available alarms',
                style: TextStyle(fontSize: 18),
              ),
            );
          }
        },
      ),
    );
  }

  DateTime _stringToTime(String timeString) {
    int hours = int.parse(timeString.substring(0, 2));
    int minutes = int.parse(timeString.substring(3, 5));

    DateTime today = DateTime.now();
    return DateTime(today.year, today.month, today.day, hours, minutes);
  }

  Alarm mapToAlarm(Map<dynamic, dynamic> alarmMap) {
    final days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

    Map<String, bool> selectedDays = {
      days[0]: alarmMap['selectedDays']['Sunday'] ?? false,
      days[1]: alarmMap['selectedDays']['Monday'] ?? false,
      days[2]: alarmMap['selectedDays']['Tuesday'] ?? false,
      days[3]: alarmMap['selectedDays']['Wednesday'] ?? false,
      days[4]: alarmMap['selectedDays']['Thursday'] ?? false,
      days[5]: alarmMap['selectedDays']['Friday'] ?? false,
      days[6]: alarmMap['selectedDays']['Saturday'] ?? false,
    };

    return Alarm(
      Id: alarmMap['Id'],
      Label: alarmMap.containsKey('Label') ? alarmMap['Label'] : '',
      Time: _stringToTime(alarmMap['Time']),
      selectedDays: selectedDays,
      isEnabled: alarmMap['isEnabled'].toLowerCase() == 'true',
    );
  }
}

class Alarm {
  final String Id;
  final String? Label;
  final DateTime Time;
  final Map<String, bool>? selectedDays;
  bool isEnabled;

  Alarm({
    required this.Id,
    this.Label,
    required this.Time,
    this.selectedDays,
    this.isEnabled = true,
  });
}

class AlarmConfigForm extends StatefulWidget {
  final Alarm? alarm;

  const AlarmConfigForm({Key? key, this.alarm}) : super(key: key);

  @override
  _AlarmConfigFormState createState() => _AlarmConfigFormState();
}

class _AlarmConfigFormState extends State<AlarmConfigForm> {
  late DateTime selectedTime;
  late int selectedHour;
  late int selectedMinute;
  late List<bool> selectedDays;
  late TextEditingController messageController;

  @override
  void initState() {
    super.initState();
    selectedTime = widget.alarm?.Time ?? DateTime.now().add(Duration(minutes: 1));
    selectedHour = selectedTime.hour;
    selectedMinute = selectedTime.minute;
    selectedDays =
        widget.alarm?.selectedDays?.values.toList() ?? List.filled(7, false);
    messageController = TextEditingController(text: widget.alarm?.Label ?? '');
  }

  void updateSelectedTime() {
    setState(() {
      selectedTime = DateTime(
        selectedTime.year,
        selectedTime.month,
        selectedTime.day,
        selectedHour,
        selectedMinute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  NumberPicker(
                    minValue: 0,
                    maxValue: 23,
                    value: selectedHour,
                    zeroPad: true,
                    infiniteLoop: true,
                    textStyle: const TextStyle(
                        color: Colors.grey, fontSize: 25),
                    selectedTextStyle: const TextStyle(
                        color: Colors.lightBlue, fontSize: 35),
                    onChanged: (value) {
                      setState(() {
                        selectedHour = value;
                        updateSelectedTime();
                      });
                    },
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  ':',
                  style: Theme
                      .of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(
                      fontWeight: FontWeight.bold, color: Colors.lightBlue),
                ),
              ),
              Column(
                children: [
                  NumberPicker(
                    minValue: 0,
                    maxValue: 59,
                    value: selectedMinute,
                    zeroPad: true,
                    infiniteLoop: true,
                    textStyle: const TextStyle(
                        color: Colors.grey, fontSize: 25),
                    selectedTextStyle: const TextStyle(
                        color: Colors.lightBlue, fontSize: 35),
                    onChanged: (value) {
                      setState(() {
                        selectedMinute = value;
                        updateSelectedTime();
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'Select days for the alarm:',
            style: Theme
                .of(context)
                .textTheme
                .bodyLarge,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate( 7,
                  (index) {
                final day = [
                  'Sun',
                  'Mon',
                  'Tue',
                  'Wed',
                  'Thu',
                  'Fri',
                  'Sat'
                ][index];
                final isSelected = selectedDays[index];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDays[index] = !isSelected;
                    });
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? Colors.blue : Colors.grey,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      day,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ).toList(),
          ),
          SizedBox(height: 20),
          TextField(
            controller: messageController,
            decoration: InputDecoration(
              labelText: 'Alarm label',
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                      context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final newAlarm = Alarm(
                    Id: widget.alarm?.Id ?? '',
                    Time: selectedTime,
                    Label: messageController.text.isNotEmpty ? messageController
                        .text : null,
                    selectedDays: Map.fromIterables(
                      [
                        'Sunday',
                        'Monday',
                        'Tuesday',
                        'Wednesday',
                        'Thursday',
                        'Friday',
                        'Saturday'
                      ],
                      selectedDays,
                    ),
                  );

                  Navigator.pop(context, newAlarm);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                ),
                child: Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}