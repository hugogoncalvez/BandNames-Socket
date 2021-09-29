import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus { onLine, offLine, connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.connecting;
  late IO.Socket _socket;

  ServerStatus get serverStatus => _serverStatus;

  IO.Socket get socket => _socket;

  Function get emit => _socket.emit;

  SocketService() {
    _initConfig();
  }

  void _initConfig() {
// Dart client
    _socket = IO.io(
        'http://192.168.0.34:3000/',
        IO.OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .enableAutoConnect() // enable auto-connection
            .setExtraHeaders({'foo': 'bar'}) // optional
            .build());
    _socket.onConnect((data) {
      _serverStatus = ServerStatus.onLine;
      notifyListeners();
    });

    _socket.onDisconnect((data) {
      _serverStatus = ServerStatus.offLine;
      notifyListeners();
    });
  }
}
