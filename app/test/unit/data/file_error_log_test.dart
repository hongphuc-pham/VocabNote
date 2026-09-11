import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:vocabnote/data/diagnostics/file_error_log.dart';

/// The local rolling error log (F-079).
///
/// There is no crash reporter and never will be (RULES §1), so this file is
/// the only record of what went wrong - and it may only ever leave the phone
/// inside a feedback email the user has read first. Two things matter above
/// all: it must never make an error worse, and it must keep the user's own
/// words out of it as far as it can.
void main() {
  late Directory dir;
  late File file;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('vnb_log_');
    file = File(p.join(dir.path, 'errors.log'));
  });

  tearDown(() => dir.delete(recursive: true));

  FileErrorLog log({int maxBytes = FileErrorLog.defaultMaxBytes}) =>
      FileErrorLog(
        file,
        now: () => DateTime.utc(2026, 9, 11, 3),
        maxBytes: maxBytes,
      );

  StackTrace frames(int count) => StackTrace.fromString(
    <String>[
      for (var i = 0; i < count; i++)
        '#$i      f$i (package:vocabnote/x.dart:$i)',
    ].join('\n'),
  );

  Future<String> text() async => (await log().read()).valueOrNull!;

  test('records when, what kind of error, and where in the code', () async {
    log().record(const FormatException('bad input'), frames(2));

    final written = await text();
    expect(written, contains('2026-09-11T03:00:00.000Z'));
    expect(written, contains('FormatException: bad input'));
    expect(written, contains('#1      f1 (package:vocabnote/x.dart:1)'));
  });

  test('keeps only the first line of a message', () async {
    // Later lines are where input tends to be quoted back.
    log().record(
      const FormatException('bad input\nthe user typed this'),
      frames(1),
    );

    expect(await text(), isNot(contains('the user typed this')));
  });

  test('keeps a long message short', () async {
    log().record(StateError('x' * 1000), frames(1));

    final written = await text();
    expect(written, isNot(contains('x' * (FileErrorLog.maxMessageLength + 1))));
    expect(written, contains('…'));
  });

  test('keeps only the top of a deep stack', () async {
    log().record(StateError('deep'), frames(50));

    final written = await text();
    const last = FileErrorLog.maxFrames - 1;
    expect(written, contains('f$last '));
    expect(written, isNot(contains('f${FileErrorLog.maxFrames} ')));
  });

  test('stays under its cap by dropping the oldest entries whole', () async {
    final small = log(maxBytes: 600);
    for (var i = 0; i < 20; i++) {
      small.record(StateError('error $i'), frames(2));
    }

    final written = await text();
    expect(file.lengthSync(), lessThanOrEqualTo(600));
    expect(written, contains('error 19'));
    expect(written, isNot(contains('error 0\n')));
    expect(written, startsWith('['), reason: 'cut at an entry, not mid-way');
  });

  test('reads oldest first', () async {
    log()
      ..record(StateError('first'), frames(1))
      ..record(StateError('second'), frames(1));

    final written = await text();
    expect(written.indexOf('first'), lessThan(written.indexOf('second')));
  });

  test('reads as empty before anything has gone wrong', () async {
    expect(await text(), isEmpty);
  });

  test('clear empties it', () async {
    log().record(StateError('gone'), frames(1));

    await log().clear();

    expect(await text(), isEmpty);
  });

  test('a log that cannot be written never throws', () {
    // Called from inside an error handler: a failure here would be a second
    // error, and a handler that throws can recurse.
    final broken = FileErrorLog(File(dir.path));

    expect(
      () => broken.record(StateError('nowhere to go'), frames(1)),
      returnsNormally,
    );
  });

  test('the discarding log keeps nothing', () async {
    const discarding = DiscardingErrorLog();

    discarding.record(StateError('dropped'), frames(1));

    expect((await discarding.read()).valueOrNull, isEmpty);
  });
}
