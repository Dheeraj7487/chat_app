import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../Controller/all_contact_controller.dart';
import '../Models/chatusers.dart';
import '../Themes/mythemes.dart';

class CreateGroup extends StatefulWidget {
  static const routeName = '/select-group-user';
  const CreateGroup({Key? key}) : super(key: key);

  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  bool isSelect = false;
  final ImagePicker imagePicker = ImagePicker();
  TextEditingController textController = TextEditingController();
  XFile? _image;
  String _image2 = '';
  final _controller = Get.put(AllContactController());
  List<ChatUser> profiles = [];
  List<String> selectedIds = [];
  var _chars =
      'AaBbCcDdE eFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();
  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyTheme.lightTheme.primaryColor,
        toolbarHeight: 100,
        centerTitle: false,
        title: Text(
          'New Group',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
          elevation: 0.0,
          child: Icon(
            Icons.done,
            color: Colors.white,
          ),
          backgroundColor: MyTheme.lightTheme.primaryColor,
          onPressed: () {
            if (selectedIds.length >= 2) {
              _controller.startCnv(
                  ids: selectedIds,
                  isGroup: true,
                  groupName: textController.text,
                  imageUrl: _image2);
              Get.back();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Please select atleast 2 user")));
            }
          }),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _showPicker(context),
                  child: CircleAvatar(
                    backgroundColor: MyTheme.lightTheme.primaryColor,
                    radius: 25,
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
                        : Container(
                            decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(50)),
                            width: 50,
                            height: 50,
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.grey[800],
                            ),
                          ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: TextField(
                    controller: textController,
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: 'Enter Group Name'),
                  ),
                ),
              ],
            ),
          ),
          Container(
            // ignore: deprecated_member_use
            color: MyTheme.lightTheme.accentColor,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(
                width: 5,
              ),
              Expanded(
                child: Text(
                  'Add Participants',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(onPressed: () {}, icon: Icon(Icons.search))
            ]),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30))),
              width: double.maxFinite,
              child: StreamBuilder<QuerySnapshot>(
                stream: _controller.getAllContacts(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    profiles = snapshot.data!.docs
                        .map((e) => ChatUser.fromDoc(e))
                        .toList();
                    return ListView.separated(
                      cacheExtent: 400,
                      itemCount: profiles.length,
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(top: 0),
                      physics: BouncingScrollPhysics(),
                      separatorBuilder: (_, __) => Divider(height: 0.5,),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            if (!(selectedIds.contains(profiles[index].uid)))
                              setState(() {
                                selectedIds.add(profiles[index].uid);
                              });
                            else
                              setState(() {
                                selectedIds.removeWhere(
                                    (element) => element == profiles[index].uid);
                              });
                          },
                          child: ListTile(
                            title: Text(
                              profiles[index].name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text('status'),
                            leading: profiles[index].imageUrl.isEmpty
                                ? CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.white,
                                    child: Image.asset(
                                      'assets/images/default_pic.png',
                                    ),
                                  )
                                : CircleAvatar(
                                    radius: 30,
                                    backgroundImage:
                                        NetworkImage(profiles[index].imageUrl),
                                  ),
                            trailing: selectedIds.contains(profiles[index].uid)
                                ? Icon(
                                    Icons.check_circle,
                                    color: MyTheme.lightTheme.primaryColor,
                                  )
                                : Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                  ),
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
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
        // uploadImage();
      });
    }
  }

  _imgFromGallery() async {
    final XFile? _file = await imagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _image = _file;
      // uploadImage();
    });
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

  void uploadImage() async {
    try {
      showLoaderDialog(context);
      String imageName = getRandomString(10);
      var storageReference =
          FirebaseStorage.instance.ref().child('Group/$imageName');
      // ignore: unused_local_variable
      var uploadTask = await storageReference.putFile(File(_image!.path));
      print('File Uploaded');
      await storageReference.getDownloadURL().then((value) {
        setState(() {
          _image2 = value;
        });
      });
      Navigator.pop(context);
      print("IMAGEURL IN PROFILE =" + _image2);
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
