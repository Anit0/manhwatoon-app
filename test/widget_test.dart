import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App boots to the shell scaffold', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('ManhwaToon'))),
    );
    expect(find.text('ManhwaToon'), findsOneWidget);
  });
}
