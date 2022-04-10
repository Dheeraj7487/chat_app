
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Controller/auth_controller.dart';
import '../Themes/mythemes.dart';
import '../Widgets/UIWidgets/custom_buttom1.dart';
import '../Widgets/UIWidgets/custom_edittext.dart';

class ResetPassword extends StatefulWidget {
  ResetPassword({Key? key}) : super(key: key);
  static const routeName = '/reset-password';

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {

  final authController = Get.find<AuthController>();

  final GlobalKey<FormState> _formKey = GlobalKey();

  var isLoading = false;

  String reset = 'reset';

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      // ignore: deprecated_member_use
      backgroundColor: MyTheme.lightTheme.accentColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Forgot your password?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'Enter your registered email below to receive password reset instruction',
                  style: TextStyle(fontSize: 13, color: Colors.black38),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 20,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                      'https://image.freepik.com/free-vector/thoughtful-woman-with-laptop-looking-big-question-mark_1150-39362.jpg'),
                ),
                const SizedBox(
                  height: 20,
                ),
                Form(
                  key: _formKey,
                  child: CustomTextField(
                    label: 'Enter your email',
                    isEnable: true,
                    width: width,
                    onChanged: (value) {
                      setState(() {
                        reset = value;
                      });
                    },
                    obscureText: false,
                    textInputType: TextInputType.emailAddress,
                  ),
                ),
                if (isLoading)
                  const CircularProgressIndicator()
                else
                  CustomButton1(
                    onTap: () {
                      _submit();
                    },
                    text: 'Send Email',
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    print("MAIL ID = "+reset);
    setState(() {
      isLoading = true;
    });
    print("Before Try");
    try {
      await authController.resetPassword(reset);
      print("Try In");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("mail sent!!"),
      ));
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String error = e.code;
      if (e.code == 'user-not-found') {
        error = 'No user found for that email.';
      }
      print("ERROR CHE = "+error);
      // print("FirebaseAuthException In");
      _showErrorDialog(error);
    } catch (error) {
      // print("Catch In");
      print("ERROR = "+error.toString());
      _showErrorDialog('Could not authenticate you. Please try again later.');
    }
    print("After Try");
    setState(() {
      isLoading = false;
    });

    Navigator.pop(context);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('An Error Occurred!'),
        content: Text(message),
        actions: <Widget>[
          // ignore: deprecated_member_use
          FlatButton(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }
}
