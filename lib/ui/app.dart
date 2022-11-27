import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:spotify_sdk/models/connection_status.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:syncus/ui/client.dart';
import 'package:syncus/ui/overlay.dart';
import 'package:syncus/ui/synchronize.dart';

const nPings = 5;

class Syncus extends StatefulWidget {
  const Syncus({Key? key}) : super(key: key);

  @override
  State<Syncus> createState() => _SyncusState();
}

class _SyncusState extends State<Syncus> {
  late String _localTimeString;
  late String _serverTimeString;
  bool _connected = false;
  bool _loading = false;
  String _authenticationToken = '';
  final _clock = ServerClockSynchronization('https://9c60-83-41-95-71.ngrok.io',
      nPings: nPings);

  final Logger _logger = Logger(
    //filter: CustomLogFilter(), // custom logfilter can be used to have logs in release mode
    printer: PrettyPrinter(
      methodCount: 2, // number of method calls to be displayed
      errorMethodCount: 8, // number of method calls if stacktrace is provided
      lineLength: 120, // width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Print an emoji for each log message
      printTime: true,
    ),
  );

  @override
  void initState() {
    super.initState();
    _getTimeString();
    Timer.periodic(const Duration(milliseconds: 25), (t) => _getTimeString());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.green),
      home: StreamBuilder<ConnectionStatus>(
        stream: SpotifySdk.subscribeConnectionStatus(),
        builder: (context, snapshot) {
          _connected = snapshot.data?.connected == true;
          if (!_connected) connectToSpotifyRemote();

          return Scaffold(
            appBar: AppBar(title: const Text('Syncus')),
            body: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // const Text(
                      //   'Local time',
                      // ),
                      // Text(
                      //   _localTimeString,
                      //   style: Theme.of(context).textTheme.headline1,
                      // ),
                      const Text(
                        'Server time',
                      ),
                      Text(
                        _serverTimeString,
                        style: Theme.of(context).textTheme.headline1,
                      ),
                    ],
                  ),
                ),
                _connected ? Container() : OverlayView.yourOverLayWidget()
              ],
            ),
            persistentFooterButtons: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    IconButton(
                      onPressed: resume,
                      icon: const Icon(Icons.play_arrow),
                      alignment: Alignment.bottomLeft,
                    ),
                    IconButton(
                      onPressed: pause,
                      icon: const Icon(Icons.pause),
                      alignment: Alignment.bottomLeft,
                    ),
                    IconButton(
                      onPressed: stop,
                      icon: const Icon(Icons.stop),
                      alignment: Alignment.bottomLeft,
                    ),
                    IconButton(
                      onPressed: connectToSpotifyRemote,
                      tooltip: 'Refresh Spotify connection',
                      icon: const Icon(Icons.connect_without_contact),
                    )
                  ])
            ],
          );
        },
      ),
    );
  }

  Future<void> connectToSpotifyRemote() async {
    if (_loading) return;
    _loading = true;

    try {
      await SpotifySdk.disconnect();
    } catch (e) {}

    try {
      var result = await SpotifySdk.connectToSpotifyRemote(
          clientId: dotenv.env['CLIENT_ID'].toString(),
          redirectUrl: dotenv.env['REDIRECT_URI'].toString());
      setStatus(result
          ? 'connect to spotify successful'
          : 'connect to spotify failed');
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
    _loading = false;
  }

  Future<void> pause() async {
    await _clock.synchronize();
    print(_clock.serverTimestamp);
    // await SpotifySdk.pause();
  }

  Future<void> play() async {
    await SpotifySdk.play(spotifyUri: 'spotify:track:1e0OVY3IiMNyeGGQv3aerm');
  }

  Future<void> resume() async {
    await SpotifySdk.resume();
  }

  void setStatus(String code, {String? message}) {
    var text = message ?? '';
    _logger.i('$code$text');
  }

  Future<void> stop() async {
    await SpotifySdk.seekTo(positionedMilliseconds: 0);
  }

  _getTimeString() {
    final localTimeString = DateFormat('kk:mm:ss').format(DateTime.now());
    final String serverTimeString;
    if (_clock.isSynchronized) {
      serverTimeString = DateFormat('kk:mm:ss')
          .format(DateTime.fromMicrosecondsSinceEpoch(_clock.serverTimestamp));
    } else {
      serverTimeString = '--:--:--';
    }
    setState(() {
      _localTimeString = localTimeString;
      _serverTimeString = serverTimeString;
    });
  }
}
