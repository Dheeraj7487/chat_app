import 'package:flutter/material.dart';

import '../Models/app_model.dart';
import '../Themes/mythemes.dart';
class AboutUs extends StatelessWidget {
  const AboutUs({Key? key}) : super(key: key);
  static const routeName = '/about-us';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("ChatApp",style: TextStyle(fontSize: 30,color: MyTheme.lightTheme.primaryColor,fontWeight: FontWeight.bold),),
            Image.asset('assets/images/about.png',),
          ],
        ),
      ),
    );
  }
}
