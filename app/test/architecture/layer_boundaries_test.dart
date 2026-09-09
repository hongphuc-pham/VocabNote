import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Enforces the dependency rule:
/// `presentation -> application -> domain <- data`
/// (`docs/ARCHITECTURE.md` section 1, `docs/RULES.md` section 20).
///
/// This is a test rather than a lint on purpose. The obvious tool would be
/// `riverpod_lint`/`custom_lint`, but `custom_lint` pins `analyzer ^8` while
/// `drift_dev` requires `analyzer >=13`, so the two cannot be installed
/// together. Drift is not negotiable (ADR-001), so the boundary is checked
/// here instead — no extra dependency, and it fails the build the same way.
void main() {
  final libDir = Directory('lib');

  /// Which layer a file under `lib/` belongs to, or null if it is in neither.
  String? layerOf(String path) {
    final normalised = path.replaceAll(r'\', '/');
    for (final layer in _layers.keys) {
      if (normalised.startsWith('lib/$layer/')) return layer;
    }
    return null;
  }

  /// The `package:vocabnote/...` imports declared by [file].
  List<String> internalImports(File file) {
    final pattern = RegExp(
      r"""^\s*(?:import|export)\s+['"]package:vocabnote/([^'"]+)['"]""",
      multiLine: true,
    );
    return pattern
        .allMatches(file.readAsStringSync())
        .map((m) => m.group(1)!)
        .toList();
  }

  late List<File> sources;

  setUpAll(() {
    sources = libDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        // Generated code follows the generator's conventions, not ours.
        .where((f) => !f.path.endsWith('.g.dart'))
        .where((f) => !f.path.endsWith('.freezed.dart'))
        .where((f) => !f.path.replaceAll(r'\', '/').contains('/l10n/gen/'))
        .toList();
  });

  test('there is something to check', () {
    expect(sources, isNotEmpty);
    expect(
      sources.map((f) => layerOf(f.path)).whereType<String>().toSet(),
      containsAll(<String>['core', 'domain', 'presentation']),
    );
  });

  test('no layer imports a layer it is not allowed to', () {
    final violations = <String>[];

    for (final file in sources) {
      final from = layerOf(file.path);
      if (from == null) continue;
      final allowed = _layers[from]!;

      final path = file.path.replaceAll(r'\', '/');
      final isCompositionRoot = _compositionRoots.any(path.endsWith);

      for (final import in internalImports(file)) {
        final to = _layerOfImport(import);
        if (to == null || to == from) continue;
        if (isCompositionRoot) continue;
        if (!allowed.contains(to)) {
          violations.add(
            '${file.path.replaceAll(r'\', '/')}\n'
            '    $from must not import $to  (package:vocabnote/$import)',
          );
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          'Layer direction is presentation -> application -> domain <- '
          'data.\n${violations.join('\n')}',
    );
  });

  test('domain imports nothing but Dart, meta and freezed', () {
    // RULES.md section 20. A Flutter import in domain/ is how an entity ends up
    // knowing about BuildContext, and how the model becomes untestable.
    final violations = <String>[];
    const allowedPackages = <String>{
      'meta',
      'freezed_annotation',
      'collection',
    };

    for (final file in sources) {
      if (layerOf(file.path) != 'domain') continue;
      final imports = RegExp(
        r"""^\s*import\s+['"]([^'"]+)['"]""",
        multiLine: true,
      ).allMatches(file.readAsStringSync()).map((m) => m.group(1)!);

      for (final import in imports) {
        if (import.startsWith('dart:')) continue;
        if (import.startsWith('package:vocabnote/')) continue;
        if (!import.startsWith('package:')) continue;
        final package = import.substring(8).split('/').first;
        if (!allowedPackages.contains(package)) {
          violations.add('${file.path.replaceAll(r'\', '/')} imports $import');
        }
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('the composition-root exemption stays small and real', () {
    // The exemption is the dangerous part of this file, so it is itself
    // tested: every exempted path must exist, and the list must not grow
    // quietly.
    expect(_compositionRoots, hasLength(3));
    for (final root in _compositionRoots) {
      expect(File(root).existsSync(), isTrue, reason: '$root is missing');
    }
  });

  test('only the router crosses into presentation from core', () {
    // Being exempt from the matrix does not make core/router a free-for-all:
    // nothing else under core/ may reach for a widget.
    final offenders = <String>[];

    for (final file in sources) {
      final path = file.path.replaceAll(r'\', '/');
      if (layerOf(path) != 'core') continue;
      if (path.endsWith('lib/core/router/app_router.dart')) continue;
      for (final import in internalImports(file)) {
        if (import.startsWith('presentation/')) {
          offenders.add('$path -> $import');
        }
      }
    }

    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('a library directive comes before every other directive', () {
    // Not architecture, but it belongs to the same family of "this compiles
    // everywhere except where it does not". A `library;` placed after the
    // imports is legal to the analyzer's eye in some contexts but makes
    // build_runner refuse the file outright, with an error that names the
    // line rather than the cause. Cheap to check, tedious to rediscover.
    final offenders = <String>[];

    for (final file in sources) {
      final content = file.readAsStringSync();
      final directives = RegExp(
        '^(library;|import |export |part )',
        multiLine: true,
      ).allMatches(content).toList();

      if (directives.isEmpty) continue;
      if (!content.contains(RegExp('^library;', multiLine: true))) continue;

      if (!directives.first.group(1)!.startsWith('library')) {
        offenders.add(file.path.replaceAll(r'\', '/'));
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'Move `library;` (and its doc comment) above the imports:\n'
          '${offenders.join('\n')}',
    );
  });

  test('data never imports presentation', () {
    // Called out separately from the matrix above because it is the violation
    // that actually happens: a repository reaching for a widget's helper.
    final violations = <String>[];

    for (final file in sources) {
      if (layerOf(file.path) != 'data') continue;
      for (final import in internalImports(file)) {
        if (import.startsWith('presentation/')) {
          violations.add('${file.path.replaceAll(r'\', '/')} -> $import');
        }
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('only core/extensions/grapheme.dart reaches for package:characters', () {
    // ADR-006: every IPA slice goes through the helper, so there is exactly one
    // place where a grapheme bug can live.
    final offenders = <String>[];

    for (final file in sources) {
      final path = file.path.replaceAll(r'\', '/');
      if (path.endsWith('lib/core/extensions/grapheme.dart')) continue;
      if (file.readAsStringSync().contains('package:characters/')) {
        offenders.add(path);
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'Use core/extensions/grapheme.dart instead of package:characters '
          'directly.\n${offenders.join('\n')}',
    );
  });
}

/// Files that are allowed to wire layers together.
///
/// `docs/ARCHITECTURE.md` section 2 places the router in `core/router/`, but a
/// router exists to name screens, and section 1 forbids `core -> presentation`.
/// The two rules cannot both hold for this one file. It is resolved the way
/// `main.dart` is: a composition root is the place where wiring is *supposed*
/// to cross layers, so it is exempted by name rather than by category.
///
/// Keep this list at three entries. If a fourth file wants in, the design is
/// drifting and the answer is an interface, not another exemption.
const List<String> _compositionRoots = <String>[
  'lib/core/router/app_router.dart',
  'lib/bootstrap.dart',
  // Supplies the `data/` implementations for the DI seam that
  // `application/repositories.dart` declares. Kept here rather than in
  // bootstrap so tests can build the same overrides against an in-memory
  // database without duplicating the list.
  'lib/data/composition_root.dart',
];

/// What each layer is allowed to import.
///
/// `core` is deliberately importable from anywhere: it holds tokens, `Result`,
/// failures and the grapheme helpers, none of which carry business rules.
const Map<String, Set<String>> _layers = <String, Set<String>>{
  'domain': <String>{'core'},
  'data': <String>{'core', 'domain'},
  'application': <String>{'core', 'domain'},
  'presentation': <String>{'core', 'domain', 'application'},
  'core': <String>{'domain'},
};

String? _layerOfImport(String importPath) {
  for (final layer in _layers.keys) {
    if (importPath.startsWith('$layer/')) return layer;
  }
  return null;
}
