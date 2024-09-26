import 'package:flutter/material.dart';

void main() {
  runApp(SimpleWeatherApp());
}

class SimpleWeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Simple Weather Info App'),
        ),
        body: Center(
          child: Text('Welcome to the Weather Info App!'),
        ),
      ),
    );
  }
}
