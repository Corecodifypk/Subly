import 'dart:io';

import 'package:image/image.dart' as img;

/// Fixes splash logo assets: removes black corner pixels and exports an
/// icon-only crop for the Flutter splash (no baked-in title / white card).
Future<void> main() async {
  const source = 'assets/images/splash_logo.png';
  final bytes = await File(source).readAsBytes();
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    stderr.writeln('Failed to decode $source');
    exit(1);
  }

  final fixed = _replaceBlackCorners(decoded);
  await File(source).writeAsBytes(img.encodePng(fixed));

  final icon = _cropIconOnly(fixed);
  const iconPath = 'assets/images/splash_icon.png';
  await File(iconPath).writeAsBytes(img.encodePng(icon));

  await _syncNativeAssets(icon);

  stdout.writeln('Updated $source, $iconPath, and native launch assets.');
}

img.Image _replaceBlackCorners(img.Image image) {
  final out = img.Image.from(image);
  for (var y = 0; y < out.height; y++) {
    for (var x = 0; x < out.width; x++) {
      final p = out.getPixel(x, y);
      final r = p.r.toInt();
      final g = p.g.toInt();
      final b = p.b.toInt();
      if (r < 40 && g < 40 && b < 40) {
        out.setPixelRgba(x, y, 255, 255, 255, 255);
      }
    }
  }
  return out;
}

/// Keeps the top graphic only (receipt + ring + checkmark), drops baked text.
img.Image _cropIconOnly(img.Image image) {
  final cropHeight = (image.height * 0.62).round();
  return img.copyCrop(image, x: 0, y: 0, width: image.width, height: cropHeight);
}

Future<void> _syncNativeAssets(img.Image image) async {
  final png = img.encodePng(image);
  await File('android/app/src/main/res/drawable/splash_logo.png')
      .writeAsBytes(png);

  const iosDir = 'ios/Runner/Assets.xcassets/LaunchImage.imageset';
  await File('$iosDir/LaunchImage.png').writeAsBytes(png);
  await File('$iosDir/LaunchImage@2x.png').writeAsBytes(png);
  await File('$iosDir/LaunchImage@3x.png').writeAsBytes(png);
}
