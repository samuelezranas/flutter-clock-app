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
    mode: StopWatchMode.countDown, // Mengubah mode menjadi countdown
  );
  late AudioPlayer audioPlayer;
  bool _isRunning = false;
  int _presetTime = 3 * 60 * 1000; // Default preset ke 3 menit (dalam milidetik)
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
    _stopWatchTimer.setPresetSecondTime(_presetTime ~/ 1000); // Reset ke preset time
    setState(() {
      _isRunning = false;
      _remainingTime = _presetTime;
    });
  }

  void _setPreset(int minutes) {
    setState(() {
      _presetTime = minutes * 60 * 1000; // Ubah preset waktu berdasarkan menit
      _stopWatchTimer.setPresetSecondTime(_presetTime ~/ 1000); // Set preset countdown time
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Countdown Timer')),
      body: Column(
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
          
          // Preset Buttons for 3, 5, and 10 minutes
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _setPreset(3),
                child: const Text('3 min'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => _setPreset(5),
                child: const Text('5 min'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => _setPreset(10),
                child: const Text('10 min'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Slider to increase or decrease time
          Slider(
            value: (_presetTime / 1000).toDouble(),
            min: 60, // 1 minute
            max: 20 * 60, // 20 minutes
            divisions: 19, // 1 minute increments
            label: "${(_presetTime / 1000 / 60).round()} min",
            onChanged: (value) {
              setState(() {
                _presetTime = (value * 1000).round(); // Set the time in milliseconds
                _stopWatchTimer.setPresetSecondTime(_presetTime ~/ 1000); // Update preset time
              });
            },
          ),
          const SizedBox(height: 20),
          
          // Start, Pause, and Reset Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _isRunning ? _pauseTimer : _startTimer,
                child: Text(_isRunning ? 'Pause' : 'Start'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _resetTimer,
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
            child: const Text('Finish and Save'),
          ),
        ],
      ),
    );
  }
}
