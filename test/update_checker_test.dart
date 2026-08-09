import 'package:flutter_test/flutter_test.dart';
import 'package:manhwa_toon/core/network/update_checker.dart';

void main() {
  test('extracts version from release name and tag', () {
    expect(UpdateChecker.extractVersion('ManhwaToon v1.0.2 beta'), '1.0.2');
    expect(UpdateChecker.extractVersion('1.2.3'), '1.2.3');
    expect(UpdateChecker.extractVersion('v10.0.0'), '10.0.0');
    expect(UpdateChecker.extractVersion('manhwatoon-app'), isNull);
    expect(UpdateChecker.extractVersion('v1.2'), '1.2');
  });

  test('compares semver versions correctly', () {
    expect(UpdateChecker.isNewerVersion('1.0.2', '1.0.0'), isTrue);
    expect(UpdateChecker.isNewerVersion('1.1.0', '1.0.9'), isTrue);
    expect(UpdateChecker.isNewerVersion('2.0.0', '1.9.9'), isTrue);
    expect(UpdateChecker.isNewerVersion('1.0.0', '1.0.0'), isFalse);
    expect(UpdateChecker.isNewerVersion('1.0.0', '1.0.2'), isFalse);
    expect(UpdateChecker.isNewerVersion('1.2', '1.2.0'), isFalse);
    expect(UpdateChecker.isNewerVersion('1.2.1', '1.2'), isTrue);
  });
}
