import 'package:flutter/material.dart';

class OverlayView extends StatelessWidget {
  final ValueNotifier<bool> toggle;
  const OverlayView({Key? key, required this.toggle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: toggle,
      builder: (context, value, child) {
        if (value) {
          return yourOverLayWidget();
        } else {
          return Container();
        }
      },
    );
  }

  static Container yourOverLayWidget() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Row(
            children: [
              Expanded(
                child: Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Spacer(),
                          Icon(Icons.close_outlined),
                        ],
                      ),
                      Icon(
                        Icons.error_rounded,
                        color: Colors.red,
                        size: 50,
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Column(
                        children: [
                          Text('hola'),
                          SizedBox(
                            height: 8,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
