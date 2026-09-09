// Licence gate for the dependency tree (`docs/DATA-SOURCES.md` section 6,
// `docs/RULES.md` section 15).
//
// Permissive only: MIT, BSD-2/3, Apache-2.0, OFL. No copyleft, nothing
// "non-commercial". Run locally with:
//
//   dart run tool/check_licences.dart
//
// CI runs the same command, so a new non-permissive licence fails the build
// rather than being discovered during release prep.
import 'dart:io';

/// Packages that resolve into the graph but can never reach a shipped binary.
///
/// Flutter's federated plugins pull in one implementation package per platform.
/// VocabNote ships Android and iOS only, so the Linux, Windows, macOS and web
/// implementations are resolved by pub but never compiled. They are listed
/// individually — never wildcarded — so a genuinely new dependency cannot hide
/// behind the exemption.
const Map<String, String> _notShipped = <String, String>{
  'dbus':
      'MPL-2.0, via file_picker_linux and '
      'flutter_local_notifications_linux. Linux desktop only; VocabNote '
      'targets Android and iOS, so this is never compiled or distributed.',
};

/// Text that marks a licence we may not ship.
const List<String> _forbidden = <String>[
  'gnu general public',
  'gnu lesser general public',
  'gnu affero',
  'mozilla public license',
  'eclipse public license',
  'common public license',
  'non-commercial',
  'noncommercial',
];

void main(List<String> args) {
  final lock = File('pubspec.lock');
  if (!lock.existsSync()) {
    stderr.writeln('pubspec.lock not found - run from the app/ directory.');
    exit(2);
  }

  final cache = _pubCacheDir();
  if (cache == null) {
    stderr.writeln('Could not locate the pub cache.');
    exit(2);
  }

  final packages = _hostedPackages(lock.readAsStringSync());
  final violations = <String>[];
  final missing = <String>[];
  var checked = 0;

  for (final entry in packages.entries) {
    final dir = Directory('${cache.path}/${entry.key}-${entry.value}');
    if (!dir.existsSync()) continue;

    final licence = _licenceFile(dir);
    if (licence == null) {
      missing.add(entry.key);
      continue;
    }

    checked++;
    final text = licence.readAsStringSync().toLowerCase();
    final hit = _forbidden.where(text.contains).toList();
    if (hit.isEmpty) continue;

    final reason = _notShipped[entry.key];
    if (reason != null) {
      stdout.writeln('  exempt: ${entry.key} - $reason');
      continue;
    }
    violations.add('${entry.key} ${entry.value}: matches "${hit.first}"');
  }

  stdout.writeln('Checked $checked package licences.');

  if (missing.isNotEmpty) {
    stdout.writeln('No licence file found for: ${missing.join(', ')}');
  }

  if (violations.isEmpty) {
    stdout.writeln('All licences are permissive.');
    return;
  }

  stderr.writeln('\nNon-permissive licences found:');
  for (final violation in violations) {
    stderr.writeln('  - $violation');
  }
  stderr.writeln(
    '\nRULES.md section 15 allows MIT / BSD / Apache-2.0 / OFL only.',
  );
  exit(1);
}

/// Every hosted package in the lockfile, mapped to its resolved version.
Map<String, String> _hostedPackages(String lockfile) {
  final packages = <String, String>{};
  final lines = lockfile.split('\n');

  for (var i = 0; i < lines.length; i++) {
    final name = RegExp(r'^  ([a-z0-9_]+):\s*$').firstMatch(lines[i]);
    if (name == null) continue;

    // Look ahead within this entry for a hosted source and its version.
    var hosted = false;
    String? version;
    for (var j = i + 1; j < lines.length && lines[j].startsWith('    '); j++) {
      if (lines[j].trim() == 'source: hosted') hosted = true;
      final v = RegExp(r'^    version:\s*"?([^"\s]+)"?').firstMatch(lines[j]);
      if (v != null) version = v.group(1);
    }
    if (hosted && version != null) packages[name.group(1)!] = version;
  }
  return packages;
}

File? _licenceFile(Directory dir) {
  for (final name in <String>['LICENSE', 'LICENSE.md', 'LICENSE.txt']) {
    final file = File('${dir.path}/$name');
    if (file.existsSync()) return file;
  }
  return null;
}

Directory? _pubCacheDir() {
  final env = Platform.environment;
  final explicit = env['PUB_CACHE'];
  if (explicit != null) {
    final dir = Directory('$explicit/hosted/pub.dev');
    if (dir.existsSync()) return dir;
  }

  final candidates = <String>[
    if (env['LOCALAPPDATA'] != null)
      '${env['LOCALAPPDATA']}/Pub/Cache/hosted/pub.dev',
    if (env['HOME'] != null) '${env['HOME']}/.pub-cache/hosted/pub.dev',
    if (env['APPDATA'] != null) '${env['APPDATA']}/Pub/Cache/hosted/pub.dev',
  ];

  for (final path in candidates) {
    final dir = Directory(path);
    if (dir.existsSync()) return dir;
  }
  return null;
}
