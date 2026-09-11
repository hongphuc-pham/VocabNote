// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The router for the whole app (`docs/UI-UX.md` section 3).
///
/// Three tab branches keep their own stacks inside [AppShell]; detail, editor
/// and settings routes are pushed onto the root navigator so they cover the
/// bottom bar and get a back arrow, matching the mocks in section 4.3-4.4.
///
/// Screens that a later milestone owns resolve to [PlaceholderScreen] for now,
/// so navigation is real and testable from M0.

@ProviderFor(appRouter)
final appRouterProvider = AppRouterProvider._();

/// The router for the whole app (`docs/UI-UX.md` section 3).
///
/// Three tab branches keep their own stacks inside [AppShell]; detail, editor
/// and settings routes are pushed onto the root navigator so they cover the
/// bottom bar and get a back arrow, matching the mocks in section 4.3-4.4.
///
/// Screens that a later milestone owns resolve to [PlaceholderScreen] for now,
/// so navigation is real and testable from M0.

final class AppRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// The router for the whole app (`docs/UI-UX.md` section 3).
  ///
  /// Three tab branches keep their own stacks inside [AppShell]; detail, editor
  /// and settings routes are pushed onto the root navigator so they cover the
  /// bottom bar and get a back arrow, matching the mocks in section 4.3-4.4.
  ///
  /// Screens that a later milestone owns resolve to [PlaceholderScreen] for now,
  /// so navigation is real and testable from M0.
  AppRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appRouterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return appRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$appRouterHash() => r'36d644df9ed3dfc6cccfe6d6f6a8793393ba62f1';
