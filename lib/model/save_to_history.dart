import 'package:flutter/material.dart';
import 'package:flutter_clock_app/helper/database_helper.dart';

class SaveToHistoryPage extends StatelessWidget {
  final int time;

  const SaveToHistoryPage({super.key, required this.time});

  @override
  Widget build(BuildContext context) {
    final dbHelper = DatabaseHelper(); // Inisialisasi DatabaseHelper

    return Scaffold(
      appBar: AppBar(title: const Text('Save to History')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Time: $time seconds', style: const TextStyle(fontSize: 24)),
          ElevatedButton(
            onPressed: () async {
              // Save to SQLite logic
              Map<String, dynamic> row = {
                'name': 'Workout',  // Anda bisa mengganti dengan nama dinamis
                'time': time
              };
              await dbHelper.insertHistory(row);  // Menyimpan data ke SQLite

              // Pop after saving
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}