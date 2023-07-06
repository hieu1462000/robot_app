import 'dart:math';
import 'package:robot_app/model/node.dart';


class OptimizePath {
  void sortOpenList(List<Node> open) {
    for (int i = 0; i < open.length; i++) {
      for (int j = i + 1; j < open.length - 1; j++) {
        if (open[i].k > open[j].k) {
          Node tmp = open[i];
          open[i] = open[j];
          open[j] = tmp;
        }
      }
    }
  }

  Node? getMinNode(List<Node> open) {
    if (open.isEmpty) {
      return null;
    }
    sortOpenList(open);
    return open[0];
  }

  double getKMin(List<Node>? open) {
    if (open!.isEmpty) {
      return -1;
    }
    sortOpenList(open);
    return open[0].k;
  }

  void insertToOpenList(List<Node> open, Node x, double hNew) {
    if (hNew >= 10000) {
      hNew = 10000;
    }
    if (x.t == "NEW") {
      x.k = hNew;
    } else if (x.t == "OPEN") {
      x.k = min(x.k, hNew);
    } else if (x.t == "CLOSE") {
      x.k = min(x.h, hNew);
    }

    x.h = hNew;
    x.t = "OPEN";
    open.add(x);
    sortOpenList(open);
  }

  double processState(List<Node>? open,List<Node> listNode, int numberOfColumn) {
    Node? x = getMinNode(open!);

    if (x == null) {
      return -1;
    }

    double kMin = getKMin(open);
    open.remove(x);
    x.t = "CLOSED";

    if (kMin < x.h) {
      for (Node y in x.getNeighbors(listNode, numberOfColumn)) {
        if (y.h <= kMin && x.h > y.h + distance(x, y,  numberOfColumn)) {
          x.b = y;
          x.h = y.h + distance(x, y, numberOfColumn);
        }
      }
    }
    if (kMin == x.h) {
      for (Node y in x.getNeighbors(listNode, numberOfColumn)) {
        if (y.t == "NEW" ||
            (y.b == x && y.h != x.h + distance(x, y, numberOfColumn)) ||
            (y.b != x && y.h > x.h + distance(x, y, numberOfColumn))) {
          y.b = x;
          insertToOpenList(open, y, x.h + distance(x, y, numberOfColumn));
        }
      }
    } else { //kMin <x.h
      for (Node y in x.getNeighbors(listNode, numberOfColumn)) {
        if (y.t == "NEW" ||
            (y.b == x && y.h != x.h + distance(x, y,  numberOfColumn))) {
          y.b = x;
          insertToOpenList(open, y, x.h + distance(x, y,  numberOfColumn));
        } else {
          if (y.b != x && y.h > x.h + distance(x, y,  numberOfColumn)) {
            insertToOpenList(open, x, x.h);
          } else {
            if (y.b != x &&
                x.h > y.h + distance(x, y,  numberOfColumn) &&
                y.t == "CLOSED" &&
                y.h > kMin) {
              insertToOpenList(open, y, y.h);
            }
          }
        }
      }
    }

    return getKMin(open);
  }

  List<Node> firstPlanning(List<Node> open,List<Node> listNode, int numberOfColumn, Node xStart) {
    double kMin = processState(open,listNode, numberOfColumn);
    while (kMin != -1 && xStart.t != "CLOSED") {
      kMin = processState(open,listNode, numberOfColumn);
    }

    return getBackPointerList(xStart);
  }

  double distance(Node x, Node y, int numberOfColumn) {
    if (y.index == x.index + 1 ||
        y.index == x.index - 1 ||
        y.index == x.index + numberOfColumn ||
        y.index == x.index - numberOfColumn) {
      return 1;
    } else {
      return 1.4;
    }
  }

  List<Node> getBackPointerList(Node xStart) {
    List<Node> p = [];
    while (xStart.b != null) {
      p.add(xStart);
      xStart = xStart.b!;
    }
    return p;
  }
}
