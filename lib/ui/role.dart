import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncus/logger.dart';

final roleProvider = StateProvider<Role>((_) => Role.lead);

class RoleButton extends ConsumerWidget {
  const RoleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const padding = EdgeInsets.symmetric(horizontal: 18);
    final theme = Theme.of(context);
    return ToggleButtons(
      renderBorder: true,
      borderColor: theme.backgroundColor,
      color: theme.backgroundColor,
      selectedColor: theme.colorScheme.onPrimary,
      fillColor: theme.backgroundColor,
      splashColor: theme.splashColor,
      borderRadius: BorderRadius.circular(15),
      children: const [
        Padding(
          padding: padding,
          child: Text('LEAD'),
        ),
        Padding(
          padding: padding,
          child: Text('FOLLOW'),
        ),
      ],
      isSelected: _role2selectionState(ref.watch(roleProvider)),
      onPressed: (i) => ref.read(roleProvider.notifier).state = _index2role(i),
    );
  }

  static Role _index2role(int index) => index == 0 ? Role.lead : Role.follow;
  static List<bool> _role2selectionState(Role role) =>
      role == Role.lead ? [true, false] : [false, true];
}

enum Role { lead, follow }
