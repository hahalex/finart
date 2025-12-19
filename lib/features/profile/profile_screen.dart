// import 'package:flutter/material.dart';

// import 'mock_profile.dart';
// import 'widgets/profile_action_tile.dart';

// /// Экран "Профиль"
// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final user = mockUserProfile;

//     return SafeArea(
//       child: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           /// Аватар + имя
//           Column(
//             children: [
//               const CircleAvatar(
//                 radius: 40,
//                 child: Icon(Icons.person, size: 40),
//               ),
//               const SizedBox(height: 12),
//               Text(user.name, style: Theme.of(context).textTheme.titleLarge),
//               const SizedBox(height: 4),
//               Text(user.email, style: Theme.of(context).textTheme.bodyMedium),
//             ],
//           ),

//           const SizedBox(height: 32),

//           /// Действия
//           ProfileActionTile(
//             icon: Icons.edit,
//             title: 'Изменить профиль',
//             onTap: () {},
//           ),
//           ProfileActionTile(
//             icon: Icons.lock,
//             title: 'Сменить пароль',
//             onTap: () {},
//           ),
//           ProfileActionTile(
//             icon: Icons.settings,
//             title: 'Настройки',
//             onTap: () {},
//           ),

//           const SizedBox(height: 16),

//           /// Выход
//           ProfileActionTile(icon: Icons.logout, title: 'Выйти', onTap: () {}),
//         ],
//       ),
//     );
//   }
// }
