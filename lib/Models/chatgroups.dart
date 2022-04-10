import 'package:cloud_firestore/cloud_firestore.dart';

import '../firebase_key.dart';

class ChatGroups {
  Timestamp created_at;
  String group_id;
  String name;
  String photo;
  String desc;
  String createdBy;

  ChatGroups({
    Timestamp? created_at,
    this.group_id = '',
    this.name = '',
    this.photo = '',
    this.desc = '',
    this.createdBy = '',
  }) : this.created_at = created_at ?? Timestamp.now();

  factory ChatGroups.fromDoc(DocumentSnapshot doc) => ChatGroups(
    created_at: doc[FirebaseKey.createdAt],
    group_id: doc[FirebaseKey.group_id],
     name: doc[FirebaseKey.group_name],
    photo: doc[FirebaseKey.group_photo],
    desc: doc[FirebaseKey.desc],
    createdBy: doc[FirebaseKey.createdBy],
  );

  factory ChatGroups.fromJson(Map<String,dynamic> json) => ChatGroups(
    created_at: json[FirebaseKey.createdAt],
    group_id: json[FirebaseKey.group_id],
    name: json[FirebaseKey.group_name],
    photo: json[FirebaseKey.group_photo],
    desc: json[FirebaseKey.desc],
    createdBy: json[FirebaseKey.createdBy],
  );

  Map toJson()
  {
    Map<String,dynamic> map = {};
    map[FirebaseKey.createdAt] = created_at;
    map[FirebaseKey.group_id] = group_id;
    map[FirebaseKey.group_name] = name;
    map[FirebaseKey.group_photo] = photo;
    map[FirebaseKey.desc] = desc;
    map[FirebaseKey.createdBy] = createdBy;
    return map;
  }
}
