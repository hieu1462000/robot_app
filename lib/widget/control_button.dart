import 'package:flutter/material.dart';

class ControlButton extends StatelessWidget {
  final color;
  final child;
  final function;

  ControlButton({this.color, this.child, this.function});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: GestureDetector(
        onTap: function,
        child: Container(
          height: 60,
          width: 60,
          child: Center(
            child:child
          ),
          decoration: BoxDecoration(
            borderRadius:BorderRadius.circular(45) ,
            color: color,
              border: Border.all(
                color: Colors.indigo,
                width: 2,
              ),
        ),
        ),
      ),
    );
  }
}
