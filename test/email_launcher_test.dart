import 'package:email_launcher/email_launcher.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('email_launcher');
  final methodCalls = <MethodCall>[];

  setUp(() {
    methodCalls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          methodCalls.add(methodCall);
          return true;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('launch sends the email payload over the method channel', () async {
    final launched = await EmailLauncher.launch(
      Email(
        to: const ['to@example.com'],
        cc: const ['cc@example.com'],
        bcc: const ['bcc@example.com'],
        subject: 'Subject',
        body: 'Body',
      ),
    );

    expect(launched, isTrue);
    expect(methodCalls, hasLength(1));
    expect(methodCalls.single.method, 'launch');
    expect(
      methodCalls.single.arguments,
      equals({
        'to': ['to@example.com'],
        'cc': ['cc@example.com'],
        'bcc': ['bcc@example.com'],
        'subject': 'Subject',
        'body': 'Body',
      }),
    );
  });
}
