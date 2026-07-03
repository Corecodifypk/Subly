import 'dart:io';

import 'package:image/image.dart' as img;

/// Syncs [assets/images/app_icon_source.png] to native splash + launcher icons.
Future<void> main() async {
  const source = 'assets/images/app_icon_source.png';
  final bytes = await File(source).readAsBytes();
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    stderr.writeln('Failed to decode $source');
    exit(1);
  }

  final logo = _replaceBlackCorners(decoded);
  const resRoot = 'android/app/src/main/res';

  // Native splash (Android drawable + iOS LaunchImage) — scaled to 120px.
  const splashSize = 120;
  final splash = img.copyResize(
    logo,
    width: splashSize,
    height: splashSize,
    interpolation: img.Interpolation.average,
  );
  final splashPng = img.encodePng(splash);
  await File('$resRoot/drawable/splash_logo.png').writeAsBytes(splashPng);

  const iosDir = 'ios/Runner/Assets.xcassets/LaunchImage.imageset';
  await File('$iosDir/LaunchImage.png').writeAsBytes(splashPng);
  await File('$iosDir/LaunchImage@2x.png').writeAsBytes(splashPng);
  await File('$iosDir/LaunchImage@3x.png').writeAsBytes(splashPng);

  // Android launcher icons (all densities).
  const legacySizes = <String, int>{
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
  };

  const adaptiveSizes = <String, int>{
    'mipmap-mdpi': 108,
    'mipmap-hdpi': 162,
    'mipmap-xhdpi': 216,
    'mipmap-xxhdpi': 324,
    'mipmap-xxxhdpi': 432,
  };

  for (final entry in legacySizes.entries) {
    final out = img.copyResize(
      logo,
      width: entry.value,
      height: entry.value,
      interpolation: img.Interpolation.average,
    );
    await File('$resRoot/${entry.key}/ic_launcher.png')
        .writeAsBytes(img.encodePng(out));
  }

  for (final entry in adaptiveSizes.entries) {
    final size = entry.value;
    final foreground = _adaptiveForeground(logo, size);
    final background = img.Image(width: size, height: size);
    img.fill(background, color: img.ColorRgba8(255, 255, 255, 255));

    await File('$resRoot/${entry.key}/ic_launcher_foreground.png')
        .writeAsBytes(img.encodePng(foreground));
    await File('$resRoot/${entry.key}/ic_launcher_background.png')
        .writeAsBytes(img.encodePng(background));
  }

  stdout.writeln('Synced native icons from $source');
}

img.Image _replaceBlackCorners(img.Image image) {
  final out = img.Image.from(image);
  for (var y = 0; y < out.height; y++) {
    for (var x = 0; x < out.width; x++) {
      final p = out.getPixel(x, y);
      if (p.r < 40 && p.g < 40 && p.b < 40) {
        out.setPixelRgba(x, y, 255, 255, 255, 255);
      }
    }
  }
  return out;
}

img.Image _adaptiveForeground(img.Image icon, int canvasSize) {
  final canvas = img.Image(width: canvasSize, height: canvasSize);
  img.fill(canvas, color: img.ColorRgba8(0, 0, 0, 0));

  final logoSize = (canvasSize * 0.84).round();
  final resized = img.copyResize(
    icon,
    width: logoSize,
    height: logoSize,
    interpolation: img.Interpolation.average,
  );

  final x = (canvasSize - resized.width) ~/ 2;
  final y = (canvasSize - resized.height) ~/ 2;
  img.compositeImage(canvas, resized, dstX: x, dstY: y);
  return canvas;
}
