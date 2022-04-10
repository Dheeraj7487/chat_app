import 'package:flutter/gestures.dart';
import 'package:get/get.dart';

import '../Controller/chatroom_controller.dart';
import '../Models/chatmembers.dart';
import '../Models/chats.dart';

class ChatRoomBindings extends Bindings
{
  @override
  void dependencies() {
    Chats chats = Get.arguments[0];
    ChatMembers members = Get.arguments[1];

    Get.lazyPut<ChatRoomController>(
            () => ChatRoomController(chats: chats,appUser: members));
  }

}