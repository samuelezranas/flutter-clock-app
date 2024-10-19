import 'package:flutter/material.dart';
import 'package:flutter_clock_app/pages/stopwatch_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Menghilangkan banner debug
      title: 'Flutter Stopwatch',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StopwatchPage(),  // Halaman utama adalah StopwatchPage
    );
  }
}

