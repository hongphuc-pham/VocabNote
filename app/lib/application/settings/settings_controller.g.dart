// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The user's settings, kept current.
///
/// Watched rather than read once so that changing the speech rate in Settings
/// takes effect on a detail screen that is already open, without the screen
/// knowing anything happened.
///
/// Kept alive because almost every screen ends up wanting it, and re-reading
/// the same single row each time a screen is pushed is pure waste.

@ProviderFor(appSettings)
final appSettingsProvider = AppSettingsProvider._();

/// The user's settings, kept current.
///
/// Watched rather than read once so that changing the speech rate in Settings
/// takes effect on a detail screen that is already open, without the screen
/// knowing anything happened.
///
/// Kept alive because almost every screen ends up wanting it, and re-reading
/// the same single row each time a screen is pushed is pure waste.

final class AppSettingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<AppSettings>,
          AppSettings,
          Stream<AppSettings>
        >
    with $FutureModifier<AppSettings>, $StreamProvider<AppSettings> {
  /// The user's settings, kept current.
  ///
  /// Watched rather than read once so that changing the speech rate in Settings
  /// takes effect on a detail screen that is already open, without the screen
  /// knowing anything happened.
  ///
  /// Kept alive because almost every screen ends up wanting it, and re-reading
  /// the same single row each time a screen is pushed is pure waste.
  AppSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appSettingsHash();

  @$internal
  @override
  $StreamProviderElement<AppSettings> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<AppSettings> create(Ref ref) {
    return appSettings(ref);
  }
}

String _$appSettingsHash() => r'1fbccf594e943c765c27b0d24d3418ce472da0bf';

/// The settings, or the documented defaults while they are still loading.
///
/// Speech is the reason this exists: a play button that is disabled for the
/// first frame because a single-row query has not come back yet would be a
/// worse experience than one that briefly uses the default rate. Reading a
/// wrong-but-sane rate for one frame costs nothing; refusing to speak does.

@ProviderFor(appSettingsOrDefaults)
final appSettingsOrDefaultsProvider = AppSettingsOrDefaultsProvider._();

/// The settings, or the documented defaults while they are still loading.
///
/// Speech is the reason this exists: a play button that is disabled for the
/// first frame because a single-row query has not come back yet would be a
/// worse experience than one that briefly uses the default rate. Reading a
/// wrong-but-sane rate for one frame costs nothing; refusing to speak does.

final class AppSettingsOrDefaultsProvider
    extends $FunctionalProvider<AppSettings, AppSettings, AppSettings>
    with $Provider<AppSettings> {
  /// The settings, or the documented defaults while they are still loading.
  ///
  /// Speech is the reason this exists: a play button that is disabled for the
  /// first frame because a single-row query has not come back yet would be a
  /// worse experience than one that briefly uses the default rate. Reading a
  /// wrong-but-sane rate for one frame costs nothing; refusing to speak does.
  AppSettingsOrDefaultsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appSettingsOrDefaultsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appSettingsOrDefaultsHash();

  @$internal
  @override
  $ProviderElement<AppSettings> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppSettings create(Ref ref) {
    return appSettingsOrDefaults(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppSettings>(value),
    );
  }
}

String _$appSettingsOrDefaultsHash() =>
    r'52ce68de482b0ba6f70c48d9c68e7be613892c7d';
