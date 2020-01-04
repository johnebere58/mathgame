import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vibration/vibration.dart';


import 'engine.dart';
import 'gameSettings.dart';

class scoreBoard extends StatefulWidget {
  int totalCorrect;
  int totalWrong;
  String rankText;
  String scoreText;
  scoreBoard(
    this.scoreText,
    this.rankText,
    this.totalCorrect,
    this.totalWrong,
  );

  @override
  _scoreBoardState createState() => _scoreBoardState();
}

class _scoreBoardState extends State<scoreBoard> with TickerProviderStateMixin {
  bool ready = false;
  int totalCorrect;
  int totalWrong;
//  int totalQuestions;
  int ranking = 0;
  String rankText;
  String scoreText;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    totalCorrect = widget.totalCorrect;
    totalWrong = widget.totalWrong;
    scoreText = widget.scoreText;
    rankText = widget.rankText;
    load();

  }


  load() async {
    Future.delayed(Duration(milliseconds: 1000), () {
      ready = true;
      setState(() {});
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    ranking = prefs.getInt(RANKING) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, true);
      },
      child: Container(
          color: white,
          child: SafeArea(
              child: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: blue09,
                        borderRadius: BorderRadius.circular(5),
                        border:
                            Border.all(color: black.withOpacity(.1), width: 1)),
                    child: Text(
                      "$scoreText",
                      style: textStyle(true, 25, black),
                    ),
                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                    margin: EdgeInsets.all(20),
                  ),
                  if (rankText != null)
                    Text(
                      rankText,
                      style: textStyle(true, 16, black.withOpacity(.5)),
                    ),
                  if (rankText != null) addSpace(20),
                  Row(
                    children: <Widget>[
                      Flexible(
                        flex: 1,
                        fit: FlexFit.tight,
                        child: Container(
                          height: 40,
                          margin: EdgeInsets.fromLTRB(20, 0, 10, 0),
                          child: FlatButton(
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  side: BorderSide(color: blue0, width: 1)),
                              color: transparent,
                              onPressed: () {
                                //pushAndResult(context, gameLeadership());
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Flexible(
                                    child: Text("Leadership",
                                        style: textStyle(true, 13, blue0),
                                        maxLines: 1),
                                  ),
                                  addSpaceWidth(3),
                                  Icon(Icons.star, size: 13, color: blue0)
                                ],
                              )),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        fit: FlexFit.tight,
                        child: Container(
                          height: 40,
                          margin: EdgeInsets.fromLTRB(10, 0, 20, 0),
                          child: FlatButton(
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  side: BorderSide(color: blue0, width: 1)),
                              color: transparent,
                              onPressed: () {
                                pushAndResult(context, gameSettings());
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Flexible(
                                    child: Text("Game Settings",
                                        style: textStyle(true, 13, blue0),
                                        maxLines: 1),
                                  ),
                                  addSpaceWidth(3),
                                  Icon(Icons.settings, size: 13, color: blue0)
                                ],
                              )),
                        ),
                      ),
                    ],
                  ),
                  addSpace(20),
                ]
                  ..addAll(List.generate(2, (p) {
                    String title =
                        p == 0 ? "Incorrect" : p == 1 ? "Accuracy" : "Rating";
                    String text = "";
                    double percent = 0;
                    int totalAnswered = totalCorrect + totalWrong;
                    if (p == 0) {
                      text = "$totalWrong";
                      percent = totalAnswered == 0
                          ? 0
                          : ((totalWrong / totalAnswered) * 100);
                    }
                    if (p == 1) {
                      percent = totalAnswered == 0
                          ? 0
                          : ((totalCorrect / totalAnswered) * 100);
                      text = "${percent.toStringAsFixed(0)}%";
                    }
                    /*if (p == 2) {
                      percent = (totalCorrect / totalQuestions) * 100;
                      text = "${percent.toStringAsFixed(0)}%";
                    }*/

                    double width = MediaQuery.of(context).size.width - 40;
                    width = width * (percent / 100);
                    return Container(
                      margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Row(children: [
                            Flexible(
                                flex: 1,
                                fit: FlexFit.tight,
                                child: Text(title,
                                    style: textStyle(true, 14, black))),
                            Text(text, style: textStyle(true, 14, black))
                          ]),
                          addSpace(10),
                          Container(
                            width: double.infinity,
                            height: 20,
                            decoration: BoxDecoration(
                                color: blue09,
                                border: Border.all(
                                    color: black.withOpacity(.1), width: 1),
                                borderRadius: BorderRadius.circular(10)),
                            child: Stack(children: [
                              AnimatedContainer(
                                  duration: Duration(milliseconds: 1000),
                                  height: 20,
                                  width: !ready ? 0 : width,
                                  decoration: BoxDecoration(
                                      color: red0,
                                      borderRadius: BorderRadius.circular(10)))
                            ]),
                          ),
                          addSpace(10),
                        ],
                      ),
                    );
                  }))
                  ..add(Container(
                    width: 150,
                    height: 50,
                    margin: EdgeInsets.all(20),
                    child: RaisedButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      child:
                          Text("Play Again", style: textStyle(true, 18, white)),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      color: blue0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ))
                 ),
          ))),
    );
  }
}
