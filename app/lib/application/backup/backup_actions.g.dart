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

/// How many bytes the library takes on this phone, or null if it cannot be
/// measured just now.

@ProviderFor(storageUsed)
final storageUsedProvider = StorageUsedProvider._();

/// How many bytes the library takes on this phone, or null if it cannot be
/// measured just now.

final class StorageUsedProvider
    extends $FunctionalProvider<AsyncValue<int?>, int?, FutureOr<int?>>
    with $FutureModifier<int?>, $FutureProvider<int?> {
  /// How many bytes the library takes on this phone, or null if it cannot be
  /// measured just now.
  StorageUsedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storageUsedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storageUsedHash();

  @$internal
  @override
  $FutureProviderElement<int?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int?> create(Ref ref) {
    return storageUsed(ref);
  }
}

String _$storageUsedHash() => r'2d5c6806fae1cc97da65545a8a725dc9163fa5a7';

/// The write side of the user's whole library: backup, import, delete.

@ProviderFor(BackupActions)
final backupActionsProvider = BackupActionsProvider._();

/// The write side of the user's whole library: backup, import, delete.
final class BackupActionsProvider
    extends $NotifierProvider<BackupActions, void> {
  /// The write side of the user's whole library: backup, import, delete.
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

String _$backupActionsHash() => r'b1f95d48446f531e556f29ca14ee08c0f0871c88';

/// The write side of the user's whole library: backup, import, delete.

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
