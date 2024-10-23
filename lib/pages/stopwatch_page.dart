import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class StopwatchPage extends StatefulWidget {
  const StopwatchPage({super.key});

  @override
  _StopwatchPageState createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> {
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();
  bool _isRunning = false; // Status apakah stopwatch sedang berjalan atau tidak

  @override
  void initState() {
    super.initState();
    _stopWatchTimer.rawTime.listen((value) {
      setState(() {
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
      _stopWatchTimer.onStopTimer(); // Berhenti jika sedang berjalan
    } else {
      _stopWatchTimer.onStartTimer(); // Mulai jika belum berjalan
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Stopwatch',
          style: TextStyle(
            color: Colors.blue,
            fontSize: 24,
            fontWeight: FontWeight.bold
          ),
        ),
        elevation: 0.0,
        centerTitle: true,
      ),  
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Tombol Start/Stop
                OutlinedButton(
                  onPressed: _startStopTimer,
                  style: OutlinedButton.styleFrom(
                    shape: const CircleBorder(), // Membuat tombol menjadi bulat
                    padding: const EdgeInsets.all(20), // Ukuran tombol
                    side: BorderSide(
                      color: _isRunning ? Colors.blue : Colors.blue, // Outline berwarna biru
                      width: 2,
                    ),
                    backgroundColor: _isRunning ? Colors.blue : Colors.white, // Background biru saat running
                  ),
                  child: Icon(
                    _isRunning ? Icons.pause : Icons.play_arrow, // Icon play/pause
                    color: _isRunning ? Colors.white : Colors.blue, // Warna ikon putih saat running
                    size: 32,
                  ),
                ),
                const SizedBox(width: 20), // Jarak antara tombol
                // Tombol Restart
                OutlinedButton(
                  onPressed: _restartTimer,
                  style: OutlinedButton.styleFrom(
                    shape: const CircleBorder(), // Membuat tombol menjadi bulat
                    padding: const EdgeInsets.all(20), // Ukuran tombol
                    side: const BorderSide(color: Colors.blue, width: 2), // Outline biru
                    backgroundColor: Colors.white, // Background putih
                  ),
                  child: const Icon(
                    Icons.restart_alt, // Icon restart
                    color: Colors.blue, // Warna ikon biru
                    size: 32,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
