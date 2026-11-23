import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

/// Pilihan kategori, sama dengan `Experience.EXPERIENCE_CHOICES` di web.
const experienceCategories = {
  'internship': 'Internship',
  'research': 'Research',
  'volunteer': 'Volunteer',
  'part-time': 'Part-Time',
  'full-time': 'Full-Time',
  'freelance': 'Freelance',
};

/// Batas panjang mengikuti `max_length` field di model web.
const titleMaxLength = 255;
const thumbnailMaxLength = 500;

String? validateTitle(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Judul tidak boleh kosong!';
  if (text.length > titleMaxLength) {
    return 'Judul maksimal $titleMaxLength karakter!';
  }
  return null;
}

String? validateDescription(String? value) {
  if ((value?.trim() ?? '').isEmpty) return 'Deskripsi tidak boleh kosong!';
  return null;
}

/// Thumbnail boleh kosong, tapi kalau diisi harus URL http atau https.
String? validateThumbnail(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return null;
  if (text.length > thumbnailMaxLength) {
    return 'URL maksimal $thumbnailMaxLength karakter!';
  }
  final uri = Uri.tryParse(text);
  final valid =
      uri != null &&
      (uri.scheme == 'http' || uri.scheme == 'https') &&
      uri.host.isNotEmpty;
  return valid ? null : 'URL harus diawali http:// atau https://';
}

/// Tanggal selesai wajib kalau pengalaman sudah berakhir,
/// dan tidak boleh lebih awal dari tanggal mulai.
String? validateEndDate(
  DateTime? start,
  DateTime? end, {
  required bool ongoing,
}) {
  if (ongoing) return null;
  if (end == null) return 'Pilih tanggal selesai atau tandai masih berjalan!';
  if (start != null && end.isBefore(start)) {
    return 'Tanggal selesai tidak boleh sebelum tanggal mulai!';
  }
  return null;
}

String formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/'
    '${date.month.toString().padLeft(2, '0')}/${date.year}';

/// Halaman form untuk menambahkan pengalaman baru ke portofolio.
class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({super.key});

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _startController = TextEditingController();
  final _endController = TextEditingController();

  String _category = 'full-time'; // default sama dengan model web
  DateTime? _startedAt;
  DateTime? _endedAt;
  bool _ongoing = false;

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startedAt : _endedAt) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startedAt = picked;
        _startController.text = formatDate(picked);
      } else {
        _endedAt = picked;
        _endController.text = formatDate(picked);
      }
    });
  }

  InputDecoration _decoration(String label, {String? hint, Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
    );
  }

  void _save() {
    _formKey.currentState!.validate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Add Experience Form')),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        // Scroll supaya tombol Simpan tetap terjangkau di layar sempit
        // atau saat papan ketik muncul.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // === Title ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  maxLength: titleMaxLength,
                  decoration: _decoration(
                    'Judul Experience',
                    hint: 'Contoh: Asisten Dosen PBP',
                  ),
                  validator: validateTitle,
                ),
              ),

              // === Description ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                  decoration: _decoration('Deskripsi'),
                  validator: validateDescription,
                ),
              ),

              // === Category ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  decoration: _decoration('Kategori'),
                  initialValue: _category,
                  items: experienceCategories.entries
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _category = value!),
                ),
              ),

              // === Thumbnail ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  keyboardType: TextInputType.url,
                  decoration: _decoration(
                    'Thumbnail (opsional)',
                    hint: 'https://...',
                  ),
                  validator: validateThumbnail,
                ),
              ),

              // === Started at ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _startController,
                  readOnly: true,
                  decoration: _decoration(
                    'Tanggal Mulai',
                    suffix: const Icon(Icons.calendar_today),
                  ),
                  onTap: () => _pickDate(isStart: true),
                  validator: (_) =>
                      _startedAt == null ? 'Pilih tanggal mulai!' : null,
                ),
              ),

              // === Ongoing ===
              SwitchListTile(
                title: const Text('Masih berjalan'),
                value: _ongoing,
                activeThumbColor: Colors.indigo,
                onChanged: (value) => setState(() => _ongoing = value),
              ),

              // === Ended at ===
              if (!_ongoing)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _endController,
                    readOnly: true,
                    decoration: _decoration(
                      'Tanggal Selesai',
                      suffix: const Icon(Icons.event),
                    ),
                    onTap: () => _pickDate(isStart: false),
                    validator: (_) => validateEndDate(
                      _startedAt,
                      _endedAt,
                      ongoing: _ongoing,
                    ),
                  ),
                ),

              // === Tombol Simpan ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.indigo),
                  ),
                  onPressed: _save,
                  child: const Text(
                    'Simpan',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
