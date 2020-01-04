import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'engine.dart';

class listDialog extends StatelessWidget {
  String title;
  var items;
  List images;
  bool useTint;
  BuildContext context;
  String allText;
  var allAction;

  listDialog(items,
      {title, images, bool useTint = true, String allText, allAction}) {
    this.title = title;
    this.items = items;
    this.images = images == null ? List() : images;
    this.useTint = useTint;
    this.allText = allText;
    this.allAction = allAction;
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return Stack(fit: StackFit.expand, children: <Widget>[
      GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
            child: Container(
              color: black.withOpacity(.7),
            )),
      ),
      page()
    ]);
  }

  page() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(25, 45, 25, 25),
        child: new Container(
          decoration: BoxDecoration(
              color: white, borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  color: white,
                  child: new ConstrainedBox(
                    constraints: BoxConstraints(
                        maxHeight: (MediaQuery.of(context).size.height / 2) +
                            (MediaQuery.of(context).orientation ==
                                    Orientation.landscape
                                ? 0
                                : (MediaQuery.of(context).size.height / 5))),
                    child: Scrollbar(
                      child: new ListView.builder(
                        padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                        itemBuilder: (context, position) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              position == 0
                                  ? Container()
                                  : addLine(
                                      .5, black.withOpacity(.1), 0, 0, 0, 0),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop(items[position]);
                                },
                                child: new Container(
                                  color: white,
                                  width: double.infinity,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 15, 0, 15),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        images.isEmpty
                                            ? Container()
                                            : !(images[position] is String)
                                                ? Icon(
                                                    images[position],
                                                    size: 17,
                                                    color: !useTint
                                                        ? null
                                                        : black.withOpacity(.3),
                                                  )
                                                : Image.asset(
                                                    images[position],
                                                    width: 17,
                                                    height: 17,
                                                    color: !useTint
                                                        ? null
                                                        : black.withOpacity(.3),
                                                  ),
                                        images.isNotEmpty
                                            ? addSpaceWidth(10)
                                            : Container(),
                                        Text(
                                          items[position],
                                          style: textStyle(
                                              false, 15, black.withOpacity(.8)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                        itemCount: items.length,
                        shrinkWrap: true,
                      ),
                    ),
                  ),
                ),

                //gradientLine(alpha: .1)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
