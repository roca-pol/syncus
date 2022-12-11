import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncus/logger.dart';
import 'package:syncus/ui/role.dart';

final tagProvider = StateProvider<String>((ref) {
  var role = ref.watch(roleProvider);
  if (role == Role.lead) {
    return _generateTag();
  }
  return '';
});

final controllerProvider =
    Provider((ref) => TextEditingController(text: ref.watch(tagProvider)));

const String tagAlphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

class TagTextField extends ConsumerWidget {
  const TagTextField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double fontSize = Theme.of(context).textTheme.titleLarge!.fontSize!;
    var tag = ref.watch(tagProvider);
    var controller = TextEditingController.fromValue(TextEditingValue(
      text: tag,
      selection: TextSelection.collapsed(offset: tag.length),
    ));

    return TextField(
      textAlign: TextAlign.center,
      style: TextStyle(
          color: Theme.of(context).backgroundColor, fontSize: fontSize),
      controller: controller,
      onChanged: (value) {
        ref.read(tagProvider.notifier).state = value;
      },
      readOnly: ref.watch(roleProvider) == Role.lead,
      maxLength: 6,
      inputFormatters: [ToUpperCaseFormatter()],
      decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black),
              borderRadius: BorderRadius.circular(15)),
          enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black),
              borderRadius: BorderRadius.circular(15)),
          contentPadding: const EdgeInsets.all(10.0)),
    );
  }
}

String _generateTag() {
  List<String> charList = tagAlphabet.split('')..shuffle();
  return charList.getRange(0, 6).join();
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
