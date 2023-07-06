import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:provider/provider.dart';

import '../model/node.dart';
import '../optimize_path.dart';
import '../provider/channel_notifier.dart';
import '../widget/pixel.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  int numberOfSquares = 680;
  int numberOfColumn = 20;

  num realCoordinateX = 0;
  num realCoordinateY = 0;

  int coordinateX = 0;
  int coordinateY = 0;

  num roundX = 0;
  num roundY = 0;

  int robotPositionRounded = 333;
  num yaw = 0;

  List<int> obstacles = [];
  List<int> pathNodes = [];
  List<int> checkBox = [];

  final viewTransformationController = TransformationController();

  OptimizePath optimizePath = OptimizePath();

  @override
  void initState() {
    // TODO: implement initState
    final zoomFactor = 2.0;
    final xTranslate = 300.0;
    final yTranslate = 300.0;
    viewTransformationController.value.setEntry(0, 0, zoomFactor);
    viewTransformationController.value.setEntry(1, 1, zoomFactor);
    viewTransformationController.value.setEntry(2, 2, zoomFactor);
    viewTransformationController.value.setEntry(0, 3, -xTranslate);
    viewTransformationController.value.setEntry(1, 3, -yTranslate);
    super.initState();
  }

  int convertToCoordinateY(int index) {
    return ((index + 1) / numberOfColumn).ceil() - 1;
  }

  int convertToCoordinateX(int index) {
    return index - (convertToCoordinateY(index) * numberOfColumn) - 13;
  }

  int reverseConvertToCoordinateY(int index) {
    return -(((index + 1) / numberOfColumn).ceil()) +
        numberOfSquares ~/ numberOfColumn -
        17; // ceil[(position+1)/numberOfCol] + numberOfRow
  }

  int convertToIndex(int coordinateX, int coordinateY) {
    return (coordinateX + 13) +
        (numberOfSquares ~/ numberOfColumn - 1 - (coordinateY + 17)) *
            numberOfColumn;
  }

  Future<void> sendDataStop(String event, int targetX, int targetY, double data,
      ChannelNotifier channelNotifier) async {
    channelNotifier.channel.sink.add(
      jsonEncode(
        {
          "event": event,
          "targetX": targetX,
          "targetY": targetY,
          "linear": data
        },
      ),
    );
  }

  Future<void> sendDataMoving(
      String event,
      double currentX,
      double currentY,
      double targetX,
      double targetY,
      double currentYaw,
      ChannelNotifier channelNotifier) async {
    channelNotifier.channel.sink.add(
      jsonEncode(
        {
          "event": event,
          "currentX": currentX,
          "currentY": currentY,
          "targetX": targetX,
          "targetY": targetY,
          "currentYaw": currentYaw
        },
      ),
    );
  }

  List<int> listX = [];
  List<int> listY = [];

  bool containX(int index) {
    if (listX.contains(index)) {
      return true;
    }
    return false;
  }

  bool containY(int index) {
    if (listY.contains(index)) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    for (int i = 320; i < 340; i++) {
      listX.add(i);
    }
    int j = 13;
    while (j < 680) {
      listY.add(j);
      j = j + 20;
    }
    ChannelNotifier channelNotifier =
        Provider.of<ChannelNotifier>(context, listen: false);
    return StreamBuilder(
        stream: channelNotifier.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data =
                jsonDecode(snapshot.data as String) as Map<String, dynamic>;
            if (data['coordinateX'] != null) {
              realCoordinateX = data['realCoordinateX'];
              realCoordinateY = data['realCoordinateY'];
              coordinateX = data['coordinateX'];
              coordinateY = data['coordinateY'];
              // print("Real y: ${data['realCoordinateY']}");
              roundX = data['roundX'];
              roundY = data['roundY'];
              robotPositionRounded =
                  convertToIndex(data['coordinateX'], data['coordinateY']);
              yaw = data['yaw'];
              //print(robotPositionRounded);
              print("$roundX,$roundY");

              // print("Current x: ${data['coordinateX']}");
              // print("Current y: ${data['coordinateY']}");
              // print("Current angle: ${yaw*180/math.pi}");
              // print('///')
            } else {
              print(convertToIndex(0, 0));
            }
            return Column(
              children: [
                Expanded(
                    flex: 3,
                    child: InteractiveViewer(
                      transformationController: viewTransformationController,
                      minScale: 0.1,
                      maxScale: 6,
                      child: Container(
                        color: Colors.black,
                        child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: numberOfSquares,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: numberOfColumn),
                            itemBuilder: (BuildContext context, int index) {
                              if (robotPositionRounded == index) {
                                return MyPixel(
                                  index: index,
                                  numberOfColumn: numberOfColumn,
                                  borderColor: Colors.grey[500],
                                  borderSize: 0.1,
                                  leftBorderColor: containY(index)
                                      ? Colors.green
                                      : Colors.grey[500],
                                  bottomBorderColor: containX(index)
                                      ? Colors.red
                                      : Colors.grey[500],
                                  leftBorderSize: containY(index) ? 0.7 : 0.1,
                                  bottomBorderSize: containX(index) ? 0.7 : 0.1,
                                  child: Transform.rotate(
                                    angle: -(yaw.toDouble()),
                                    child: SvgPicture.asset(
                                      'assets/icons/turtle.svg',
                                    ),
                                  ),
                                );
                              } else if (obstacles.contains(index)) {
                                return MyPixel(
                                  borderColor: Colors.grey[500],
                                  borderSize: 0.1,
                                  child: SvgPicture.asset(
                                    'assets/icons/block.svg',
                                  ),
                                );
                              } else if (pathNodes.contains(index)) {
                                return MyPixel(
                                  index: index,
                                  numberOfColumn: numberOfColumn,
                                  borderColor: Colors.grey[500],
                                  borderSize: 0.1,
                                  backgroundColor: Colors.indigo[800],
                                  leftBorderColor: containY(index)
                                      ? Colors.green
                                      : Colors.grey[500],
                                  bottomBorderColor: containX(index)
                                      ? Colors.red
                                      : Colors.grey[500],
                                  leftBorderSize: containY(index) ? 0.7 : 0.1,
                                  bottomBorderSize: containX(index) ? 0.7 : 0.1,
                                  child: Text(
                                    '${convertToCoordinateX(index)},${reverseConvertToCoordinateY(index)}',
                                    style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 7,
                                        fontWeight: FontWeight.bold),
                                  ),
                                );
                              } else if (checkBox.contains(index)) {
                                return MyPixel(
                                  ontapFunction: () => showDialog<String>(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                      backgroundColor: Colors.indigo[800],
                                      title: const Text(
                                        'Confirm Destination',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      content: const Text(
                                          'Would you like to move your Robot to this point?',
                                          style:
                                              TextStyle(color: Colors.black)),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context, 'Cancel');
                                            setState(() {
                                              if (checkBox.isNotEmpty) {
                                                checkBox.removeAt(0);
                                              }
                                            });
                                          },
                                          child: Text(
                                            'Cancel',
                                            style: TextStyle(
                                                color: Colors.red[500]),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.pop(context, 'Yes');
                                            setState(() {
                                              if (checkBox.isNotEmpty) {
                                                checkBox.removeAt(0);
                                              }
                                              while (pathNodes.isNotEmpty) {
                                                pathNodes.removeAt(0);
                                              }
                                            });

                                            int xGoal =
                                                convertToCoordinateX(index);
                                            int yGoal =
                                                reverseConvertToCoordinateY(
                                                    index);

                                            List<Node> listNode = [];
                                            List<Node> openList = [];
                                            for (int i = 0;
                                                i < numberOfSquares;
                                                i++) {
                                              Node node = Node(i);
                                              listNode.add(node);
                                              listNode[i].t = "NEW";
                                            }

                                            print("Goal:$xGoal,$yGoal");

                                            Node goal = listNode[index];
                                            Node start =
                                                listNode[robotPositionRounded];
                                            goal.h = 0;
                                            optimizePath.insertToOpenList(
                                                openList, goal, goal.h);

                                            List<Node> p =
                                                optimizePath.firstPlanning(
                                                    openList,
                                                    listNode,
                                                    numberOfColumn,
                                                    start);
                                            p.add(goal);
                                            setState(() {
                                              for (int i = 1;
                                                  i < p.length;
                                                  i++) {
                                                pathNodes.add(p[i].index);
                                              }
                                            });

                                            int i = 0;
                                            while (
                                                robotPositionRounded != index) {
                                              //print("${convertToCoordinateX(robotPositionRounded)},${reverseConvertToCoordinateY(robotPositionRounded)}");
                                              if (robotPositionRounded ==
                                                  p[i].index) {
                                                setState(() {
                                                  pathNodes.remove(p[i].index);
                                                });
                                                int xRobot =
                                                    convertToCoordinateX(
                                                        p[i].index);
                                                int yRobot =
                                                    reverseConvertToCoordinateY(
                                                        p[i].index);
                                                int xNext =
                                                    convertToCoordinateX(
                                                        p[i + 1].index);
                                                int yNext =
                                                    reverseConvertToCoordinateY(
                                                        p[i + 1].index);
                                                if (xNext > xRobot &&
                                                    yNext > yRobot) {
                                                  while (roundX != xNext ||
                                                      roundY != yNext) {
                                                    sendDataMoving(
                                                        "Goal",
                                                        realCoordinateX
                                                            .toDouble(),
                                                        realCoordinateY
                                                            .toDouble(),
                                                        xNext.toDouble(),
                                                        yNext.toDouble(),
                                                        yaw.toDouble(),
                                                        channelNotifier);
                                                    await Future.delayed(
                                                        Duration(
                                                            milliseconds: 400));
                                                  }
                                                } else if (xNext < xRobot &&
                                                    yNext < yRobot) {
                                                  while (roundX != xRobot ||
                                                      roundY != yRobot) {
                                                    sendDataMoving(
                                                        "Goal",
                                                        realCoordinateX
                                                            .toDouble(),
                                                        realCoordinateY
                                                            .toDouble(),
                                                        xRobot.toDouble(),
                                                        yRobot.toDouble(),
                                                        yaw.toDouble(),
                                                        channelNotifier);
                                                    await Future.delayed(
                                                        Duration(
                                                            milliseconds: 400));
                                                  }
                                                }
                                                // } else if ((xNext < xRobot && yNext > yRobot) || (xNext > xRobot && yNext < yRobot)) {
                                                //   while(roundX != xRobot+0.5 || roundY != yRobot+0.5) {
                                                //     sendDataMoving("Goal", realCoordinateX.toDouble(), realCoordinateY.toDouble(), xRobot.toDouble()+0.5, yRobot.toDouble() +0.5, yaw.toDouble(), channelNotifier);
                                                //     await Future.delayed(Duration(milliseconds: 400));
                                                //   }
                                                // }
                                                while (roundX != xNext + 0.5 ||
                                                    roundY != yNext + 0.5) {
                                                  sendDataMoving(
                                                      "Goal",
                                                      realCoordinateX
                                                          .toDouble(),
                                                      realCoordinateY
                                                          .toDouble(),
                                                      xNext.toDouble() + 0.5,
                                                      yNext.toDouble() + 0.5,
                                                      yaw.toDouble(),
                                                      channelNotifier);
                                                  await Future.delayed(Duration(
                                                      milliseconds: 400));
                                                }
                                                // while(roundX != xNext || roundY != yNext) {
                                                //   sendDataMoving("Goal", realCoordinateX.toDouble(), realCoordinateY.toDouble(), xNext.toDouble(), yNext.toDouble(), yaw.toDouble(), channelNotifier);
                                                //   await Future.delayed(Duration(milliseconds: 400));
                                                // }
                                                i++;
                                              } else {
                                                break;
                                              }
                                            }
                                            sendDataStop("Stop", 0, 0, 0,
                                                channelNotifier);
                                            setState(() {
                                              for (int i = 0;
                                                  i < pathNodes.length;
                                                  i++) {
                                                pathNodes.removeAt(i);
                                              }
                                            });
                                          },
                                          child: Text(
                                            'Yes',
                                            style: TextStyle(
                                                color: Colors.indigo[300]),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  index: index,
                                  numberOfColumn: numberOfColumn,
                                  borderColor: Colors.indigo[800],
                                  leftBorderColor: Colors.indigo[800],
                                  bottomBorderColor: Colors.indigo[800],
                                  borderSize: 1.0,
                                  leftBorderSize: 1.0,
                                  bottomBorderSize: 1.0,
                                  child: Text(
                                    '${convertToCoordinateX(index)},${reverseConvertToCoordinateY(index)}',
                                    style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 7,
                                        fontWeight: FontWeight.bold),
                                  ),
                                );
                              } else {
                                return MyPixel(
                                  index: index,
                                  numberOfColumn: numberOfColumn,
                                  borderColor: Colors.grey[500],
                                  borderSize: 0.1,
                                  leftBorderColor: containY(index)
                                      ? Colors.green
                                      : Colors.grey[500],
                                  bottomBorderColor: containX(index)
                                      ? Colors.red
                                      : Colors.grey[500],
                                  leftBorderSize: containY(index) ? 0.7 : 0.1,
                                  bottomBorderSize: containX(index) ? 0.7 : 0.1,
                                  ontapFunction: () {
                                    setState(() {
                                      if (checkBox.isNotEmpty) {
                                        checkBox.removeAt(0);
                                      }
                                      checkBox.add(index);
                                    });
                                  },
                                  function: () => showDialog<String>(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                      backgroundColor: Colors.indigo[800],
                                      title: const Text(
                                        'Confirm Destination',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      content: const Text(
                                          'Would you like to move your Robot to this point?',
                                          style:
                                              TextStyle(color: Colors.black)),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context, 'Cancel');
                                            setState(() {
                                              if (checkBox.isNotEmpty) {
                                                checkBox.removeAt(0);
                                              }
                                            });
                                          },
                                          child: Text(
                                            'Cancel',
                                            style: TextStyle(
                                                color: Colors.red[500]),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.pop(context, 'Yes');
                                            setState(() {
                                              if (checkBox.isNotEmpty) {
                                                checkBox.removeAt(0);
                                              }
                                              while (pathNodes.isNotEmpty) {
                                                pathNodes.removeAt(0);
                                              }
                                            });

                                            int xGoal =
                                                convertToCoordinateX(index);
                                            int yGoal =
                                                reverseConvertToCoordinateY(
                                                    index);

                                            List<Node> listNode = [];
                                            List<Node> openList = [];
                                            for (int i = 0;
                                                i < numberOfSquares;
                                                i++) {
                                              Node node = Node(i);
                                              listNode.add(node);
                                              listNode[i].t = "NEW";
                                            }

                                            print("Goal:$xGoal,$yGoal");

                                            Node goal = listNode[index];
                                            Node start =
                                                listNode[robotPositionRounded];
                                            goal.h = 0;
                                            optimizePath.insertToOpenList(
                                                openList, goal, goal.h);

                                            List<Node> p =
                                                optimizePath.firstPlanning(
                                                    openList,
                                                    listNode,
                                                    numberOfColumn,
                                                    start);
                                            p.add(goal);
                                            setState(() {
                                              for (int i = 1;
                                                  i < p.length;
                                                  i++) {
                                                pathNodes.add(p[i].index);
                                              }
                                            });

                                            int i = 0;
                                            while (
                                                robotPositionRounded != index) {
                                              //print("${convertToCoordinateX(robotPositionRounded)},${reverseConvertToCoordinateY(robotPositionRounded)}");
                                              if (robotPositionRounded ==
                                                  p[i].index) {
                                                setState(() {
                                                  pathNodes.remove(p[i].index);
                                                });
                                                int xRobot =
                                                    convertToCoordinateX(
                                                        p[i].index);
                                                int yRobot =
                                                    reverseConvertToCoordinateY(
                                                        p[i].index);
                                                int xNext =
                                                    convertToCoordinateX(
                                                        p[i + 1].index);
                                                int yNext =
                                                    reverseConvertToCoordinateY(
                                                        p[i + 1].index);
                                                if ((xNext > xRobot &&
                                                        yNext > yRobot) ||
                                                    (xNext < xRobot &&
                                                        yNext < yRobot)) {
                                                  while (roundX != xNext ||
                                                      roundY != yNext) {
                                                    sendDataMoving(
                                                        "Goal",
                                                        realCoordinateX
                                                            .toDouble(),
                                                        realCoordinateY
                                                            .toDouble(),
                                                        xNext.toDouble(),
                                                        yNext.toDouble(),
                                                        yaw.toDouble(),
                                                        channelNotifier);
                                                    await Future.delayed(
                                                        Duration(
                                                            milliseconds: 400));
                                                  }
                                                }
                                                // } else if ((xNext < xRobot && yNext > yRobot) || (xNext > xRobot && yNext < yRobot)) {
                                                //   while(roundX != xRobot+0.5 || roundY != yRobot+0.5) {
                                                //     sendDataMoving("Goal", realCoordinateX.toDouble(), realCoordinateY.toDouble(), xRobot.toDouble()+0.5, yRobot.toDouble() +0.5, yaw.toDouble(), channelNotifier);
                                                //     await Future.delayed(Duration(milliseconds: 400));
                                                //   }
                                                // }
                                                while (roundX != xNext + 0.5 ||
                                                    roundY != yNext + 0.5) {
                                                  sendDataMoving(
                                                      "Goal",
                                                      realCoordinateX
                                                          .toDouble(),
                                                      realCoordinateY
                                                          .toDouble(),
                                                      xNext.toDouble() + 0.5,
                                                      yNext.toDouble() + 0.5,
                                                      yaw.toDouble(),
                                                      channelNotifier);
                                                  await Future.delayed(Duration(
                                                      milliseconds: 400));
                                                }
                                                // while(roundX != xNext || roundY != yNext) {
                                                //   sendDataMoving("Goal", realCoordinateX.toDouble(), realCoordinateY.toDouble(), xNext.toDouble(), yNext.toDouble(), yaw.toDouble(), channelNotifier);
                                                //   await Future.delayed(Duration(milliseconds: 400));
                                                // }
                                                i++;
                                              } else {
                                                break;
                                              }
                                            }
                                            sendDataStop("Stop", 0, 0, 0,
                                                channelNotifier);
                                            setState(() {
                                              for (int i = 0;
                                                  i < pathNodes.length;
                                                  i++) {
                                                pathNodes.removeAt(i);
                                              }
                                            });
                                          },
                                          child: Text(
                                            'Yes',
                                            style: TextStyle(
                                                color: Colors.indigo[300]),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            }),
                      ),
                    )),
              ],
            );
          } else {
            return Container(
                color: Colors.black,
                child: Center(
                    child: CircularProgressIndicator(
                  color: Colors.indigo[800],
                )));
          }
        });
  }
}
