import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart' as rx;

import '../Models/app_model.dart';
import '../Models/chatgroups.dart';
import '../Models/chatmembers.dart';
import '../Models/chats.dart';
import '../Models/chatusers.dart';
import '../Models/messages.dart';
import '../Models/searchModel.dart';
import '../collection_name.dart';
import '../firebase_key.dart';
import 'basecontroller.dart';

class MainScreenController extends BaseController {
  List<ChatMembers> chatmembers = [];
  List<Chats> favChatList = [];
  List<Chats> archiveChatList = [];

  @override
  void initState() {
    getAllusers();
  }

  Stream<QuerySnapshot> getAllusers() {
    return FirebaseFirestore.instance
        .collection(CollectionName.Chats)
        .orderBy(FirebaseKey.createdAt, descending: true)
        .where(FirebaseKey.displayUsers, arrayContains: app.userId)
        .snapshots();
  }

  Stream<DocumentSnapshot> getChatMembersInfo(
      String chatId, String ChatuserId) {
    return FirebaseFirestore.instance
        .collection(CollectionName.Chats)
        .doc(chatId)
        .collection(CollectionName.ChatMembers)
        .doc(ChatuserId)
        .snapshots();
  }

  Future<ChatUser> getUserInfo(String profileId) async {
    print("Profile Id = " + profileId);
    ChatUser chatUser = ChatUser();
    await FirebaseFirestore.instance
        .collection(CollectionName.ChatUsers)
        .doc(profileId)
        .get()
        .then((value) {
      if (value.exists) {
        chatUser = ChatUser.fromDoc(value);
      }
    });
    return chatUser;
  }

