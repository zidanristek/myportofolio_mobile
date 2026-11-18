import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

/// Halaman utama MyPortfolio: identitas pemilik di atas, tombol aksi di bawah.
///
/// Stateless karena semua isinya tetap; tidak ada data yang berubah saat
/// aplikasi berjalan.
class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});

  final String npm = "2506534876";
  final String nama = "Muhammad Sultan Zidan";
  final String kelas = "PBP E";

  final List<ItemHomepage> items = [
    // Warna diambil dari palet web myportofolio (static/css/style.css).
    ItemHomepage("Lihat Proyek", Icons.folder, const Color(0xFF0968BF)),
    ItemHomepage("Lihat Experience", Icons.work, const Color(0xFF00A551)),
    ItemHomepage("Tambah Proyek", Icons.add_circle, const Color(0xFF022347)),
    ItemHomepage("Logout", Icons.logout, const Color(0xFFBA2121)),
  ];

  @override
  Widget build(BuildContext context) {
    // Scaffold menyediakan struktur visual dasar halaman (AppBar, Body, SnackBar).
    return Scaffold(
      // AppBar menampilkan bar bagian atas halaman aplikasi.
      appBar: AppBar(
        title: const Text(
          'MyPortfolio',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        // Ikon hamburger drawer ikut putih agar terbaca di AppBar indigo.
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const LeftDrawer(),
      // Body bisa di-scroll supaya kisi tidak terpotong di layar pendek.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Baris horizontal untuk menampilkan 3 InfoCard secara sejajar.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InfoCard(title: 'NPM', content: npm),
                InfoCard(title: 'Name', content: nama),
                InfoCard(title: 'Class', content: kelas),
              ],
            ),

            const SizedBox(height: 16.0),

            // Bagian tengah: pesan sambutan dan kisi tombol menu portofolio.
            Center(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Text(
                      'Selamat datang di MyPortfolio Mobile!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                  ),

                  // GridView menampilkan kartu tombol dalam tata letak kisi 3 kolom.
                  GridView.count(
                    // Scroll ditangani halaman, bukan kisi.
                    primary: false,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    crossAxisCount: 3,
                    // shrinkWrap agar ukuran kisi menyesuaikan tinggi konten anak.
                    shrinkWrap: true,
                    children: items.map((ItemHomepage item) {
                      return ItemCard(item);
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kartu kecil berisi satu data identitas, misalnya NPM atau kelas.
///
/// Lebarnya sepertiga lebih sedikit dari layar supaya tiga kartu muat
/// dalam satu [Row].
class InfoCard extends StatelessWidget {
  /// Label tebal di atas kartu, misalnya `'NPM'`.
  final String title;

  /// Nilai yang ditampilkan di bawah [title].
  final String content;

  const InfoCard({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      // Memberikan efek bayangan kartu elevasi 2 unit.
      elevation: 2.0,
      child: Container(
        // Menyesuaikan lebar kartu dengan proporsi layar (dibagi 3.5).
        width: MediaQuery.of(context).size.width / 3.5,
        padding: const EdgeInsets.all(16.0),
        // Menyusun teks title dan content secara vertikal.
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(content),
          ],
        ),
      ),
    );
  }
}

/// Data satu tombol aksi di halaman utama.
///
/// Warna disimpan di sini agar [ItemCard] tidak perlu mencocokkan nama
/// tombol untuk memilih warna.
class ItemHomepage {
  /// Teks tombol, juga dipakai di pesan SnackBar.
  final String name;

  /// Ikon yang tampil di atas [name].
  final IconData icon;

  /// Warna latar kartu.
  final Color color;

  ItemHomepage(this.name, this.icon, this.color);
}

/// Kartu tombol yang menampilkan satu [ItemHomepage].
///
/// Saat ditekan, kartu memunculkan SnackBar berisi nama tombol. Khusus
/// Logout, pengguna diminta konfirmasi lewat dialog lebih dulu.
class ItemCard extends StatelessWidget {
  /// Data tombol yang ditampilkan.
  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  // Menampilkan SnackBar dengan pesan interaktif.
  void _showPressed(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text("Kamu telah menekan tombol ${item.name}!")),
      );
  }

  // Logout tidak bisa dibatalkan, jadi pengguna diminta konfirmasi dulu.
  Future<bool> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Yakin ingin keluar dari MyPortfolio?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      // Warna latar diambil dari item, jadi tiap tombol bisa berbeda.
      color: item.color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        // Aksi ketika kartu ditekan oleh pengguna.
        onTap: () async {
          if (item.name == "Logout" && !await _confirmLogout(context)) {
            return;
          }
          if (context.mounted) _showPressed(context);
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item.icon,
                  color: Colors.white,
                  size: 30.0,
                ),
                const Padding(padding: EdgeInsets.all(3)),
                Text(
                  item.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
