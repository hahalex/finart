// Файл: lib/features/profile/providers/user_provider.dart.
// Назначение: объявляет Riverpod-провайдеры для состояния, сервисов и репозиториев.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/providers/database_provider.dart';
import '../data/user_repository.dart';
import '../domain/user_model.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return UserRepository(db);
});

final userProvider = StateNotifierProvider<UserNotifier, AsyncValue<UserModel>>(
  (ref) {
    final repo = ref.watch(userRepositoryProvider);
    return UserNotifier(repo)..loadUser();
  },
);

class UserNotifier extends StateNotifier<AsyncValue<UserModel>> {
  UserNotifier(this._repo) : super(const AsyncValue.loading());

  final UserRepository _repo;

  Future<void> loadUser() async {
    try {
      final user = await _repo.getUser();

      if (user != null) {
        state = AsyncValue.data(user);
        return;
      }

      const newUser = UserModel(id: '1', name: '');
      await _repo.saveUser(newUser);
      state = const AsyncValue.data(newUser);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateProfile({required String name, String? avatarPath}) async {
    final currentUser = state.valueOrNull ?? const UserModel(id: '1', name: '');
    final updatedUser = currentUser.copyWith(
      name: name,
      avatarPath: avatarPath,
    );
    state = AsyncValue.data(updatedUser);
    await _repo.saveUser(updatedUser);
  }
}
