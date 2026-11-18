import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/main.dart';

void main() {
  testWidgets('shows owner identity', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('2506534876'), findsOneWidget);
    expect(find.text('Muhammad Sultan Zidan'), findsOneWidget);
    expect(find.text('PBP E'), findsOneWidget);
  });

  testWidgets('every action card has its own color', (tester) async {
    await tester.pumpWidget(const MyApp());

    final colors = tester
        .widgetList<Material>(find.descendant(
          of: find.byType(GridView),
          matching: find.byType(Material),
        ))
        .map((m) => m.color)
        .toList();

    expect(colors.length, 4);
    expect(colors.toSet().length, colors.length);
  });

  testWidgets('tapping a card shows its name in a SnackBar', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Lihat Proyek'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Kamu telah menekan tombol Lihat Proyek!'), findsOneWidget);
  });

  testWidgets('logout waits for confirmation', (tester) async {
    await tester.pumpWidget(const MyApp());
    final logoutCard = find.text('Logout');
    await tester.ensureVisible(logoutCard);
    await tester.pumpAndSettle();

    await tester.tap(logoutCard);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(find.text('Kamu telah menekan tombol Logout!'), findsNothing);

    await tester.tap(logoutCard);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Logout'));
    await tester.pumpAndSettle();
    expect(find.text('Kamu telah menekan tombol Logout!'), findsOneWidget);
  });
}
