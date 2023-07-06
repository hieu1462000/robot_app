import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robot_app/test.dart';
import 'package:robot_app/test2.dart';
import 'package:robot_app/test3.dart';

import 'provider/channel_notifier.dart';
import 'screen/welcome_screen.dart';

void main() {
  runApp( ChangeNotifierProvider(
      create: (context) => ChannelNotifier(),
      child: MyApp()
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:WelcomeScreen(),
    );
  }
}

