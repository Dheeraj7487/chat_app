import 'package:cloud_firestore/cloud_firestore.dart';

import '../firebase_key.dart';

enum onoff { online, offline }

class ChatUser {
  String name;
  String email;
  String number;
  String imageUrl;
  String uid;
  int onoffStatus;
  String fcm;
  Map<String,dynamic> deviceInfo;
  Map<String,dynamic> packageInfo;
  String pStatus;

  ChatUser(
      {this.email = '',
      this.imageUrl = '',
      this.name = '',
      this.number = '',
      this.onoffStatus = 0,
      this.fcm = '',
      this.pStatus = '',
      this.deviceInfo = const{},
        this.packageInfo = const{},
      this.uid = ''});

  String get displayName {
    return name[0].toUpperCase() + name.substring(1);
  }

  factory ChatUser.fromDoc(DocumentSnapshot doc) {
    Map<String,dynamic> deviceInfo = {};
    Map<String,dynamic> packageInfo = {};
    try{
      deviceInfo = doc[FirebaseKey.deviceInfo];
      packageInfo = doc[FirebaseKey.packageInfo];
    }catch(e)
    {
      print(e.toString());
    }
   return  ChatUser(
      email: doc[FirebaseKey.uemail],
      imageUrl: doc[FirebaseKey.profilepic],
      name: doc[FirebaseKey.uname],
      number: doc[FirebaseKey.unumber],
      uid: doc[FirebaseKey.uId],
      onoffStatus: doc[FirebaseKey.onoffStatus] ?? 0,
      fcm: doc[FirebaseKey.fcm],
      pStatus: doc[FirebaseKey.pStatus],
      deviceInfo: deviceInfo,
      packageInfo: packageInfo,
    );
  }

  factory ChatUser.fromJson(Map<String, dynamic> json) {

    return ChatUser(
      email: json[FirebaseKey.uemail] ?? "",
      imageUrl: json[FirebaseKey.profilepic] ?? "",
      name: json[FirebaseKey.uname] ?? "",
      number: json[FirebaseKey.unumber] ?? "",
      uid: json[FirebaseKey.uId] ?? "",
      onoffStatus: json[FirebaseKey.onoffStatus] ?? 0,
      fcm: json[FirebaseKey.fcm],
      pStatus: json[FirebaseKey.pStatus] ?? "",
      deviceInfo: json[FirebaseKey.deviceInfo] ?? "",
      packageInfo: json[FirebaseKey.packageInfo] ?? "",
    );
  }

  onoff get status {
    switch (this.onoffStatus) {
      case 1:
        return onoff.online;
      default:
        return onoff.offline;
    }
  }

  Map toJson() {
    Map<String, dynamic> map = {};
    map['name'] = name;
    map['email'] = email;
    map['number'] = number;
    map['imageUrl'] = imageUrl;
    map['uid'] = uid;
    map['onoffStatus'] = onoffStatus;
    map['fcm'] = fcm;
    map['pStatus'] = pStatus;
    map['deviceInfo'] = deviceInfo;
    map['packageInfo'] = packageInfo;
    return map;
  }
}
