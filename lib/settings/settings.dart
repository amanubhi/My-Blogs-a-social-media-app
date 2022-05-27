import 'dart:convert';
import 'dart:math';

import 'package:comp_440/customwidgets/custom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Settings extends StatelessWidget {

  VoidCallback logOut;
  BuildContext context;
  Settings({required this.logOut, required this.context});
  final customWidgets = CustomWidgets();
  final _baseURL = 'https://advancing-cough.000webhostapp.com/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customWidgets.customAppBar(
        title: 'settings',
        leading: true,
        leadingType: Icons.arrow_back,
        context: context
      ),
      body: settingsBody(),
    );
  }
  Future<void> initializeDatabase() async{
    var response = await http.post(Uri.parse('${_baseURL}initializedatabase.php'));
    var data = json.decode(response.body);
    if(data['isSuccessful']) {
      print('database initialized!');
    }
    else {
      print('some kind of error happened');
    }
  }
  void logUserOut() {
    logOut();
    Navigator.pop(context);
  }
  Column settingsBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,

      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                ElevatedButton(
                  onPressed: initializeDatabase,
                  child: Text(
                    'Initialize Database',
                    style: TextStyle(fontSize: 15),),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.red
                      )
                  )
              ),
              ElevatedButton(
                  onPressed: logUserOut,
                  child: Text(
                    'Sign Out',
                    style: TextStyle(fontSize: 15),),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Color.fromARGB(255,77, 19, 209)
                      )
                  )
              ),
            ]
          ),
        )
      ],
    );
  }
}