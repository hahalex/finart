/// Мок-данные пользователя
/// Позже будут приходить с backend

class UserProfile {
  final String name;
  final String email;

  const UserProfile({required this.name, required this.email});
}

/// Пример пользователя
const UserProfile mockUserProfile = UserProfile(
  name: 'Алексей',
  email: 'alexey@example.com',
);
