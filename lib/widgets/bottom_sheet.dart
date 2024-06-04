import 'package:flutter/material.dart';
import 'package:incite/api_controller/user_controller.dart';
import 'package:incite/model/home.dart';
import 'package:incite/pages/setting/widgets/slider.dart';
import 'package:incite/widgets/text_field.dart';

class BottomSheetWidget {
  static Widget makeDismissible(
      {required Widget child, required BuildContext context}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.pop(context),
      child: GestureDetector(
        onTap: () {},
        child: child,
      ),
    );
  }

  static void bottom(BuildContext context, Widget child,
      {double maxChild = 1,
      double initialSize = 0.75,
      isFooter = false,
      isTextField = false,
      required title,
       VoidCallback? onSelect ,
       ValueChanged? onChanged,
      isScrollable = false}) async {
  List<ScrollModel> scrollList = [
  ScrollModel(title: 'Max Fling Velocity',value: scrollConfig.value.maxFlingVelocity,
  max: 20000.0,
  description: 'Scroll fling velocity magnitudes will be clamped to this value.'
  ),
  ScrollModel(title: 'Min Fling Velocity',
  max: 15000.0,
  value: scrollConfig.value.minFlingVelocity,
  description: ' The minimum distance an input pointer drag must have moved to be considered a scroll fling gesture.'
    'This value is typically compared with the distance traveled along the scrolling axis.'),
  ScrollModel(title: 'Min Fling Distance',
  value: scrollConfig.value.minFlingDistance,
  max: 50.0,
  description: 'The minimum velocity for an input pointer drag to be considered a scroll fling.' 
   'This value is typically compared with the magnitude of fling gesture\'s velocity along the scrolling axis.'),
  ScrollModel(title: 'Drag Start Distance\nMotion Threshold',
  value: scrollConfig.value.dragStartDistanceMotionThreshold,
  max: 100.0,
  description: 'The minimum amount of pixel distance drags must move by to start' 
   'motion the first time or after each time the drag motion stopped.'),
  ScrollModel(title: 'Mass',value: scrollConfig.value.mass,
  max: 1.0,
  description: 'The mass of the spring (m). The units are arbitrary, but all springs within a system should use the same mass units.'),
  ScrollModel(title: 'Stiffness',
  value: scrollConfig.value.stiffness,
  max: 400.0,
  description: 'The spring constant (k). The units of stiffness are M/T², where M is the mass unit used for the value of the [mass] property, and T is the time unit used for driving the [SpringSimulation].'),
  ScrollModel(title: 'Ratio',
  value: scrollConfig.value.ratio,
  max: 1.0,
  description: 'Creates a spring given the mass (m), stiffness (k), and damping ratio (ζ).'
  'The damping ratio is especially useful trying to determining the type of spring to create.'
  ' A ratio of 1.0 creates a critically damped spring, > 1.0 creates an overdamped spring'
  ' and < 1.0 an underdamped one.''See [mass] and [stiffness] for the units for'
  ' those arguments. The damping ratio is unitless.'),
];

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12), topRight: Radius.circular(12))),
        builder: (_) {
          // outFocus(context);
          return makeDismissible(
              child: DraggableScrollableSheet(
                  initialChildSize: initialSize,
                  maxChildSize: maxChild,
                  minChildSize: 0.3,
                  builder: (context, controller) {
                    return ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16)),
                      child: isScrollable
                          ? Container(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 24),
                              child: SingleChildScrollView(
                                controller: controller,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                     ...scrollList.map((e) => SlideWrap(
                                      key:ValueKey(e.hashCode), 
                                      scroll: e))
                                  ],
                                ),
                              ),
                            )
                          : child,
                    );
                  }),
              context: context);
        });
  }
}

class SlideWrap extends StatefulWidget {
  const SlideWrap({
    super.key,
    required this.scroll,
  });

  final ScrollModel scroll;

  @override
  State<SlideWrap> createState() => _SlideWrapState();
}

class _SlideWrapState extends State<SlideWrap> {
 late double val;
 
  var controller =TextEditingController();

  @override
  void initState() {
    val = widget.scroll.value as double;
    controller.text = widget.scroll.value!.toStringAsFixed(2);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.scroll.title ?? 'Max Fling Velocity',
            style: Theme.of(context).textTheme.bodyLarge
            ),
            SizedBox(
              width: 100,
              child: TextFieldWidget(
              height: 30,
              radius: 6,
                controller: controller,
                onChanged: (value) {
                  val = double.parse(value);
                  setState(() {  });
                },
                align: TextAlign.end,
                contentPad: const EdgeInsets.symmetric(vertical: 6,horizontal: 8),
              ),
            )
          ],
        ),
        const SizedBox(height: 12),
        Text(widget.scroll.description ?? 'data',style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 12),
        SliderWidget(
          max: widget.scroll.max,
          value: val,
          onChanged: (double value) {
           switch (widget.scroll.title) {
             case 'Max Fling Velocity':
              scrollConfig.value.maxFlingVelocity = value;
              val = value;
                controller.text = value.toStringAsFixed(2);
              setState(() {  });
               break;
             case 'Min Fling Velocity':
              scrollConfig.value.minFlingVelocity = value;
              val = value;
                controller.text = value.toStringAsFixed(2);
              setState(() {  });
               break;
              case 'Min Fling Distance':
              scrollConfig.value.minFlingDistance = value;
              val = value;
                controller.text = value.toStringAsFixed(2);
              setState(() {  });
               break;
              case 'Mass':
              scrollConfig.value.mass = value;
              val = value;
                controller.text = value.toStringAsFixed(2);
              setState(() {  });
               break;
              case 'Stiffness':
              scrollConfig.value.stiffness = value;
              val = value;
                controller.text = value.toStringAsFixed(2);
              setState(() {  });
               break;
              case 'Ratio':
              scrollConfig.value.ratio = value;
               val = value;
                controller.text = value.toStringAsFixed(2);
              setState(() {  });
               break;
                case 'Drag Start Distance\nMotion Threshold':
                scrollConfig.value.dragStartDistanceMotionThreshold = value;         
                val = value;
                controller.text = value.toStringAsFixed(2);
                setState(() {  });
               break;
             default:
                 value;
           }
        }),
        const Divider(height: 12,thickness: 1),
        const SizedBox(height: 12)
      ],
    );
  }
}