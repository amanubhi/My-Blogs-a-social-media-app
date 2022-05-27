import 'dart:convert';

import 'package:comp_440/Follower/FollowerPage.dart';
import 'package:comp_440/authorization/user.dart';
import 'package:comp_440/comments/commentpage.dart';
import 'package:comp_440/customwidgets/searchbar.dart';
import 'package:flutter/material.dart';
import 'package:comp_440/customwidgets/custom_widgets.dart';
import 'package:comp_440/blog/blog.dart';
import 'package:http/http.dart' as http;

enum PostType {
  get,
  post
}
class BlogPage extends StatefulWidget {

  late final User user;
  VoidCallback logOut;
  BlogPage({required this.user, required this.logOut});

  @override
  State<StatefulWidget> createState() {
    return BlogPageState();
  }

}

class BlogPageState extends State<BlogPage> {
  @override
  void initState() {
    super.initState();
    pingBlogs();
  }
  // bottom navigation bar necessities
  var index = 0;
  List<Widget> _children = [];
  // thisBlog necessities
  Blog? blog;
  final _baseURL = 'https://advancing-cough.000webhostapp.com/';
  var customWidgets = CustomWidgets();
  var searchbar = SearchBar();
  var blogList = [];
  // followerPage necessities


  @override
  Widget build(BuildContext context) {
    // populating children before using it
    _children = [thisBody(), FollowerPage()];
    var isBlogPageActive = index == 0;
    return Scaffold(
      appBar: customWidgets.customAppBar(
          title: isBlogPageActive ? 'blog' : 'followers',
          leading: true,
          leadingType: Icons.settings,
          trailing: isBlogPageActive,
          trailingType: isBlogPageActive ? Icons.add_circle_outline_rounded : null,
          context: context,
          setBlog: setBlog,
          user: widget.user,
          logOut: logOut),

      body: _children[index],
      floatingActionButton: isBlogPageActive ? FloatingActionButton(
        child: Icon(Icons.refresh, color: CustomWidgets.accentColor,),
        onPressed: pingBlogs,
        backgroundColor: CustomWidgets.mainColor,
      ) : null,
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.fireplace), label: 'blogs'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'followers')
        ],
        currentIndex: index,
        onTap: (currentIndex) {
          setState(() {
            index = currentIndex;
          });
        },
      ),
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
          itemCount: blogList.length + 1,
          itemBuilder: (_, index) {
            if (index == 0) {

              return searchbar.build(searchQuery: searchQuery, defaultTitle: 'All Blogs');
            }
            else {
              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text('${blogList[index - 1].subject}',
                      style: TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('${blogList[index - 1].description.toString()}',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.normal)),
                      Text('${blogList[index - 1].tags}',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.normal, color: Colors.black54)),
                      Text('${blogList[index - 1].pdate}',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.normal, color: Colors.blueGrey)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) =>
                                    CommentPage(blog: blogList[index - 1],
                                        user: widget.user)));
                          },
                          icon: Icon(Icons.add_comment_rounded)),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
  Future<void> pingBlogs({PostType postType = PostType.get, Blog? blog}) async {
    http.Response response = http.Response('',200);

    // posting or getting depending on postType
    if (postType == PostType.get) {
      response = await http.post(
          Uri.parse('${_baseURL}blogs.php'), body: jsonEncode({'postType': 'get'}));
    }
    else if (postType == PostType.post && blog != null){
      response = await http.post(
          Uri.parse('${_baseURL}blogs.php'),
          body: jsonEncode({
            'postType': 'post',
            'subject' : '${blog.subject}',
            'description' : '${blog.description}',
            'pdate' : '${blog.pdate}',
            'userid' : '${blog.userid}',
            'tags' : blog.tags.replaceAll(RegExp(r'#'), '').split(' ')
          }));
      var data = json.decode(response.body);
      if (data['didPostSucceed']) {
        // post was successful
        print('blog was successfully posted!');
      }
      else {
        print('${data['errorMsgPost']}');
      }
    }
    // display blogs if successfully retrieved
    var data = json.decode(response.body);

    if(data['didBlogRetrievalSucceed']) {
      // create blogs
      var size = data['tags'].length;
      var maxID = int.parse(data['tags'][size-1]['blogid']);
      var tags = List<String>.filled(maxID + 1, '', growable: false);

      // creating tag strings and storing them in tags list where index = blogid
      data['tags'].forEach((var tag) {
        tags[int.parse(tag['blogid'])] = '${tags[int.parse(tag['blogid'])]}, ${tag['tag']}';
      });

      // creating blogs
      var blogs = [];
      data['blogs'].forEach((var blog) {
        print(blog);
        blogs.add(Blog.fromJson(json: blog, tags: tags[int.parse(blog['blogid'])]));
      });
      setState(() {
        blogList = blogs;
      });
      searchbar.searchController.clear();
      /* DEBUG */
      print("BLOGS RETRIEVED");
    }
    else {
      print('${data['errorMsgGet']}');
    }
  }
  Future<void> searchQuery() async {
    var text = searchbar.searchController.text;
    String? delimiter;
    var searchType;
    if (text.contains('#')) {
      delimiter = '#';
      searchType = 'tag';
    }
    else if (text.contains('@')) {
      delimiter = '@';
      searchType = 'username';
    }
    else if (text.contains('-')) {
      searchType = 'pdate';
    }
    text.replaceAll(' ', '');
    var textArray = text.split('$delimiter');
    var response = await http.post(Uri.parse('${_baseURL}specificblog.php'),
    body: jsonEncode(
      {
        'searchType': '$searchType',
        'username': searchType == 'username' ? '${textArray[1]}' : '',
        'tag': searchType == 'tag' ? '${textArray[1]}' : '',
        'pdate': searchType == 'pdate' ? text : '',
      }
    )
    );
    print('here------------------->${response.body}');
    var data = jsonDecode(response.body);
    if(data['didBlogRetrievalSucceed']) {
      // create blogs
      var size = data['tags'].length;
      var maxID = int.parse(data['tags'][size - 1]['blogid']);
      var tags = List<String>.filled(maxID + 1, '', growable: false);

      // creating tag strings and storing them in tags list where index = blogid
      data['tags'].forEach((var tag) {
        tags[int.parse(tag['blogid'])] =
        '${tags[int.parse(tag['blogid'])]}, ${tag['tag']}';
      });

      // creating blogs
      var blogs = [];
      data['blogs'].forEach((var blog) {
        print(blog);
        blogs.add(
            Blog.fromJson(json: blog, tags: tags[int.parse(blog['blogid'])]));
      });
      setState(() {
        blogList = blogs;
      });
      /* DEBUG */
      print("BLOGS RETRIEVED");
    }
    else {
      setState(() {
        blogList.clear();
      });
    }
  }
  //create setBlog method
  void setBlog(Blog blog) {
    setState(() {
      this.blog = blog;
    });
    pingBlogs(postType: PostType.post, blog: blog);
  }

  void logOut() {
    widget.logOut();
  }
}