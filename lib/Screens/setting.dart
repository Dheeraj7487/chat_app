import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'about_us.dart';

class Setting extends StatelessWidget {
  const Setting({Key? key}) : super(key: key);
  static const routeName = '/setting-page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 100,
        title: Text('Setting'),
      ),
      body: Container(
        child: Column(
          children: [
            InkWell(
              onTap: () {

              },
              child: ListTile(
                leading: Icon(Icons.brightness_6),
                title: Text(
                  'Change Theme',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.wallpaper_rounded),
              title: Text(
                'Change Wallpepar',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.notifications_active),
              title: Text(
                'Notification setting',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.sports_basketball_rounded),
              title: Text(
                'App Language',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Divider(),
            InkWell(
              onTap: () {
                Get.toNamed(AboutUs.routeName);
              },
              child: ListTile(
                leading: Icon(Icons.info),
                title: Text(
                  'About us',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
