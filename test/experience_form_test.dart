import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';

Future<void> _pickToday(WidgetTester tester, String label) async {
  final field = find.widgetWithText(TextFormField, label);
  await tester.ensureVisible(field);
  await tester.tap(field);
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

Future<void> _save(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Simpan'));
  await tester.tap(find.text('Simpan'));
  await tester.pumpAndSettle();
}

void main() {
  group('validators follow the web model', () {
    test('title rejects blank, whitespace and over 255 characters', () {
      expect(validateTitle(''), isNotNull);
      expect(validateTitle('   '), isNotNull);
      expect(validateTitle('a' * 256), isNotNull);
      expect(validateTitle('Asisten Dosen'), isNull);
    });

    test('description rejects whitespace only', () {
      expect(validateDescription(' \n '), isNotNull);
      expect(validateDescription('Membantu lab'), isNull);
    });

    test('thumbnail is optional but must be an http or https URL', () {
      expect(validateThumbnail(''), isNull);
      expect(validateThumbnail('https://example.com/a.png'), isNull);
      expect(validateThumbnail('example.com/a.png'), isNotNull);
      expect(validateThumbnail('ftp://example.com/a.png'), isNotNull);
      expect(validateThumbnail('https://${'a' * 500}.com'), isNotNull);
    });

    test('end date is required unless ongoing and never before start', () {
      final start = DateTime(2026, 3, 10);
      expect(validateEndDate(start, null, ongoing: false), isNotNull);
      expect(validateEndDate(start, null, ongoing: true), isNull);
      expect(
        validateEndDate(start, DateTime(2026, 3, 9), ongoing: false),
        isNotNull,
      );
      expect(validateEndDate(start, start, ongoing: false), isNull);
    });
  });

  testWidgets('Tambah Experience card opens the form and back returns',
      (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.ensureVisible(find.text('Tambah Experience'));
    await tester.tap(find.text('Tambah Experience'));
    await tester.pumpAndSettle();
    expect(find.text('Add Experience Form'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('PBP E'), findsOneWidget);
  });

  testWidgets('drawer opens the experience form and Home returns',
      (tester) async {
    // Same reason as the project drawer test: the test font wraps the header.
    tester.platformDispatcher.textScaleFactorTestValue = 0.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(find.text('Add Project'), findsOneWidget);
    await tester.tap(find.text('Add Experience'));
    await tester.pumpAndSettle();
    expect(find.text('Add Experience Form'), findsOneWidget);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('PBP E'), findsOneWidget);
  });

  testWidgets('invalid input shows errors and no dialog', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ExperienceFormPage()));

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Judul Experience'),
      '   ',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Thumbnail (opsional)'),
      'bukan-url',
    );
    await _save(tester);

    expect(find.text('Judul tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Deskripsi tidak boleh kosong!'), findsOneWidget);
    expect(find.text('URL harus diawali http:// atau https://'), findsOneWidget);
    expect(find.text('Pilih tanggal mulai!'), findsOneWidget);
    expect(
      find.text('Pilih tanggal selesai atau tandai masih berjalan!'),
      findsOneWidget,
    );
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('valid input on a narrow screen shows the summary dialog',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: ExperienceFormPage()));

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Judul Experience'),
      'Asisten Dosen PBP',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Deskripsi'),
      'Membantu lab Flutter',
    );
    await _pickToday(tester, 'Tanggal Mulai');
    await _pickToday(tester, 'Tanggal Selesai');
    await _save(tester);

    expect(find.text('Experience berhasil disimpan!'), findsOneWidget);
    expect(
      find.textContaining('Judul: Asisten Dosen PBP', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.textContaining('Kategori: Full-Time', findRichText: true),
      findsOneWidget,
    );

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Add Experience Form'), findsOneWidget);
  });

  testWidgets('ongoing hides the end date and shows it in the dialog',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ExperienceFormPage()));

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Judul Experience'),
      'Riset',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Deskripsi'),
      'Riset AI',
    );
    await _pickToday(tester, 'Tanggal Mulai');
    await tester.tap(find.text('Masih berjalan'));
    await tester.pumpAndSettle();
    expect(find.text('Tanggal Selesai'), findsNothing);

    await _save(tester);
    expect(
      find.textContaining('Selesai: Masih berjalan', findRichText: true),
      findsOneWidget,
    );
  });
}
