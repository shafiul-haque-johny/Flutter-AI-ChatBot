import 'package:flutter/material.dart';

class ThreeDots extends StatefulWidget {
  const ThreeDots({Key? key}) : super(key: key);

  @override
  State<ThreeDots> createState() => _ThreeDotsState();
}

class _ThreeDotsState extends State<ThreeDots>
    with SingleTickerProviderStateMixin {
  AnimationController? animationController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          currentIndex++;
          if (currentIndex == 3) {
            currentIndex = 0;
          }
          animationController!.reset();
          animationController!.forward();
        }
      });
    animationController!.forward();
  }

  @override
  void dispose() {
    animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController!,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
            (index) {
              return Opacity(
                opacity: index == currentIndex ? 1.0 : 0.2,
                child: const Text(
                  '',
                  textScaleFactor: 5,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
