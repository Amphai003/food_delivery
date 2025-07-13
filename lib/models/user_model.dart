class User {
  final String name;
  final String email;
  final String? tagline; // Added tagline
  final String? profileImageUrl; // Added profileImageUrl

  User({
    required this.name,
    required this.email,
    this.tagline,
    this.profileImageUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      email: json['email'],
      tagline: json['tagline'],
      profileImageUrl: json['profileImageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'tagline': tagline,
      'profileImageUrl': profileImageUrl,
    };
  }
}