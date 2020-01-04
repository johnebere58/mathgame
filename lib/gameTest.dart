import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:screen/screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vibration/vibration.dart';

import 'listDialog.dart';
import 'gameSettings.dart';
import 'scoreBoard.dart';
import 'engine.dart';

class gameTest extends StatefulWidget {
  @override
  _gameTestState createState() => _gameTestState();
}

class _gameTestState extends State<gameTest> with WidgetsBindingObserver {
  String result = "";
  List numbersList = [];
  List signsList = [];
  List totalsList = [];

  static const ADD = "+";
  static const SUB = "-";
  static const DIV = "/";
  static const MUL = "x";
  List symbols1 = [ADD, SUB, DIV, MUL];
  List symbols2 = [ADD, SUB, MUL];
  bool setup = false;
  int currentQuestion = 0;

  String scaleText = "";
  bool paused = false;
  bool timeup = false;
  int gameTime;
  int score;
  int scoreWrong;
  String flashText = "";
  int gameMode;
  bool timedGame;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    restartGame();
    Screen.keepOn(true);
    WidgetsBinding.instance.addObserver(this);

  }

  @override
  void dispose() {
    // TODO: implement dispose
    Screen.keepOn(false);
    //interstitialAd.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    if (state == AppLifecycleState.paused) {
      paused = true;
      setState(() {});
    }

    super.didChangeAppLifecycleState(state);
  }

  restartGame() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    timedGame = prefs.getBool(TIMED_GAME) ?? true;
    gameMode = prefs.getInt(GAME_MODE) ?? MODE_MEDIUM;
    timeup = false;
    paused = false;
    currentSigns.clear();
    numbersList.clear();
    signsList.clear();
    totalsList.clear();
    currentQuestion = 0;
    int timePer =
        gameMode == 2 ? 3 : gameMode == 3 ? 8 : gameMode == 4 ? 13 : 20;
    gameTime = (10 * (timePer)) + 1;
    score = 0;
    scoreWrong = 0;
    load();
    setState(() {});
  }

  load() async {
    StringBuffer sb = StringBuffer();
    for (int i = 0; i < 10; i++) {
      String text = createGame();
      sb.write(text);
      sb.write("\n");
    }
    result = sb.toString();
    setup = true;
    if (timedGame) startTimer();
    setState(() {});
  }

  startTimer() {
    Future.delayed(Duration(seconds: 1), () {
      if (paused) return;
      if (timeup) return;
      if (!timedGame) return;
      gameTime--;
      gameTime = gameTime < 0 ? 0 : gameTime;
      if (gameTime == 0) timeup = true;
      setState(() {});
      startTimer();

      if (timeup) {
        /* showMessage(context, Icons.timer, red0, "Time up!",
            "Your score: $score/${totalsList.length}", cancellable: false,
            onClicked: (_) {
          if (_ == true) {
            restartGame();
          } else {
            exit(0
;          }
        }, clickYesText: "Retry", clickNoText: "Exit");*/
        flashText = "Time up!";
        Vibration.vibrate(duration: 200);
        //if (canSound) audioPlayer.play(soundError, isLocal: true);
        setState(() {});
        Future.delayed(Duration(seconds: 1), () {
          flashText = "";
          showResult();
          setState(() {});
        });
      }
    });
  }

  String createGame() {
    StringBuffer sb = StringBuffer();
    List numbers = [];
    List signs = [];
    for (int i = 0; i < gameMode; i++) {
      int theNum = Random().nextInt(10) + 1;
      if (i == 0) {
        numbers.add(theNum);
        sb.write(" $theNum");
        continue;
      }
      String theSign = symbols1[Random().nextInt(symbols2.length)];
      if (theSign == DIV) {
        int sum = getSumTotal(numbers, signs);
        if (sum != null && (sum % theNum) != 0) {
          theSign = symbols2[Random().nextInt(symbols2.length)];
        }
      }
      signs.add(theSign);
      numbers.add(theNum);

      sb.write(" $theSign");
      sb.write(" $theNum");
    }

    int total = getSumTotal(numbers, signs);
    numbersList.add(numbers);
    signsList.add(signs);
    totalsList.add(total);

    String res = "${sb.toString().trim()} = ${total}";
    return res;
  }

  int getSumTotal(List numbers, List signs) {
    if (numbers.isEmpty) return null;
    double total;
    for (int i = 0; i < numbers.length; i++) {
      int num = numbers[i];
      if (i == 0) {
        total = double.parse(num.toString());
        continue;
      }
      String sign = signs[i - 1];
      if (sign == ADD) {
        total = total + num;
      }
      if (sign == SUB) {
        total = total - num;
      }
      if (sign == MUL) {
        total = total * num;
      }
      if (sign == DIV) {
        total = total / num;
      }
    }

    return total.toInt();
  }

  showResult() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    double rank = (score) * gameMode / 1;
    rank = !timedGame ? (rank / 3) : rank;
    int myRank = prefs.getInt(RANKING) ?? 0;
    int ranking = rank.toInt() + myRank;
    prefs.setInt(RANKING, ranking);
    pushAndResult(
        context,
        scoreBoard(
            "Your Score: ${score}/10",
            "Your Rank ${ranking} (+${rank.toInt()})",
            score,
            scoreWrong), result: (_) {
      //interstitialAd.show();
      restartGame();
    });
  }

  int clickBack = 0;
  BuildContext con;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (paused) {
          paused = false;
          setState(() {});
          startTimer();
          return;
        }

        exit(0);

      },
      child: Scaffold(
        body: Builder(builder: (c) {
          con = c;
          return Container(
              color: white,
              child: SafeArea(
                  child: !setup
                      ? loadingLayout()
                      : Column(children: [
                          Expanded(
                              flex: 1,
                              child: Stack(children: [
                                page(),
                                IgnorePointer(
                                  ignoring: true,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Expanded(
                                          flex: 1,
                                          child: Container(
                                              child: Center(
                                            child: scaleText.isEmpty
                                                ? Container()
                                                : ScaleAnimatedTextKit(
                                                    text: [scaleText],
                                                    textStyle: textStyle(
                                                        true,
                                                        35,
                                                        scaleText == "Wrong"
                                                            ? red0
                                                            : blue0),
                                                  ),
                                          ))),
                                      Expanded(flex: 1, child: Container()),
                                    ],
                                  ),
                                )
                              ])),

                        ])));
        }),
      ),
    );
  }

  List currentSigns = List();
  page() {
    currentQuestion = currentQuestion > numbersList.length - 1
        ? (numbersList.length - 1)
        : currentQuestion;
    List numbers = numbersList[currentQuestion];
    List signs = signsList[currentQuestion];
    int total = totalsList[currentQuestion];
    int defLength = numbers.length + signs.length;
    List merged = [];
    for (int i = 0; i < numbers.length; i++) {
      int num = numbers[i];
      if (i == 0) {
        merged.add(num);
        continue;
      }
      String sign = signs[i - 1];
      merged.add(sign);
      merged.add(num);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
            height: 60,
            child: Stack(children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  addSpaceWidth(20),
                  if (timedGame)
                    Container(
                      decoration: BoxDecoration(
                          color: blue09,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                              color: black.withOpacity(.1), width: 1)),
                      child: Text(
                        getTimerText(gameTime),
                        style: textStyle(true, 18, black),
                      ),
                      padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                      //margin: EdgeInsets.all(20),
                    ),
                  if (timedGame) addSpaceWidth(20),
                  Text(
                    "(Q${currentQuestion + 1}) Score: $score/${totalsList.length} ",
                    style: textStyle(true, 14,
                        score >= (totalsList.length / 2) ? blue0 : red0),
                  ),
                  Flexible(flex: 1, fit: FlexFit.tight, child: Container()),
                  addSpaceWidth(10),
                  new Container(
                    height: 30,
                    width: 30,
                    child: new FlatButton(
                        padding: EdgeInsets.all(0),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: CircleBorder(
                            side: BorderSide(
                                color: black.withOpacity(.1), width: 1)),
                        color: blue3,
                        onPressed: () {
                          paused = true;
                          setState(() {});
                        },
                        child: Center(
                            child: Icon(
                          Icons.pause,
                          size: 13,
                          color: white,
                        ))),
                  ),
                  addSpaceWidth(15),
                ],
              ),
              if (paused) Container(color: white.withOpacity(.8)),
            ])),
        Expanded(
            flex: 1,
            child: Stack(
              children: <Widget>[
                Container(
                    child: Center(
                  child: paused
                      ? (Column(mainAxisSize: MainAxisSize.min, children: [
                          Container(
                            margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
                            child: FlatButton(
                              onPressed: () {
                                paused = false;
                                setState(() {});
                                startTimer();
                              },
                              child: Text("Resume",
                                  style: textStyle(true, 18, blue0)),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              color: blue09,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  side: BorderSide(
                                      color: black.withOpacity(.1), width: .5)),
                            ),
                            height: 50,
                            width: double.infinity,
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
                            child: FlatButton(
                              onPressed: () {
                                pushAndResult(context, gameSettings(),
                                    result: (_) {
                                  if (_ == true) restartGame();
                                  setState(() {});
                                });
                              },
                              child: Text("Game Settings",
                                  style: textStyle(true, 18, black)),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              color: blue09,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  side: BorderSide(
                                      color: black.withOpacity(.1), width: .5)),
                            ),
                            height: 50,
                            width: double.infinity,
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
                            child: FlatButton(
                              onPressed: () {
                                restartGame();
                              },
                              child: Text("Restart",
                                  style: textStyle(true, 18, red0)),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              color: blue09,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  side: BorderSide(
                                      color: black.withOpacity(.1), width: .5)),
                            ),
                            height: 50,
                            width: double.infinity,
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
                            child: FlatButton(
                              onPressed: () {
                                  exit(0);
                              },
                              child: Text("Exit",
                                  style: textStyle(true, 18, red0)),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              color: blue09,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  side: BorderSide(
                                      color: black.withOpacity(.1), width: .5)),
                            ),
                            height: 50,
                            width: double.infinity,
                          ),
                        ]))
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(defLength, (p) {
                                double ind = (p + 1) / 2;
                                int index = (ind.toInt() - 1);
                                var item = merged[p];
                                var text = "";
                                try {
                                  text = currentSigns[index];
                                } catch (e) {}
                                bool hide = (item is String);

                                return Container(
                                  child: hide
                                      ? (Container(
                                          width: 30,
                                          height: 30,
                                          child: Center(
                                              child: Text(
                                            "$text",
                                            style: textStyle(true, 18, black),
                                          )),
                                          decoration: BoxDecoration(
                                              color: blue09,
                                              border: Border.all(
                                                  color: black.withOpacity(.4),
                                                  width: 1)),
                                        ))
                                      : Text(
                                          "$item",
                                          style: textStyle(true, 18, black),
                                        ),
                                  margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                );
                              })
                                ..add(Text(
                                  "=",
                                  style: textStyle(true, 18, black),
                                ))
                                ..add(addSpaceWidth(5))
                                ..add(Text(
                                  "$total",
                                  style: textStyle(true, 18, black),
                                )),
                            ),
                            Container(
                              margin: EdgeInsets.all(20),
                              child: Row(
                                children: List.generate(4, (p) {
                                  List icons = [
                                    Icons.add,
                                    Icons.remove,
                                    Icons.close,
                                    ic_divide
                                  ];
                                  List colors = [blue0, red0, brown0, blue6];

                                  var icon = icons[p];
                                  var color = colors[p];
                                  return Flexible(
                                    flex: 1,
                                    fit: FlexFit.tight,
                                    child: Container(
                                      margin: EdgeInsets.all(5),
                                      child: RaisedButton(
                                        onPressed: () {
                                          if (paused) return;
                                          if (timeup) return;
                                          Vibration.vibrate(duration: 100);
                                          var sign = p == 0
                                              ? ADD
                                              : p == 1
                                                  ? SUB
                                                  : p == 2 ? MUL : DIV;
                                          currentSigns.add(sign);
                                          if (currentSigns.length >=
                                              gameMode - 1) {
                                            Future.delayed(
                                                Duration(milliseconds: 400),
                                                () {
                                              int theTotal = getSumTotal(
                                                  numbers, currentSigns);
                                              bool correct = theTotal == total;

                                              bool completed =
                                                  currentQuestion >=
                                                      totalsList.length - 1;
                                              currentSigns.clear();
                                              if (!completed) currentQuestion++;
                                              if (correct) score++;
                                              if (!correct) scoreWrong++;
                                              if (completed) {
                                                timeup = true;
                                                showResult();
                                              }
                                              scaleText =
                                                  correct ? "Correct" : "Wrong";
                                              setState(() {});

                                              Future.delayed(
                                                  Duration(milliseconds: 1000),
                                                  () {
                                                scaleText = "";
                                                setState(() {});
                                              });
                                            });
                                          }
                                          setState(() {});
                                        },
                                        child: icon is String
                                            ? (Image.asset(icon,
                                                width: 20,
                                                height: 20,
                                                color: white))
                                            : (Icon(icon,
                                                size: 30, color: white)),
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        elevation: .5,
                                        color: color,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                      ),
                                      height: 80,
                                    ),
                                  );
                                }),
                              ),
                            ),
                            if (gameMode != 2)
                              Container(
                                margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
                                child: FlatButton(
                                  onPressed: () {
                                    currentSigns.clear();
                                    setState(() {});
                                  },
                                  child: Text("Clear",
                                      style: textStyle(true, 16, red0)),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  color: blue09,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      side: BorderSide(
                                          color: black.withOpacity(.1),
                                          width: .5)),
                                ),
                                height: 40,
                                width: double.infinity,
                              ),
                          ],
                        ),
                )),
                flashText.isEmpty
                    ? Container()
                    : Container(
                        color: white.withOpacity(.9),
                        child: Center(
                          child: ScaleAnimatedTextKit(
                            text: [flashText],
                            textStyle: textStyle(true, 45, red0),
                          ),
                        ),
                      )
              ],
            ))
      ],
    );
  }
}
