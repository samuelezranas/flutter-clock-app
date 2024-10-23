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
    mode: StopWatchMode.countDown,
  );
  late AudioPlayer audioPlayer;
  bool _isRunning = false;
  double _sliderValue = 0;
  int _remainingTime = 0;
  double _initialTime = 0;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();

    _stopWatchTimer.rawTime.listen((value) async {
      setState(() {
        _remainingTime = value;
        if (_isRunning) {
          _sliderValue = value / (60 * 1000);
        }
      });

      if (value <= 0 && _isRunning) {
        await audioPlayer.play(AssetSource('audio/alarm.mp3'));
        _stopWatchTimer.onStopTimer();
        setState(() {
          _isRunning = false;
          _sliderValue = 0;
        });
        
        // Menampilkan SnackBar dengan posisi yang disesuaikan
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Timer ${(_initialTime.toStringAsFixed(0))} menit telah selesai",
                textAlign: TextAlign.center,
              ),
              duration: const Duration(seconds: 7),
              // Hapus behavior: SnackBarBehavior.floating dan margin
              backgroundColor: Colors.blue,
            ),
          );
        }
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
    if (_sliderValue > 0) {
      // Simpan nilai awal saat timer dimulai
      _initialTime = _sliderValue;
      // Set ulang waktu sesuai nilai slider sebelum memulai timer
      final timeInMillis = (_sliderValue * 60 * 1000).toInt();
      _stopWatchTimer.setPresetTime(mSec: timeInMillis, add: false);
      _stopWatchTimer.onStartTimer();
      setState(() {
        _isRunning = true;
        _remainingTime = timeInMillis;
      });
    }
  }

  void _pauseTimer() {
    _stopWatchTimer.onStopTimer();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _stopWatchTimer.onResetTimer();
    setState(() {
      _isRunning = false;
      _sliderValue = 0;
      _remainingTime = 0;
      _initialTime = 0;
    });
  }

  void _adjustTime(double value) {
    if (!_isRunning) {
      final timeInMillis = (value * 60 * 1000).toInt();
      setState(() {
        _sliderValue = value;
        _remainingTime = timeInMillis;
        _initialTime = value; // Update nilai awal saat slider diubah
      });
      // Set waktu preset saat slider diubah
      _stopWatchTimer.setPresetTime(mSec: timeInMillis, add: false);
    }
  }

  String _formatTime(int milliseconds) {
    final minutes = (milliseconds / (60 * 1000)).floor();
    final seconds = ((milliseconds % (60 * 1000)) / 1000).floor();
    final millis = ((milliseconds % 1000) / 10).floor();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${millis.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timer')),
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<int>(
              stream: _stopWatchTimer.rawTime,
              initialData: _remainingTime,
              builder: (context, snapshot) {
                final displayTime = _isRunning
                    ? _formatTime(snapshot.data!)
                    : _formatTime((_sliderValue * 60 * 1000).toInt());
                return Text(
                  displayTime,
                  style: const TextStyle(
                    fontSize: 40,
                    fontFeatures: [
                      FontFeature.tabularFigures(),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            Slider(
              value: _sliderValue,
              min: 0,
              max: 60,
              divisions: 60,
              label: '${_sliderValue.toStringAsFixed(0)} min',
              onChanged: _isRunning ? null : (value) {
                _adjustTime(value);
              },
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _sliderValue > 0 ? (_isRunning ? _pauseTimer : _startTimer) : null,
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

            ElevatedButton(
              onPressed: () async {
                _pauseTimer();
                _saveToHistory(_remainingTime);
              },
              child: const Text('Finish and Save'),
            ),
          ],
        ),
      ),
    );
  }
}