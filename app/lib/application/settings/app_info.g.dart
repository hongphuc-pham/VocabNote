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

/// Whether this launch opens on onboarding (F-077).
///
/// Decided once in `bootstrap`, before the first frame, so the router knows
/// its first location synchronously and the words tab never flashes up
/// before a redirect. False unless bootstrap says otherwise - so a test that
/// is not about onboarding starts where every other launch does.

@ProviderFor(showOnboarding)
final showOnboardingProvider = ShowOnboardingProvider._();

/// Whether this launch opens on onboarding (F-077).
///
/// Decided once in `bootstrap`, before the first frame, so the router knows
/// its first location synchronously and the words tab never flashes up
/// before a redirect. False unless bootstrap says otherwise - so a test that
/// is not about onboarding starts where every other launch does.

final class ShowOnboardingProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether this launch opens on onboarding (F-077).
  ///
  /// Decided once in `bootstrap`, before the first frame, so the router knows
  /// its first location synchronously and the words tab never flashes up
  /// before a redirect. False unless bootstrap says otherwise - so a test that
  /// is not about onboarding starts where every other launch does.
  ShowOnboardingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'showOnboardingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$showOnboardingHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return showOnboarding(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$showOnboardingHash() => r'74055113aa99f92afdf6ad091a0348e69a7b4edb';

/// Where *Send feedback* writes to, or null when this build has no address.
///
/// Set with `--dart-define=FEEDBACK_EMAIL=…` at release (M8). Until then Help
/// offers GitHub Issues only: an address baked into the app is public, and
/// it is the owner's to choose (`plan.md`, decided 11 Sep).

@ProviderFor(feedbackAddress)
final feedbackAddressProvider = FeedbackAddressProvider._();

/// Where *Send feedback* writes to, or null when this build has no address.
///
/// Set with `--dart-define=FEEDBACK_EMAIL=…` at release (M8). Until then Help
/// offers GitHub Issues only: an address baked into the app is public, and
/// it is the owner's to choose (`plan.md`, decided 11 Sep).

final class FeedbackAddressProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// Where *Send feedback* writes to, or null when this build has no address.
  ///
  /// Set with `--dart-define=FEEDBACK_EMAIL=…` at release (M8). Until then Help
  /// offers GitHub Issues only: an address baked into the app is public, and
  /// it is the owner's to choose (`plan.md`, decided 11 Sep).
  FeedbackAddressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedbackAddressProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedbackAddressHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return feedbackAddress(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$feedbackAddressHash() => r'41dd36b0a2f884195f8fa357cf1938e6607f6558';
