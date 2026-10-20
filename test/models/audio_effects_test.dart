import 'package:flutter_test/flutter_test.dart';
import 'package:studio_wiz/models/audio_effects.dart';

void main() {
  test('ReverbEffect process', () {
    final reverb = ReverbEffect(id: '1');
    final input = List<double>.filled(10000, 1.0);
    final output = reverb.process(input);
    expect(output.length, 10000);
  });
}
