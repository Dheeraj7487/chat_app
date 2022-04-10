import 'package:firebase_auth/firebase_auth.dart';

import 'chatusers.dart';

AppModel app = AppModel();

class AppModel {
  static final AppModel _appModel = AppModel.internal();

  factory AppModel() => _appModel;

  AppModel.internal();

  User? user;

  bool get hashUser => user != null;

  ChatUser? appUser;

  String get version => appUser!.packageInfo['packageVersion'];

  String get userId => user!.uid;
}
