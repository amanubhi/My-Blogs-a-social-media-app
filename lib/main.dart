import 'package:comp_440/customwidgets/custom_widgets.dart';
import 'package:flutter/material.dart';
import 'Follower/followerpage.dart';
import 'authorization/root.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final customWidgets = CustomWidgets();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Root()
    );
  }

}