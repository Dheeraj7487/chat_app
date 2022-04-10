import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../Controller/buildcomposercontroller.dart';
import '../Models/chatgroups.dart';
import '../Models/chatmembers.dart';
import '../Models/chats.dart';
import '../Themes/mythemes.dart';

class BuildChatComposer extends StatefulWidget {
  Chats chats;
  ChatGroups? chatGroups;
  ChatMembers members;
  BuildChatComposer(
      {required this.chats, this.chatGroups, required this.members});

  @override
  State<BuildChatComposer> createState() => _BuildChatComposerState();
}

class _BuildChatComposerState extends State<BuildChatComposer> {
  final ImagePicker imagePicker = ImagePicker();
  final TextEditingController textController = TextEditingController();
  final _composerController = Get.put(BuildComposerController());
  @override
  Widget build(BuildContext context) {
    _composerController.chatGroup = widget.chatGroups!;
    _composerController.chatMember = widget.members;
    return Container(
      height: 100,
      padding: EdgeInsets.symmetric(horizontal: 10),
      color: Colors.white,
      child: Row(children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                PopupMenuButton(
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem(
                        child: Text('Camera'),
                        onTap: () {
                          _imgFromCamera();
                        },
                      ),
                      PopupMenuItem(
                        child: Text('Photos'),
                        onTap: () {
                          _imgFromGallery();
                        },
                      ),
                      PopupMenuItem(
                        child: Text('Video'),
                        onTap: () {
                          _videoFromGallery();
                        },
                      ),
                    ];
                  },
                ),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Type your message',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                    ),
                    onChanged: (value) {
                      _composerController.updateTypingStatus(true);
                      Future.delayed(Duration(milliseconds: 800))
                          .whenComplete(() {
                        _composerController.updateTypingStatus(false);
                      });
                    },
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.mic,
                    color: Colors.grey[500],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    String msg = textController.text;
                    textController.text = '';
                    if (msg != '')
                      await _composerController.addNewMsg(msg, 0, widget.chats);
                  },
                  child: CircleAvatar(
                    backgroundColor: MyTheme.lightTheme.primaryColor,
                    radius: 20,
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ]),
    );
  }

  _imgFromGallery() async {
    final XFile? _file = await imagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);

    setState(() async {
      _composerController.image = _file;
      if (!_file.isNull) {
        await _composerController.uploadImage(widget.chats);
      }
    });
  }

  _imgFromCamera() async {
    final XFile? _file = await imagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50);

    if (!_file.isNull) {
      setState(() async {
        _composerController.image = _file;
        if (!_file.isNull) {
          await _composerController.uploadImage(widget.chats);
        }
      });
    }
  }

  _videoFromGallery() async {
    final XFile? _file =
        await imagePicker.pickVideo(source: ImageSource.gallery);
    setState(() async {
      _composerController.image = _file;
      if (!_file.isNull) {
        await _composerController.uploadVideo(widget.chats);
      }

    });
  }
}
