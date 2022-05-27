class Blog {
  int? blogid;
  var subject;
  var description;
  var pdate;
  var userid;
  var tags;

  Blog({this.blogid,
        required this.subject,
        required this.description,
        required this.pdate,
        required this.userid,
        required this.tags});

  factory Blog.fromJson({required Map<String, dynamic> json, String tags = ''}) {
    tags = tags.replaceAll(' ', '').replaceAll(RegExp(r','), ' #').trimLeft();
    print(tags);
    return Blog(
      blogid: int.parse(json['blogid']),
      subject: json['subject'],
      description: json['description'],
      pdate: json['pdate'],
      userid: int.parse(json['userid']),
      tags: tags
    );
  }
}

