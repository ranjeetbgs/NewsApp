import 'package:flutter/material.dart';

class DismissWidget extends StatefulWidget {
  const DismissWidget({super.key,required this.child});
  final Widget child;


  @override
  State<DismissWidget> createState() => _DismissWidgetState();
}

class _DismissWidgetState extends State<DismissWidget> {
  @override
  Widget build(BuildContext context) {
    return  Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          Navigator.pop(context);
        }
      },
      child: widget.child
    );
  }
}