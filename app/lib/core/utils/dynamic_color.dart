import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Reads the device's Material You accent colour on Android 12+.
///
/// A package could do this, but the whole job is one integer over one platform
/// channel, so `docs/RULES.md` §18 says write the helper. The Android side
/// reads the framework resource `android.R.color.system_accent1_500`, which
/// exists from API 31; every other platform and every older Android returns
/// null and the caller falls back to the brand seed.
abstract final class DynamicColor {
  static const MethodChannel _channel = MethodChannel(
    'com.vocabnote/dynamic_color',
  );

  /// The device accent, or null when there isn't one.
  ///
  /// Never throws: dynamic colour is a nicety, and a broken channel must not
  /// stop the app from starting. A failure is reported in debug and swallowed
  /// in release.
  static Future<Color?> accent() async {
    if (kIsWeb || !Platform.isAndroid) return null;
    try {
      final value = await _channel.invokeMethod<int>('getAccentColor');
      return value == null ? null : Color(value);
    } on PlatformException catch (error, stackTrace) {
      assert(() {
        debugPrint('Dynamic colour unavailable: $error\n$stackTrace');
        return true;
      }(), 'debugPrint always returns true');
      return null;
    } on MissingPluginException {
      // The channel is not registered — an older build or a unit test.
      return null;
    }
  }
}
