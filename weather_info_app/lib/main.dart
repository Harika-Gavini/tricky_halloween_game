import 'package:flutter/material.dart';

void main() {
  runApp(WeatherInfoApp());
}

class WeatherInfoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Info',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Weather Info'),
        ),
        body: Center(
          child: Text('Weather Info App'),
        ),
      ),
    );
  }
}
