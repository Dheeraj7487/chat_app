import 'package:cloud_firestore/cloud_firestore.dart';

import '../firebase_key.dart';
import 'app_model.dart';

class Chats {
  String chatId;
  Timestamp createdAt;
  List<dynamic> displayUsers;
  bool isGroup;
  String lastmsg;
  String senderId;
  Map<String, dynamic> unReadFlag;
  List<dynamic> chatDeleteFor;

  Chats(
      {this.chatId = '',
      Timestamp? createdAt,
      this.displayUsers = const [],
      this.isGroup = false,
      this.lastmsg = '',
      this.unReadFlag = const {},
      this.chatDeleteFor = const [],
      this.senderId = ''})
      : this.createdAt = createdAt ?? Timestamp.now();

  factory Chats.fromDoc(DocumentSnapshot doc) => Chats(
        chatId: doc[FirebaseKey.chatId],
        createdAt: doc[FirebaseKey.createdAt],
        displayUsers: doc[FirebaseKey.displayUsers],
        isGroup: doc[FirebaseKey.isGroup],
        lastmsg: doc[FirebaseKey.lastmsg],
        senderId: doc[FirebaseKey.lastmsg],
        unReadFlag: doc[FirebaseKey.unReadFlag],
        chatDeleteFor: doc[FirebaseKey.chatDeleteFor],
      );

  factory Chats.fromJson(Map<String, dynamic> json) => Chats(
        chatId: json[FirebaseKey.chatId],
        createdAt:
            Timestamp.fromDate(DateTime.parse(json[FirebaseKey.createdAt])),
        displayUsers: json[FirebaseKey.displayUsers],
        isGroup: json[FirebaseKey.isGroup],
        lastmsg: json[FirebaseKey.lastmsg],
        senderId: json[FirebaseKey.lastmsg],
        unReadFlag: json[FirebaseKey.unReadFlag],
        chatDeleteFor: json[FirebaseKey.chatDeleteFor],
      );

  String get opponentUser {
    return displayUsers.firstWhere((element) => element != app.userId);
  }

  Map toJson() {
    Map<String, dynamic> map = {};
    map['chatId'] = chatId;
    map['createdAt'] = createdAt.toDate().toIso8601String();
    map['displayUsers'] = displayUsers;
    map['isGroup'] = isGroup;
    map['lastmsg'] = lastmsg;
    map['senderId'] = senderId;
    map['unReadFlag'] = unReadFlag;
    map['chatDeleteFor'] = chatDeleteFor;
    return map;
  }
}
