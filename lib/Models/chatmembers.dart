import 'package:cloud_firestore/cloud_firestore.dart';

import '../firebase_key.dart';

class ChatMembers {
  bool isArchive;
  bool isDeleted;
  bool isFavorite;
  Timestamp startDate;
  bool typing;
  String uId;
  int unReadCount;

  ChatMembers({
    this.isArchive = false,
    this.isDeleted = false,
    this.isFavorite = false,
    Timestamp? startDate,
    this.typing = false,
    this.uId = '',
    this.unReadCount = 0,
  }) : this.startDate = startDate ?? Timestamp.now();

  factory ChatMembers.fromDoc(DocumentSnapshot doc) => ChatMembers(
        isArchive: doc[FirebaseKey.isArchive],
        isDeleted: doc[FirebaseKey.isDeleted],
        isFavorite: doc[FirebaseKey.isFavorite],
        startDate: doc[FirebaseKey.startDate],
        typing: doc[FirebaseKey.typing],
        uId: doc[FirebaseKey.uId],
        unReadCount: doc[FirebaseKey.unReadCount],
      );

  factory ChatMembers.fromJson(Map<String, dynamic> json) => ChatMembers(
        isArchive: json[FirebaseKey.isArchive],
        isDeleted: json[FirebaseKey.isDeleted],
        isFavorite: json[FirebaseKey.isFavorite],
        startDate:
            Timestamp.fromDate(DateTime.parse(json[FirebaseKey.startDate])),
        typing: json[FirebaseKey.typing],
        uId: json[FirebaseKey.uId],
        unReadCount: json[FirebaseKey.unReadCount],
      );

  Map toJson() {
    Map<String, dynamic> map = {};
    map['isArchive'] = isArchive;
    map['isDeleted'] = isDeleted;
    map['isFavorite'] = isFavorite;
    map['startDate'] = startDate.toDate().toIso8601String();
    map['typing'] = typing;
    map['uId'] = uId;
    map['unReadCount'] = unReadCount;
    return map;
  }
}
