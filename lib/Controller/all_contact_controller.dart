import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../Models/app_model.dart';
import '../Models/chatmembers.dart';
import '../Models/chats.dart';
import '../Models/chatusers.dart';
import '../Screens/chatroom.dart';
import '../collection_name.dart';
import '../firebase_key.dart';
import 'basecontroller.dart';

class AllContactController extends BaseController {
  List<ChatUser> profiles = [];

  Stream<QuerySnapshot> getAllContacts() {
    return FirebaseFirestore.instance
        .collection(CollectionName.ChatUsers)
        .where(FirebaseKey.uId, isNotEqualTo: app.userId)
        .snapshots();
  }

  Future<void> startCnv(
      {required List<String> ids,
      required bool isGroup,
      String groupName = '',
      String imageUrl = ''}) async {
    try {
      ids.add(app.userId);
      if (isGroup) {
        DocumentReference reference = FirebaseFirestore.instance
            .collection(CollectionName.ChatGroups)
            .doc();
        reference.set({
          FirebaseKey.group_id: reference.id,
          FirebaseKey.group_name: groupName,
          FirebaseKey.group_photo: imageUrl,
          FirebaseKey.createdAt: Timestamp.now(),
          FirebaseKey.desc: "Hiii I'm Using ChatApp",
          FirebaseKey.createdBy: app.userId,
        }).then((value) {
          FirebaseFirestore.instance
              .collection(CollectionName.Chats)
              .doc(reference.id)
              .set({
            FirebaseKey.displayUsers: ids,
            FirebaseKey.chatId: reference.id,
            FirebaseKey.lastmsg: '',
            FirebaseKey.sender: '',
            FirebaseKey.createdAt: Timestamp.now(),
            FirebaseKey.isGroup: true,
            FirebaseKey.chatDeleteFor: [],
            FirebaseKey.unReadFlag: {for (String ids in ids) ids: false},
          }).then((value) {
            for (String id in ids) {
              FirebaseFirestore.instance
                  .collection(CollectionName.Chats)
                  .doc(reference.id)
                  .collection('ChatMembers')
                  .doc(id)
                  .set({
                FirebaseKey.isArchive: false,
                FirebaseKey.isDeleted: false,
                FirebaseKey.isFavorite: false,
                FirebaseKey.startDate: Timestamp.now(),
                FirebaseKey.typing: false,
                FirebaseKey.uId: id,
                FirebaseKey.unReadCount: 0,
              });
            }
          });
          sendGroupNotification(ids,groupName);
        });
      } else {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection(CollectionName.Chats)
            .where(FirebaseKey.displayUsers, arrayContains: app.userId)
            .where(FirebaseKey.isGroup, isEqualTo: false)
            .get();

        print(querySnapshot.docs);
        List<Chats> chat =
            querySnapshot.docs.map((e) => Chats.fromDoc(e)).toList();
        List<Chats> temp = chat
            .where((element) => element.displayUsers.contains(ids.first))
            .toList();
        if (temp.isNotEmpty) {
          FirebaseFirestore.instance
              .collection(CollectionName.Chats)
              .doc(temp.first.chatId)
              .collection(CollectionName.ChatMembers)
              .doc(app.userId)
              .get()
              .then((value) {
            ChatMembers chatMembers = ChatMembers.fromDoc(value);
            Get.toNamed(
              ChatRoom.routeName,
              arguments: [temp.first, chatMembers],
            );
          });
          FirebaseFirestore.instance
              .collection(CollectionName.Chats)
              .doc(temp.first.chatId)
              .set({
            FirebaseKey.chatDeleteFor: FieldValue.arrayRemove([app.userId]),
          }, SetOptions(merge: true));
        } else {
          print("NOT EXTSTS");
          try {
            DocumentReference reference = await FirebaseFirestore.instance
                .collection(CollectionName.Chats)
                .doc();
            reference.set({
              FirebaseKey.displayUsers: ids,
              FirebaseKey.chatId: reference.id,
              FirebaseKey.lastmsg: '',
              FirebaseKey.sender: '',
              FirebaseKey.createdAt: Timestamp.now(),
              FirebaseKey.isGroup: false,
              FirebaseKey.chatDeleteFor: [],
              FirebaseKey.unReadFlag: {for (String ids in ids) ids: false},
            }).then((value) {
              for (String id in ids) {
                FirebaseFirestore.instance
                    .collection(CollectionName.Chats)
                    .doc(reference.id)
                    .collection(CollectionName.ChatMembers)
                    .doc(id)
                    .set({
                  FirebaseKey.isArchive: false,
                  FirebaseKey.isDeleted: false,
                  FirebaseKey.isFavorite: false,
                  FirebaseKey.startDate: Timestamp.now(),
                  FirebaseKey.typing: false,
                  FirebaseKey.uId: id,
                  FirebaseKey.unReadCount: 0,
                });
              }
            });
            Get.toNamed(
              ChatRoom.routeName,
              arguments: [
                Chats(
                  isGroup: false,
                  createdAt: Timestamp.now(),
                  chatId: reference.id,
                  chatDeleteFor: [],
                  displayUsers: ids,
                  lastmsg: "",
                  senderId: "",
                  unReadFlag: {for (String ids in ids) ids: false},
                ),
                ChatMembers(
                    isArchive: false,
                    isDeleted: false,
                    isFavorite: false,
                    startDate: Timestamp.now(),
                    typing: false,
                    uId: app.userId,
                    unReadCount: 0)
              ],
            );
          } catch (e) {
            printError(info: e.toString() + " Unable to start conversation");
          }
        }
      }
    } catch (e) {
      printError(info: e.toString());
    }
  }


}
