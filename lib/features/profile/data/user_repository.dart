// Файл: lib/features/profile/data/user_repository.dart.
// Назначение: хранит исходные данные, локальные таблицы или вспомогательный слой данных.

import 'package:drift/drift.dart';

import '../../../common/database/app_database.dart';
import '../domain/user_model.dart';

class UserRepository {
  final AppDatabase _db;

  UserRepository(this._db);

  Future<UserModel?> getUser() async {
    final data = await _db.getUser();
    if (data == null) return null;
    return UserModel(id: data.id, name: data.name, avatarPath: data.avatarPath);
  }

  Future<void> saveUser(UserModel user) async {
    final companion = UserTableCompanion(
      id: Value(user.id),
      name: Value(user.name),
      avatarPath: Value(user.avatarPath),
    );

    await _db.into(_db.userTable).insertOnConflictUpdate(companion);
  }
}
