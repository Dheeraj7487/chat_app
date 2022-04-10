import 'package:flutter/material.dart';

import '../../Themes/mythemes.dart';

class CustomButton1 extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  CustomButton1({required this.onTap, this.text = ''});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: MyTheme.lightTheme.primaryColor,
        ),
        child: Center(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white),
            )),
      ),
    );
  }
}
