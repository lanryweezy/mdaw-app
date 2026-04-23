import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'mock_audioplayer.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupAudioPlayerMocks();
  await testMain();
}
