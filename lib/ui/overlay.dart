import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class OverlayView extends StatelessWidget {
  const OverlayView({Key? key}) : super(key: key);

  // @override
  // Widget build(BuildContext context) {
  //   return ValueListenableBuilder<bool>(
  //     valueListenable: toggle,
  //     builder: (context, value, child) {
  //       if (value) {
  //         return yourOverLayWidget();
  //       } else {
  //         return Container();
  //       }
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Center(
          child: Row(
            children: [
              Expanded(
                child: Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Row(
                      //   children: [
                      //     Spacer(),
                      //     const Padding(
                      //       padding: EdgeInsets.all(10.0),
                      //       child: Icon(Icons.close_outlined),
                      //     ),
                      //   ],
                      // ),
                      const SizedBox(
                        height: 16,
                      ),
                      // Icon(
                      //   Icons.login,
                      //   color: Colors.greenAccent[400],
                      //   size: 50,
                      // ),
                      LoadingAnimationWidget.staggeredDotsWave(
                          color: Colors.lightGreen, size: 50),
                      const SizedBox(
                        height: 16,
                      ),
                      Column(
                        children: const [
                          Text('Connecting to Spotify...'),
                          SizedBox(
                            height: 12,
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
