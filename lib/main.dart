import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'Bindings/chatroom_bindings.dart';
import 'Controller/auth_controller.dart';
import 'Models/chatmembers.dart';
import 'Models/chats.dart';
import 'Screens/Authentication/auth_page.dart';
import 'Screens/Profiles/group_profile.dart';
import 'Screens/Profiles/my_profiles.dart';
import 'Screens/Profiles/opponent_profile.dart';
import 'Screens/about_us.dart';
import 'Screens/add_new_members.dart';
import 'Screens/all_contact.dart';
import 'Screens/chatroom.dart';
import 'Screens/create_group.dart';
import 'Screens/forward_screen.dart';
import 'Screens/reset_password.dart';
import 'Screens/setting.dart';
import 'Themes/mythemes.dart';
import 'Widgets/ChatWidgets/fullVideo.dart';
import 'Widgets/all_archive.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Get.put(AuthController());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: MyTheme.lightTheme,
      initialRoute: "/",
      getPages: [
        GetPage(name: '/', page: () => FirstPage()),
        GetPage(name: AuthPage.routeName, page: () => AuthPage()),
        GetPage(name: MyProfiles.routeName, page: () => MyProfiles()),
        GetPage(name: CreateGroup.routeName, page: () => CreateGroup()),
        GetPage(name: AllContact.routeName, page: () => AllContact()),
        GetPage(
            name: ChatRoom.routeName,
            page: () => ChatRoom(),
            binding: ChatRoomBindings()),
        GetPage(name: FullVideo.routeName, page: () => FullVideo()),
        GetPage(name: OpponentProfile.routeName, page: () => OpponentProfile()),
        GetPage(name: GroupProfile.routeName, page: () => GroupProfile()),
        GetPage(name: AddNewMembers.routeName, page: () => AddNewMembers()),
        GetPage(name: AllArchive.routeName, page: () => AllArchive()),
        GetPage(name: ForwardScreen.routeName, page: () => ForwardScreen()),
        GetPage(name: ResetPassword.routeName, page: () => ResetPassword()),
        GetPage(name: Setting.routeName, page: () => Setting()),
        GetPage(name: AboutUs.routeName, page: () => AboutUs()),
      ],
    );
  }
}

class FirstPage extends StatefulWidget {
  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  final authController = Get.find<AuthController>();

  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    } else {
      print("ERROR IN RECEVING NOTIFICATION");
    }
    await FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  Future<void> _handleMessage(RemoteMessage message) async {
    // print("MESSAGE DATA = " + message.data.toString());
    Chats chats = Chats.fromJson(json.decode(message.data['chats']));
    ChatMembers chatMembers = ChatMembers.fromJson(json.decode(message.data['members']));
    Get.toNamed(
      ChatRoom.routeName,
      arguments: [chats,chatMembers],
    );
  }

  @override
  void initState() {
    super.initState();
    setupInteractedMessage();
  }

  @override
  Widget build(BuildContext context) {
    authController.getCurrentUser();
    return Material(
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
