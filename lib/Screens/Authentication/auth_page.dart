import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../Controller/auth_controller.dart';
import '../../Themes/mythemes.dart';
import '../../Widgets/UIWidgets/custom_buttom1.dart';
import '../../Widgets/UIWidgets/custom_edittext.dart';
import '../reset_password.dart';

class AuthPage extends StatefulWidget {
  static const routeName = '/auth-page';

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final authcontroller = Get.find<AuthController>();

  final GlobalKey<FormState> _formKey = GlobalKey();

  AuthMode? _authMode;

  var isLoading = false;

  String name = 'Dheeraj';

  String number = '123456789';

  String email = 'dheerajprajapat7487@gmail.com';

  String password = '123456789';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        await authcontroller.signIn(email: email, password: password);
      }
      if (_authMode == AuthMode.Signup) {
        String? uId =
            await authcontroller.signUp(email: email, password: password);
        await authcontroller.addInfo(
          uId: uId!,
          name: name,
          number: number,
          email: email,
        );
      }
    } on FirebaseAuthException catch (e) {
      String error = e.code;
      if (error == 'weak-password') {
        error = 'The password provided is too weak.';
      } else if (error == 'email-already-in-use') {
        error = 'The account already exists for that email.';
      } else if (e.code == 'user-not-found') {
        error = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        error = 'Wrong password provided for that user.';
      }
      print(error);
      authcontroller.showErrorDialog(error);
    } catch (error) {
      authcontroller
        ..showErrorDialog(
            'Could not authenticate you. Please try again later.');
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    _authMode = authcontroller.authMode;
    return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: MyTheme.lightTheme.accentColor,
        body: Stack(
          children: [
            Positioned(
              width: width,
              height: height,
              child: Container(
                color: Colors.white70,
              ),
            ),
            Positioned(
              bottom: 0.0,
              width: width,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40)),
                child: Container(
                  // ignore: deprecated_member_use
                  color: MyTheme.lightTheme.accentColor,
                  child: Center(
                    child: Column(
                      // ignore: prefer_const_literals_to_create_immutables
                      children: [
                        // ignore: prefer_const_constructors
                        Padding(
                          padding: const EdgeInsets.only(top: 70, bottom: 15),
                          child: Text(
                            _authMode == AuthMode.Signup
                                ? 'Create Account'
                                : 'Sign In',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 40, right: 40),
                          child: Form(
                            key: _formKey,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  if (_authMode == AuthMode.Signup)
                                    CustomTextField(
                                      label: 'Full Name',
                                      width: width,
                                      onChanged: (value) {
                                        name = value;
                                      },
                                      obscureText: false,
                                      isEnable: true,
                                      textInputType: TextInputType.name,
                                    ),
                                  if (_authMode == AuthMode.Signup)
                                    CustomTextField(
                                      label: 'Phone Number',
                                      width: width,
                                      onChanged: (value) {
                                        number = value;
                                      },
                                      obscureText: false,
                                      isEnable: true,
                                      textInputType: TextInputType.phone,
                                    ),
                                  CustomTextField(
                                    label: 'Email Address',
                                    width: width,
                                    onChanged: (value) {
                                      email = value;
                                    },
                                    obscureText: false,
                                    isEnable: true,
                                    textInputType: TextInputType.emailAddress,
                                  ),
                                  CustomTextField(
                                    label: 'Password',
                                    width: width,
                                    onChanged: (value) {
                                      password = value;
                                    },
                                    obscureText: true,
                                    isEnable: true,
                                    textInputType:
                                        TextInputType.visiblePassword,
                                  ),
                                  if (_authMode == AuthMode.Login)
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: TextButton(
                                        child: const Text(
                                          'Forgot Password?',
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 11),
                                        ),
                                        onPressed: () {
                                          Get.toNamed(ResetPassword.routeName);
                                        },
                                      ),
                                    ),
                                  if (isLoading)
                                    CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          MyTheme.lightTheme.primaryColor),
                                    )
                                  else
                                    CustomButton1(
                                      onTap: _submit,
                                      text: _authMode == AuthMode.Login
                                          ? 'Sign In'
                                          : 'Sign Up',
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 20, bottom: 30),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _authMode == AuthMode.Login
                                              ? authcontroller
                                                  .updateAuthMode('Up')
                                              : authcontroller
                                                  .updateAuthMode('In');
                                        });
                                      },
                                      child: RichText(
                                        text: TextSpan(
                                          style: TextStyle(
                                            fontSize: 11.0,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: GoogleFonts.poppins()
                                                .fontFamily,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: _authMode == AuthMode.Signup
                                                  ? 'Already a member?'
                                                  : 'Not a member?.',
                                            ),
                                            TextSpan(
                                                text:
                                                    _authMode == AuthMode.Signup
                                                        ? 'Sign In'
                                                        : 'Sign Up',
                                                style: TextStyle(
                                                    color: MyTheme.lightTheme
                                                        .primaryColor)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
