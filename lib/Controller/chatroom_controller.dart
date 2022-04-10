import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Models/app_model.dart';
import '../Models/chatgroups.dart';
import '../Models/chatmembers.dart';
import '../Models/chats.dart';
import '../Models/chatusers.dart';
import '../Models/messages.dart';
import '../collection_name.dart';
import '../firebase_key.dart';
import 'basecontroller.dart';

class ChatRoomController extends BaseController {
  Chats chats;
  ChatUser user = ChatUser();
  int documentLimit = 10;
  ChatMembers appUser;
  StreamController<List<DocumentSnapshot>> controller =
      StreamController<List<DocumentSnapshot>>();
  Stream<List<DocumentSnapshot>> get streamController => controller.stream;
  ScrollController scrollController = ScrollController();
  ChatRoomController({required this.chats, required this.appUser});
  List<Messages> messages = [];
  ChatGroups chatGroup = ChatGroups();
  List<ChatUser> notInGroup = [];
  List<ChatUser> inGroupUser = [];

  @override
  void onInit() async {
    super.onInit();
    chatsData = chats;
    getGroupUserInfo();
    scrollController.addListener(() async {
      double maxScroll = scrollController.position.maxScrollExtent;
      double currentScroll = scrollController.position.pixels;
      double delta = MediaQuery.of(Get.context!).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {
        await Future.delayed(Duration(seconds: 1));
        documentLimit = documentLimit + 10;
      }
    });
  }

  Future<ChatMembers> getAppUser() async {
    print("getAppUser");
    FirebaseFirestore.instance
        .collection(CollectionName.Chats)
        .doc(chats.chatId)
        .collection(CollectionName.ChatMembers)
        .doc(app.userId)
        .get()
        .then((value) {
      appUser = ChatMembers.fromDoc(value);
      return appUser;
    });
    return appUser;
  }

  @override
  void onClose() {
    super.onClose();
    scrollController.removeListener(() {});
    controller.close();
  }

  Stream<DocumentSnapshot> getOpponentProfile() {
    print("getOpponentProfile");
    if (chats.isGroup) {
      return FirebaseFirestore.instance
          .collection(CollectionName.ChatGroups)
          .doc(chats.chatId)
          .snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection(CollectionName.ChatUsers)
          .doc(chats.opponentUser)
          .snapshots();
    }
  }

  Stream<QuerySnapshot> getChats() {
    return FirebaseFirestore.instance
        .collection(CollectionName.Chats)
        .doc(chats.chatId)
        .collection(CollectionName.Messages)
        .where(FirebaseKey.createdAt, isGreaterThan: appUser.startDate)
        .orderBy(FirebaseKey.createdAt, descending: true)
        .limit(documentLimit)
        .snapshots();
  }

  Future<void> getGroupUserInfo() async {
    print("ChatId = " + chats.chatId);
    for (String id in chats.displayUsers) {
      print("Sender id = " + id);
      await FirebaseFirestore.instance
          .collection(CollectionName.ChatUsers)
          .doc(id)
          .get()
          .then((value) {
        if (value.exists) {
          print("getGroupUserInfo = " + ChatUser.fromDoc(value).name);
          inGroupUser.add(ChatUser.fromDoc(value));
          update();
        }
      });
    }
  }

  Future<void> updateSingleMsgStatus(String msgId) async {
    print("updateSingleMsgStatus");
    try {
      await FirebaseFirestore.instance
          .collection(CollectionName.Chats)
          .doc(chats.chatId)
          .collection(CollectionName.Messages)
          .doc(msgId)
          .get()
          .then((value) async {
        Messages messages = Messages.fromDoc(value);
        if (messages.sender != app.userId && messages.status[app.userId] != 2) {
          print(messages.toJson());
          await FirebaseFirestore.instance
              .collection(CollectionName.Chats)
              .doc(chats.chatId)
              .collection(CollectionName.Messages)
              .doc(msgId)
              .set({
            FirebaseKey.status: {app.userId: 2}
          }, SetOptions(merge: true)).then((value) async {
            await FirebaseFirestore.instance
                .collection(CollectionName.Chats)
                .doc(chats.chatId)
                .collection(CollectionName.ChatMembers)
                .doc(app.userId)
                .set({
              FirebaseKey.unReadCount: 0,
            }, SetOptions(merge: true));
          });
          update();
        }
        await FirebaseFirestore.instance
            .collection(CollectionName.Chats)
            .doc(chats.chatId)
            .set({
          FirebaseKey.unReadFlag: {
            app.userId: false,
          },
        }, SetOptions(merge: true));
      });
    } catch (e) {
      printError(info: e.toString());
    }
  }

