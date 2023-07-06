class Node {
  Node? b; //back pointer
  String t = "NEW"; //tag
  double h = 0; //distance to goal
  double k = 0; //priority
  int index;

  Node(this.index);

  List<Node> getNeighbors(List<Node> listNode, int numberOfColumn) {
    List<Node> listNeighbor = [];
    if (index%numberOfColumn==0) {
      for (int i = 0; i < listNode.length; i++) {
        if (listNode[i].index == index + 1 ||
            listNode[i].index == index + numberOfColumn ||
            listNode[i].index == index - numberOfColumn ||
            listNode[i].index == index + numberOfColumn + 1 ||
            listNode[i].index == index - numberOfColumn + 1) {
          listNeighbor.add(listNode[i]);
        }
      }
    } else if ((index+1)%numberOfColumn==0) {
      for (int i = 0; i < listNode.length; i++) {
        if (listNode[i].index == index - 1 ||
            listNode[i].index == index + numberOfColumn ||
            listNode[i].index == index - numberOfColumn ||
            listNode[i].index == index + numberOfColumn - 1 ||
            listNode[i].index == index - numberOfColumn - 1) {
          listNeighbor.add(listNode[i]);
        }
      }
    } else{
      for (int i = 0; i < listNode.length; i++) {
        if (listNode[i].index == index + 1 ||
            listNode[i].index == index - 1 ||
            listNode[i].index == index + numberOfColumn ||
            listNode[i].index == index - numberOfColumn ||
            listNode[i].index == index + numberOfColumn + 1 ||
            listNode[i].index == index + numberOfColumn - 1 ||
            listNode[i].index == index - numberOfColumn + 1 ||
            listNode[i].index == index - numberOfColumn - 1) {
          listNeighbor.add(listNode[i]);
        }
      }
    }
    return listNeighbor;
  }
}
