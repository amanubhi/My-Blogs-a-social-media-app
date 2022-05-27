import 'dart:convert';

import 'package:comp_440/authorization/user.dart';
import 'package:comp_440/blog/blog.dart';
import 'package:comp_440/blog/home.dart';
import 'package:comp_440/customwidgets/custom_widgets.dart';
import 'package:flutter/material.dart';
import 'comment.dart';
import 'package:http/http.dart' as http;

enum PostType {
  get,
  post
}

enum Sentiment {
  positive,
  negative
}

class CommentPage extends StatefulWidget {
  late final Blog blog;
  late final User user;
  CommentPage({required this.blog, required this.user});

  @override
  State<StatefulWidget> createState() {
    return CommentPageState();
  }

}

class CommentPageState extends State<CommentPage> {
  List<Comment> commentList = [];
  
  var customWidgets = CustomWidgets();
  var sentiment = Sentiment.positive;
  var commentController = TextEditingController();
  final _baseURL = 'https://advancing-cough.000webhostapp.com/';
  @override

  @override
  void initState() {
    super.initState();
    pingComments();
  }

  Future<void> pingComments({PostType postType = PostType.get, Comment? comment}) async {
    http.Response response = http.Response('', 200);
    if (postType == PostType.get) {
      response = await http.post(Uri.parse('${_baseURL}comments.php'),
      body: {
        'postType' : 'get',
        'blogid' : '${widget.blog.blogid}'
      });
    }
    else if (postType == PostType.post && comment != null) {
      response = await http.post(Uri.parse('${_baseURL}comments.php'),
          body: {
            'postType' : 'post',
            'blogid' : '${comment.blogid}',
            'sentiment' : '${comment.sentiment}',
            'description' : '${comment.description}',
            'cdate' : '${comment.cdate}',
            'authorid' : '${comment.authorid}',
          });
      print('here------------------------------------------------------> ${response.body}');
      var data = json.decode(response.body);
      if(data['didPostSucceed']) {
        // post was successful
        print('comment was posted');
        commentController.clear();
      }
      else {
        print(data['errorMsgPost']);
      }
    }
    // creating comment objects from received comments
    var data = json.decode(response.body);
    List<Comment> list = [];
    if (data['didCommentRetrievalSucceed']) {
      data['comments'].forEach((var comment) {
        list.add(Comment.fromJson(comment));
      });
      setState(() {
        commentList = list;
      });
      /* DEBUG */
      print('Comments retrieved');
    }
    else {
      print(data['errorMsgGet']);
    }
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customWidgets.customAppBar(
        title: widget.blog.subject,
        leading: true,
        leadingType: Icons.arrow_back,
        trailing: true,
        trailingType: Icons.refresh,
        context: context,
        refreshComments: pingComments
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            color: Colors.limeAccent,
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              title: Text('${widget.blog.subject}',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              subtitle: Text('${widget.blog.description}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal, color: Colors.black)),
              ),
            ),
          Divider(
              color: Colors.black26,
            ),
          Expanded(
            child: ListView.separated(
                itemBuilder: (context, index) =>
                  commentCard(commentList[index]),
                separatorBuilder: (context, index) => Divider(
                  color: Colors.black26,
                ),
                itemCount: commentList.length),
          ),
          commentTextField()
        ]
      ),
    );
  }

  Widget commentCard(Comment comment) {
    IconData icon = comment.sentiment == 'positive' ? Icons.thumb_up : Icons.thumb_down;
    return Card(
      child:
        ListTile(
          title: Text('${comment.description}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
              color: icon == Icons.thumb_up ? Colors.blue : Colors.red,)
            ],
          ),
        ),
    );
  }

  Widget commentTextField() {
    return Row(
      children: [
        Expanded(
          child: Container(
            constraints: BoxConstraints(maxHeight: 200),
            child: TextField(
              controller: commentController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Comment',
                border: OutlineInputBorder(borderSide: BorderSide.none),
                prefixIcon: IconButton(
                  onPressed: (){
                    setState(() {
                      if(sentiment == Sentiment.positive) {
                        sentiment = Sentiment.negative;
                      }
                      else {
                        sentiment = Sentiment.positive;
                      }
                    });
                  },
                  icon: Icon(sentiment == Sentiment.positive ? Icons.thumb_up : Icons.thumb_down,
                  color: sentiment == Sentiment.positive ? Colors.lightBlueAccent : Colors.redAccent,),
                )
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 10),
          child: IconButton(
              onPressed: () {
                if (commentController.text.isNotEmpty) {
                  // prepping comment values
                  var sentiment = this.sentiment == Sentiment.positive ? 'positive' : 'negative';
                  var now = DateTime.now();
                  var dateTime = DateTime(now.year, now.month, now.day);
                  var date = dateTime.toString().split(' ')[0];
                  // creating comment object
                  var comment = Comment(
                    sentiment: sentiment,
                    description: commentController.text,
                    authorid: widget.user.id,
                    cdate: date,
                    blogid: widget.blog.blogid
                  );
                  // posting comment
                  pingComments(postType: PostType.post, comment: comment);
                }
                else {
                  //TODO: tell user comment is empty
                  print('textfield is empty!!!');
                }
              },
              icon: Icon(Icons.send,
              color: Colors.blue,)
          ),
        )
      ],
    );
  }
}