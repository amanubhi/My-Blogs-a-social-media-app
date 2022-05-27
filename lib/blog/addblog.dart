import 'package:comp_440/authorization/user.dart';
import 'package:flutter/material.dart';
import '../customwidgets/custom_widgets.dart';
import 'blog.dart';

class AddBlog extends StatelessWidget{
  late final Function(Blog) setBlog;
  late final User user;
  AddBlog({required this.setBlog, required this.user});
  var customWidgets = CustomWidgets();
  var _authorizationChildrenPadding = 30.0;
  var subjectController = TextEditingController();
  var descriptionController = TextEditingController();
  var tagsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: customWidgets.customAppBar(
        title: 'New Blog',
        leading: true,
        leadingType: Icons.arrow_back,
        context: context,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
        Padding(
        padding: EdgeInsets.only(
            left: _authorizationChildrenPadding,
            right: _authorizationChildrenPadding
        ),
        child: TextFormField(
          controller: subjectController,
          decoration: InputDecoration(
            border: UnderlineInputBorder(),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: CustomWidgets.mainColor)
            ),
            labelText: 'Subject',
          ),
          validator: (text) {
            if(text!.isEmpty || text.contains('\'') || text.contains('\"')) {
              return 'Must enter valid Subject name';
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
                controller: descriptionController,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: CustomWidgets.mainColor)
                  ),
                  labelText: 'Description',
                ),
                validator: (text) {
                  if(text!.isEmpty || text.contains('\'') || text.contains('\"')) {
                    return 'Must enter valid Description Name';
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
                controller: tagsController,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: CustomWidgets.mainColor)
                  ),
                  labelText: 'Tags',
                ),
                validator: (text) {
                  if(text!.isEmpty || text.contains('\'') || text.contains('\"')) {
                    return 'Must enter valid Tags Name';
                  }
                },
              ),
            ),
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
                    var subject = subjectController.text;
                    var description = descriptionController.text;
                    var tags = tagsController.text;
                    var now = DateTime.now();
                    var dateTime = DateTime(now.year, now.month, now.day);
                    var date = dateTime.toString().split(' ')[0];
                    var blog = Blog(description: description, subject: subject, tags: tags, userid: this.user.id, pdate: date);
                    setBlog(blog);
                    _formKey.currentState!.reset();
                    Navigator.pop(context);
                  }
                },
                child: Text(
                    'Submit',
                ),
                style: ButtonStyle(
                    backgroundColor: MaterialStateColor.resolveWith((states) => CustomWidgets.mainColor)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}