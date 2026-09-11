// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The reminder's write side.
///
/// Every change goes to the OS first and the settings row second, so the
/// switch never says "on" for a reminder that was never scheduled.

@ProviderFor(ReminderActions)
final reminderActionsProvider = ReminderActionsProvider._();

/// The reminder's write side.
///
/// Every change goes to the OS first and the settings row second, so the
/// switch never says "on" for a reminder that was never scheduled.
final class ReminderActionsProvider
    extends $NotifierProvider<ReminderActions, void> {
  /// The reminder's write side.
  ///
  /// Every change goes to the OS first and the settings row second, so the
  /// switch never says "on" for a reminder that was never scheduled.
  ReminderActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reminderActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reminderActionsHash();

  @$internal
  @override
  ReminderActions create() => ReminderActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$reminderActionsHash() => r'd67ab15178322fadecaf47364c1e101f59246296';

/// The reminder's write side.
///
/// Every change goes to the OS first and the settings row second, so the
/// switch never says "on" for a reminder that was never scheduled.

abstract class _$ReminderActions extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
