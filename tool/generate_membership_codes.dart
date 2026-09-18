import 'dart:io';
import 'dart:math';

const _alphabet = '23456789ABCDEFGHJKMNPQRSTUVWXYZ';

String _group(Random random) =>
    List.generate(4, (_) => _alphabet[random.nextInt(_alphabet.length)]).join();

void main(List<String> args) {
  final count = args.isEmpty ? 0 : int.tryParse(args.first) ?? 0;
  if (count < 1 || count > 10000) {
    stderr.writeln('Usage: dart run tool/generate_membership_codes.dart COUNT');
    exitCode = 64;
    return;
  }

  final random = Random.secure();
  final codes = <String>{};
  while (codes.length < count) {
    codes.add('MWBS-${_group(random)}-${_group(random)}-${_group(random)}');
  }

  stdout.writeln('code');
  for (final code in codes) {
    stdout.writeln(code);
  }
}
