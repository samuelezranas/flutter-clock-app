import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:blueclock/widget/edit_alarm.dart';
import 'package:blueclock/services/permission.dart';
import 'package:blueclock/widget/tile.dart';
import 'package:url_launcher/url_launcher.dart';

const version = '4.0.8';

class AlarmPage extends StatefulWidget {
  const AlarmPage({super.key});

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  late List<AlarmSettings> alarms;

  static StreamSubscription<int>? updateSubscription;

  @override
  void initState() {
    super.initState();
    AlarmPermissions.checkNotificationPermission();
    if (Alarm.android) {
      AlarmPermissions.checkAndroidScheduleExactAlarmPermission();
    }
    loadAlarms();
    updateSubscription ??= Alarm.updateStream.stream.listen((_) {
      loadAlarms();
    });
  }

  void loadAlarms() {
    setState(() {
      alarms = Alarm.getAlarms();
      alarms.sort((a, b) => a.dateTime.isBefore(b.dateTime) ? 0 : 1);
    });
  }

  Future<void> navigateToAlarmScreen(AlarmSettings? settings) async {
    final res = await showModalBottomSheet<bool?>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.75,
          child: AlarmEditScreen(alarmSettings: settings),
        );
      },
    );

    if (res != null && res == true) loadAlarms();
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alarm Feature Overview'),
          content: const Text(
            'This alarm feature is created using the alarm plugin version 4.0.8, '
            'which brings powerful scheduling and notification capabilities to our app. '
            'Here’s a summary of what the app can do with this plugin:\n\n'
            '1. Scheduled Alarms: The alarm plugin allows the app to schedule alarms '
            'for specific times, even if the app is closed or the device is restarted.\n'
            '2. Recurring Alarms: Users can set recurring alarms for daily or weekly intervals.\n'
            '3. Custom Notifications: Alarms can be configured to show custom notifications.\n'
            '4. Sound and Vibration: The plugin supports customizable alarm sounds and vibrations.\n'
            '5. Persistence: Alarms set through this plugin remain active even if the app is killed.\n'
            '6. Background Execution: The plugin operates in the background, ensuring alarms work seamlessly.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                launchReadmeUrl(); // Open the README URL
              },
              child: const Text('Read More'),
            ),
          ],
        );
      },
    );
  }

  Future<void> launchReadmeUrl() async {
    final url = Uri.parse('https://pub.dev/packages/alarm/versions/$version');
    await launchUrl(url);
  }

  @override
  void dispose() {
    updateSubscription?.cancel();
    super.dispose();
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
        GestureDetector(
          onTap: () => _showInfoDialog(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            alignment: Alignment.center,
            width: 35,
            child: 
              const Icon(
                Icons.info, 
                size: 25,),
          ),
        ),
      ],
      ),  
      body: SafeArea(
        child: alarms.isNotEmpty
            ? ListView.separated(
                itemCount: alarms.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  return AlarmTile(
                    key: Key(alarms[index].id.toString()),
                    title: TimeOfDay(
                      hour: alarms[index].dateTime.hour,
                      minute: alarms[index].dateTime.minute,
                    ).format(context),
                    onPressed: () => navigateToAlarmScreen(alarms[index]),
                    onDismissed: () {
                      Alarm.stop(alarms[index].id).then((_) => loadAlarms());
                    },
                  );
                },
              )
            : Center(
                child: Text(
                  'No alarms set',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
      ),
      floatingActionButton: Padding(
      padding: const EdgeInsets.only(right: 24, bottom: 24),
      child: SizedBox(
        width: 65, // Set width for larger size
        height: 65, // Set height for larger size
        child: FloatingActionButton(
          onPressed: () => navigateToAlarmScreen(null),
          backgroundColor: Colors.blue, // Background color white
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50), // Circular shape
          ),
          child: const Icon(
            Icons.alarm_add_rounded,
            size: 40, // Increase icon size as well
            color: Colors.white, // Icon color blue
          ),
        ),
      ),
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Position on the right
    );
  }
}
