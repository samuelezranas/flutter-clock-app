import 'package:flutter/material.dart';
import 'package:flutter_clock_app/model/save_to_history.dart';

class StopwatchPage extends StatefulWidget {
  @override
  _StopwatchPageState createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> {
  late int elapsedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stopwatch')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tampilan waktu berjalan
            Text('$elapsedTime seconds', style: TextStyle(fontSize: 48)),
            ElevatedButton(
              onPressed: () {
                // Navigasi ke halaman SaveToHistory setelah stopwatch selesai
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SaveToHistoryPage(time: elapsedTime),
                  ),
                );
              },
              child: Text('Finish and Save'),
            ),
          ],
        ),
      ),
    );
  }
}