class Comment {
  
  int? commentid;
  var sentiment;
  var description;
  var cdate;
  var blogid;
  var authorid;
  
  Comment({
    this.commentid,
    required this.sentiment,
    required this.description,
    required this.cdate,
    required this.blogid,
    required this.authorid
  });
  
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      commentid: int.parse(json['commentid']),
      sentiment: json['sentiment'],
      description: json['description'],
      cdate: json['cdate'],
      blogid: int.parse(json['blogid']),
      authorid: int.parse(json['authorid'])
    );
  }
}