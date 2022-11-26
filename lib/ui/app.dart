import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
// import 'widgets/sized_icon_button.dart';

import 'package:logger/logger.dart';
import 'package:spotify_sdk/models/connection_status.dart';
import 'package:spotify_sdk/models/crossfade_state.dart';
import 'package:spotify_sdk/models/image_uri.dart';
import 'package:spotify_sdk/models/player_context.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class Syncus extends StatefulWidget {
  const Syncus({Key? key}) : super(key: key);

  @override
  State<Syncus> createState() => _SyncusState();
}

class _SyncusState extends State<Syncus> {
  late String _timeString;
  bool _connected = false;
  bool _loading = false;
  String _authenticationToken = '';

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
    _getTimeString();
    Timer.periodic(const Duration(milliseconds: 101), (t) => _getTimeString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.green),
      home: StreamBuilder<ConnectionStatus>(
        stream: SpotifySdk.subscribeConnectionStatus(),
        builder: (context, snapshot) {
          _connected = false;
          var data = snapshot.data;
          if (data != null) {
            _connected = data.connected;
          }
          return Scaffold(
            appBar: AppBar(title: const Text('Syncus')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Current time',
                  ),
                  Text(
                    _timeString,
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ],
              ),
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
    try {
      await SpotifySdk.disconnect();
    } catch (e) {}

    try {
      setState(() {
        _loading = true;
      });
      var result = await SpotifySdk.connectToSpotifyRemote(
          clientId: dotenv.env['CLIENT_ID'].toString(),
          redirectUrl: dotenv.env['REDIRECT_URI'].toString());
      setStatus(result
          ? 'connect to spotify successful'
          : 'connect to spotify failed');
      setState(() {
        _loading = false;
      });
    } on PlatformException catch (e) {
      setState(() {
        _loading = false;
      });
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setState(() {
        _loading = false;
      });
      setStatus('not implemented');
    }
  }

  Future<void> play() async {
    await SpotifySdk.play(spotifyUri: 'spotify:track:1e0OVY3IiMNyeGGQv3aerm');
  }

  Future<void> resume() async {
    await SpotifySdk.resume();
  }

  Future<void> pause() async {
    await SpotifySdk.pause();
  }

  Future<void> stop() async {
    await SpotifySdk.seekTo(positionedMilliseconds: 0);
  }

  _getTimeString() {
    final timeString = DateFormat('kk:mm:ss.SSS').format(DateTime.now());
    // final timeString = DateTime.now().toIso8601String();
    setState(() {
      _timeString = timeString;
    });
  }

  void setStatus(String code, {String? message}) {
    var text = message ?? '';
    _logger.i('$code$text');
  }
}
