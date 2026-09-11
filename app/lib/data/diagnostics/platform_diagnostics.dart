import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vocabnote/core/failure.dart';
import 'package:vocabnote/core/result.dart';
import 'package:vocabnote/domain/entities/diagnostics.dart';
import 'package:vocabnote/domain/repositories/diagnostics_source.dart';

/// [DiagnosticsSource] over `package_info_plus` and `device_info_plus`
/// (RULES §4 ledger).
///
/// Reads the model, never the device `name` - on both platforms that is the
/// owner's own label for their phone, often their name.
class PlatformDiagnostics implements DiagnosticsSource {
  /// Creates the source. Inert until read.
  const new();

  @override
  AsyncResult<Diagnostics> read() => Results.guard(
    () async {
      final package = await PackageInfo.fromPlatform();
      final device = DeviceInfoPlugin();
      final String os;
      final String model;
      if (Platform.isAndroid) {
        final android = await device.androidInfo;
        os = 'Android ${android.version.release}';
        model = '${_capitalised(android.manufacturer)} ${android.model}';
      } else if (Platform.isIOS) {
        final ios = await device.iosInfo;
        os = '${ios.systemName} ${ios.systemVersion}';
        model = ios.modelName;
      } else {
        os = Platform.operatingSystem;
        model = '';
      }
      return Diagnostics(
        appVersion: '${package.version} (${package.buildNumber})',
        osVersion: os,
        deviceModel: model,
      );
    },
    onError: (error, stackTrace) => UnavailableFailure(
      capability: 'device details',
      cause: error,
      stackTrace: stackTrace,
    ),
  );

  /// `samsung` → `Samsung`: manufacturers report themselves in lower case.
  static String _capitalised(String word) =>
      word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}';
}
