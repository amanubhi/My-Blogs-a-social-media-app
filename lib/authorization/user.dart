class User {

  final int id;
  final String username;
  final bool? isSignedIn;

  User({
    required this.id,
    required this.username,
    this.isSignedIn
  });

  factory User.fromJson(Map<String, dynamic> json, bool isSignedIn) {
    return User(
      id: int.parse(json['userid']),
      username: json['username'],
      isSignedIn: isSignedIn
    );
  }

}