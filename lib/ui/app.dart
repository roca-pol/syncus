import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:syncus/logger.dart';
import 'package:syncus/ui/clock.dart';
import 'package:syncus/ui/role.dart';
import 'package:syncus/ui/overlay.dart';
import 'package:syncus/ui/synchronize.dart';
import 'package:syncus/ui/tag.dart';

const nPings = 5;

final connectionStatusProvider =
    StreamProvider((_) => SpotifySdk.subscribeConnectionStatus());

final connectionProvider = Provider((ref) {
  return ref.watch(connectionStatusProvider).when<bool>(
        data: (snapshot) => snapshot.connected,
        error: (error, stackTrace) => false,
        loading: () => false,
      );
});

class Syncus extends HookConsumerWidget {
  Syncus({super.key});

  bool _connected = false;
  bool _loading = false;
  String _authenticationToken = '';
  final _sync = ServerClockSynchronization('https://9c60-83-41-95-71.ngrok.io',
      nPings: nPings);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var isConnected = ref.watch(connectionProvider);
    if (!isConnected) connectToSpotifyRemote();

    // double screenWidth = MediaQuery.of(context).size.width;
    var animationCtrl = useAnimationController(
        duration: Duration(seconds: 2),
        initialValue: 0.0,
        lowerBound: 0.0,
        upperBound: 1.0);
    final hasRun = useState(false);
    if (!hasRun.value) {
      animationCtrl.forward();
      hasRun.value = true;
    }
    useAnimation(animationCtrl);
    // if (animationCtrl.status == AnimationStatus.completed) {
    //   animationCtrl.stop();
    // } else {
    //   var ticker = animationCtrl.repeat(reverse: true);
    // }

    logger.i('BUILD Main ' +
        animationCtrl.value.toString() +
        ' ' +
        animationCtrl.status.toString());

    return MaterialApp(
        theme: ThemeData.dark(useMaterial3: true),
        home: Scaffold(
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
                                color: const Color.fromARGB(255, 252, 255, 217),
                                child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Center(
                                      child: IntrinsicWidth(
                                          child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          const RoleButton(),
                                          const SizedBox(height: 10.0),
                                          const TagTextField(),
                                          const SizedBox(height: 10.0),
                                          LinearProgressIndicator(
                                            value: animationCtrl.value,
                                          )
                                        ],
                                      )),
                                    ))),
                          )
                        ],
                      ),
                    ),
                    const Spacer(),
                    ServerClock(_sync)
                  ],
                ),
              ),
              isConnected ? Container() : const LoadingOverlay()
            ],
          ),
          persistentFooterButtons: <Widget>[
            isConnected
                ? Row(
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
                : Container()
          ],
        ));
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
    logger.i('$code$text');
  }

  Future<void> stop() async {
    await SpotifySdk.seekTo(positionedMilliseconds: 0);
  }
}
