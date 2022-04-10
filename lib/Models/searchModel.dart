import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../firebase_key.dart';

class SearchModel {
  String name;
  String id;
  String photo;
  String status;
  bool isGroup;

  SearchModel({
    this.name = '',
    this.id = '',
    this.photo = '',
    this.status = '',
    this.isGroup = false,
  });

  factory SearchModel.fromDoc(DocumentSnapshot doc) => SearchModel(
        name: doc[FirebaseKey.group_name] ?? doc[FirebaseKey.uname],
        id: doc[FirebaseKey.group_id] ?? doc[FirebaseKey.uId],
        photo: doc[FirebaseKey.group_photo] ?? doc[FirebaseKey.profilepic],
        status: doc[FirebaseKey.desc] ?? doc[FirebaseKey.pStatus],
        isGroup: doc[FirebaseKey.group_name] == null ? false : true,
      );

  factory SearchModel.fromJson(Map<String, dynamic> json) => SearchModel(
        name: json[FirebaseKey.group_name] ?? json[FirebaseKey.uname],
        id: json[FirebaseKey.group_id] ?? json[FirebaseKey.uId],
        photo: json[FirebaseKey.group_photo] ?? json[FirebaseKey.profilepic],
        status: json[FirebaseKey.desc] ?? json[FirebaseKey.pStatus],
        isGroup: json[FirebaseKey.group_name] == null ? false : true,
      );

  String get displayName {
    return name[0].toUpperCase()+name.substring(1);
  }

  Map toJson() {
    Map<String, dynamic> map = {};
    map['name'] = name;
    map['id'] = id;
    map['photo'] = photo;
    map['status'] = status;
    map['isGroup'] = isGroup;
    return map;
  }
}
