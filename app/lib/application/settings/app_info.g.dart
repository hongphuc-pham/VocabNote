// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_info.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's version as the platform reports it, e.g. `1.0.0`.
///
/// Read once in `bootstrap` - it is a platform channel call, and Settings must
/// not wait on one - and supplied by the composition root. Declared here like
/// the repositories, and for the same reason: nothing above `data/` may name
/// `package_info_plus`.

@ProviderFor(appVersion)
final appVersionProvider = AppVersionProvider._();

/// The app's version as the platform reports it, e.g. `1.0.0`.
///
/// Read once in `bootstrap` - it is a platform channel call, and Settings must
/// not wait on one - and supplied by the composition root. Declared here like
/// the repositories, and for the same reason: nothing above `data/` may name
/// `package_info_plus`.

final class AppVersionProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// The app's version as the platform reports it, e.g. `1.0.0`.
  ///
  /// Read once in `bootstrap` - it is a platform channel call, and Settings must
  /// not wait on one - and supplied by the composition root. Declared here like
  /// the repositories, and for the same reason: nothing above `data/` may name
  /// `package_info_plus`.
  AppVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appVersionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appVersionHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return appVersion(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$appVersionHash() => r'4e466275f1f252167aaf775bea1c58ddf6eee056';
