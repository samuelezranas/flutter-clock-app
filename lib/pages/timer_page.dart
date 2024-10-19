import 'package:flutter/material.dart';
import 'package:flutter_clock_app/model/save_to_history.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class TimerPage extends StatefulWidget {
  @override
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    isLapHours: true,
  );

  @override
  void initState() {
    super.initState();
    _stopWatchTimer.rawTime.listen((value) {
      if (value == 0) {
        // Ketika waktu habis, bunyikan ringtone
        FlutterRingtonePlayer.playRingtone();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _stopWatchTimer.dispose();
  }

  void _saveToHistory(int elapsedTime) async {
    // Panggil halaman pop-up untuk menyimpan history
    final result = await showDialog(
      context: context,
      builder: (context) => SaveToHistoryPage(time: elapsedTime),
    );
    if (result != null && result == true) {
      print("Data telah disimpan ke history");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timer')),
      body: Column(
        children: [
          StreamBuilder<int>(
            stream: _stopWatchTimer.rawTime,
            initialData: _stopWatchTimer.rawTime.value,
            builder: (context, snapshot) {
              final value = snapshot.data!;
              final displayTime = StopWatchTimer.getDisplayTime(value);
              return Text(displayTime, style: const TextStyle(fontSize: 40));
            },
          ),
          ElevatedButton(
            onPressed: () async {
              // Simpan setelah timer selesai
              _stopWatchTimer.onStop!();
              _saveToHistory(_stopWatchTimer.rawTime.value);
            },
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }
}