  Future<Chats> getSearchUserInfo(String profileId) async {
    print("Profile Id = " + profileId);
    Chats singleChat = Chats();
    await FirebaseFirestore.instance
        .collection(CollectionName.Chats)
        .where(FirebaseKey.displayUsers, arrayContains: profileId)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        List<Chats> chatLists =
            value.docs.map((e) => Chats.fromDoc(e)).toList();
        singleChat = chatLists
            .where((element) =>
                element.displayUsers.contains(app.userId) &&
                element.isGroup == false)
            .first;
      }
    });
    return singleChat;
  }

  Future<Chats> getSearchGroupInfo(String groupId) async {
    Chats singlechat = Chats();
    await FirebaseFirestore.instance
        .collection(CollectionName.Chats)
        .where(FirebaseKey.chatId, isEqualTo: groupId)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        singlechat = value.docs.map((e) => Chats.fromDoc(e)).toList().first;
      }
    });
    return singlechat;
  }

  Future<DocumentSnapshot> getConvDoc(Chats currentChat) async {
    if (currentChat.isGroup) {
      return FirebaseFirestore.instance
          .collection(CollectionName.ChatGroups)
          .doc(currentChat.chatId)
          .get();
    } else {
      return FirebaseFirestore.instance
          .collection(CollectionName.ChatUsers)
          .doc(currentChat.opponentUser)
          .get();
    }
  }

  Future<ChatGroups> getGroupInfo(String groupId) async {
    print("group Id = " + groupId);
    ChatGroups chatGroups = ChatGroups();
    await FirebaseFirestore.instance
        .collection(CollectionName.ChatGroups)
        .doc(groupId)
        .get()
        .then((value) {
      if (value.exists) {
        chatGroups = ChatGroups.fromDoc(value);
      }
    });
    return chatGroups;
  }

  Widget profileImage(String imageUrl) {
    return imageUrl.isEmpty
        ? Image.asset('assets/images/default_pic.png')
        : ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.network(
              imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          );
  }

  Future<void> updateMsgStatus(Chats chats) async {
    try {
      await FirebaseFirestore.instance
          .collection(CollectionName.Chats)
          .doc(chats.chatId)
          .collection(CollectionName.Messages)
          .get()
          .then((value) {
        value.docs.forEach((element) {
          Messages messages = Messages.fromDoc(element);
          Map<String, dynamic> currentUserMap = messages.status;

          // print(currentUserMap);
          if (currentUserMap[app.userId] != 2 &&
              messages.sender != app.userId) {
            print('Yesss');

            FirebaseFirestore.instance
                .collection(CollectionName.Chats)
                .doc(chats.chatId)
                .collection(CollectionName.Messages)
                .doc(element.id)
                .set({
              FirebaseKey.status: {app.userId: 1}
            }, SetOptions(merge: true));
            update();
          }
        });
      });
    } catch (e) {
      printError(info: e.toString());
    }
  }

  Future<void> updateStatus(int status) async {
    CollectionReference users =
        FirebaseFirestore.instance.collection(CollectionName.ChatUsers);
    try {
      users
          .doc(app.userId)
          .set({
            FirebaseKey.onoffStatus: status,
          }, SetOptions(merge: true))
          .then((value) => print('Status Updated'))
          .catchError((error) => print("Failed to add user: $error"));
      update();
    } catch (e) {
      printError(info: e.toString());
    }
  }

  Stream<List<SearchModel>> query(String queryString) {
    Stream<QuerySnapshot> userData = FirebaseFirestore.instance
        .collection(CollectionName.ChatUsers)
        .orderBy(FirebaseKey.uname)
        .startAt([
      queryString,
    ]).endAt([
      queryString + '\uf8ff',
    ]).snapshots();

    Stream<QuerySnapshot> groupData = FirebaseFirestore.instance
        .collection(CollectionName.ChatGroups)
        .orderBy(FirebaseKey.group_name)
        .startAt([
      queryString,
    ]).endAt([
      queryString + '\uf8ff',
    ]).snapshots();
    return rx.Rx.combineLatest2(userData, groupData, (a, b) {
      List<SearchModel> searchList = [];
      QuerySnapshot udata = a as QuerySnapshot;
      QuerySnapshot gdata = b as QuerySnapshot;
      udata.docs.forEach((element) {
        if (element[FirebaseKey.uId] != app.userId) {
          searchList.add(SearchModel(
            id: element[FirebaseKey.uId],
            name: element[FirebaseKey.uname],
            photo: element[FirebaseKey.profilepic],
            status: element[FirebaseKey.pStatus],
            isGroup: false,
          ));
        }
      });
      gdata.docs.forEach((element) {
        searchList.add(SearchModel(
          id: element[FirebaseKey.group_id],
          name: element[FirebaseKey.group_name],
          photo: element[FirebaseKey.group_photo],
          status: element[FirebaseKey.desc],
          isGroup: true,
        ));
      });
      return searchList;
    });
  }

  Future<QuerySnapshot> getChatbyId(String id, bool isGroup) async {
    if (isGroup) {
      print("getCh+atbyId GROUP= " + id);
      return FirebaseFirestore.instance
          .collection(CollectionName.Chats)
          .where(FirebaseKey.chatId, isEqualTo: id)
          .get();
    } else {
      print("getChatbyId PERSONAL= " + id);
      return FirebaseFirestore.instance
          .collection(CollectionName.Chats)
          .where(FirebaseKey.displayUsers, arrayContains: id)
          .get();
    }
  }

  Future<void> deleteConversation(Chats chats) async {
    try {
      await FirebaseFirestore.instance
          .collection(CollectionName.Chats)
          .doc(chats.chatId)
          .update({
        FirebaseKey.chatDeleteFor: FieldValue.arrayUnion([app.userId])
      });
      if (chats.isGroup) {
        chats.unReadFlag.removeWhere((key, value) {
          return key == app.userId;
        });
        await FirebaseFirestore.instance
            .collection(CollectionName.Chats)
            .doc(chats.chatId)
            .update({
          FirebaseKey.displayUsers: FieldValue.arrayRemove([app.userId]),
          FirebaseKey.unReadFlag: chats.unReadFlag,
        });
        await FirebaseFirestore.instance
            .collection(CollectionName.Chats)
            .doc(chats.chatId)
            .collection(CollectionName.ChatMembers)
            .doc(app.userId)
            .delete();
      } else {
        await FirebaseFirestore.instance
            .collection(CollectionName.Chats)
            .doc(chats.chatId)
            .collection(CollectionName.ChatMembers)
            .doc(app.userId)
            .set({
          FirebaseKey.isArchive: false,
          FirebaseKey.isDeleted: false,
          FirebaseKey.isFavorite: false,
          FirebaseKey.startDate: Timestamp.now(),
          FirebaseKey.typing: false,
          FirebaseKey.uId: app.userId,
          FirebaseKey.unReadCount: 0,
        });
      }
    } catch (e) {
      printError(info: e.toString());
    }
    update();
  }

  Future<void> updateStared(
    Chats chats,
  ) async {
    try {
      FirebaseFirestore.instance
          .collection(CollectionName.Chats)
          .doc(chats.chatId)
          .collection(CollectionName.ChatMembers)
          .doc(app.userId)
          .get()
          .then((value) {
        ChatMembers members = ChatMembers.fromDoc(value);
        print("CHATMEMBERS = " + members.toJson().toString());
        members.isFavorite
            ? FirebaseFirestore.instance
                .collection(CollectionName.Chats)
                .doc(chats.chatId)
                .collection(CollectionName.ChatMembers)
                .doc(app.userId)
                .set({FirebaseKey.isFavorite: false}, SetOptions(merge: true))
            : FirebaseFirestore.instance
                .collection(CollectionName.Chats)
                .doc(chats.chatId)
                .collection(CollectionName.ChatMembers)
                .doc(app.userId)
                .set({FirebaseKey.isFavorite: true}, SetOptions(merge: true));
      });
    } catch (e) {
      printError(info: e.toString());
    }
  }

  Future<void> updateArchive(
    Chats chats,
  ) async {
    try {
      FirebaseFirestore.instance
          .collection(CollectionName.Chats)
          .doc(chats.chatId)
          .collection(CollectionName.ChatMembers)
          .doc(app.userId)
          .get()
          .then((value) {
        ChatMembers members = ChatMembers.fromDoc(value);
        print("CHATMEMBERS = " + members.toJson().toString());
        members.isArchive
            ? FirebaseFirestore.instance
                .collection(CollectionName.Chats)
                .doc(chats.chatId)
                .collection(CollectionName.ChatMembers)
                .doc(app.userId)
                .set({FirebaseKey.isArchive: false}, SetOptions(merge: true))
            : FirebaseFirestore.instance
                .collection(CollectionName.Chats)
                .doc(chats.chatId)
                .collection(CollectionName.ChatMembers)
                .doc(app.userId)
                .set({FirebaseKey.isArchive: true}, SetOptions(merge: true));
      });
    } catch (e) {
      printError(info: e.toString());
    }
  }

  Future<void> forwardMsg(List<String> chatIds, Messages messages) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(CollectionName.Chats)
          .where(FirebaseKey.displayUsers, arrayContains: app.userId)
          .get();
      List<Chats> chat =
          querySnapshot.docs.map((e) => Chats.fromDoc(e)).toList();
      print(chat.toString());
      List<Chats> temp = [];
      for (String id in chatIds) {
        temp = chat.where((element) => element.chatId == id).toList();
        for (Chats element in temp) {
          print(element.toJson());
          await addNewMsg(messages.msg, messages.msgType, element);
        }
      }
    } catch (e) {
      printError(info: e.toString());
    }
  }

  Widget dummyListViewCell() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 48.0,
            height: 48.0,
            color: Colors.white,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  height: 8.0,
                  color: Colors.white,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.0),
                ),
                Container(
                  width: double.infinity,
                  height: 8.0,
                  color: Colors.white,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.0),
                ),
                Container(
                  width: 40.0,
                  height: 8.0,
                  color: Colors.white,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

}
