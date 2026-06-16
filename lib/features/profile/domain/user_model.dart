// Файл: lib/features/profile/domain/user_model.dart.
// Назначение: описывает доменные модели и вычисления, которыми пользуются экраны и сервисы.

class UserModel {
  static const _unset = Object();

  final String id;
  final String name;
  final String? avatarPath;

  const UserModel({required this.id, required this.name, this.avatarPath});

  UserModel copyWith({String? name, Object? avatarPath = _unset}) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      avatarPath: identical(avatarPath, _unset)
          ? this.avatarPath
          : avatarPath as String?,
    );
  }
}
