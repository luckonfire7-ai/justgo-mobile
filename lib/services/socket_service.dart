import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  IO.Socket? _socket;

  void connect(String baseUrl) {
    _socket = IO.io(
      baseUrl,
      IO.OptionBuilder().setTransports(['websocket']).build(),
    );
  }

  void joinGroup({
    required String groupId,
    required String userId,
    required String name,
    required String motorLabel,
  }) {
    _socket?.emit('group:join', {
      'groupId': groupId,
      'userId': userId,
      'name': name,
      'motorLabel': motorLabel,
    });
  }

  void sendLocation({
    required String groupId,
    required String userId,
    required String name,
    required String motorLabel,
    required double lat,
    required double lng,
    double? heading,
  }) {
    _socket?.emit('location:update', {
      'groupId': groupId,
      'userId': userId,
      'name': name,
      'motorLabel': motorLabel,
      'lat': lat,
      'lng': lng,
      'heading': heading,
    });
  }

  void onLocationUpdated(void Function(Map<String, dynamic>) callback) {
    _socket?.on('location:updated', (data) => callback(data));
  }

  // mode: 'ptt' (tahan-bicara) atau 'open' (mic terus-menerus)
  void pttStart({
    required String groupId,
    required String userId,
    required String name,
    required String mode,
  }) {
    _socket?.emit('ptt:start', {
      'groupId': groupId,
      'userId': userId,
      'name': name,
      'mode': mode,
    });
  }

  void pttStop({required String groupId, required String userId}) {
    _socket?.emit('ptt:stop', {'groupId': groupId, 'userId': userId});
  }

  void onSpeakingChanged(void Function(Map<String, dynamic>) callback) {
    _socket?.on('ptt:speaking', (data) => callback(data));
  }

  void dispose() => _socket?.dispose();
}
