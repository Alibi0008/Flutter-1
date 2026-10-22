import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:reading_list/main.dart';
import 'package:reading_list/models/book.dart';

void main() {
  test('Level 1 dart helpers', () {
    expect(totalPages(seed), 1220);
    expect(unread(seed).length, 4);
    expect(
      Book.fromMap({'title': 'X', 'author': 'Y', 'pages': 10}).toString(),
      'X — Y, 10 pp.',
    );
    expect(authors(seed).length, 5);
  });

  testWidgets('library filter and form validation', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.textContaining('Reading list (5)'), findsOneWidget);
    expect(find.text('Books'), findsOneWidget);
    expect(find.text('1220'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Unread'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Reading list (4)'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('At least 2 characters'), findsOneWidget);
    expect(find.text('Author is required'), findsOneWidget);
    expect(find.text('A whole number above 0'), findsOneWidget);
  });
}
