import 'package:flutter/material.dart';

import '../../Models/app_model.dart';
import '../../Models/messages.dart';
import '../../Themes/mythemes.dart';
// ignore: must_be_immutable
class DeletedMsg extends StatelessWidget {
  Messages messages ;

  DeletedMsg({required this.messages});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: RichText(
        text: TextSpan(
          children: [
            WidgetSpan(
              child: Icon(Icons.crop_square_sharp,
                  color: Colors.grey[300], size: 14),
            ),
            TextSpan(
              text: " This message was deleted.",
              style: TextStyle(
                color: Colors.grey[300],
              ),
            ),
          ],
        ),
      ),
      decoration: BoxDecoration(
        color: messages.sender  == app.userId
            ? MyTheme.lightTheme.primaryColor
        // ignore: deprecated_member_use
            : MyTheme.lightTheme.accentColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft:
          Radius.circular(messages.sender == app.userId ? 12 : 0),
          bottomRight:
          Radius.circular(messages.sender == app.userId ? 0 : 12),
        ),
      ),
      constraints:
      BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
    );
  }
}
