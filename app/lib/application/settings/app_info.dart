/// Facts about this build of the app.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_info.g.dart';

/// The app's version as the platform reports it, e.g. `1.0.0`.
///
/// Read once in `bootstrap` - it is a platform channel call, and Settings must
/// not wait on one - and supplied by the composition root. Declared here like
/// the repositories, and for the same reason: nothing above `data/` may name
/// `package_info_plus`.
@Riverpod(keepAlive: true)
String appVersion(Ref ref) => throw UnimplementedError(
  'appVersionProvider must be overridden in bootstrap() or in a test.',
);
