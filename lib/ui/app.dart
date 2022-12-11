import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:syncus/logger.dart';
import 'package:syncus/ui/client.dart';
import 'package:syncus/ui/clock.dart';
import 'package:syncus/ui/pbar.dart';
import 'package:syncus/ui/role.dart';
import 'package:syncus/ui/overlay.dart';
import 'package:syncus/ui/sync_button.dart';
import 'package:syncus/ui/synchronize.dart';
import 'package:syncus/ui/tag.dart';
import 'package:syncus/definitions.dart';

final connectionStreamProvider =
    StreamProvider((_) => SpotifySdk.subscribeConnectionStatus());

final connectionStatusProvider = Provider((ref) {
  return ref.watch(connectionStreamProvider).when<bool>(
        data: (snapshot) => snapshot.connected,
        error: (error, stackTrace) => false,
        loading: () => false,
      );
});

final syncClientProvider =
    Provider((_) => ServerClockSynchronization(serverUrl, nPings: nSyncPings));

final apiClientProvider = Provider((_) => APIClient(serverUrl));

class Syncus extends HookConsumerWidget {
  const Syncus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var isConnected = ref.watch(connectionStatusProvider);
    final isConnecting = useRef(false);
    if (!isConnected && !isConnecting.value) {
      connectToSpotifyRemote();
      isConnecting.value = true;
    }

    logger.i('BUILD Main');

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
                                color: Color.fromARGB(255, 209, 248, 223),
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
                                          ProgressBar(),
                                          const SizedBox(height: 10.0),
                                          SyncButton()
                                        ],
                                      )),
                                    ))),
                          )
                        ],
                      ),
                    ),
                    const Spacer(),
                    ServerClock(ref.watch(syncClientProvider))
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
                        // IconButton(
                        //   onPressed: connectToSpotifyRemote,
                        //   tooltip: 'Refresh Spotify connection',
                        //   icon: const Icon(Icons.connect_without_contact),
                        // )
                      ])
                : Container()
          ],
        ));
  }

  Future<void> connectToSpotifyRemote() async {
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
