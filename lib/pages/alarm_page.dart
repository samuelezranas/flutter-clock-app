import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_clock_app/helper/alarm_database.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

class AlarmPage extends StatefulWidget {
  @override
  _AlarmPageState createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  final AlarmDatabaseHelper _dbHelper = AlarmDatabaseHelper();
  List<Map<String, dynamic>> _alarms = [];

  @override
  void initState() {
    super.initState();
    _loadAlarms();
  }

  Future<void> _loadAlarms() async {
    List<Map<String, dynamic>> alarms = await _dbHelper.getAlarms();
    setState(() {
      _alarms = alarms;
    });
  }

  Future<void> _saveAlarm(String name, String time) async {
    Map<String, dynamic> alarm = {
      'name': name,
      'time': time,
      'isActive': 1, // Default active
    };
    await _dbHelper.insertAlarm(alarm);
    _loadAlarms(); // Reload alarms after saving
  }

  Future<void> _toggleAlarmStatus(int id, bool isActive) async {
    await _dbHelper.updateAlarmStatus(id, isActive ? 1 : 0);
    _loadAlarms();
  }

  Future<void> _deleteAlarm(int id) async {
    await _dbHelper.deleteAlarm(id);
    _loadAlarms();
  }

  void _onAlarmTrigger(String time) async {
  // Play alarm sound
  AudioPlayer player = AudioPlayer();
  await player.play(AssetSource('audio/alarm.mp3'));

  // Vibrate phone (will stop automatically after a short burst)
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
          // No need to cancel vibration as it will stop automatically
        },
      ),
    ),
  );
}

  Future<void> _showAddAlarmDialog() async {
    String? alarmName;
    TimeOfDay? selectedTime;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Alarm'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Alarm Name'),
                onChanged: (value) {
                  alarmName = value;
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  selectedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  Navigator.of(context).pop();
                },
                child: Text('Pick Alarm Time'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (alarmName != null && selectedTime != null) {
                  final time = selectedTime!.format(context);
                  _saveAlarm(alarmName!, time);
                }
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
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
            onPressed: _showAddAlarmDialog,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _alarms.length,
        itemBuilder: (context, index) {
          final alarm = _alarms[index];
          final isActive = alarm['isActive'] == 1;
          return ListTile(
            title: Text(alarm['name']),
            subtitle: Text('Waktu: ${alarm['time']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: isActive,
                  onChanged: (value) {
                    _toggleAlarmStatus(alarm['id'], value);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _deleteAlarm(alarm['id']);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}