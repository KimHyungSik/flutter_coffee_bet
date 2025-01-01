import 'dart:async';

import 'package:coffee_bet/user_circle_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game_over.dart';
import 'guessing_game/guessing_game.dart';

void main() {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  runApp(const GuessingGameApp());
}


