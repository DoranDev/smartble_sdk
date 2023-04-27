import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartble_sdk/smartble_sdk_method_channel.dart';

void main() {
  MethodChannelSmartbleSdk platform = MethodChannelSmartbleSdk();
  const MethodChannel channel = MethodChannel('smartble_sdk');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
