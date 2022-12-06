import 'package:flutter/material.dart';

class RoleButton extends StatelessWidget {
  final Role role;
  final Function(Role) onPressed;
  const RoleButton({Key? key, required this.role, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return ToggleButtons(
      renderBorder: true,
      borderColor: Colors.grey,
      color: theme.primaryColor,
      selectedColor: theme.colorScheme.onPrimary,
      fillColor: theme.backgroundColor,
      splashColor: theme.splashColor,
      borderRadius: BorderRadius.circular(15),
      children: const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('LEAD'),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('FOLLOW'),
        ),
      ],
      isSelected: role == Role.lead ? [true, false] : [false, true],
      onPressed: _onPressed,
    );
  }

  void _onPressed(int index) {
    onPressed(index == 0 ? Role.lead : Role.follow);
  }
}

enum Role { lead, follow }
