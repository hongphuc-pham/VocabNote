// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Watches one word and everything hanging off it.
///
/// Emits null once the word is gone — soft-deleted from the list screen while
/// this one is open, for instance — so the screen can say so rather than
/// showing a stale copy of something the user just deleted.
///
/// The three streams are joined with [combineLatest3] at this layer. Riverpod 3
/// removed `StreamProvider.stream`, so combining by reaching into other
/// providers is no longer possible even where it was once tempting; this is
/// also exactly how `WordRepositoryImpl.watchWords` composes the list screen.

@ProviderFor(wordDetail)
final wordDetailProvider = WordDetailFamily._();

/// Watches one word and everything hanging off it.
///
/// Emits null once the word is gone — soft-deleted from the list screen while
/// this one is open, for instance — so the screen can say so rather than
/// showing a stale copy of something the user just deleted.
///
/// The three streams are joined with [combineLatest3] at this layer. Riverpod 3
/// removed `StreamProvider.stream`, so combining by reaching into other
/// providers is no longer possible even where it was once tempting; this is
/// also exactly how `WordRepositoryImpl.watchWords` composes the list screen.

final class WordDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<WordDetail?>,
          WordDetail?,
          Stream<WordDetail?>
        >
    with $FutureModifier<WordDetail?>, $StreamProvider<WordDetail?> {
  /// Watches one word and everything hanging off it.
  ///
  /// Emits null once the word is gone — soft-deleted from the list screen while
  /// this one is open, for instance — so the screen can say so rather than
  /// showing a stale copy of something the user just deleted.
  ///
  /// The three streams are joined with [combineLatest3] at this layer. Riverpod 3
  /// removed `StreamProvider.stream`, so combining by reaching into other
  /// providers is no longer possible even where it was once tempting; this is
  /// also exactly how `WordRepositoryImpl.watchWords` composes the list screen.
  WordDetailProvider._({
    required WordDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'wordDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$wordDetailHash();

  @override
  String toString() {
    return r'wordDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<WordDetail?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<WordDetail?> create(Ref ref) {
    final argument = this.argument as String;
    return wordDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WordDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$wordDetailHash() => r'a9f7788d9d742b2ec0035c67f34c9abcc07bf8f3';

/// Watches one word and everything hanging off it.
///
/// Emits null once the word is gone — soft-deleted from the list screen while
/// this one is open, for instance — so the screen can say so rather than
/// showing a stale copy of something the user just deleted.
///
/// The three streams are joined with [combineLatest3] at this layer. Riverpod 3
/// removed `StreamProvider.stream`, so combining by reaching into other
/// providers is no longer possible even where it was once tempting; this is
/// also exactly how `WordRepositoryImpl.watchWords` composes the list screen.

final class WordDetailFamily extends $Family
    with $FunctionalFamilyOverride<Stream<WordDetail?>, String> {
  WordDetailFamily._()
    : super(
        retry: null,
        name: r'wordDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Watches one word and everything hanging off it.
  ///
  /// Emits null once the word is gone — soft-deleted from the list screen while
  /// this one is open, for instance — so the screen can say so rather than
  /// showing a stale copy of something the user just deleted.
  ///
  /// The three streams are joined with [combineLatest3] at this layer. Riverpod 3
  /// removed `StreamProvider.stream`, so combining by reaching into other
  /// providers is no longer possible even where it was once tempting; this is
  /// also exactly how `WordRepositoryImpl.watchWords` composes the list screen.

  WordDetailProvider call(String wordId) =>
      WordDetailProvider._(argument: wordId, from: this);

  @override
  String toString() => r'wordDetailProvider';
}
