import 'package:flutter/material.dart';
import 'package:flutter_clock_app/helper/alarm_database.dart';

class AlarmListPage extends StatefulWidget {
  const AlarmListPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AlarmListPageState createState() => _AlarmListPageState();
}

class _AlarmListPageState extends State<AlarmListPage> {
  late Future<List<Map<String, dynamic>>> _alarms;

  @override
  void initState() {
    super.initState();
    _loadAlarms();
  }

  Future<void> _loadAlarms() async {
    _alarms = AlarmDatabaseHelper.instance.getAlarms();
    setState(() {});
  }

  Future<void> _deleteAlarm(int id) async {
    await AlarmDatabaseHelper.instance.deleteAlarm(id);
    _loadAlarms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alarms')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _alarms,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No alarms set'));
          }

          final alarms = snapshot.data!;

          return ListView.builder(
            itemCount: alarms.length,
            itemBuilder: (context, index) {
              final alarm = alarms[index];
              return ListTile(
                title: Text(alarm['description']),
                subtitle: Text('Time: ${alarm['time']}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteAlarm(alarm['id']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
