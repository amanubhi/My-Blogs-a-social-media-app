import 'dart:convert';
import 'package:comp_440/customwidgets/custom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

enum TryingTo {
  login,
  createAccount
}

class Authorization extends StatefulWidget {
  Authorization(this.setUser);
  final Function(Map<String,dynamic>) setUser;
  @override
  State<StatefulWidget> createState() {
    return _AuthorizationState();
  }
}

class _AuthorizationState extends State<Authorization> {
  final _baseURL = 'https://advancing-cough.000webhostapp.com/';
  final _customWidgets = CustomWidgets();
  final _formKey = GlobalKey<FormState>();
  var tryingTo = TryingTo.login;

  var firstName = TextEditingController();
  var lastName = TextEditingController();
  var username = TextEditingController();
  var email = TextEditingController();
  var password = TextEditingController();

  var scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _customWidgets.customAppBar(title: 'blog'),
      body: authorizationBody(),
    );
  }

  Future<void> sendCreateAccountData() async {
    final response = await http.post(Uri.parse("${_baseURL}createaccount.php"), body: {
      'first_name' : firstName.text,
      'last_name' : lastName.text,
      'username' : username.text,
      'email' : email.text,
      'password' : password.text,
    });
    var data = json.decode(response.body);
    if(data['isSuccessful']) {
      print('Account Created');
      loginUser();
    }
    else {
      print('${data['errorMsg']}');
    }
  }

  Future<void> loginUser() async {

    final response = await http.post(Uri.parse("${_baseURL}login.php"), body: {
      'username' : username.text,
      'password' : password.text,
    });

    /*
    response.body will contain a map, with values:
    'isSuccessful' : boolean,
    'errorMsg' : String, -- only contains an error if isSuccessful is false
    'user' : Map<String,dynamic> -- pass to User.fromJson to create a user object
     */
    var data = json.decode(response.body);

    if (data['isSuccessful']) {
      widget.setUser(data['user'][0]);
    }
    else {
      print('${data['errorMsg']}');
    }
  }

  Form authorizationBody() {
    return Form(
      key: _formKey,
      child: tryingTo == TryingTo.login ?
          textFieldPortion() :
          SingleChildScrollView(
            controller: scrollController,
            child: Container(
              color: Colors.white,
              child: Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: textFieldPortion()
              ),
            ),
          )
    );
  }

  Container textFieldPortion() {
    var _authorizationChildrenPadding = 30.0;

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Image.asset('assets/Logo.jpg',
              width: tryingTo != TryingTo.createAccount ? 150 : 100,
              height: tryingTo != TryingTo.createAccount ? 150 : 100,
            ),
          ),
          tryingTo == TryingTo.createAccount ?
          Padding(
            padding: EdgeInsets.only(
                left: _authorizationChildrenPadding,
                right: _authorizationChildrenPadding
            ),
            child: TextFormField(
              controller: firstName,
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: CustomWidgets.mainColor)
                ),
                labelText: 'First Name',
              ),
              validator: (text) {
                if(text!.isEmpty || text.contains('\'') || text.contains('\"')) {
                  return 'Must enter valid First Name';
                }
              },
            ),
          ) : Container(),
          tryingTo == TryingTo.createAccount ?
          Padding(
            padding: EdgeInsets.only(
                left: _authorizationChildrenPadding,
                right: _authorizationChildrenPadding
            ),
            child: TextFormField(
              controller: lastName,
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: CustomWidgets.mainColor)
                ),
                labelText: 'Last Name',
              ),
              validator: (text) {
                if(text!.isEmpty || text.contains('\'') || text.contains('\"')) {
                  return 'Must enter valid Last Name';
                }
              },
            ),
          ) : Container(),
          tryingTo == TryingTo.createAccount ?
          Padding(
            padding: EdgeInsets.only(
                left: _authorizationChildrenPadding,
                right: _authorizationChildrenPadding
            ),
            child: TextFormField(
              controller: username,
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: CustomWidgets.mainColor)
                ),
                labelText: 'Username',
              ),
              validator: (text) {
                if(text!.isEmpty) {
                  return 'Must enter valid Username';
                }
                else if(text.contains('\'') || text.contains('\"')) {
                  return 'Username cannot contain \' or \" characters';
                }
              },
              onTap: () {
                scrollController.animateTo(
                    scrollController.position.minScrollExtent,
                    duration: Duration(
                        milliseconds: 200
                    ),
                    curve: Curves.fastOutSlowIn
                );
              }
            ),
          ) : Container(),
          Padding(
            padding: EdgeInsets.only(
                left: _authorizationChildrenPadding,
                right: _authorizationChildrenPadding
            ),
            child: TextFormField(
              controller: tryingTo == TryingTo.login ? username : email,
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: CustomWidgets.mainColor)
                ),
                labelText: tryingTo == TryingTo.login ? 'Username' : 'Email',
              ),
              validator: (text) {
                if(text!.isEmpty /*|| !text.contains('@')*/) {
                  var placeHolder = tryingTo == TryingTo.login ? 'Username' : 'Email';
                  return 'Must enter valid $placeHolder';
                }
                else if(text.contains('\'') || text.contains('\"')) {
                  return 'Email cannot contain \' or \" characters';
                }
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                left: _authorizationChildrenPadding,
                right: _authorizationChildrenPadding
            ),
            child: TextFormField(
              controller: password,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: CustomWidgets.mainColor)
                ),
                labelText: 'Password',
              ),
              validator: (text) {
                if(text!.isEmpty) {
                  return 'Must enter valid password';
                }
                else if(text.contains('\'') || text.contains('\"')) {
                  return 'Password cannot contain \' or \" characters';
                }
              },
              onTap: () {
                scrollController.animateTo(scrollController.position.maxScrollExtent,
                    duration: Duration(
                        milliseconds: 50
                    ),
                    curve: Curves.fastOutSlowIn
                );
              },
            ),
          ),
          tryingTo == TryingTo.createAccount ?
          Padding(
            padding: EdgeInsets.only(
                left: _authorizationChildrenPadding,
                right: _authorizationChildrenPadding
            ),
            child: TextFormField(
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: CustomWidgets.mainColor)
                ),
                labelText: 'Confirm Password',
              ),
              validator: (text) {
                if(text!.isEmpty || password.text != text) {
                  return 'Passwords must match!';
                }
                else if(text.contains('\'') || text.contains('\"')) {
                  return 'Password cannot contain \' or \" characters';
                }
              },
              onTap: () {
                scrollController.animateTo(scrollController.position.maxScrollExtent,
                    duration: Duration(
                        milliseconds: 50
                    ),
                    curve: Curves.fastOutSlowIn
                );
              },
            ),
          ) : Container(),
          Padding(
            padding: EdgeInsets.only(
                left: _authorizationChildrenPadding,
                right: _authorizationChildrenPadding,
                top: _authorizationChildrenPadding / 2
            ),
            child: ElevatedButton(
              onPressed: () {
                if(_formKey.currentState!.validate()) {
                  print('validated');
                  tryingTo == TryingTo.login ? loginUser() : sendCreateAccountData();
                  //DEBUG
                  //_formKey.currentState!.reset();
                }
              },
              child: Text(
                  tryingTo == TryingTo.login ? 'Log in' : 'Create account'
              ),
              style: ButtonStyle(
                  backgroundColor: MaterialStateColor.resolveWith((states) => CustomWidgets.mainColor)
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                left: _authorizationChildrenPadding,
                right: _authorizationChildrenPadding,
                top: _authorizationChildrenPadding / 2,
                bottom: tryingTo == TryingTo.login ? 0 : 200
            ),
            child: TextButton(
              onPressed: () {
                setState(() {
                  tryingTo = (tryingTo == TryingTo.login ? TryingTo.createAccount : TryingTo.login);
                });
                _formKey.currentState!.reset();
              },
              child: Text(
                tryingTo == TryingTo.login ? "Don't have an account? Sign up!" : 'Have an account? Log in!',
                style: TextStyle(
                    color: CustomWidgets.mainColor
                ),),
            ),
          ),
        ],
      ),
    );
  }
}