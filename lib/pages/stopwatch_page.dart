import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_clock_app/model/save_to_history.dart';
import 'dart:async';

class StopwatchPage extends StatefulWidget {
  @override
  _StopwatchPageState createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> {
  late int elapsedTime = 0;
  late Timer _timer;
  bool _isRunning = false;
  AudioPlayer audioPlayer = AudioPlayer();

  // Function to start the stopwatch
  void _startTimer() {
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        elapsedTime++;
      });
    });
  }

  // Function to stop the stopwatch
  void _stopTimer() {
    _isRunning = false;
    _timer.cancel();
  }

  // Function to play the alarm sound
  void _playAlarmSound() {
    audioPlayer.play(AssetSource('sounds/alarm_sound.mp3'));
  }

  // Function to handle finish and save
  void _finishAndSave() {
    _stopTimer();
    _playAlarmSound(); // Play sound when finishing
    // Navigate to SaveToHistoryPage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SaveToHistoryPage(time: elapsedTime),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stopwatch')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tampilan waktu berjalan
            Text('$elapsedTime seconds', style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isRunning ? null : _startTimer,
              child: const Text('Start'),
            ),
            ElevatedButton(
              onPressed: !_isRunning ? null : _stopTimer,
              child: const Text('Stop'),
            ),
            ElevatedButton(
              onPressed: !_isRunning ? null : _finishAndSave,
              child: const Text('Finish and Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    audioPlayer.dispose();
    super.dispose();
  }
}
