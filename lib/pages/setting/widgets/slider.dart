import 'package:flutter/material.dart';

import '../../../utils/color_util.dart';
import '../../../utils/theme_util.dart';

class SliderWidget extends StatefulWidget {
  const SliderWidget({super.key,
  this.max=100.0,
  this.value,
  this.divison,
  required this.onChanged});

  final ValueChanged<double> onChanged;
  final double? value,max;
  final int? divison;

  @override
  State<SliderWidget> createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  @override
  Widget build(BuildContext context) {
    return Slider(
          min: 0,
          max: widget.max ?? 100.0,
          inactiveColor:Theme.of(context).cardColor,
          thumbColor: Theme.of(context).primaryColor,
          overlayColor:const MaterialStatePropertyAll( Colors.white),
          activeColor: Theme.of(context).primaryColor,
          secondaryActiveColor: dark(context) ? Colors.grey.shade700 : Colors.white,
          onChanged:widget.onChanged,
          value: widget.value??0.0,
        );
  }
}