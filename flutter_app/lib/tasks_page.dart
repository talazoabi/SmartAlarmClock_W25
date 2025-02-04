import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:numberpicker/numberpicker.dart';

class TasksPage extends StatefulWidget {
  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  DatabaseReference databaseReference = FirebaseDatabase.instance.ref().child('App/Tasks');
  OverlayEntry? _errorOverlay;

  void _showErrorOverlay(String message) {
    if (!mounted) return;

    if (_errorOverlay != null) {
      _errorOverlay?.remove();
      _errorOverlay = null;
    }

    _errorOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.15,
        left: MediaQuery.of(context).size.width * 0.1,
        right: MediaQuery.of(context).size.width * 0.1,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    _errorOverlay?.remove();
                    _errorOverlay = null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final overlay = Overlay.of(context);
    if (overlay != null) {
      overlay.insert(_errorOverlay!);
      Future.delayed(Duration(seconds: 3), () {
        if (_errorOverlay != null) {
          _errorOverlay?.remove();
          _errorOverlay = null;
        }
      });
    } else {
      debugPrint("Overlay not found in the current context.");
    }
  }

  Future<void> _showTaskDialog({Map<dynamic, dynamic>? task}) async {
    // Edit or Add
    bool isEdit = task != null;

    if (isEdit) {
      DateTime taskDateTime = DateTime(
        int.parse('20${task!['Date'].substring(4, 6)}'),
        int.parse(task['Date'].substring(2, 4)),
        int.parse(task['Date'].substring(0, 2)),
        int.parse(task['Time'].split(':')[0]),
        int.parse(task['Time'].split(':')[1]),
      );

      if (taskDateTime.isBefore(DateTime.now())) {
        _showErrorOverlay("This task has already ended and cannot be edited.");
        return;
      }
    }

    String taskName = isEdit ? task!['Label'] : '';
    DateTime selectedDate = isEdit ? _stringToDate(task!['Date']) : DateTime.now();
    int selectedHour = isEdit
        ? int.parse(task!['Time'].split(':')[0])
        : DateTime.now().add(Duration(minutes: 1)).hour;
    int selectedMinute = isEdit
        ? int.parse(task!['Time'].split(':')[1])
        : DateTime.now().add(Duration(minutes: 1)).minute;

    TextEditingController nameController = TextEditingController(text: taskName);

    DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (newDate == null) return;

    bool timeConfirmed = false;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'Edit Time' : 'Select Time'),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Column(
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
                            textStyle: const TextStyle(color: Colors.grey, fontSize: 25),
                            selectedTextStyle: const TextStyle(color: Colors.lightBlue, fontSize: 35),
                            onChanged: (value) {
                              setStateDialog(() {
                                selectedHour = value;
                              });
                            },
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          ':',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold, color: Colors.lightBlue),
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
                            textStyle: const TextStyle(color: Colors.grey, fontSize: 25),
                            selectedTextStyle: const TextStyle(color: Colors.lightBlue, fontSize: 35),
                            onChanged: (value) {
                              setStateDialog(() {
                                selectedMinute = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                DateTime selectedDateTime = DateTime(
                  newDate.year,
                  newDate.month,
                  newDate.day,
                  selectedHour,
                  selectedMinute,
                );
                if (selectedDateTime.isBefore(DateTime.now())) {
                  _showErrorOverlay("Please select a future time.");
                  return;
                }

                timeConfirmed = true;
                Navigator.pop(context);
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );

    if (!timeConfirmed) return;

    String? newName = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'Edit Task Name' : 'Enter Task Name'),
          content: TextField(
            controller: nameController,
            autofocus: true,
            decoration: InputDecoration(hintText: "Task name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              child: Text("OK"),
              onPressed: () {
                String updatedName = nameController.text.trim();

                if (updatedName.isEmpty) {
                  _showErrorOverlay("Please enter a task name.");
                  return;
                }

                if (updatedName.length > 20) {
                  _showErrorOverlay("Task name cannot be longer than 20 characters.");
                  return;
                }

                Navigator.pop(context, updatedName);
              },
            ),
          ],
        );
      },
    );

    if (newName == null || newName.isEmpty) return;

    String formattedDate = DateFormat('ddMMyy').format(newDate);
    String formattedTime =
        '${selectedHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')}';

    if (isEdit) {
      databaseReference.child(task!['Id']).update({
        'Label': newName,
        'Date': formattedDate,
        'Time': formattedTime,
      });
    } else {
      String taskId = databaseReference.push().key!;
      databaseReference.child(taskId).set({
        'Id': taskId,
        'Date': formattedDate,
        'Time': formattedTime,
        'Label': newName,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.lightBlue[50],
        title: const Text(
          'Task Manager',
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.blueGrey),
            onPressed: _showTaskDialog,
          ),
        ],
      ),
      body: StreamBuilder<DataSnapshot>(
          stream: databaseReference.onValue.map((event) => event.snapshot),
          builder: (context, AsyncSnapshot<DataSnapshot> snapshot) {
            if (snapshot.hasData && snapshot.data!.value != null) {
              Map<dynamic, dynamic> tasks =
              Map<dynamic, dynamic>.from(snapshot.data!.value as Map);

              List<Map<dynamic, dynamic>> sortedTasks = tasks.values
                  .map<Map<dynamic, dynamic>>((task) => task as Map<dynamic, dynamic>)
                  .toList();

              sortedTasks.sort((a, b) {
                int dateComparison = a['Date'].compareTo(b['Date']);
                if (dateComparison != 0) return dateComparison;
                return a['Time'].compareTo(b['Time']);
              });

              return ListView.builder(
                itemCount: sortedTasks.length,
                itemBuilder: (context, index) {
                  var task = sortedTasks[index];
                  DateTime taskDateTime = DateTime(
                    int.parse('20${task!['Date'].substring(4, 6)}'),
                    int.parse(task['Date'].substring(2, 4)),
                    int.parse(task['Date'].substring(0, 2)),
                    int.parse(task['Time'].split(':')[0]),
                    int.parse(task['Time'].split(':')[1]),
                  );
                  return GestureDetector(
                    child: Dismissible(
                      key: Key(task['Id']),
                      onDismissed: (direction) {
                        databaseReference.child(task['Id']).remove();
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
                              if (task['Label'] != null && task['Label'].isNotEmpty)
                                Text(
                                  task['Label'],
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                  ),
                                ),
                              Text(
                                '${task['Time']}',
                                style: TextStyle(
                                  fontSize: 28,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${task['Date'].substring(0, 2)}/${task['Date'].substring(2, 4)}/${task['Date'].substring(4)}',
                                    style: TextStyle(
                                      fontSize: 22,
                                      color: Colors.black,
                                    ),
                                  ),
                                  taskDateTime.isBefore(DateTime.now())
                                      ? Icon(Icons.done, color: Colors.green, size: 30,)
                                      : IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      _showTaskDialog(task: task);
                                    },
                                  ),
                                ],
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
                  'No upcoming tasks',
                  style: TextStyle(fontSize: 18),
                ),
              );
            }
          },
      ),
    );
  }

  DateTime _stringToDate(String dateString) {
    return DateTime(
      int.parse('20${dateString.substring(4, 6)}'),
      int.parse(dateString.substring(2, 4)),
      int.parse(dateString.substring(0, 2)),
    );
  }
}