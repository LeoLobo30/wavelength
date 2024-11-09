// lib/main.dart
import 'package:flutter/material.dart';
import 'package:sintonia_project/View/gameView.dart';
import 'package:sintonia_project/controller/gameController.dart';
void main() {
  runApp(WavelengthGameApp());
}
class WavelengthGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wavelength Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: GameView(controller: GameController()),
    );
  }
}
