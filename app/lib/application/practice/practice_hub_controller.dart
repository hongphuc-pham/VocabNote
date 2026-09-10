/// What the practice hub needs to know (F-060).
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vocabnote/application/repositories.dart';

part 'practice_hub_controller.g.dart';

/// How many cards are due right now — the "Daily review (7 due)" count.
@riverpod
Stream<int> dueCardCount(Ref ref) {
  return ref
      .watch(practiceRepositoryProvider)
      .watchDueCount()
      .map(
        (result) => result.fold((count) => count, (failure) => throw failure),
      );
}
