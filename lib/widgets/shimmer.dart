import 'dart:async';

import 'package:flutter/material.dart';
import 'package:incite/utils/theme_util.dart';

class ShimmerLoader extends StatefulWidget {
  final double? width, height;

  const ShimmerLoader({super.key, this.width, this.height, this.margin, this.borderRadius, this.updateIt});
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final Future Function()? updateIt;

  @override
  State<ShimmerLoader> createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<ShimmerLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int initialCountDown = 1;

  Timer? timer;

  manageReloads() {
    if (widget.updateIt != null) {
      Future.delayed(const Duration(milliseconds: 100)).then((v){
        updateData();
      });
    }
  }

  updateData() async {
    timer?.cancel();
    if(mounted == false){
      timer?.cancel();
      return;
    }
    await widget.updateIt!();
    initialCountDown++;
    if(mounted){
    timer = Timer(Duration(seconds: initialCountDown), () {
      updateData();
    });
    } else {

      timer?.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
    manageReloads();
  }

  @override
  void dispose() {
    timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("appProvider.featureBlogs");
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        const beginAlignment = Alignment.topRight;
        const endAlignment = Alignment.bottomLeft;
        final gradient = LinearGradient(
          begin: Alignment.lerp(beginAlignment, endAlignment, _animation.value)!,
          end: Alignment.lerp(beginAlignment, endAlignment, _animation.value - 0.5)!,
          colors: dark(context)
              ? [
                  Colors.grey[700]!,
                  Colors.grey[500]!,
                  Colors.grey[700]!,
                ]
              : [
                  Colors.grey[300]!,
                  Colors.grey[100]!,
                  Colors.grey[300]!,
                ],
          stops: const [0.0, 0.5, 1.0],
        );
        return Container(
          // duration: Duration(milliseconds: 100),
          // curve: Curves.linear,
          width: widget.width,
          height: widget.height,
          margin: widget.margin ?? const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 20),
            gradient: gradient,
          ),
        );
      },
    );
  }
}
