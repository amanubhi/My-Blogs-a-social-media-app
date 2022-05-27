import 'dart:convert';
import 'package:comp_440/authorization/user.dart';
import 'package:comp_440/blog/blog.dart';
import 'package:flutter/material.dart';
import '../customwidgets/searchbar.dart';
import 'package:http/http.dart' as http;


class FollowerPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return FollowerPageState();
  }
}

class FollowerPageState extends State<FollowerPage>{
  var userid = 'usernames';
  var blogLookUp = 'blogid';
  var random;
  var searchbar = SearchBar();
  final _baseURL = 'https://advancing-cough.000webhostapp.com/';
  List<User> userList = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    searchQuery();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: thisBody()
    );
  }

  Widget thisBody() {
    return Padding(
      padding: EdgeInsets.only(bottom: 25),
      child: ListTileTheme(
        contentPadding: EdgeInsets.all(15),
        iconColor: Colors.purple,
        textColor: Colors.black87,
        tileColor: Colors.limeAccent,
        style: ListTileStyle.list,
        dense: true,
        child: ListView.builder(
          itemCount: userList.length + 1,
          itemBuilder: (_, index) {
            if (index == 0) {

              return searchbar.build(searchQuery: searchQuery, defaultTitle: 'Have Not Commented');
            }
            else {
              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text('${userList[index - 1].username}',
                      style: TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold)),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> searchQuery() async {
    var text = searchbar.searchController.text;
    String? delimiter;
    var searchType;
    if (text.contains('@')) {
      delimiter = '@';
      searchType = 'usernames';
    }
    else if (text.contains('-')) {
      searchType = 'pdate';
    }
    else if (text.isEmpty) {
      searchType = 'default';
    }
    text = text.replaceAll(' ', '').replaceAll(RegExp(r','), '').replaceFirst(RegExp('@'), '');
    var textArray = text.split('$delimiter');
    print(text);
    print(textArray);
    var response = await http.post(Uri.parse('${_baseURL}users.php'),
        body: jsonEncode(
            {
              'searchType': '$searchType',
              'usernames': searchType == 'usernames' ? textArray : [],
              'pdate': searchType == 'pdate' ? text : '',
            }
        )
    );
    print('here------------------->${response.body}');
    var data = jsonDecode(response.body);
    if(data['didUserRetrievalSucceed']) {

      // creating users
      List<User> users = [];
      data['users'].forEach((var user) {
        print(user);
        users.add(
            User.fromJson(user, false));
      });
      setState(() {
        userList = users;
      });
      /* DEBUG */
      print("USERS RETRIEVED");
    }
    else {
      setState(() {
        userList.clear();
      });
    }
  }


}