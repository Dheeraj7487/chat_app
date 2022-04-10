// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../Models/app_model.dart';
import '../Models/chatgroups.dart';
import '../Models/chatmembers.dart';
import '../Models/chats.dart';
import '../Models/chatusers.dart';
import '../Models/messages.dart';
import '../collection_name.dart';
import '../firebase_key.dart';

class BaseController extends GetxController {
  ChatMembers chatMember = ChatMembers();
  ChatGroups chatGroup = ChatGroups();
  Chats chatsData = Chats();
  List<ChatMembers> chatMembers = [];
  void showErrorDialog(String message) {
    Get.defaultDialog(
        title: 'An Error Occurred!',
        barrierDismissible: false,
        content: Center(child: Text(message)),
        confirm: FlatButton(
          child: const Text('Okay'),
          onPressed: () {
            Get.back();
          },
        ));
  }

  Stream<DocumentSnapshot> getInfo(String uid) {
    return FirebaseFirestore.instance
        .collection(CollectionName.ChatUsers)
        .doc(uid)
        .snapshots();
  }

  Future<void> addNewMsg(String msg, int msgType, Chats chats) async {
    String lastmsg = '';
    switch (msgType) {
      case 0:
        lastmsg = msg;
        break;
      case 1:
        lastmsg = "Photo";
        break;
      case 2:
        lastmsg = "Video";
        break;
      default:
        lastmsg = "Audio";
    }
    try {
      // print("CHATID = "+chats.displayUsers.toString());
      DocumentReference reference = await FirebaseFirestore.instance
          .collection(CollectionName.Chats)
          .doc(chats.chatId)
          .collection(CollectionName.Messages)
          .add({
        FirebaseKey.msg: msg,
        FirebaseKey.sender: app.userId,
        FirebaseKey.createdAt: Timestamp.now(),
        FirebaseKey.status: {
          for (String id
              in chats.displayUsers.where((element) => element != app.userId))
            id: 0
        },
        FirebaseKey.msgDeleteFor: [],
        FirebaseKey.msgType: msgType,
        FirebaseKey.msgId: '',
      });
      // print("Message = MSG ENTRED");
      FirebaseFirestore.instance
          .collection(CollectionName.Chats)
          .doc(chats.chatId)
          .set({
        FirebaseKey.lastmsg: lastmsg,
        FirebaseKey.sender: app.userId,
        FirebaseKey.createdAt: Timestamp.now()
      }, SetOptions(merge: true));
      // print("Message = Last MSG UPDATED");
      FirebaseFirestore.instance
          .collection(CollectionName.Chats)
          .doc(chats.chatId)
          .collection(CollectionName.Messages)
          .doc(reference.id)
          .set({FirebaseKey.msgId: reference.id}, SetOptions(merge: true));
      // print("Message = Update msg id");
      FirebaseFirestore.instance
          .collection(CollectionName.Chats)
          .doc(chats.chatId)
          .collection(CollectionName.Messages)
          .doc(reference.id)
          .get()
          .then((value) {
        Messages messages = Messages.fromDoc(value);
        chats.displayUsers.forEach((element) {
          int messageStatus = messages.status[element];
          if (element != app.userId) {
            updateCount(chats, element, messageStatus);
            notification(messageStatus, element, msg);
          }
        });
      });
      print("Message = all done");
    } catch (e) {
      printError(info: e.toString());
    }
  }

  void notification(int messageStatus, String id, String msg) {
    if (messageStatus == 0) {
      FirebaseFirestore.instance
          .collection(CollectionName.ChatUsers)
          .doc(id)
          .get()
          .then((value) {
        ChatUser chatUser = ChatUser.fromDoc(value);
        if (chatsData.isGroup) {
          sendPushMessage(
              chatUser.fcm, app.appUser!.name + " : " + msg, chatGroup.name);
        } else {
          sendPushMessage(chatUser.fcm, msg, app.appUser!.name);
        }
      });
    }
  }

  void updateCount(Chats chats, String id, int messageStatus) {
    if (messageStatus != 2) {
      FirebaseFirestore.instance
          .collection(CollectionName.Chats)
          .doc(chats.chatId)
          .collection(CollectionName.ChatMembers)
          .doc(id)
          .set({FirebaseKey.unReadCount: FieldValue.increment(1)},
              SetOptions(merge: true));
      print("Message = Update Count");
      FirebaseFirestore.instance
          .collection(CollectionName.Chats)
          .doc(chats.chatId)
          .set({
        FirebaseKey.unReadFlag: {id: true}
      }, SetOptions(merge: true));
      print("Message = Update flag");
    }
  }

