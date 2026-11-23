# myportofolio_mobile

Nama : Muhammad Sultan Zidan
NPM : 2506534876
Kelas : PBP E

Aplikasi mobile untuk [myportofolio](https://github.com/zidanristek/myportofolio), dibuat dengan Flutter untuk mata kuliah PBP (CSGE602022) Gasal 2026/2027.

## Setup

Butuh Flutter 3.38 atau lebih baru.

```bash
git clone https://github.com/zidanristek/myportofolio_mobile.git
cd myportofolio_mobile
flutter pub get
flutter run -d chrome
```

Cek kode dengan `flutter analyze` dan jalankan tes dengan `flutter test`.

## Progres

| Minggu | Pekerjaan |
|---|---|
| Tutorial 08 | Halaman utama di `lib/menu.dart`: `InfoCard` identitas dan grid `ItemCard` dengan SnackBar |
| Tugas 7 | Identitas sendiri, 4 tombol (Lihat Proyek, Lihat Experience, Tambah Proyek, Logout) dengan warna dari palet web, konfirmasi Logout, halaman bisa di-scroll, dan tes widget |
| Tutorial 09 | Import `material_ui`, `LeftDrawer` (Home, Add Project), `ProjectFormPage` dengan validasi dan dialog data, kartu Tambah Proyek membuka form, struktur `screens/` dan `widgets/` |
| Tugas 8 | `ExperienceFormPage` mengikuti model `Experience` di web (judul, deskripsi, kategori, thumbnail, tanggal mulai/selesai dengan `showDatePicker()`, switch masih berjalan), validasi panjang, URL, dan urutan tanggal, dialog ringkasan, kartu Tambah Experience (`Navigator.push`), opsi Add Experience di drawer, dan tes widget |

## Pertanyaan Reflektif

### Tugas 7

1. Widget tree itu widget yang nested di dalam widget lain, jadi parent ngasih constraint ke child-nya lalu child nentuin size sendiri dan parent yang ngatur posisinya.
2. Aku pakai `MaterialApp` sebagai root dan `Scaffold` + `AppBar` buat struktur halaman, terus layout pakai `SingleChildScrollView`/`Padding`/`Column`/`Row`/`Center`/`SizedBox`/`Container`/`GridView.count`, isi kartu pakai `Card`/`Material`/`InkWell`/`Text`/`Icon`, feedback pakai `SnackBar` dan `AlertDialog`, plus custom widget `MyHomePage`/`InfoCard`/`ItemCard`.
3. `MaterialApp` udah nyediain theme, `Navigator`, dan `MediaQuery` buat semua widget di bawahnya, makanya jadi root karena tanpa itu `Scaffold` bakal error "No MediaQuery widget ancestor found".
4. `StatelessWidget` propertinya immutable jadi nggak bisa rebuild sendiri, sedangkan `StatefulWidget` punya state yang bisa diubah lewat `setState`, jadi Stateless cocok buat halaman statis kayak menu ini dan Stateful buat data yang berubah kayak form atau counter.
5. `BuildContext` itu lokasi widget di tree yang dipakai buat ngakses widget di atasnya, contohnya `Theme.of(context)` dan `ScaffoldMessenger.of(context)` di method `build`.
6. Hot reload ngerebuild widget tree tanpa ngilangin state sedangkan hot restart ngulang app dari awal sampai state hilang, jadi kalau ngubah `main()` atau `initState()` harus hot restart dan kalau ngubah `pubspec.yaml` atau kode native harus full restart.

### Tugas 8

1. `push()` nambahin route baru ke atas stack jadi bisa back ke halaman sebelumnya, `pushReplacement()` replace route sekarang dengan route baru, dan `pop()` remove route paling atas dari stack, jadi card Tambah Experience pakai `push()` sedangkan Home di drawer pakai `pushReplacement()` ke `MyHomePage` biar stack-nya nggak terus bertambah.
2. Semua page pakai `Scaffold` dengan `AppBar` di atas dan `LeftDrawer` yang sama, jadi layout tiap page konsisten, contohnya warna indigo dipakai di `AppBar` project form, experience form, dan header drawer.
3. Form-nya pakai layout satu kolom biar gampang diisi berurutan di mobile, `Padding` ngasih spacing antar input, dan `SingleChildScrollView` bikin form scrollable jadi button Simpan tetap reachable waktu screen sempit atau keyboard muncul.
4. `GlobalKey<FormState>` dipakai buat manggil `validate()` yang ngejalanin semua `validator` dan nampilin error message di field yang invalid, contohnya thumbnail `example.com/a.png` di-reject karena nggak diawali `http://` atau `https://`, dan `TextInputType.url` aja nggak cukup karena itu cuma ngubah layout keyboard, user tetap bisa ketik atau paste input apa aja.

## AI Disclosure

### Tugas 7

Mostly kebanyakan masih ngikutin tutorial, ngelihat tutorial youtube terkait flutter, terus coba implemence. Penggunaan AI mostly disini buat ngemandu ketika ada yg error dan ngerubah kode agar penamaan variable lebih baik, kode lebih rapih, dan dokumentasi. Karena saya masih belajar standard prinsiple di Flutter jadi lebih baik jika saya menanyakan hal tersebut ke AI based on riset yang saya temukan

### Tugas 8

Pakai Claude buat bantu ngeplan dari checklist tugas agar memenuhi 100% rubrik penilaian, ngebantu ngenulis `ExperienceFormPage` yang fieldnya di fetch  dari model `Experience` di web, dan bantu ngenulis tes widget. Kekurangannya kelihatan pas AI-nya malah minta saya reskontruksi semua file dan ujung-ujungnya banyak yg error akibat overthinking itu, jadi harus aku cek dan benerin di commit `style: normalize line endings to lf`, terus first test juga gagal karena card kelima ada di outside layar dan finder teksnya agak aneh, jadi tetap harus dicek manual lewat `flutter test` dan dijalanin langsung di Chrome.
