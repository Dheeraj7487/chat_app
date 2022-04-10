import 'package:flutter/material.dart';

import '../../Themes/mythemes.dart';

// ignore: must_be_immutable
class CustomTextField extends StatefulWidget {
  String label;
  double width;
  final bool obscureText;
  final TextInputType textInputType;
  final bool isEnable;
  String initalValue;
  void Function(String value)? onChanged;
  CustomTextField(
      {required this.label,
        required this.width,
        required this.obscureText,
        required this.textInputType,
        required this.isEnable,
        this.initalValue = '',
        this.onChanged});

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    if (widget.initalValue.isNotEmpty) {
      controller.text = widget.initalValue;
    }
    return Column(
      children: [
        Container(
          width: widget.width,
          child: Text(
            widget.label,
            textAlign: TextAlign.start,
            style: const TextStyle(fontSize: 10),
          ),
        ),
        SizedBox(
          child: Padding(
            padding: const EdgeInsets.only(top: 3, bottom: 10),
            child: TextFormField(
              onChanged: widget.onChanged,
              enabled: widget.isEnable,
              // ignore: body_might_complete_normally_nullable
              validator: (value) {
                if (widget.textInputType == TextInputType.name) {
                  if (value!.isEmpty) {
                    return 'Please enter full name';
                  }
                }
                if (widget.textInputType == TextInputType.phone) {
                  if (value!.isEmpty || value.length < 10) {
                    return 'Please Enter Correct Number';
                  }
                }
                if (widget.textInputType == TextInputType.emailAddress) {
                  if (value!.isEmpty) {
                    return ' Please enter email!';
                  }
                  if (!value.contains('@')) {
                    return ' Invalid email!';
                  }
                }
                if (widget.textInputType == TextInputType.visiblePassword) {
                  if (value!.isEmpty || value.length < 5) {
                    return 'Password is too short!';
                  }
                }

              },
              obscureText: widget.obscureText,
              controller: controller,
              keyboardType: widget.textInputType,
              style: const TextStyle(fontSize: 13, color: Colors.black),
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                contentPadding: const EdgeInsets.only(
                  left: 10.0,
                ),
                border: InputBorder.none,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: MyTheme.lightTheme.primaryColor, width: 2.0),
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
