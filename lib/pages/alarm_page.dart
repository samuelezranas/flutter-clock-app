import 'package:flutter/material.dart';
import 'package:flutter_clock_app/helper/alarm_database.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'dart:async';

class AlarmPage extends StatefulWidget {
  @override
  _AlarmPageState createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  List<Map<String, dynamic>> _alarms = [];
  bool _loading = true;
  TimeOfDay? _selectedTime;
  String? _description;

  late Timer _alarmTimer;

  @override
  void initState() {
    super.initState();
    _fetchAlarms(); // Fetch saved alarms when page is loaded
  }

  Future<void> _fetchAlarms() async {
    final alarms = await AlarmDatabaseHelper.instance.getAlarms();
    setState(() {
      _alarms = alarms;
      _loading = false;
    });
  }

  Future<void> _pickTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
      _showDescriptionDialog(); // Show dialog to get description
    }
  }

  Future<void> _showDescriptionDialog() async {
    TextEditingController controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Alarm Description'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Description'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _description = controller.text;
                });
                if (_description != null && _selectedTime != null) {
                  _saveAlarm(_description!, _selectedTime!.format(context));
                }
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveAlarm(String description, String time) async {
    await AlarmDatabaseHelper.instance.insertAlarm({
      'time': time,
      'description': description,
      'isActive': 1, // Set alarm as active by default
    });
    _fetchAlarms(); // Refresh the list of alarms after saving
  }

  // Function to trigger alarm
  void _onAlarmTrigger(String time) async {
    // Play alarm sound
    AudioPlayer player = AudioPlayer();
    await player.play(AssetSource('audio/alarm.mp3'));

    // Vibrate phone
    if (await Vibrate.canVibrate) {
      Vibrate.vibrate();
    }

    // Show snackbar with OK button
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Alarm pada $time telah berbunyi!'),
        action: SnackBarAction(
          label: 'Okay',
          onPressed: () {
            player.stop(); // Stop sound
          },
        ),
      ),
    );
  }

  // Function to handle start/stop logic
  void _toggleAlarm(int id, bool isActive) async {
    if (isActive) {
      // Schedule the alarm
      _scheduleAlarm(id);
    } else {
      // Cancel the alarm if deactivated
      if (_alarmTimer.isActive) {
        _alarmTimer.cancel();
      }
      await AlarmDatabaseHelper.instance.updateAlarmStatus(id, 0);
    }
    _fetchAlarms(); // Refresh alarms
  }

  // Function to schedule the alarm
  void _scheduleAlarm(int id) async {
    final alarm = _alarms.firstWhere((element) => element['id'] == id);
    String alarmTime = alarm['time'];

    // Calculate time difference to trigger the alarm
    TimeOfDay alarmTimeObj = TimeOfDay(
      hour: int.parse(alarmTime.split(':')[0]),
      minute: int.parse(alarmTime.split(':')[1]),
    );

    DateTime now = DateTime.now();
    DateTime nextAlarm = DateTime(now.year, now.month, now.day, alarmTimeObj.hour, alarmTimeObj.minute);

    if (nextAlarm.isBefore(now)) {
      nextAlarm = nextAlarm.add(Duration(days: 1)); // Set for next day if time already passed
    }

    // Schedule the alarm to trigger after the calculated duration
    _alarmTimer = Timer(nextAlarm.difference(now), () {
      _onAlarmTrigger(alarmTime);
    });

    // Update alarm status in the database
    await AlarmDatabaseHelper.instance.updateAlarmStatus(id, 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Alarm',
          style: TextStyle(
            color: Colors.blue,
            fontSize: 24,
            fontWeight: FontWeight.bold
          ),
        ),
        elevation: 0.0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _pickTime(context); // Call the time picker when adding an alarm
            },
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _alarms.length,
              itemBuilder: (context, index) {
                final alarm = _alarms[index];
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    title: Text(
                      alarm['time'], // Display alarm time
                      style: TextStyle(color: Colors.black),
                    ),
                    subtitle: Text(
                      alarm['description'], // Display alarm description
                      style: TextStyle(color: Colors.black),
                    ),
                    trailing: Switch(
                      value: alarm['isActive'] == 1, // Determine active state
                      onChanged: (bool value) {
                        _toggleAlarm(alarm['id'], value);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}