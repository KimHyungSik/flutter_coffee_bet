import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'home.dart';

void main() {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  runApp(
      const MaterialApp(
        home: HomeScreen(),
        debugShowCheckedModeBanner: false,
      )
  );
}


