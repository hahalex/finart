import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/database/app_database.dart';
import '../data/user_repository.dart';
import '../domain/user_model.dart';

final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return UserRepository(db);
});

final userProvider = StateNotifierProvider<UserNotifier, UserModel>((ref) {
  final repo = ref.watch(userRepositoryProvider);
  return UserNotifier(repo)..loadUser();
});

class UserNotifier extends StateNotifier<UserModel> {
  final UserRepository _repo;

  UserNotifier(this._repo) : super(UserModel(id: '1', name: '', email: ''));

  Future<void> loadUser() async {
    final user = await _repo.getUser();

    if (user != null) {
      state = user;
    } else {
      final newUser = UserModel(id: '1', name: '', email: '');
      await _repo.saveUser(newUser);
      state = newUser;
    }
  }

  Future<void> updateProfile({
    required String name,
    required String email,
  }) async {
    final updatedUser = state.copyWith(name: name, email: email);
    state = updatedUser;
    await _repo.saveUser(updatedUser);
  }
}
