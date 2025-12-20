class UserModel {
  final String id;
  final String name;
  final String? email;

  const UserModel({required this.id, required this.name, this.email});

  UserModel copyWith({String? name, String? email}) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }
}
