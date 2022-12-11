import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syncus/logger.dart';
import 'package:syncus/models/models.dart';
import 'package:syncus/ui/app.dart';
import 'package:syncus/ui/sync_button.dart';

class ProgressBar extends HookConsumerWidget {
  const ProgressBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastJunctureRef = useRef<Juncture?>(null);
    final currJuncture = ref.watch(junctureProvider);
    final syncClient = ref.read(syncClientProvider);

    int us = 0;
    if (currJuncture != null) {
      us = syncClient.toLocalTime(currJuncture.microsecondTimestamp) -
          DateTime.now().microsecondsSinceEpoch;
    }
    final animationCtrl = useAnimationController(
      duration: Duration(microseconds: us),
      initialValue: 0.0,
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    final currAnimation = useRef<AnimationController?>(null);
    if (currJuncture != lastJunctureRef.value) {
      logger.i('Start: ' + us.toString());
      animationCtrl.reset();
      animationCtrl.forward();
      currAnimation.value = animationCtrl;
      lastJunctureRef.value = currJuncture;
    } else {
      currAnimation.value ??= animationCtrl;
    }
    useAnimation(currAnimation.value!);
    print(currAnimation.value!.value);

    return LinearProgressIndicator(
      value: currAnimation.value!.value,
      minHeight: 10,
      // color: Theme.of(context).backgroundColor,
    );
  }
}
