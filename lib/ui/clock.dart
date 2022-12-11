import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncus/ui/synchronize.dart';

class ServerClock extends StatefulWidget {
  final ServerClockSynchronization sync;
  const ServerClock(this.sync, {super.key});

  @override
  State<StatefulWidget> createState() => _ServerClockState();
}

class _ServerClockState extends State<ServerClock> {
  late String _timeString;
  late Timer _timer;

  @override
  void initState() {
    _updateTimeString();
    _timer = Timer.periodic(
        const Duration(milliseconds: 25), (t) => _updateTimeString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Server clock'),
        Text(
          _timeString,
          style: Theme.of(context).textTheme.headline1,
        )
      ],
    );
  }

  void _updateTimeString() {
    // final localTimeString = DateFormat('kk:mm:ss').format(DateTime.now());
    final String serverTimeString;
    if (widget.sync.isSynchronized) {
      serverTimeString = DateFormat('kk:mm:ss').format(
          DateTime.fromMicrosecondsSinceEpoch(widget.sync.serverTimestamp));
    } else {
      serverTimeString = '--:--:--';
    }
    setState(() {
      // _localTimeString = localTimeString;
      _timeString = serverTimeString;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
