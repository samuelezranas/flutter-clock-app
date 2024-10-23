import 'package:flutter/material.dart';
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

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Timer ${(_initialTime.toStringAsFixed(0))} menit telah selesai",
                textAlign: TextAlign.center,
              ),
              duration: const Duration(seconds: 7),
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

  void _startTimer() {
    if (_sliderValue > 0) {
      _initialTime = _sliderValue;
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
        _initialTime = value;
      });
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
      appBar: AppBar(
        title: const Text(
          'Timer',
          style: TextStyle(
            color: Colors.blue,
            fontSize: 24,
            fontWeight: FontWeight.bold
          ),
        ),
        elevation: 0.0,
        centerTitle: true,
      ),  
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
                    fontSize: 50,
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
              activeColor: Colors.blue,
              inactiveColor: Colors.blue[100],
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _sliderValue > 0 ? (_isRunning ? _pauseTimer : _startTimer) : null,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                    side: BorderSide(
                      color: Colors.blue, // Outline biru
                      width: 2,
                    ),
                    backgroundColor:
                        _isRunning ? Colors.blue : Colors.white, // Biru saat pause, putih saat start
                  ),
                  child: Icon(
                    _isRunning ? Icons.pause : Icons.play_arrow,
                    size: 30,
                    color: _isRunning ? Colors.white : Colors.blue, // Ikon putih saat pause, biru saat start
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _resetTimer,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                    side: const BorderSide(
                      color: Colors.blue, // Outline biru
                      width: 2,
                    ),
                    backgroundColor: Colors.white, // Latar belakang putih
                  ),
                  child: const Icon(
                    Icons.refresh,
                    size: 30,
                    color: Colors.blue, // Ikon biru
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
