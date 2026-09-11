// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_actions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// When the last backup was handed over, or null if never.

@ProviderFor(lastBackupAt)
final lastBackupAtProvider = LastBackupAtProvider._();

/// When the last backup was handed over, or null if never.

final class LastBackupAtProvider
    extends
        $FunctionalProvider<
          AsyncValue<DateTime?>,
          DateTime?,
          FutureOr<DateTime?>
        >
    with $FutureModifier<DateTime?>, $FutureProvider<DateTime?> {
  /// When the last backup was handed over, or null if never.
  LastBackupAtProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lastBackupAtProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lastBackupAtHash();

  @$internal
  @override
  $FutureProviderElement<DateTime?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<DateTime?> create(Ref ref) {
    return lastBackupAt(ref);
  }
}

String _$lastBackupAtHash() => r'8ff84f52f20d8f2495fb55acaddc52658d7d00fa';

/// The backup screen's write side.

@ProviderFor(BackupActions)
final backupActionsProvider = BackupActionsProvider._();

/// The backup screen's write side.
final class BackupActionsProvider
    extends $NotifierProvider<BackupActions, void> {
  /// The backup screen's write side.
  BackupActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupActionsHash();

  @$internal
  @override
  BackupActions create() => BackupActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$backupActionsHash() => r'c90c0bfdcfd5f2d40b75428623f5ecef1fe69eb8';

/// The backup screen's write side.

abstract class _$BackupActions extends $Notifier<void> {
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