  Future<void> sendPushMessage(String token, String body, String title) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAADmn9TzU:APA91bHU-5rYH_dDNg0zUScRAokBO_9rNwqm9E1GAcMbq_r7xCDEgnBN2A3ch2fUQOwXRcUjbtY9BtPoVvXcts4wq2nUCH3VFfF01pGHv_fgpyY69wjM5BsFIhZowO90pA7UHe5jlUhZ',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': body,
              'title': title,
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done',
              'chats': '${json.encode(chatsData.toJson())}',
              'members': '${json.encode(chatMember.toJson())}'
            },
            "to": token
          },
        ),
      );
    } catch (e) {
      printError(info: e.toString());
      print("error push notification");
    }
  }

  Stream<DocumentSnapshot> getAppMemberInfo(String chatId) {
    return FirebaseFirestore.instance
        .collection(CollectionName.Chats)
        .doc(chatId)
        .collection(CollectionName.ChatMembers)
        .doc(app.userId)
        .snapshots();
  }

  Future<String> sendMedia(int msgType, Chats chats) async {
    String lastmsg = '';
    switch (msgType) {
      case 1:
        lastmsg = "Photo";
        break;
      case 2:
        lastmsg = "Video";
        break;
      default:
        lastmsg = "Audio";
    }
    try {
      DocumentReference reference = await FirebaseFirestore.instance
          .collection(CollectionName.Chats)
          .doc(chats.chatId)
          .collection(CollectionName.Messages)
          .doc();
      await reference.set({
        FirebaseKey.msg: "",
        FirebaseKey.sender: app.userId,
        FirebaseKey.createdAt: Timestamp.now(),
        FirebaseKey.status: {
          for (String id
              in chats.displayUsers.where((element) => element != app.userId))
            id: 0
        },
        FirebaseKey.msgDeleteFor: [],
        FirebaseKey.msgType: msgType,
        FirebaseKey.msgId: reference.id,
      });
      return reference.id;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> updateMedia(
      String msgId, Chats chats, int msgType, String msg) async {
    String lastmsg = '';
    switch (msgType) {
      case 1:
        lastmsg = "Photo";
        break;
      case 2:
        lastmsg = "Video";
        break;
      default:
        lastmsg = "Audio";
    }
    try {
      FirebaseFirestore.instance
          .collection(CollectionName.Chats)
          .doc(chats.chatId)
          .collection(CollectionName.Messages)
          .doc(msgId)
          .set({
        FirebaseKey.msg: msg,
      }, SetOptions(merge: true));
      await FirebaseFirestore.instance
          .collection(CollectionName.Chats)
          .doc(chats.chatId)
          .collection(CollectionName.Messages)
          .doc(msgId)
          .get()
          .then((value) async {
        Messages messages = Messages.fromDoc(value);
        for (String id
            in chats.displayUsers.where((element) => element != app.userId)) {
          int messagestatus = messages.status[id];
          FirebaseFirestore.instance
              .collection(CollectionName.Chats)
              .doc(chats.chatId)
              .collection(CollectionName.ChatMembers)
              .doc(id)
              .get()
              .then((value) async {
            ChatMembers chatMembers = ChatMembers.fromDoc(value);
            print("unReadCount = " + chatMembers.unReadCount.toString());
            int count = chatMembers.unReadCount;

            await FirebaseFirestore.instance
                .collection(CollectionName.Chats)
                .doc(chats.chatId)
                .set({
              FirebaseKey.lastmsg: lastmsg,
              FirebaseKey.sender: app.userId,
              FirebaseKey.unReadFlag: {
                id: true,
              },
              FirebaseKey.createdAt: Timestamp.now(),
            }, SetOptions(merge: true)).then((value) async {
              await FirebaseFirestore.instance
                  .collection(CollectionName.Chats)
                  .doc(chats.chatId)
                  .collection(CollectionName.ChatMembers)
                  .doc(id)
                  .set({
                FirebaseKey.unReadCount: count,
              }, SetOptions(merge: true));
            });

            if (messagestatus != 2) {
              count++;
            }
            FirebaseFirestore.instance
                .collection(CollectionName.ChatUsers)
                .doc(app.userId)
                .get()
                .then((value) {
              ChatUser currentUser = ChatUser.fromDoc(value);
              FirebaseFirestore.instance
                  .collection(CollectionName.ChatUsers)
                  .doc(id)
                  .get()
                  .then((value) {
                ChatUser chatUser = ChatUser.fromDoc(value);
                {
                  if (messagestatus == 0) {
                    if (chats.isGroup) {
                      sendPushMessage(chatUser.fcm,
                          currentUser.name + " : " + msg, chatGroup.name);
                    } else {
                      sendPushMessage(chatUser.fcm, msg, currentUser.name);
                    }
                  }
                }
              });
            });
          });
        }
      });
    } catch (e) {
      printError(info: e.toString());
    }
  }

  Future<void> sendGroupNotification(List<String> ids,String groupName) async {
    ids.forEach((element) async {
      if (element != app.userId) {
        await FirebaseFirestore.instance
            .collection(CollectionName.ChatUsers)
            .doc(element)
            .get()
            .then((value) {
          ChatUser chatUser = ChatUser.fromDoc(value);
          print("CHATUSER FCM = "+chatUser.fcm);
          sendNotification(chatUser.fcm,groupName);
        });
      }
    });
  }

  Future<void> sendNotification(String token,String groupName) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
          'key=AAAADmn9TzU:APA91bHU-5rYH_dDNg0zUScRAokBO_9rNwqm9E1GAcMbq_r7xCDEgnBN2A3ch2fUQOwXRcUjbtY9BtPoVvXcts4wq2nUCH3VFfF01pGHv_fgpyY69wjM5BsFIhZowO90pA7UHe5jlUhZ',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': "You are added to "+groupName+" by "+app.appUser!.name,
              'title': groupName,
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done',
              // 'chats': '${json.encode(chatsData.toJson())}',
              // 'members': '${json.encode(chatMember.toJson())}'
            },
            "to": token
          },
        ),
      );
    } catch (e) {
      printError(info: e.toString());
      print("error push notification");
    }
  }
}
