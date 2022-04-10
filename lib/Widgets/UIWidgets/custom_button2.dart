import 'package:flutter/material.dart';

import '../../Themes/mythemes.dart';

class CustomButton2 extends StatelessWidget {
  final VoidCallback onTap;
  final String text;

  CustomButton2({required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: MyTheme.lightTheme.primaryColor,
            width: 1,
          ),
        ),
        child: Center(
            child: Text(
              text,
              style: const TextStyle(color: Colors.black),
            )),
      ),
    );
  }
}
