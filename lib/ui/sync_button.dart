import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:syncus/definitions.dart';
import 'package:syncus/logger.dart';
import 'package:syncus/models/models.dart';
import 'package:syncus/ui/app.dart';
import 'package:syncus/ui/role.dart';
import 'package:syncus/ui/tag.dart';

final junctureProvider = StateProvider<Juncture?>((_) => null);

class SyncButton extends HookConsumerWidget {
  const SyncButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = Colors.green[400];
    final timerRef = useRef<Timer?>(null);

    return ElevatedButton(
        onPressed: () => _onPressed(ref, timerRef),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.connect_without_contact,
                size: Theme.of(context).textTheme.headlineLarge?.fontSize,
                color: color,
              ),
              const SizedBox(width: 10),
              Text(
                'Sync',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: color),
              )
            ],
          ),
        ));
  }

  void _onPressed(WidgetRef ref, ObjectRef<Timer?> timerRef) async {
    final timer = timerRef.value;
    if (timer?.isActive == true) return;
    timer?.cancel(); // make sure

    final apiClient = ref.read(apiClientProvider);
    final syncClient = ref.read(syncClientProvider);
    if (!syncClient.isSynchronized) await syncClient.synchronize();

    final role = ref.read(roleProvider);
    final tag = ref.read(tagProvider);
    Juncture juncture;
    if (role == Role.lead) {
      final trackURI = ''; // get from provider

      final syncTimestamp = DateTime.now().microsecondsSinceEpoch +
          syncWindowDuration * 1e6.toInt();
      juncture = Juncture(
        id: tag,
        trackURI: trackURI,
        microsecondTimestamp: syncClient.toServerTime(syncTimestamp),
      );
      juncture = await apiClient.createJuncture(juncture);
    } else {
      juncture = await apiClient.getJuncture(tag);
    }
    final us = syncClient.toLocalTime(juncture.microsecondTimestamp) -
        DateTime.now().microsecondsSinceEpoch;
    timerRef.value = Timer(Duration(microseconds: us), () {
      logger.i('TRIGGER!');
      _playSyncSong(juncture.trackURI);
    });
    ref.read(junctureProvider.notifier).state = juncture;
  }

  static void _playSyncSong(String trackURI) {
    // SpotifySdk.play(spotifyUri: trackURI);
    SpotifySdk.resume();
  }
}
