import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../Controller/main_screen_controller.dart';
import '../../Models/app_model.dart';
import '../../Models/chatgroups.dart';
import '../../Models/chatmembers.dart';
import '../../Models/chats.dart';
import '../../Models/chatusers.dart';
import '../../Screens/chatroom.dart';
import '../../Themes/mythemes.dart';

class ConvList extends StatelessWidget {
  final Chats chats;
  ChatMembers? members;

  ConvList({required this.chats, this.members});

  final _controller = Get.find<MainScreenController>();

  @override
  Widget build(BuildContext context) {
    return chats.isGroup
        ? FutureBuilder<ChatGroups>(
            future: _controller.getGroupInfo(chats.chatId),
            builder: (context, snapshot) {
              print(snapshot.error.toString());
              if (snapshot.hasData) {
                // print("ChatLIST ERROR = group snapshot.hasData");
                ChatGroups model = snapshot.data!;
                // print("GROUPNAME = "+model.name);
                return ChatTile(
                  name: model.name,
                  imageUrl: model.photo,
                  isGroup: chats.isGroup,
                  onTap: () {
                    // print("ONCLICKED");
                    Get.toNamed(
                      ChatRoom.routeName,
                      arguments: [chats, members],
                    );
                  },
                  onLongPress: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return archiveFavorite(
                            chats: chats,
                            members: members!,
                            imageUrl: model.photo,
                            name: model.name,
                            status: model.desc,
                          );
                        });
                  },
                  chats: chats,
                );
              } else
                return Padding(
                  padding: EdgeInsets.all(8),
                  child: Shimmer.fromColors(
                      child: _controller.dummyListViewCell(),
                      baseColor: Colors.grey,
                      highlightColor: Colors.grey),
                );
            },
          )
        : FutureBuilder<ChatUser>(
            future: _controller.getUserInfo(chats.opponentUser),
            builder: (context, snapshot) {
              print(snapshot.error.toString());
              if (snapshot.hasData) {
                print("ChatLIST ERROR =  snapshot.hasData");
                ChatUser model = snapshot.data!;
                print("PROFILENAME = " + model.name);
                return ChatTile(
                  name: model.name,
                  imageUrl: model.imageUrl,
                  isGroup: chats.isGroup,
                  onTap: () {
                    print("ONCLICKED");
                    Get.toNamed(
                      ChatRoom.routeName,
                      arguments: [chats, members],
                    );
                  },
                  onLongPress: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return archiveFavorite(
                            chats: chats,
                            members: members!,
                            imageUrl: model.imageUrl,
                            name: model.name,
                            status: model.pStatus,
                          );
                        });
                  },
                  chats: chats,
                );
              } else {
                return Padding(
                  padding: EdgeInsets.all(8),
                  child: Shimmer.fromColors(
                      child: _controller.dummyListViewCell(),
                      baseColor: Colors.grey,
                      highlightColor: Colors.grey),
                );
              }
            },
          );
  }
}

class ChatTile extends StatelessWidget {
  final _controller = Get.find<MainScreenController>();
  final String name;
  final String imageUrl;
  final bool isGroup;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Chats chats;
  ChatTile(
      {Key? key,
      required this.name,
      required this.imageUrl,
      required this.isGroup,
      required this.onTap,
      required this.onLongPress,
      required this.chats})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("GROUP OR PROFILE NAME = " + name);
    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Colors.white,
        child: _controller.profileImage(imageUrl),
      ),
      title: Text(
        name,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        chats.lastmsg,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            DateFormat.jm().format(chats.createdAt.toDate()),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          StreamBuilder<DocumentSnapshot>(
            stream: _controller.getChatMembersInfo(chats.chatId, app.userId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Text('');
              }
              ChatMembers chatMembers = ChatMembers.fromDoc(snapshot.data!);
              return chatMembers.unReadCount != 0
                  ? Container(
                      width: 25,
                      decoration: BoxDecoration(
                        color: MyTheme.lightTheme.primaryColor,
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(20),
                          right: Radius.circular(20),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          chatMembers.unReadCount.toString(),
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    )
                  : Text('');
            },
          ),
        ],
      ),
    );
  }
}

class archiveFavorite extends StatelessWidget {
  Chats chats;
  ChatMembers members;
  String name;
  String imageUrl;
  String status;
  final _controller = Get.find<MainScreenController>();
  archiveFavorite(
      {required this.chats,
      required this.members,
      required this.name,
      required this.status,
      required this.imageUrl});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: _controller.profileImage(imageUrl),
                ),
                SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: FlatButton(
              child: Text(
                members.isArchive ? 'unArchive' : 'Archive',
                style: TextStyle(fontSize: 15.0),
              ),
              onPressed: () async {
                await _controller.updateArchive(chats);
                Navigator.pop(context);
              },
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: FlatButton(
              child: Text(
                members.isFavorite ? 'unFavorite' : 'Favorite',
                style: TextStyle(fontSize: 15.0),
              ),
              onPressed: () async {
                await _controller.updateStared(chats);
                Navigator.pop(context);
              },
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: FlatButton(
              child: Text(
                'Delete Chat',
                style: TextStyle(fontSize: 15.0),
              ),
              onPressed: () async {
                await _controller.deleteConversation(chats);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
