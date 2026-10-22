import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:signup_form/main.dart';

void main() {
  testWidgets('empty form shows field errors on sign up', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    final button = find.widgetWithText(FilledButton, 'Sign up');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();

    expect(find.text('Name is too short'), findsOneWidget);
    expect(find.text('Email looks wrong'), findsOneWidget);
    expect(find.text('Password is too short'), findsOneWidget);
    expect(find.text('Choose a group'), findsOneWidget);
  });
}
