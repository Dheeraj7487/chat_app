import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

class MyTheme {
  static ThemeData get lightTheme {
    return ThemeData(
        primaryColor: Colors.blueAccent,
        accentColor: Colors.blueGrey[50],
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.light(primary: Colors.blueAccent),
        textTheme: const TextTheme(bodyText1: TextStyle(color: Colors.black)),
        fontFamily: GoogleFonts.poppins().fontFamily,
        buttonTheme: ButtonThemeData(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
          buttonColor: Colors.purple,
        ));
  }
}
