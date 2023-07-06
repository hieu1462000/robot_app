import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:robot_app/screen/map_screen.dart';
import '../provider/channel_notifier.dart';
import '../widget/control_button.dart';

class ControlScreen extends StatefulWidget {
  @override
  _ControlScreenState createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("Robot Application",style: TextStyle(color: Colors.black),),
      //   backgroundColor: Colors.indigo[800],
      //   centerTitle: true,
      // ),
      backgroundColor: Colors.black,
      body: body(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.indigo[800],
        type: BottomNavigationBarType.fixed,
        // showSelectedLabels: false,
        // showUnselectedLabels: false,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(
                Icons.control_camera_outlined,
              ),
              label: 'Controller'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.map_outlined,
              ),
              label: 'Mapping'),
        ],
        currentIndex: _currentIndex,
        selectedItemColor: Colors.black,
        onTap: onTapBottomBarHandler,
      ),
    );
  }

  void onTapBottomBarHandler(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget body() {
    if (_currentIndex == 0) {
      return ControlScreenBody();
    } else {
      return MapScreen();
    }
  }
}

class ControlScreenBody extends StatefulWidget {
  @override
  _ControlScreenBodyState createState() => _ControlScreenBodyState();
}

class _ControlScreenBodyState extends State<ControlScreenBody>
    with SingleTickerProviderStateMixin {
  List<bool> buttonState = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];
  late double _scale;
  late AnimationController _controller;

  void resetButtonState() {
    for (int i = 0; i < buttonState.length; i++) {
      buttonState[i] = false;
    }
  }

  Future<void> sendData(String event, double angular, double linear,
      ChannelNotifier channelNotifier) async {
    channelNotifier.channel.sink.add(
      jsonEncode(
        {"event": event, "angular": angular, "linear": linear},
      ),
    );
  }

  @override
  void initState() {
    ChannelNotifier channelNotifier =
        Provider.of<ChannelNotifier>(context, listen: false);
    channelNotifier.connect();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 250,
      ),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
        setState(() {});
      });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;
    ChannelNotifier channelNotifier =
        Provider.of<ChannelNotifier>(context, listen: false);
    return Center(
      child: Column(
        children: [
          const SizedBox(
            height: 150,
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ControlButton(
                  function: () {
                    sendData("Up left", 45, 1, channelNotifier);
                    setState(() {
                      resetButtonState();
                      buttonState[0] = true;
                    });
                  },
                  color: buttonState[0] ? Colors.indigo[400] : Colors.black,
                  child: SvgPicture.asset(
                    'assets/icons/up_left.svg',
                    width: 30,
                    height: 30,
                    fit: BoxFit.scaleDown,
                    color: Colors.indigo[800],
                  ),
                ),
                ControlButton(
                  function: () {
                    sendData("Forward", 0, 1, channelNotifier);
                    setState(() {
                      resetButtonState();
                      buttonState[1] = true;
                    });
                  },
                  color: buttonState[1] ? Colors.indigo[400] : Colors.black,
                  child: SvgPicture.asset(
                    'assets/icons/up.svg',
                    width: 40,
                    height: 40,
                    fit: BoxFit.scaleDown,
                    color: Colors.indigo[800],
                  ),
                ),
                ControlButton(
                  function: () {
                    sendData("Up right", -45, 1, channelNotifier);
                    setState(() {
                      resetButtonState();
                      buttonState[2] = true;
                    });
                  },
                  color: buttonState[2] ? Colors.indigo[400] : Colors.black,
                  child: SvgPicture.asset(
                    'assets/icons/up_right.svg',
                    width: 30,
                    height: 30,
                    fit: BoxFit.scaleDown,
                    color: Colors.indigo[800],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ControlButton(
                  function: () {
                    sendData("Left", 90, 1, channelNotifier);
                    setState(() {
                      resetButtonState();
                      buttonState[3] = true;
                    });
                  },
                  color: buttonState[3] ? Colors.indigo[400] : Colors.black,
                  child: SvgPicture.asset(
                    'assets/icons/left.svg',
                    width: 40,
                    height: 40,
                    fit: BoxFit.scaleDown,
                    color: Colors.indigo[800],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    sendData("Stop", 0, 0, channelNotifier);
                    setState(() {
                      resetButtonState();
                    });
                  },
                  onTapDown: _tapDown,
                  onTapUp: _tapUp,
                  child: Transform.scale(
                    scale: _scale,
                    child: SvgPicture.asset('assets/icons/turtlebot.svg',
                        width: 70, height: 70, fit: BoxFit.scaleDown),
                  ),
                ),
                ControlButton(
                  function: () {
                    sendData("Right", -90, 1, channelNotifier);
                    setState(() {
                      resetButtonState();
                      buttonState[4] = true;
                    });
                  },
                  color: buttonState[4] ? Colors.indigo[400] : Colors.black,
                  child: SvgPicture.asset(
                    'assets/icons/right.svg',
                    width: 40,
                    height: 40,
                    fit: BoxFit.scaleDown,
                    color: Colors.indigo[800],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ControlButton(
                  function: () {
                    sendData("Down Left", -15, -1, channelNotifier);
                    setState(() {
                      resetButtonState();
                      buttonState[5] = true;
                    });
                  },
                  color: buttonState[5] ? Colors.indigo[400] : Colors.black,
                  child: SvgPicture.asset(
                    'assets/icons/down_left.svg',
                    width: 30,
                    height: 30,
                    fit: BoxFit.scaleDown,
                    color: Colors.indigo[800],
                  ),
                ),
                ControlButton(
                  function: () {
                    sendData("Backward", 0, -1, channelNotifier);
                    setState(() {
                      resetButtonState();
                      buttonState[6] = true;
                    });
                  },
                  color: buttonState[6] ? Colors.indigo[400] : Colors.black,
                  child: SvgPicture.asset(
                    'assets/icons/down.svg',
                    width: 40,
                    height: 40,
                    fit: BoxFit.scaleDown,
                    color: Colors.indigo[800],
                  ),
                ),
                ControlButton(
                  function: () {
                    sendData("Down Right", 45, -1, channelNotifier);
                    setState(() {
                      resetButtonState();
                      buttonState[7] = true;
                    });
                  },
                  color: buttonState[7] ? Colors.indigo[400] : Colors.black,
                  child: SvgPicture.asset(
                    'assets/icons/down_right.svg',
                    width: 30,
                    height: 30,
                    fit: BoxFit.scaleDown,
                    color: Colors.indigo[800],
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ControlButton(
                function: () {
                  sendData("Rotate Left", 360, 0, channelNotifier);
                  setState(() {
                    resetButtonState();
                    buttonState[8] = true;
                  });
                },
                color: buttonState[8] ? Colors.indigo[400] : Colors.black,
                child: SvgPicture.asset(
                  'assets/icons/rotate_left.svg',
                  width: 40,
                  height: 40,
                  fit: BoxFit.scaleDown,
                  color: Colors.indigo[800],
                ),
              ),
              ControlButton(
                function: () {
                  sendData("Rotate Right", -360, 0, channelNotifier);
                  setState(() {
                    resetButtonState();
                    buttonState[9] = true;
                  });
                },
                color: buttonState[9] ? Colors.indigo[400] : Colors.black,
                child: SvgPicture.asset(
                  'assets/icons/rotate_right.svg',
                  width: 40,
                  height: 40,
                  fit: BoxFit.scaleDown,
                  color: Colors.indigo[800],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _tapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _tapUp(TapUpDetails details) {
    _controller.reverse();
  }
}
