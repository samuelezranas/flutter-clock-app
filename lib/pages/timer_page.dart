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
  double _sliderValue = 0; // Nilai slider yang diatur pengguna
  int _remainingTime = 0; // Waktu yang tersisa

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();

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
    _stopWatchTimer.setPresetSecondTime(0); // Atur ulang waktu ke 0 detik
    setState(() {
      _isRunning = false;
      _sliderValue = 0; // Reset slider value
      _remainingTime = 0; // Reset remaining time
    });
  }

  void _adjustTime(double value) {
    setState(() {
      _sliderValue = value; // Simpan nilai slider
      final presetTimeInMillis = (_sliderValue * 60 * 1000).toInt(); // Konversi ke milidetik
      _stopWatchTimer.setPresetSecondTime(presetTimeInMillis ~/ 1000); // Atur waktu dalam detik
      _remainingTime = presetTimeInMillis; // Perbarui waktu yang tersisa
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
              initialData: _remainingTime,
              builder: (context, snapshot) {
                final value = snapshot.data!;
                final displayTime = StopWatchTimer.getDisplayTime(value);
                return Text(displayTime, style: const TextStyle(fontSize: 40));
              },
            ),
            const SizedBox(height: 20),

            // Slider for adjusting time
            Slider(
              value: _sliderValue, // Gunakan nilai slider yang diatur
              min: 0, // Waktu minimal adalah 0 menit
              max: 60, // Waktu maksimal adalah 60 menit
              divisions: 60, // Membagi slider ke dalam 60 bagian (per menit)
              label: '${_sliderValue.toStringAsFixed(0)} min', // Label menit
              onChanged: _isRunning
                  ? null // Disable slider if timer is running
                  : (value) {
                      _adjustTime(value);
                    },
            ),
            const SizedBox(height: 20),

            // Start, Pause, and Reset Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isRunning ? _pauseTimer : _startTimer,
                  style: ElevatedButton.styleFrom(),
                  child: Text(_isRunning ? 'Pause' : 'Start'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _resetTimer, // Tombol Reset sekarang mengatur waktu ke 0 detik
                  style: ElevatedButton.styleFrom(),
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
              style: ElevatedButton.styleFrom(),
              child: const Text('Finish & Save'),
            ),
          ],
        ),
      ),
    );
  }
}
