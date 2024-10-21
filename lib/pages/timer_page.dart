import 'package:flutter/material.dart';
import 'package:flutter_clock_app/model/save_to_history.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:audioplayers/audioplayers.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countDown, // Menggunakan mode countdown
  );
  late AudioPlayer audioPlayer;
  bool _isRunning = false;
  int _presetTime = 0 * 60 * 1000; // Default preset ke 0 menit (dalam milidetik)
  int _remainingTime = 0; // Waktu yang tersisa

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();

    _stopWatchTimer.setPresetSecondTime(_presetTime ~/ 1000); // Set preset countdown time in seconds

    _stopWatchTimer.rawTime.listen((value) async {
      setState(() {
        _remainingTime = value;
      });

      if (value <= 0 && _isRunning) {
        // Ketika waktu habis, bunyikan ringtone dan hentikan stopwatch
        await audioPlayer.play(AssetSource('audio/alarm.mp3'));
        _stopWatchTimer.onStopTimer();
        setState(() {
          _isRunning = false;
        });
      }
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    _stopWatchTimer.dispose();
    super.dispose();
  }

  void _saveToHistory(int elapsedTime) async {
    // Panggil halaman pop-up untuk menyimpan history
    final result = await showDialog(
      context: context,
      builder: (context) => SaveToHistoryPage(time: elapsedTime),
    );
    if (result != null && result == true) {
      // ignore: avoid_print
      print("Data telah disimpan ke history");
    }
  }

  void _startTimer() {
    _stopWatchTimer.onStartTimer();
    setState(() {
      _isRunning = true;
    });
  }

  void _pauseTimer() {
    _stopWatchTimer.onStopTimer();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _stopWatchTimer.onResetTimer();
    _stopWatchTimer.setPresetSecondTime(0); // Atur ulang waktu ke 0
    setState(() {
      _isRunning = false;
      _remainingTime = 0; // Waktu kembali ke 0
    });
  }

  void _adjustTime(int adjustmentInMillis) {
    setState(() {
      // Gunakan clamp untuk memastikan waktu tidak negatif
      _presetTime = (_presetTime + adjustmentInMillis).clamp(0, 999 * 60 * 1000);
      
      // Jika hasilnya adalah 0, kita bisa mengatur timer ke nilai default minimal, misalnya 1 detik.
      if (_presetTime > 0) {
        _stopWatchTimer.setPresetSecondTime(_presetTime ~/ 1000); // Set waktu dalam detik
      } else {
        _stopWatchTimer.setPresetSecondTime(1); // Set minimal 1 detik
      }
      
      _remainingTime = _presetTime; // Perbarui waktu yang tersisa
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Countdown Timer')),
      body: Padding(
        padding: const EdgeInsets.all(20.0), // Padding 20 dari semua sisi
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<int>(
              stream: _stopWatchTimer.rawTime,
              initialData: _presetTime,
              builder: (context, snapshot) {
                final value = snapshot.data!;
                final displayTime = StopWatchTimer.getDisplayTime(value);
                return Text(displayTime, style: const TextStyle(fontSize: 40));
              },
            ),
            const SizedBox(height: 20),

            // Time Adjustment Buttons with horizontal scroll
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _adjustTime((-5) * 60 * 1000), // Kurangi 5 menit
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Warna utama
                    foregroundColor: Colors.white, // Teks putih
                  ),
                  child: const Text('-5m'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _adjustTime((-60) * 1000), // Kurangi 1 menit
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('-1m'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _adjustTime((-30) * 1000), // Kurangi 30 detik
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('-30s'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _adjustTime(30 * 1000), // Tambah 30 detik
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('+30 s'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _adjustTime(60 * 1000), // Tambah 1 menit
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('+1m'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _adjustTime(5 * 60 * 1000), // Tambah 5 menit
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('+5m'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Start, Pause, and Reset Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isRunning ? _pauseTimer : _startTimer,
                  style: ElevatedButton.styleFrom(
                  ),
                  child: Text(_isRunning ? 'Pause' : 'Start'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _resetTimer, // Tombol Reset sekarang mengatur waktu ke 0 detik
                  style: ElevatedButton.styleFrom(
                  ),
                  child: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Finish and Save Button
            ElevatedButton(
              onPressed: () async {
                _pauseTimer(); // Stop timer before saving
                _saveToHistory(_remainingTime);
              },
              style: ElevatedButton.styleFrom(
              ),
              child: const Text('Finish and Save'),
            ),
          ],
        ),
      ),
    );
  }
}
