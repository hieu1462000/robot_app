import 'package:flutter/cupertino.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChannelNotifier extends ChangeNotifier {
  late WebSocketChannel channel;

  num yaw = 0;

  get stream => channel.stream;

  void connect() {
    channel = WebSocketChannel.connect(
        Uri.parse('ws://192.168.56.1:8082'));
  }

  void close() {
    channel.sink.close();
  }
}