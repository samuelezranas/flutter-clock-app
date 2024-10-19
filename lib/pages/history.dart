import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Example: Fetch history from SQLite
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchHistory(), // Fetch from SQLite
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          final history = snapshot.data!;
          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(history[index]['name']),
                subtitle: Text('Time: ${history[index]['time']} seconds'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // Edit name logic
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchHistory() async {
    // SQLite query example
    Database db = await openDatabase('fitness.db');
    return db.query('history');
  }
}
