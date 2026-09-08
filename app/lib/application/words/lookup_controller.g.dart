// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lookup_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Runs dictionary look-ups for the add/edit form (F-004, F-005, F-006).
///
/// Only ever started by an explicit *Look up* tap - never automatically, never
/// as the user types. That is both a rate-limit courtesy and the privacy
/// promise: the only thing that leaves the device is a word the user asked us
/// to look up (`docs/DATA-SOURCES.md` §7).

@ProviderFor(Lookup)
final lookupProvider = LookupProvider._();

/// Runs dictionary look-ups for the add/edit form (F-004, F-005, F-006).
///
/// Only ever started by an explicit *Look up* tap - never automatically, never
/// as the user types. That is both a rate-limit courtesy and the privacy
/// promise: the only thing that leaves the device is a word the user asked us
/// to look up (`docs/DATA-SOURCES.md` §7).
final class LookupProvider extends $NotifierProvider<Lookup, LookupState> {
  /// Runs dictionary look-ups for the add/edit form (F-004, F-005, F-006).
  ///
  /// Only ever started by an explicit *Look up* tap - never automatically, never
  /// as the user types. That is both a rate-limit courtesy and the privacy
  /// promise: the only thing that leaves the device is a word the user asked us
  /// to look up (`docs/DATA-SOURCES.md` §7).
  LookupProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lookupProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lookupHash();

  @$internal
  @override
  Lookup create() => Lookup();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LookupState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LookupState>(value),
    );
  }
}

String _$lookupHash() => r'b6fec2265ef91435e70c6c07699f410f85f1ef6a';

/// Runs dictionary look-ups for the add/edit form (F-004, F-005, F-006).
///
/// Only ever started by an explicit *Look up* tap - never automatically, never
/// as the user types. That is both a rate-limit courtesy and the privacy
/// promise: the only thing that leaves the device is a word the user asked us
/// to look up (`docs/DATA-SOURCES.md` §7).

abstract class _$Lookup extends $Notifier<LookupState> {
  LookupState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<LookupState, LookupState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LookupState, LookupState>,
              LookupState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
