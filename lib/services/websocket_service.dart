import 'dart:convert';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketService {
  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _eventController = StreamController.broadcast();
  Stream<Map<String, dynamic>> get events => _eventController.stream;

  Future<void> connect(String token, String deviceId) async {
    disconnect(); // Close existing if any
    
    // Determine host based on platform
    String host = '192.168.100.19';
   

    final uri = Uri.parse('ws://$host:8000/v1/ws/$deviceId?token=$token');
    developer.log('Connecting to WebSocket: $uri', name: 'WebSocketService');
    
    try {
      _channel = WebSocketChannel.connect(uri);
      
      _channel!.stream.listen(
        (message) {
          developer.log('WebSocket message received: $message', name: 'WebSocketService');
          try {
            if (message is String) {
               final event = jsonDecode(message);
               _eventController.add(event);
            }
          } catch (e) {
            developer.log('Error parsing WebSocket message', name: 'WebSocketService', error: e);
          }
        },
        onError: (error) {
          developer.log('WebSocket error', name: 'WebSocketService', error: error);
        },
        onDone: () {
          developer.log('WebSocket closed', name: 'WebSocketService');
        },
      );
    } catch (e) {
       developer.log('WebSocket connection failed', name: 'WebSocketService', error: e);
    }
  }

  void disconnect() {
    if (_channel != null) {
      _channel!.sink.close(status.goingAway);
      _channel = null;
    }
  }
}



