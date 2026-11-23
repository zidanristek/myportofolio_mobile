import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';

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

    expect(colors.length, 5);
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

  testWidgets('drawer moves between menu and project form', (tester) async {
    // The test font draws every glyph as wide as its size, which wraps the
    // drawer header far more than Roboto does; a smaller scale keeps it in.
    tester.platformDispatcher.textScaleFactorTestValue = 0.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Project'));
    await tester.pumpAndSettle();
    expect(find.text('Add Project Form'), findsOneWidget);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('PBP E'), findsOneWidget);
  });

  testWidgets('Tambah Proyek card opens the form and back returns',
      (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();
    expect(find.text('Add Project Form'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('PBP E'), findsOneWidget);
  });

  testWidgets('project form validates before showing its data',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProjectFormPage()));
    final save = find.text('Save');

    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Deskripsi proyek tidak boleh kosong!'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Nama Proyek'), 'Resik');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Deskripsi Proyek'), 'Bank sampah');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(find.text('Nama Proyek: Resik'), findsOneWidget);
    expect(find.text('Deskripsi: Bank sampah'), findsOneWidget);
    expect(find.text('Kategori: Web Development'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Resik'), findsNothing);
  });
}
