import 'dart:math';

import 'package:syncus/ui/client.dart';

class ServerClockSynchronization {
  final APIClient _client;
  final int nPings;
  int _delta = 0;
  bool _isSynchronized = false;
  bool _isSynchronizing = false;

  ServerClockSynchronization(String host, {this.nPings = 5})
      : _client = APIClient(host);

  Future<int> _pingServer() async => (await _client.ping())['serverTimestamp'];

  Future<void> synchronize() async {
    if (_isSynchronizing) return;
    _isSynchronizing = true;
    final deltas = <int>[];

    final random = Random();
    for (int i = 0; i < nPings; i++) {
      int t0 = DateTime.now().microsecondsSinceEpoch;
      int serverTime = await _pingServer();
      int latency = (DateTime.now().microsecondsSinceEpoch - t0) ~/ 2;
      print(latency);
      deltas.add(serverTime - t0 - latency);
      await Future.delayed(Duration(milliseconds: 200 + random.nextInt(200)));
    }

    deltas.sort();
    print(deltas);
    _delta = deltas[nPings ~/ 2];
    _isSynchronized = true;
    _isSynchronizing = true;
  }

  int toServerTime(int timestamp) => timestamp + _delta;
  int toLocalTime(int timestamp) => timestamp - _delta;

  bool get isSynchronized => _isSynchronized;
  int get serverTimestamp =>
      toServerTime(DateTime.now().microsecondsSinceEpoch);
}
