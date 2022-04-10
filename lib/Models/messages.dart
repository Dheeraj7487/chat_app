import 'package:cloud_firestore/cloud_firestore.dart';

import 'app_model.dart';

enum Type { text, video, audio, photo }
enum seenType { send, recive, view }

class Messages {
  Timestamp createdAt;
  String msg;
  List<dynamic> msgDeleteFor;
  String msgId;
  int msgType;
  String sender;
  Map<String,dynamic> status;

  Messages({
    Timestamp? createdAt,
    this.msg = '',
    this.msgDeleteFor = const [],
    this.msgType = 0,
    this.sender = '',
    this.msgId = '',
    this.status = const {},
  }) : this.createdAt = createdAt ?? Timestamp.now();

  factory Messages.fromDoc(DocumentSnapshot doc) => Messages(
        createdAt: doc['createdAt'],
        msg: doc['msg'],
        msgDeleteFor: doc['msgDeleteFor'],
        msgType: doc['msgType'],
        sender: doc['sender'],
        msgId: doc['msgId'],
        status: doc['status'],
      );

  factory Messages.fromJson(Map<String,dynamic> json) => Messages(
    createdAt: json['createdAt'],
    msg: json['msg'],
    msgDeleteFor: json['msgDeleteFor'],
    msgType: json['msgType'],
    sender: json['sender'],
    msgId: json['msgId'],
    status: json['msgId'],
  );

  bool get isSendbyMy => sender == app.userId;

  Map toJson()
  {
    Map<String,dynamic> map = {};
    map['createdAt'] = createdAt;
    map['msg'] = msg;
    map['msgDeleteFor'] = msgDeleteFor;
    map['msgType'] = msgType;
    map['sender'] = sender;
    map['msgId'] = msgId;
    map['msgId'] = msgId;
    return map;
  }

  Type get msgViewType {
    switch (this.msgType) {
      case 0:
        return Type.text;
      case 1:
        return Type.photo;
      case 2:
        return Type.video;
      default:
        return Type.audio;
    }
  }

}
