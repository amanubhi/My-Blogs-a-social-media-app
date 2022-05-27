import 'package:comp_440/authorization/authorization.dart';
import 'package:comp_440/authorization/user.dart';
import 'package:comp_440/blog/home.dart';
import 'package:flutter/material.dart';

class Root extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RootState();
  }

}

class RootState extends State<Root> {
  //TODO: let root access shared preferences to get the value of user - either null or an actual
  User? user;

  @override
  Widget build(BuildContext context) {
    /* we can be sure that this.user will not be null when we pass it to blogpage
        because we would not be entering blogpage if it was */
    return this.user != null ? BlogPage(user: this.user!, logOut: logOut,) : Authorization(setUser);
  }

  void setUser(Map<String,dynamic> json) {
    setState(() {
      this.user = User.fromJson(json, true);
    });
  }

  void logOut() {
    setState(() {
      this.user = null;
    });
    print('User was logged out');
  }


}