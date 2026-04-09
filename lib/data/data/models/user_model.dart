class UserModel {
  final String uid;
  final String email;
  final bool isAdmin;

  UserModel({
    required this.uid,
    required this.email,
    this.isAdmin = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      isAdmin: data['isAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'isAdmin': isAdmin,
    };
  }
}
