import 'package:flutter/material.dart';
import 'package:flutter_clock_app/model/save_to_history.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class StopwatchPage extends StatefulWidget {
  const StopwatchPage({super.key});

  @override
  _StopwatchPageState createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> {
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();
  bool _isRunning = false; // Status apakah stopwatch sedang berjalan atau tidak
  late int _elapsedTime;

  @override
  void initState() {
    super.initState();
    _stopWatchTimer.rawTime.listen((value) {
      setState(() {
        _elapsedTime = value;
      });
    });
  }

  @override
  void dispose() {
    _stopWatchTimer.dispose();
    super.dispose();
  }

  void _startStopTimer() {
    if (_isRunning) {
      // Berhenti jika sedang berjalan
      _stopWatchTimer.onStopTimer();
    } else {
      // Mulai jika belum berjalan
      _stopWatchTimer.onStartTimer();
    }
    setState(() {
      _isRunning = !_isRunning; // Ganti status tombol
    });
  }

  void _restartTimer() {
    _stopWatchTimer.onResetTimer(); // Reset waktu ke 0
    setState(() {
      _isRunning = false; // Reset status tombol
    });
  }

  void _saveToHistory(int elapsedTime) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SaveToHistoryPage(time: elapsedTime),
      ),
    );
    if (result != null && result == true) {
      print("Data telah disimpan ke history");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stopwatch')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<int>(
              stream: _stopWatchTimer.rawTime,
              initialData: _stopWatchTimer.rawTime.value,
              builder: (context, snapshot) {
                final value = snapshot.data!;
                final displayTime = StopWatchTimer.getDisplayTime(value);
                return Text(displayTime, style: const TextStyle(fontSize: 48));
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startStopTimer,
              child: Text(_isRunning ? 'Stop' : 'Start'), // Ganti label berdasarkan status stopwatch
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _restartTimer, // Tombol untuk restart
              child: const Text('Restart'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_isRunning) {
                  _stopWatchTimer.onStopTimer();
                  _isRunning = false;
                }
                _saveToHistory(_elapsedTime); // Simpan hasil waktu ke history
              },
              child: const Text('Finish & Save'),
            ),
          ],
        ),
      ),
    );
  }
}