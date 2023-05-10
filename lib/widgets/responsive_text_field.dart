import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ResponsiveTextField extends StatelessWidget {

  final String label;
  final TextInputType? type;
  final TextInputAction? action;
  final FocusNode? focusNode;
  final double? width;
  final TextEditingController controller;
  final TextDirection? textDirection;
  final Function(String)? onChanged;
  final bool? isEnabled;
  final List<TextInputFormatter>? inputFormatters;
  final String? suffixText;
  final String? fontFamily;


  const ResponsiveTextField({
    Key? key,
    required this.label,
    required this.controller,
    this.type,
    this.action,
    this.focusNode,
    this.width,
    this.textDirection,
    this.onChanged,
    this.isEnabled,
    this.inputFormatters,
    this.suffixText,
    this.fontFamily,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        keyboardType: type,
        textInputAction: action,
        onChanged: onChanged,
        focusNode: focusNode,
        textDirection: textDirection ,
        enabled: isEnabled,
        inputFormatters: inputFormatters,
        style: TextStyle(
          fontFamily: fontFamily
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade400),
          suffixText: suffixText,
          floatingLabelStyle:
          const TextStyle(color: Colors.indigo),
          contentPadding: const EdgeInsets.symmetric(
              vertical: 10.0, horizontal: 20.0),
          border: const OutlineInputBorder(
            borderRadius:
            BorderRadius.all(Radius.circular(12.0)),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Colors.grey.shade700, width: 1.0),
            borderRadius:
            const BorderRadius.all(Radius.circular(12.0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Colors.grey.shade700, width: 1.0),
            borderRadius:
            const BorderRadius.all(Radius.circular(12.0)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
                color: Colors.indigo, width: 2.0),
            borderRadius:
            BorderRadius.all(Radius.circular(12.0)),
          ),
        ),
      ),
    );
  }
}
