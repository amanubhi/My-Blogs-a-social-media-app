import 'package:comp_440/blog/home.dart';
import 'package:comp_440/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:comp_440/blog/blog.dart';
import 'package:comp_440/blog/addblog.dart';

import '../authorization/user.dart';

enum Status {
  signedIn,
  notSignedIn
}

class CustomWidgets {
  static const mainColor = Color.fromARGB(225, 25, 224, 201);
  static const accentColor = Colors.white;

  AppBar customAppBar({required String title,bool leading = false, IconData? leadingType, bool trailing = false, IconData? trailingType, BuildContext? context, Function(Blog)? setBlog, Function()? refreshComments, User? user, VoidCallback? logOut}) {

    var actionSize = 25.0;

    return AppBar(
      backgroundColor: mainColor,
      centerTitle: true,
      elevation: 0,
      leading: (leading && leadingType != null) ? GestureDetector(
        child: Icon(
          leadingType,
          color: accentColor,
          size: actionSize,
        ),
        onTap: () {
          //TODO: implement settings or back button depending on leadingType
          if (context != null) {
            if (leadingType == Icons.settings) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Settings(logOut: logOut!,context: context,)));
            }
            else if (leadingType == Icons.arrow_back) {
              Navigator.pop(context);
            }
          }
          else {
            throw Exception('Context was not provided');
          }
        },
      ) : Container(),
      title: Text('$title',
                  style: TextStyle(
                    fontSize: 23
                  ),),
      actions: [
        if (trailing && trailingType != null) Padding(
          padding: EdgeInsets.only(right: 15),
          child: GestureDetector(
            child: Icon(
              trailingType,
              color: accentColor,
              size: actionSize
            ),
          onTap: () {
              if (trailingType == Icons.add_circle_outline_rounded) {
                if (setBlog != null && context != null && user != null) {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => AddBlog(setBlog: setBlog, user: user,)));
                }
              }
              else if(trailingType == Icons.refresh && refreshComments != null){
                refreshComments();
              }
          },
          ),
        ) else Container()
      ],
    );
  }
}