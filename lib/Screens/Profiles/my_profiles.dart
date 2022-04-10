// ignore_for_file: deprecated_member_use, duplicate_ignore

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../Controller/auth_controller.dart';
import '../../Models/app_model.dart';
import '../../Models/chatusers.dart';
import '../../Themes/mythemes.dart';
import '../../Widgets/UIWidgets/custom_buttom1.dart';
import '../../Widgets/UIWidgets/custom_edittext.dart';

class MyProfiles extends StatefulWidget {
  static const routeName = '/my-profile';
  @override
  State<MyProfiles> createState() => _MyProfilesState();
}

class _MyProfilesState extends State<MyProfiles> {
  XFile? _image;
  final ImagePicker imagePicker = ImagePicker();
  String imageUrl = '';
  String name = '', number = '', pstatus = '';
  static const routeName = '/my-profiles';
  bool isuploaded = false;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: MyTheme.lightTheme.accentColor,
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.black),
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: <Widget>[
              PopupMenuButton<int>(
                onSelected: (item) async {
                  await controller.updateStatus(0);
                  await controller.signOut();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                      value: 0,
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      )),
                ],
              ),
            ],
          ),
          body: StreamBuilder<DocumentSnapshot>(
            stream: controller.getInfo(app.userId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                print("NO DATA FOUND");
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                ChatUser model = ChatUser.fromDoc(snapshot.data!);
                imageUrl = model.imageUrl;
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 50,
                        ),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              _showPicker(context);
                            },
                            child: CircleAvatar(
                              radius: 50,
                              child: _image != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Image.file(
                                        File(_image!.path),
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  // ignore: prefer_is_not_empty
                                  : !(imageUrl.isEmpty)
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          child: Image.network(
                                            imageUrl.isEmpty
                                                ? model.imageUrl
                                                : imageUrl,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Container(
                                          decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(50)),
                                          width: 100,
                                          height: 100,
                                          child: Icon(
                                            Icons.camera_alt,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Change profile picture',
                          style: TextStyle(color: Colors.black, fontSize: 13),
                        ),
                        CustomTextField(
                            label: 'Full name',
                            width: MediaQuery.of(context).size.width,
                            obscureText: false,
                            isEnable: true,
                            initalValue: model.name,
                            onChanged: (value) {
                              name = value;
                            },
                            textInputType: TextInputType.name),
                        CustomTextField(
                            label: 'Phone number',
                            width: MediaQuery.of(context).size.width,
                            isEnable: true,
                            obscureText: false,
                            initalValue: model.number,
                            onChanged: (value) {
                              number = value;
                            },
                            textInputType: TextInputType.number),
                        CustomTextField(
                          label: 'Email',
                          width: MediaQuery.of(context).size.width,
                          isEnable: false,
                          obscureText: false,
                          initalValue: model.email,
                          textInputType: TextInputType.name,
                        ),
                        CustomTextField(
                          label: 'Status',
                          width: MediaQuery.of(context).size.width,
                          isEnable: true,
                          obscureText: false,
                          initalValue: model.pStatus,
                          textInputType: TextInputType.name,
                          onChanged: (value) {
                            pstatus = value;
                          },
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        CustomButton1(
                          onTap: () async {
                            Get.back();
                            await controller.updateInfo(
                                name: name.isEmpty ? model.name : name,
                                number: number.isEmpty ? model.number : number,
                                uId: app.userId,
                                email: model.email,
                                url: imageUrl,
                                pstatus:
                                    pstatus.isEmpty ? model.pStatus : pstatus);
                          },
                          text: 'Save',
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Photo Library'),
                    onTap: () {
                      _imgFromGallery();
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () {
                    _imgFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }

  _imgFromCamera() async {
    final XFile? _file = await imagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50);
    if (!_file.isNull) {
      setState(() async {
        _image = _file;
        if (!_file.isNull) {
          await uploadImage();
        }
      });
    }
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          Container(
              margin: const EdgeInsets.only(left: 7),
              child: const Text("Uploading.....")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _imgFromGallery() async {
    final XFile? _file = await imagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);
    if (!_file.isNull) {
      setState(() async {
        _image = _file;
        if (!_file.isNull) {
          await uploadImage();
        }
      });
    }
  }

  uploadImage() async {
    try {
      showLoaderDialog(context);
      String userId = app.userId;
      var storageReference =
          FirebaseStorage.instance.ref().child('Images/$userId');
      // ignore: unused_local_variable
      var uploadTask = await storageReference.putFile(File(_image!.path));
      await storageReference.getDownloadURL().then((value) {
        imageUrl = value;
        print("IMAGEURL IN PROFILE =" + imageUrl);
      });
      Navigator.pop(context);
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
}
