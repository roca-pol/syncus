import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:spotify_sdk/models/connection_status.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:syncus/ui/buttons.dart';
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
  static const String tagAlphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  String _tag = '';
  late String _localTimeString;
  late String _serverTimeString;
  bool _connected = false;
  bool _loading = false;
  Role _role = Role.lead;
  bool _tagTextFrozen = true;
  final TextEditingController _tagTextController = TextEditingController();
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
    _updateTimeString();
    Timer.periodic(
        const Duration(milliseconds: 25), (t) => _updateTimeString());
    _tag = _generateTag();
    _tagTextController.text = _tag;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(useMaterial3: true),
      home: StreamBuilder<ConnectionStatus>(
        stream: SpotifySdk.subscribeConnectionStatus(),
        builder: (context, snapshot) {
          _connected = snapshot.data?.connected == true;
          if (!_connected) connectToSpotifyRemote();

          double screenWidth = MediaQuery.of(context).size.width;
          double? fontSize = Theme.of(context).textTheme.titleLarge!.fontSize;

          return Scaffold(
            appBar: AppBar(title: const Center(child: Text('Syncus'))),
            body: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Card(
                                  color:
                                      const Color.fromARGB(255, 252, 255, 217),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      children: [
                                        RoleButton(
                                          role: _role,
                                          onPressed: _changeRole,
                                        ),
                                        const SizedBox(height: 10.0),
                                        Container(
                                            width: fontSize != null
                                                ? fontSize * 6
                                                : null,
                                            child: TextField(
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .backgroundColor,
                                                  fontSize: fontSize),
                                              controller: _tagTextController,
                                              onChanged: _onTagTextChanged,
                                              readOnly: _tagTextFrozen,
                                              maxLength: 6,
                                              inputFormatters: [
                                                ToUpperCaseFormatter()
                                              ],
                                              decoration: InputDecoration(
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                          borderSide:
                                                              const BorderSide(
                                                                  color:
                                                                      Colors
                                                                          .black),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      15)),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                          borderSide:
                                                              const BorderSide(
                                                                  color: Colors
                                                                      .black),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      15)),
                                                  contentPadding:
                                                      const EdgeInsets.all(
                                                          10.0)),
                                            ))
                                      ],
                                    ),
                                  )),
                            )
                          ],
                        ),
                      ),
                      const Spacer(),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Server clock'),
                          Text(
                            _serverTimeString,
                            style: Theme.of(context).textTheme.headline1,
                          )
                        ],
                      )
                    ],
                  ),
                ),
                // const OverlayView()
                _connected ? Container() : const OverlayView()
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
    await SpotifySdk.pause();
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

  void _updateTimeString() {
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

  void _changeRole(Role role) {
    if ((_role != Role.lead) & (role == Role.lead))
      _tagTextController.text = _generateTag();

    setState(() {
      _role = role;
      _tagTextFrozen = role == Role.lead;
      _tag = _tagTextController.text;
    });
  }

  String _generateTag() {
    List<String> charList = tagAlphabet.split('')..shuffle();
    return charList.getRange(0, 6).join();
  }

  void _onTagTextChanged(String text) {
    setState(() {
      _tag = text;
    });
  }
}

class ToUpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
