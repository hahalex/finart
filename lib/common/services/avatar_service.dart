// Файл: lib/common/services/avatar_service.dart.
// Назначение: содержит прикладной сервис с бизнес-логикой, фоновой обработкой или интеграциями.

import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AvatarService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickAndSaveAvatar({String? previousPath}) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return null;

    final bytes = await picked.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;

    final resized = img.copyResize(
      decoded,
      width: decoded.width >= decoded.height ? 512 : null,
      height: decoded.height > decoded.width ? 512 : null,
      interpolation: img.Interpolation.average,
    );

    final jpg = Uint8List.fromList(img.encodeJpg(resized, quality: 82));
    final dir = await getApplicationDocumentsDirectory();
    // Имя файла содержит время, чтобы FileImage не показывал старый кэш
    // после сохранения новой аватарки.
    final file = File(
      p.join(
        dir.path,
        'profile_avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ),
    );
    await file.writeAsBytes(jpg, flush: true);
    await removeAvatar(previousPath);
    return file.path;
  }

  Future<void> removeAvatar(String? currentPath) async {
    if (currentPath == null || currentPath.isEmpty) return;
    final file = File(currentPath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
