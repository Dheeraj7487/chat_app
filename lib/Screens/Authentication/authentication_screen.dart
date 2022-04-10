import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Controller/auth_controller.dart';
import '../../Widgets/UIWidgets/custom_buttom1.dart';
import '../../Widgets/UIWidgets/custom_button2.dart';
import 'auth_page.dart';
class AuthenticationScreen extends StatelessWidget {
  final _authcontroller = Get.put(AuthController());
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding:
            const EdgeInsets.only(top: 70, left: 30, right: 30, bottom: 30),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
              child: Container(
                height: height * 0.6,
                child: Image.asset('assets/images/main_page.png'),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 40, right: 40, bottom: 20),
            child: Text(
              'Best way to invest your money!',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 50, right: 50),
            child: Column(
              children: [
                CustomButton1(
                  onTap: () {
                    _authcontroller.updateAuthMode('Up');
                    Get.toNamed(AuthPage.routeName);
                  },
                  text: 'Sign Up',
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomButton2(
                  onTap: () {
                    _authcontroller.updateAuthMode('In');
                    Get.toNamed(AuthPage.routeName);
                  },
                  text: 'Sign In',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



