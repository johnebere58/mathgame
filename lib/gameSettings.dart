import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

import 'package:screen/screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vibration/vibration.dart';

import 'engine.dart';
import 'listDialog.dart';

class gameSettings extends StatefulWidget {
  gameSettings();
  @override
  _gameSettingsState createState() => _gameSettingsState();
}

class _gameSettingsState extends State<gameSettings>
    with TickerProviderStateMixin {
  bool modified = false;
  bool setup = false;
  SharedPreferences prefs;
  int defMode;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadPrefs();
  }

  loadPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setup = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pop(modified);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: white,
        body: Container(
            color: white,
            child: SafeArea(child: !setup ? loadingLayout() : page())),
      ),
    );
  }

  BuildContext con;

  Builder page() {
    bool timedGame = prefs.getBool(TIMED_GAME) ?? true;
    bool canSound = prefs.getBool(GAME_SOUND) ?? true;
    int gameMode = prefs.getInt(GAME_MODE) ?? -1;
    return Builder(builder: (context) {
      this.con = context;
      return new Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(
            width: double.infinity,
            child: new Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                InkWell(
                    onTap: () {
                      Navigator.of(context).pop(modified);
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      child: Center(
                          child: Icon(
                        Icons.keyboard_backspace,
                        color: black,
                        size: 25,
                      )),
                    )),
                Flexible(
                  fit: FlexFit.tight,
                  flex: 1,
                  child: GestureDetector(
                    onDoubleTap: () {},
                    child: new Text(
                      "Game Settings",
                      style: textStyle(true, 17, black),
                    ),
                  ),
                ),
                addSpaceWidth(15),
              ],
            ),
          ),
          addLine(1, black.withOpacity(.1), 0, 0, 0, 0),
          new Expanded(
              flex: 1,
              child: Scrollbar(
                child: new ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(0),
                  children: <Widget>[
                    settingsItem("Game Sound",
                        canSound ? "Enabled" : "Disabled", canSound, () {
                      canSound = !canSound;
                      modified = true;
                      prefs.setBool(GAME_SOUND, canSound);
                      setState(() {});
                    }),
                    addLine(.5, black.withOpacity(.1), 15, 0, 15, 0),
                    settingsItem("Timed Game",
                        timedGame ? "Enabled" : "Disabled", timedGame, () {
                      timedGame = !timedGame;
                      modified = true;
                      prefs.setBool(TIMED_GAME, timedGame);
                      setState(() {});
                    }),
                    addLine(.5, black.withOpacity(.1), 15, 0, 15, 0),
                    settingsItem(
                        "Game Mode",
                        gameMode == -1
                            ? "Select Mode"
                            : gameMode == 2
                                ? "Easy"
                                : gameMode == 3
                                    ? "Medium"
                                    : gameMode == 4 ? "Hard" : "Difficult",
                        null, () {
                      pushAndResult(
                          context,
                          listDialog(
                            ["Easy", "Medium", "Hard", "Difficult"],
                            title: "Mode",
                          ), result: (_) {
                        if (_ == "Easy") gameMode = 2;
                        if (_ == "Medium") gameMode = 3;
                        if (_ == "Hard") gameMode = 4;
                        if (_ == "Difficult") gameMode = 5;
                        modified = true;
                        prefs.setInt(GAME_MODE, gameMode);
                        setState(() {});
                      });
                      setState(() {});
                    }),
                    addLine(.5, black.withOpacity(.1), 15, 0, 15, 0),
                    /*settingsItem(
                        "Questions Count", "$questionCount Questions", null,
                        () {
                      pushAndResult(
                          context,
                          listDialog(
                            ["5", "10", "15", "20", "30", "40", "50"],
                            title: "Questions Count",
                          ), result: (_) {
                        questionCount = int.parse(_);
                        modified = true;
                        prefs.setInt(QUESTION_COUNT, questionCount);
                        setState(() {});
                      });
                      setState(() {});
                    }),*/
                  ],
                ),
              )),
        ],
      );
    });
  }

  settingsItem(String title, String text, bool selected, onTapped) {
    return GestureDetector(
      onTap: onTapped,
      child: Container(
        height: 70,
        padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
        color: transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    title,
                    style: textStyle(false, 18, black),
                  ),
                  (text.isEmpty) ? Container() : addSpace(3),
                  (text.isEmpty)
                      ? Container()
                      : Text(
                          text,
                          style: textStyle(false, 12, black.withOpacity(.4)),
                        ),
                ],
              ),
            ),
            addSpace(10),
            if (selected != null)
              new Container(
                //padding: EdgeInsets.all(2),
                child: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: blue09,
                      border:
                          Border.all(color: black.withOpacity(.1), width: 1)),
                  child: Container(
                    width: 13,
                    height: 13,
                    margin: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? black : transparent,
                    ),
                    child: Icon(
                      Icons.check,
                      size: 8,
                      color: white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
