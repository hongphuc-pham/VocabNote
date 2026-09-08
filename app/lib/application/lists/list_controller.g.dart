// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Every list with its word and due counts (F-042).
///
/// Used by the lists grid (M4) and, from M2, by the filter chips row - the
/// user's lists appear as chips after the four fixed ones.
///
/// Converts the repository's `Result` into Riverpod's `AsyncValue`, which is
/// the presentation layer's own success-or-failure type.

@ProviderFor(listSummaries)
final listSummariesProvider = ListSummariesProvider._();

/// Every list with its word and due counts (F-042).
///
/// Used by the lists grid (M4) and, from M2, by the filter chips row - the
/// user's lists appear as chips after the four fixed ones.
///
/// Converts the repository's `Result` into Riverpod's `AsyncValue`, which is
/// the presentation layer's own success-or-failure type.

final class ListSummariesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WordListSummary>>,
          List<WordListSummary>,
          Stream<List<WordListSummary>>
        >
    with
        $FutureModifier<List<WordListSummary>>,
        $StreamProvider<List<WordListSummary>> {
  /// Every list with its word and due counts (F-042).
  ///
  /// Used by the lists grid (M4) and, from M2, by the filter chips row - the
  /// user's lists appear as chips after the four fixed ones.
  ///
  /// Converts the repository's `Result` into Riverpod's `AsyncValue`, which is
  /// the presentation layer's own success-or-failure type.
  ListSummariesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'listSummariesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$listSummariesHash();

  @$internal
  @override
  $StreamProviderElement<List<WordListSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<WordListSummary>> create(Ref ref) {
    return listSummaries(ref);
  }
}

String _$listSummariesHash() => r'a0cd4ba53bec022373b0d44eb615c7f25bb94eeb';

/// Which lists a given word belongs to - drives the selected chips on the
/// add/edit form.

@ProviderFor(listIdsForWord)
final listIdsForWordProvider = ListIdsForWordFamily._();

/// Which lists a given word belongs to - drives the selected chips on the
/// add/edit form.

final class ListIdsForWordProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          Stream<List<String>>
        >
    with $FutureModifier<List<String>>, $StreamProvider<List<String>> {
  /// Which lists a given word belongs to - drives the selected chips on the
  /// add/edit form.
  ListIdsForWordProvider._({
    required ListIdsForWordFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'listIdsForWordProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$listIdsForWordHash();

  @override
  String toString() {
    return r'listIdsForWordProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<String>> create(Ref ref) {
    final argument = this.argument as String;
    return listIdsForWord(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ListIdsForWordProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$listIdsForWordHash() => r'91fe5cbd37a9c9544914a7a60e58dc8d85deb854';

/// Which lists a given word belongs to - drives the selected chips on the
/// add/edit form.

final class ListIdsForWordFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<String>>, String> {
  ListIdsForWordFamily._()
    : super(
        retry: null,
        name: r'listIdsForWordProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Which lists a given word belongs to - drives the selected chips on the
  /// add/edit form.

  ListIdsForWordProvider call(String wordId) =>
      ListIdsForWordProvider._(argument: wordId, from: this);

  @override
  String toString() => r'listIdsForWordProvider';
}