  Future<void> updateGroupDescription(String desc) async {
    print("updateGroupDescription");
    try {
      await FirebaseFirestore.instance
          .collection(CollectionName.ChatGroups)
          .doc(chatGroup.group_id)
          .set({
        FirebaseKey.desc: desc,
      }, SetOptions(merge: true));
      chatGroup.desc = desc;
      update();
    } catch (e) {
      printError(info: e.toString());
    }
  }

  Stream<QuerySnapshot> getNewParticipants() {
    return FirebaseFirestore.instance
        .collection(CollectionName.ChatUsers)
        .where(FirebaseKey.uId, whereNotIn: chats.displayUsers)
        .snapshots();
  }

  Future<void> addNewParticipants(List<ChatUser> idList) async {
    print("addNewParticipants = " + idList.length.toString());
    try {
      for (ChatUser user in idList) {
        await FirebaseFirestore.instance
            .collection(CollectionName.Chats)
            .doc(chats.chatId)
            .set({
          FirebaseKey.displayUsers: FieldValue.arrayUnion([user.uid]),
          FirebaseKey.unReadFlag: {
            for (ChatUser user in idList) user.uid: false
          }
        }, SetOptions(merge: true)).then((value) {
          FirebaseFirestore.instance
              .collection(CollectionName.Chats)
              .doc(chats.chatId)
              .collection(CollectionName.ChatMembers)
              .doc(user.uid)
              .set({
            FirebaseKey.isArchive: false,
            FirebaseKey.isDeleted: false,
            FirebaseKey.isFavorite: false,
            FirebaseKey.startDate: Timestamp.now(),
            FirebaseKey.typing: false,
            FirebaseKey.uId: user.uid,
            FirebaseKey.unReadCount: 0,
          });
          chats.displayUsers.add(user.uid);
          inGroupUser.add(user);
        });
        sendGroupNotification(idList.map((e) => e.uid).toList(),chatGroup.name);
      }
      update();
    } catch (e) {
      printError(info: e.toString());
    }
  }

  Future<void> deleteMsg(String msgId) async {
    print("deleteMsg");
    try {
      await FirebaseFirestore.instance
          .collection(CollectionName.Chats)
          .doc(chats.chatId)
          .collection(CollectionName.Messages)
          .doc(msgId)
          .set({
        FirebaseKey.msgDeleteFor: [app.userId]
      }, SetOptions(merge: true));
    } catch (e) {
      printError(info: e.toString());
    }
    update();
  }

  Future<void> deleteAll(
    String msgId,
  ) async {
    print("deleteAll");
    try {
      await FirebaseFirestore.instance
          .collection(CollectionName.Chats)
          .doc(chats.chatId)
          .collection(CollectionName.Messages)
          .doc(msgId)
          .set({
        FirebaseKey.msgDeleteFor: [
          for (ChatMembers member in chatMembers) member.uId
        ]
      }, SetOptions(merge: true));
    } catch (e) {
      printError(info: e.toString());
    }
    update();
  }

  Future<void> exitGroup(String id) async {
    print("exitGroup");
    chats.displayUsers.removeWhere((element) => element == id);
    inGroupUser.removeWhere((element) => element.uid == id);
    try {
      List<dynamic> tempList =
          chats.displayUsers.where((element) => element != id).toList();
      Map<String, dynamic> map = chats.unReadFlag;
      map.removeWhere((key, value) => key == id);
      print(map);
      await FirebaseFirestore.instance
          .collection(CollectionName.Chats)
          .doc(chats.chatId)
          .update({
        FirebaseKey.displayUsers: tempList,
        FirebaseKey.unReadFlag: map,
      }).then((value) async {
        await FirebaseFirestore.instance
            .collection(CollectionName.Chats)
            .doc(chats.chatId)
            .collection(CollectionName.ChatMembers)
            .doc(id)
            .delete();
      });
      update();
    } catch (e) {
      printError(info: e.toString());
    }
  }

  Future<void> removeGroup() async {
    print("removeGroup");
    try {
      FirebaseFirestore.instance
          .collection(CollectionName.Chats)
          .doc(chats.chatId)
          .delete();
      FirebaseFirestore.instance
          .collection(CollectionName.Chats)
          .doc(chats.chatId)
          .collection(CollectionName.ChatMembers)
          .get()
          .then((value) {
        for (DocumentSnapshot doc in value.docs) {
          doc.reference.delete();
        }
      });
      FirebaseFirestore.instance
          .collection(CollectionName.Chats)
          .doc(chats.chatId)
          .collection(CollectionName.Messages)
          .get()
          .then((value) {
        for (DocumentSnapshot doc in value.docs) {
          doc.reference.delete();
        }
      });
      FirebaseFirestore.instance
          .collection(CollectionName.ChatGroups)
          .doc(chats.chatId)
          .delete();
    } catch (e) {
      print(e.toString());
    }
  }
}
