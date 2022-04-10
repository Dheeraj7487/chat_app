import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../Models/app_model.dart';
import '../Models/chats.dart';
import '../collection_name.dart';
import '../firebase_key.dart';
import 'basecontroller.dart';

class BuildComposerController extends BaseController {
  XFile? image;
  var _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();
  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));



  uploadImage(Chats chats) async {
    try {
      String msgId = await sendMedia(1, chats);
      String imageName = getRandomString(10);
      var storageReference =
          FirebaseStorage.instance.ref().child('SentPhotos/$imageName');
      var uploadTask = await storageReference.putFile(File(image!.path));
      print('File Uploaded');
      await storageReference.getDownloadURL().then((value) async {
        await updateMedia(msgId, chats, 1, value);
      });
    } on FirebaseException catch (e) {
      if (e.code == "object_not_found") {
        print("ERROR_REASON=object_not_found");
      } else if (e.code == "unauthorized") {
        print("ERROR_REASON=unauthorized");
      } else if (e.code == "canceled") {
        print("ERROR_REASON=canceled");
      } else if (e.code == "unknown") {
        print("ERROR_REASON=unknown");
      }
    }
  }

  uploadVideo(Chats chats) async {
    try {
      String msgId = await sendMedia(2, chats);
      String videoName = getRandomString(10);
      var storageReference =
          FirebaseStorage.instance.ref().child('SentPhotos/$videoName');
      var uploadTask = await storageReference.putFile(File(image!.path));
      print('File Uploaded');
      await storageReference.getDownloadURL().then((value) async {
        await updateMedia(msgId, chats, 2, value);
      });
    } on FirebaseException catch (e) {
      if (e.code == "object_not_found") {
        print("ERROR_REASON=object_not_found");
      } else if (e.code == "unauthorized") {
        print("ERROR_REASON=unauthorized");
      } else if (e.code == "canceled") {
        print("ERROR_REASON=canceled");
      } else if (e.code == "unknown") {
        print("ERROR_REASON=unknown");
      }
    }
  }

  // uploadAudio(String pathToAudio, Chats chats) async {
  //   try {
  //     String imageName = getRandomString(10);
  //     var storageReference =
  //         FirebaseStorage.instance.ref().child('Audios/$imageName');
  //     await storageReference.putFile(File(pathToAudio));
  //     print('File Uploaded');
  //     await storageReference.getDownloadURL().then((value) async {
  //       await addNewMsg(value, 3, chats);
  //     });
  //   } on FirebaseException catch (e) {
  //     if (e.code == "object_not_found") {
  //       print("ERROR_REASON=object_not_found");
  //     } else if (e.code == "unauthorized") {
  //       print("ERROR_REASON=unauthorized");
  //     } else if (e.code == "canceled") {
  //       print("ERROR_REASON=canceled");
  //     } else if (e.code == "unknown") {
  //       print("ERROR_REASON=unknown");
  //     }
  //   }
  // }

  Future<void> updateTypingStatus(bool status) async {
    try {
      await FirebaseFirestore.instance
          .collection(CollectionName.Chats)
          .doc(chatsData.chatId)
      .collection(CollectionName.ChatMembers).doc(app.userId)
          .set({
        FirebaseKey.typing: status
      }, SetOptions(merge: true));
    } catch (e) {
      printError(info: e.toString());
    }
  }
}
