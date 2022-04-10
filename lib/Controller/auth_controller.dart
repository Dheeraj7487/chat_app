import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../Models/app_model.dart';
import '../Models/chatusers.dart';
import '../Screens/Authentication/authentication_screen.dart';
import '../Screens/main_screen.dart';
import '../collection_name.dart';
import '../firebase_key.dart';
import 'basecontroller.dart';

enum AuthMode { Signup, Login }

class AuthController extends BaseController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  AuthMode authMode = AuthMode.Login;
  String? fcm;

  StreamSubscription<User?> getCurrentUser() {
    StreamSubscription<User?> streamSubscription;
    streamSubscription = _auth.authStateChanges().listen((event) async {
      if (event != null) {
        app.user = event;
        await getToken();
        await updateToken();
        await getAppUserInfo();
        await updateDevicePackageInfo();
        // print(app.user!.email);
        Get.offAll(() => MainScreen());
      } else {
        app.user = null;
        app.appUser = null;
        Get.off(() => AuthenticationScreen());
      }
    });
    return streamSubscription;
  }

  Future<void> getAppUserInfo() async {
    await FirebaseFirestore.instance
        .collection(CollectionName.ChatUsers)
        .doc(app.userId)
        .get()
        .then((value) {
      app.appUser = ChatUser.fromDoc(value);
    });
  }

  Future<void> updateDevicePackageInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    try {
      FirebaseFirestore.instance
          .collection(CollectionName.ChatUsers)
          .doc(app.userId)
          .set({
        FirebaseKey.deviceInfo: {
          FirebaseKey.brand: androidInfo.brand,
          FirebaseKey.modelName: androidInfo.model,
          FirebaseKey.androidVersion: androidInfo.version.release
        },
        FirebaseKey.packageInfo:{
          FirebaseKey.packageName: packageInfo.packageName,
          FirebaseKey.packageVersion: packageInfo.version,
          FirebaseKey.buildVersion: packageInfo.buildNumber,
        }
      }, SetOptions(merge: true));
    } catch (e) {
      printError(info: e.toString());
    }
  }

  void updateAuthMode(String text) {
    if (text == 'In') {
      authMode = AuthMode.Login;
    }
    if (text == "Up") {
      authMode = AuthMode.Signup;
    }
    update();
  }

  Future<String?> signUp(
      {required String email, required String password}) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (credential.user != null) {
        return credential.user!.uid;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }

  Future<String?> signIn(
      {required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return "Signed in";
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }

  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return "Main Sent!!";
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> signOut() async {
    try {
      FirebaseFirestore.instance
          .collection(CollectionName.ChatUsers)
          .doc(app.userId)
          .set({FirebaseKey.fcm: ""}, SetOptions(merge: true));
      await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException catch (e) {
      printError(info: e.toString());
    }
  }

  Future<void> addInfo(
      {required String name,
      required String number,
      required String uId,
      required String email}) async {
    try {
      CollectionReference users =
          FirebaseFirestore.instance.collection(CollectionName.ChatUsers);
      users
          .doc(uId)
          .set({
            FirebaseKey.uname: name.toLowerCase(),
            FirebaseKey.profilepic: '',
            FirebaseKey.unumber: number,
            FirebaseKey.uemail: email,
            FirebaseKey.uId: uId,
            FirebaseKey.onoffStatus: 0,
            FirebaseKey.fcm: '',
            FirebaseKey.pStatus: "Hii there! i'm using Messeger app",
          })
          .then((value) => print('User Added'))
          .catchError((error) => print("Failed to add user: $error"));
      update();
    } catch (e) {
      printError(info: e.toString());
    }
    update();
  }

  Future<void> getToken() async {
    await FirebaseMessaging.instance.getToken().then((value) {
      fcm = value;
    });
  }

  Future<void> updateToken() async {
    await FirebaseFirestore.instance
        .collection(CollectionName.ChatUsers)
        .doc(app.userId)
        .set({
      FirebaseKey.fcm: fcm,
    }, SetOptions(merge: true));
  }

  Future<void> updateStatus(int status) async {
    CollectionReference users =
        FirebaseFirestore.instance.collection(CollectionName.ChatUsers);
    try {
      users
          .doc(app.userId)
          .set({
            FirebaseKey.onoffStatus: status,
          }, SetOptions(merge: true))
          .then((value) => print('Status Updated'))
          .catchError((error) => print("Failed to add user: $error"));
      update();
    } catch (e) {
      printError(info: e.toString());
    }
  }

  Future<void> updateInfo(
      {required String name,
      required String number,
      required String uId,
      required String url,
      required String email,
      required String pstatus}) async {
    print("IMAGEURL = " + url);
    try {
      CollectionReference users =
          FirebaseFirestore.instance.collection(CollectionName.ChatUsers);
      users
          .doc(uId)
          .set({
            FirebaseKey.uname: name,
            FirebaseKey.profilepic: url,
            FirebaseKey.unumber: number,
            FirebaseKey.uemail: email,
            FirebaseKey.onoffStatus: 1,
            FirebaseKey.pStatus: pstatus,
          }, SetOptions(merge: true))
          .then((value) => print('User Added'))
          .catchError((error) => print("Failed to add user: $error"));
      update();
    } catch (e) {
      printError(info: e.toString());
    }
  }
}
