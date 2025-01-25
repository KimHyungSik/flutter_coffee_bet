import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

Widget startButton(VoidCallback onPressed) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(32)),
        color: Color(0xFF007C4A),
      ),
      width: 108,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 37),
        child: SvgPicture.asset('assets/icon/icon_arrow_32.svg'),
      ),
    ),
  );
}
