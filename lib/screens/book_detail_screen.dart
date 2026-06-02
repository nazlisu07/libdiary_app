import 'package:flutter/material.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart'; // Müzik linki açmak için
import '../services/database_helper.dart';
import 'add_book_screen.dart';

class BookDetailScreen extends StatefulWidget {
  final Map<String, dynamic> book;

  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late Map<String, dynamic> currentBook;

  @override
  void initState() {
    super.initState();
    currentBook = widget.book;
  }

  // Düzenlemeden sonra güncel bilgileri ekrana çekmek için
  Future<void> _refreshBook() async {
    final db = await DatabaseHelper.instance.database;
    var res =
        await db.query('Book', where: 'id = ?', whereArgs: [currentBook['id']]);
    if (res.isNotEmpty) {
      setState(() {
        currentBook = res.first;
      });
    }
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text("Link açılamadı. Geçerli bir URL girdiğinden emin ol.")));
    }
  }

  Widget _buildStatBox(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF6750A4), size: 24),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A4458))),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildRatingRow(String label, double rating) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF4A4458),
                  fontSize: 15,
                  fontWeight: FontWeight.w500)),
          Row(
            children: [
              Text(rating.toStringAsFixed(1),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF6750A4))),
              const Icon(Icons.star_rounded,
                  color: Color(0xFFFFB13B), size: 18),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostItView(
      String label, String? text, Color color, double rotation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6750A4))),
        const SizedBox(height: 12),
        Transform.rotate(
          angle: rotation,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(2),
                    topRight: Radius.circular(24),
                    bottomLeft: Radius.circular(2),
                    bottomRight: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(4, 4))
                ]),
            child: Text(
                (text == null || text.trim().isEmpty)
                    ? "Henüz buraya bir not karalanmamış..."
                    : text,
                style: const TextStyle(
                    color: Color(0xFF4A4458),
                    fontSize: 15,
                    height: 1.6,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500)),
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }

  Widget _buildDetailsPage(
      double genelPuan, double hikaye, double karakter, double yazim) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          expandedHeight: 320,
          pinned: true,
          backgroundColor: const Color(0xFFFDFCF7),
          leading: IconButton(
            icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF4A4458), size: 18)),
            onPressed: () => Navigator.maybePop(context),
          ),
          actions: [
            // SAĞ ÜST DÜZENLE / SİL MENÜSÜ EKLENDİ
            PopupMenuButton<String>(
              icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.more_horiz_rounded,
                      color: Color(0xFF4A4458), size: 18)),
              onSelected: (value) async {
                if (value == 'edit') {
                  bool? updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              AddBookScreen(bookToEdit: currentBook)));
                  if (updated == true) _refreshBook();
                } else if (value == 'delete') {
                  await DatabaseHelper.instance.deleteBook(currentBook['id']);
                  if (mounted)
                    Navigator.pop(
                        context, true); // Sildiğini belirtmek için true döner
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [
                      Icon(Icons.edit_rounded,
                          color: Color(0xFF6750A4), size: 20),
                      SizedBox(width: 8),
                      Text("Kitabı Düzenle")
                    ])),
                const PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_rounded,
                          color: Colors.redAccent, size: 20),
                      SizedBox(width: 8),
                      Text("Kitabı Sil",
                          style: TextStyle(color: Colors.redAccent))
                    ])),
              ],
            )
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                    child: Container(
                        color: const Color(0xFF6750A4).withOpacity(0.05))),
                Positioned(
                  top: 80,
                  child: Hero(
                    tag: 'book_cover_${currentBook['id']}',
                    child: Container(
                      height: 220,
                      width: 150,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A3762),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 10))
                        ],
                        image: (currentBook['coverImage'] != null &&
                                currentBook['coverImage'].toString().isNotEmpty)
                            ? DecorationImage(
                                image:
                                    FileImage(File(currentBook['coverImage'])),
                                fit: BoxFit.cover)
                            : null,
                      ),
                      child: (currentBook['coverImage'] == null ||
                              currentBook['coverImage'].toString().isEmpty)
                          ? Center(
                              child: Text(
                                  currentBook['title']
                                      .toString()[0]
                                      .toUpperCase(),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold)))
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding:
                const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Text(currentBook['title'] ?? 'İsimsiz Kitap',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF4A4458))),
                      const SizedBox(height: 6),
                      Text(currentBook['author'] ?? 'Bilinmeyen Yazar',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: _buildStatBox(
                            "Sayfa",
                            currentBook['sayfaSayisi'].toString(),
                            Icons.menu_book_rounded)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildStatBox(
                            "Durum",
                            currentBook['status'] ?? '-',
                            Icons.bookmark_added_rounded)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildStatBox("Vibe", currentBook['vibe'] ?? '-',
                            Icons.auto_awesome_rounded)),
                  ],
                ),
                const SizedBox(height: 32),

                // YENİ EKLENEN PLAYLIST (MÜZİK) KARTI!
                if (currentBook['playlistUrl'] != null &&
                    currentBook['playlistUrl']
                        .toString()
                        .trim()
                        .isNotEmpty) ...[
                  const Text("Bu Kitabın Sesi (Playlist)",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A4458))),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => _launchURL(currentBook['playlistUrl']),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: const Color(0xFF1DB954).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xFF1DB954).withOpacity(0.3))),
                      child: Row(
                        children: [
                          Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                  color: Color(0xFF1DB954),
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.music_note_rounded,
                                  color: Colors.white, size: 28)),
                          const SizedBox(width: 16),
                          const Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text("Müzik Dinle",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF4A4458))),
                                Text("Okurken dinlemek için tıkla",
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey))
                              ])),
                          const Icon(Icons.arrow_forward_ios_rounded,
                              color: Color(0xFF1DB954), size: 18)
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: const Color(0xFF6750A4).withOpacity(0.1)),
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0xFF6750A4).withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5))
                      ]),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Genel Puan",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4A4458))),
                          Row(children: [
                            const Icon(Icons.emoji_events_rounded,
                                color: Color(0xFFFFB13B), size: 28),
                            const SizedBox(width: 8),
                            Text(genelPuan.toStringAsFixed(1),
                                style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4A4458)))
                          ]),
                        ],
                      ),
                      const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Divider(color: Colors.black12)),
                      _buildRatingRow("Hikaye Kurgusu", hikaye),
                      _buildRatingRow("Karakterler", karakter),
                      _buildRatingRow("Yazım Dili", yazim),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildPostItView("Kitap Özeti", currentBook['summary'],
                    const Color(0xFFFFF7D6), -0.015),
                _buildPostItView("Genel Düşüncelerim", currentBook['review'],
                    const Color(0xFFFCE4EC), 0.015),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildQuotesPage() {
    return FutureBuilder<List<Map<String, dynamic>>>(
        future:
            DatabaseHelper.instance.getQuotesForBook(currentBook['id'] as int),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF6750A4)));
          var quotes = snapshot.data ?? [];

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                pinned: true,
                backgroundColor: const Color(0xFFFDFCF7),
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
                  title: const Text("Altı Çizilenler",
                      style: TextStyle(
                          color: Color(0xFF4A4458),
                          fontWeight: FontWeight.w900,
                          fontSize: 24)),
                  background: Container(
                      color: const Color(0xFF6750A4).withOpacity(0.05)),
                ),
              ),
              if (quotes.isEmpty)
                SliverToBoxAdapter(
                    child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Center(
                            child: Text(
                                "Bu kitap için henüz altını çizdiğin bir satır yok.",
                                style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic)))))
              else
                SliverPadding(
                  padding: const EdgeInsets.only(
                      left: 24, right: 24, top: 16, bottom: 80),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      var quote = quotes[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color:
                                    const Color(0xFF6750A4).withOpacity(0.1)),
                            boxShadow: [
                              BoxShadow(
                                  color:
                                      const Color(0xFF6750A4).withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4))
                            ]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("\"${quote['text']}\"",
                                style: const TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF4A4458),
                                    height: 1.6,
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FontStyle.italic)),
                            if (quote['page'] != null &&
                                quote['page'].toString().isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                          color: const Color(0xFF6750A4)
                                              .withOpacity(0.08),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Text("Sayfa ${quote['page']}",
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF6750A4))))),
                            ]
                          ],
                        ),
                      );
                    }, childCount: quotes.length),
                  ),
                ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    double hikaye = currentBook['hikayePuan'] ?? 0.0;
    double karakter = currentBook['karakterPuan'] ?? 0.0;
    double yazim = currentBook['yazimDiliPuan'] ?? 0.0;
    double genelPuan = (hikaye + karakter + yazim) / 3;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF7),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            children: [
              _buildDetailsPage(genelPuan, hikaye, karakter, yazim),
              _buildQuotesPage()
            ],
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _currentPage == 0 ? 24 : 8,
                    decoration: BoxDecoration(
                        color: _currentPage == 0
                            ? const Color(0xFF6750A4)
                            : Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4))),
                AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _currentPage == 1 ? 24 : 8,
                    decoration: BoxDecoration(
                        color: _currentPage == 1
                            ? const Color(0xFF6750A4)
                            : Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
