import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:incite/utils/color_util.dart';
import 'package:incite/widgets/anim_util.dart';

import '../utils/theme_util.dart';

class TextFieldWidget extends StatefulWidget {
  const TextFieldWidget({super.key,
  this.radius,
  this.suffix,
  this.focusNode,
  this.contentPad,
  this.align,
  this.suffixWidth,
  this.onChanged,
  this.length,
  this.lengthFormatter,
  this.onFieldSubmitted,
  this.onValidate,
  this.isRead=false,
  this.height,
  this.keyboard, 
  this.textAction,
  this.pos=1,
  this.controller,
  this.hint,
  this.isObscure=false,
  this.errorText,
  this.prefix,
  this.onSaved,
  });

  final Widget? prefix,suffix;
  final int? length;
  final double? suffixWidth;
  final FocusNode? focusNode;
  final TextInputAction? textAction;
  final List<TextInputFormatter>? lengthFormatter;
  final TextAlign? align;
  final String? hint,errorText;
  final EdgeInsetsGeometry? contentPad;
  final ValueChanged? onChanged;
  final String? Function(String?)? onValidate;
  final void Function(String?)? onSaved;
  final int pos;
  final void Function(String)? onFieldSubmitted;
  final bool isRead;
  final bool isObscure;
  final double? radius,height;
  final TextInputType? keyboard;
  final TextEditingController? controller;

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return AnimationFadeSlide(
      dx: 0,
      dy: 0.75,
      duration: 200*widget.pos,
      child: SizedBox(
        height: widget.height,
        child: TextFormField(
          obscureText: widget.isObscure,
          obscuringCharacter: '*',
          validator: widget.onValidate,
          onSaved: widget.onSaved,
          controller: widget.controller,
          maxLength: widget.length,
          focusNode:widget.focusNode,
          onChanged: widget.onChanged,
       
          keyboardType: widget.keyboard,
          readOnly: widget.isRead,
          textInputAction: widget.textAction,
          textAlign: widget.align ?? TextAlign.start,
          style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              letterSpacing: 0.25,
              fontWeight: FontWeight.w500,
              color:dark(context) ? ColorUtil.white : ColorUtil.textblack
            ),
            onFieldSubmitted: widget.onFieldSubmitted,
            inputFormatters: widget.lengthFormatter,
            decoration: InputDecoration(
             errorText:  widget.errorText,
             counterText: '',
             errorStyle: TextStyle(
              fontFamily: 'Roboto',
              color: Colors.red.shade400,
              letterSpacing: 0.5
             ),
            prefixIcon: widget.prefix,
            suffixIcon: widget.suffix,
            filled: true,
            hintText: widget.hint,
            hintStyle: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              color: ColorUtil.textgrey
            ),
            fillColor: dark(context) ? Theme.of(context).cardColor :ColorUtil.whiteGrey,
            contentPadding:widget.contentPad ?? const EdgeInsets.symmetric(horizontal: 12,vertical: 15),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular( widget.radius ?? 40),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular( widget.radius ?? 40),
            ),
          ),
        ),
      ),
    );
  }
}