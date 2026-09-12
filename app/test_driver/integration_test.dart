import 'package:integration_test/integration_test_driver.dart';

/// The driver half of `flutter drive`, needed only by the tests that must run
/// in **profile** mode.
///
/// `flutter test integration_test/... -d <device>` runs a test in *debug*,
/// where frame times are inflated by assertions and an unoptimised build and
/// therefore say nothing about performance. `integration_test/words_scroll_perf_test.dart`
/// measures frame times, so it has to be driven:
///
///     flutter drive --driver=test_driver/integration_test.dart \
///       --target=integration_test/words_scroll_perf_test.dart \
///       -d emulator-5554 --profile
///
/// `backup_round_trip_test.dart` asserts behaviour rather than timing, so it
/// stays on plain `flutter test` and does not need this file.
Future<void> main() => integrationDriver();
