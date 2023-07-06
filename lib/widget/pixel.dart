import 'package:flutter/material.dart';

class MyPixel extends StatefulWidget {
  final borderColor;
  final leftBorderColor;
  final bottomBorderColor;
  final child;
  final function;
  final backgroundColor;
  final ontapFunction;
  final borderSize;
  final leftBorderSize;
  final bottomBorderSize;
  final index;
  final numberOfColumn;

  MyPixel(
      {this.borderColor,
      this.child,
      this.function,
      this.backgroundColor,
      this.ontapFunction,
      this.borderSize,
      this.index,
      this.numberOfColumn,
      this.leftBorderColor,
      this.bottomBorderColor,
      this.leftBorderSize,
      this.bottomBorderSize});

  @override
  State<MyPixel> createState() => _MyPixelState();
}

class _MyPixelState extends State<MyPixel> {
  Color? pixelBorderColor = Colors.indigo[300];
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: InkWell(
        onDoubleTap: widget.function,
        onTap: widget.ontapFunction,
        // onTap:  () {
        //   setState(() {
        //     pixelBorderColor = pixelBorderColor == Colors.red ?
        //     Colors.indigo[300] :
        //     Colors.red;
        //   });
        // },
        // child: myWidget(),
        child: Container(
          decoration: BoxDecoration(
              color: widget.backgroundColor,
              // border: Border.all(
              //   color: widget.borderColor,
              //   width: widget.borderSize,
              // )
            border: Border(
              top: BorderSide(
                color: widget.borderColor,
                width: widget.borderSize
              ),
              right: BorderSide(
                  color: widget.borderColor,
                  width: widget.borderSize
              ),
              left: BorderSide(
                color: widget.leftBorderColor,
                width: widget.leftBorderSize
              ),
              bottom: BorderSide(
                  color: widget.bottomBorderColor,
                  width: widget.bottomBorderSize
              )
            )
          ),
          child: Center(
            child: widget.child,
          ),
        ),
      ),
    );
  }

  // Widget myWidget() {
  //   if ((widget.index ~/ widget.numberOfColumn) % 2 == 0) {
  //     if (widget.index % 2 == 0) {
  //       return Container(
  //         decoration: BoxDecoration(
  //             color: widget.backgroundColor,
  //             border: Border(
  //               top: BorderSide(
  //                 color: widget.borderColor,
  //                 width: widget.borderSize,
  //               ),
  //               left: BorderSide(
  //                 color: widget.borderColor,
  //                 width: widget.borderSize,
  //               ),
  //             )),
  //         child: Center(
  //           child: widget.child,
  //         ),
  //       );
  //     } else {
  //       return Container(
  //         decoration: BoxDecoration(
  //             color: widget.backgroundColor,
  //             border:  Border(
  //               top: BorderSide(
  //                 color: widget.borderColor,
  //                 width: widget.borderSize,
  //               ),
  //               right: BorderSide(
  //                 color: widget.borderColor,
  //                 width: widget.borderSize,
  //               ),
  //             )),
  //         child: Center(
  //           child: widget.child,
  //         ),
  //       );
  //     }
  //   } else {
  //     if (widget.index % 2 == 0) {
  //       return Container(
  //         decoration: BoxDecoration(
  //             color: widget.backgroundColor,
  //             border:  Border(
  //               bottom: BorderSide(
  //                 color: widget.borderColor,
  //                 width: widget.borderSize,
  //               ),
  //               left: BorderSide(
  //                 color: widget.borderColor,
  //                 width: widget.borderSize,
  //               ),
  //             )),
  //         child: Center(
  //           child: widget.child,
  //         ),
  //       );
  //     } else {
  //       return Container(
  //         decoration: BoxDecoration(
  //             color: widget.backgroundColor,
  //             border:  Border(
  //               bottom: BorderSide(
  //                 color: widget.borderColor,
  //                 width: widget.borderSize,
  //               ),
  //               right: BorderSide(
  //                 color: widget.borderColor,
  //                 width: widget.borderSize,
  //               ),
  //             )),
  //         child: Center(
  //           child: widget.child,
  //         ),
  //       );
  //     }
  //   }
  // }
}
