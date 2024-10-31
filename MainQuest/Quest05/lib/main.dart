import 'package:flutter/material.dart';
import 'homepage.dart';

void main() {
  runApp(FootballApp());
}

class FootballApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Football Player Management',
      theme: ThemeData(primarySwatch: Colors.green),
      home: HomePage(),
    );
  }
}
