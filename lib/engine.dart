

import 'dart:ui';

import 'package:flutter/material.dart';

const Color black = Color(0xff000000);
const Color white = Color(0xffffffff);
const Color transparent = Color(0xff00000000);
const Color default_white = Color(0xfffff3f3f3);
const Color blue09 = Color(0xff0f534949);
const Color red0 = Color(0xffff0000);
const Color blue0 = Color(0xff8470ff);
const Color blue3 = Color(0xff5c4eb2);
const Color brown0 = Color(0xffa52a2a);
const Color blue6 = Color(0xff342c66);

const String ic_divide = 'assets/ic_divide.png';

const int MODE_EASY = 2;
const int MODE_MEDIUM = 3;
const int MODE_HARD = 4;
const int MODE_DIFFICULT = 5;
const String TIMED_GAME = "timedGame";
const String GAME_MODE = "gameMode";
const String GAME_SOUND = "gameSound";
const String RANKING = "ranking";

textStyle(bool bold, double size, color,
    {underlined = false, bool withShadow = false}) {
  return TextStyle(
      color: color,
      fontWeight: FontWeight.normal,
      fontSize: size,
      shadows: !withShadow
          ? null
          : (<Shadow>[
        Shadow(offset: Offset(4.0, 4.0), blurRadius: 6.0, color: black),
      ]),
      decoration: underlined ? TextDecoration.underline : TextDecoration.none);
}

addSpaceWidth(double size) {
  return SizedBox(
    width: size,
  );
}

Container addLine(
    double size, color, double left, double top, double right, double bottom) {
  return Container(
    height: size,
    width: double.infinity,
    color: color,
    margin: EdgeInsets.fromLTRB(left, top, right, bottom),
  );
}

loadingLayout() {
  return new Container(
    color: white,
    child: Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Center(
          child: CircularProgressIndicator(
            //value: 20,
            valueColor: AlwaysStoppedAnimation<Color>(black),
            strokeWidth: 2,
          ),
        ),
      ],
    ),
  );
}

pushAndResult(context, item, {result}) {
  Navigator.push(
      context,
      PageRouteBuilder(
          opaque: false,
          pageBuilder: (context, _, __) {
            return item;
          })).then((_) {
    if (_ != null) {
      if (result != null) result(_);
    }
  });
}

SizedBox addSpace(double size) {
  return SizedBox(
    height: size,
  );
}

int getSeconds(String time) {
  List parts = time.split(":");
  int mins = int.parse(parts[0]) * 60;
  int secs = int.parse(parts[1]);
  return mins + secs;
}

String getTimerText(int seconds, {bool three = false}) {
  int hour = seconds ~/ Duration.secondsPerHour;
  int min = (seconds ~/ 60) % 60;
  int sec = seconds % 60;

  String h = hour.toString();
  String m = min.toString();
  String s = sec.toString();

  String hs = h.length == 1 ? "0$h" : h;
  String ms = m.length == 1 ? "0$m" : m;
  String ss = s.length == 1 ? "0$s" : s;

  return three ? "$hs:$ms:$ss" : "$ms:$ss";
}
