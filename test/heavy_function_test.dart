import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    debugPrint('start');
    final result = await compute(heavyFunction, 100);
    debugPrint(result.toString());
    debugPrint('end');
    // result.then((value) => debugPrint(value));
  });
}

int heavyFunction(int length) {
  int result = 0;
  for (int i = 0; i < length; i++) {
    result += i;
  }
  return result;
}
