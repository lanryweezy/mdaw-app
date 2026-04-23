import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void setupAudioPlayerMocks() {
  const MethodChannel channel = MethodChannel('xyz.luan/audioplayers');
  const MethodChannel globalChannel = MethodChannel('xyz.luan/audioplayers.global');

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
    return 1;
  });

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(globalChannel, (MethodCall methodCall) async {
    return 1;
  });
}
