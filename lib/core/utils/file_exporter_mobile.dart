import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

Future<void> saveAndShareFile({
  required Uint8List bytes,
  required String filename,
  required String mimeType,
  required String shareText,
}) async {
  // 1. Write file to temporary storage first to ensure valid file path on Android/iOS
  final tempDir = await getTemporaryDirectory();
  final filePath = '${tempDir.path}/$filename';
  final file = File(filePath);
  await file.writeAsBytes(bytes, flush: true);

  // 2. Use Printing package for PDF if applicable
  if (mimeType == 'application/pdf') {
    try {
      await Printing.sharePdf(bytes: bytes, filename: filename);
      return;
    } catch (_) {
      // Fallback to Share.shareXFiles if Printing fails
    }
  }

  // 3. Use Share.shareXFiles with real File path
  try {
    await Share.shareXFiles(
      [XFile(file.path, mimeType: mimeType, name: filename)],
      text: shareText,
    ).timeout(
      const Duration(seconds: 15),
      onTimeout: () => ShareResult(filename, ShareResultStatus.dismissed),
    );
  } catch (_) {
    // Ignore share dismissal or intent unavailability on emulators
  }
}
