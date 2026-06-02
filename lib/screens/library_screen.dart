import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import 'dart:io';
import 'book_detail_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _selectedFilter = "Tüm";
  String _selectedGenre = "Tümü"; // Tür filtresi eklendi
  final List<String> _filters = ["Tüm", "Okunuyor", "Okundu", "Okunacak"];

  final List<String> _genres = [
    "Tümü",
    "Fantastik",
    "Bilim Kurgu",
    "Aksiyon / Macera",
    "Şiir",
    "Dünya Klasikleri",
    "Türk Klasikleri",
    "Hikaye",
    "Masal",
    "Gizem / Gerilim",
    "Korku",
    "Genç Kurgu",
    "Tarihi Kurgu",
    "LGBTQ+",
    "Çizgi Roman",
    "Kişisel Gelişim",
    "Biyografi / Otobiyografi",
    "Denemeler",
    "Felsefe",
    "Bilim",
    "Yetişkin Kurgu",
    "Çocuk Kitabı"
  ];

  void _showGenreFilter() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (context) {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 20),
            itemCount: _genres.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_genres[index],
                    style: TextStyle(
                        fontWeight: _selectedGenre == _genres[index]
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: _selectedGenre == _genres[index]
                            ? const Color(0xFF6750A4)
                            : Colors.black87)),
                trailing: _selectedGenre == _genres[index]
                    ? const Icon(Icons.check_circle, color: Color(0xFF6750A4))
                    : null,
                onTap: () {
                  setState(() => _selectedGenre = _genres[index]);
                  Navigator.pop(context);
                },
              );
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Kitaplığım",
            style: TextStyle(
                color: Color(0xFF1D1B20),
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        actions: [
          // TÜR FİLTRELEME İKONU
          IconButton(
              icon: Icon(Icons.tune_rounded,
                  color: _selectedGenre == "Tümü"
                      ? const Color(0xFF4A4458)
                      : const Color(0xFF6750A4)),
              onPressed: _showGenreFilter),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedGenre != "Tümü")
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Text("Filtre: $_selectedGenre",
                  style: const TextStyle(
                      color: Color(0xFF6750A4), fontWeight: FontWeight.bold)),
            ),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                bool isSelected = _selectedFilter == _filters[index];
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedFilter = _filters[index]),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                        color:
                            isSelected ? const Color(0xFF4A3762) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : Colors.black12)),
                    child: Center(
                        child: Text(_filters[index],
                            style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[700],
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                fontSize: 14))),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: DatabaseHelper.instance.getBooks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF6750A4)));
                if (!snapshot.hasData || snapshot.data!.isEmpty)
                  return Center(
                      child: Text("Henüz kitap eklemedin.",
                          style: TextStyle(
                              color: Colors.grey[500], fontSize: 16)));

                var books = snapshot.data!;
                if (_selectedFilter != "Tüm")
                  books = books
                      .where((book) => book['status'] == _selectedFilter)
                      .toList();
                if (_selectedGenre != "Tümü")
                  books = books
                      .where((book) => book['vibe'] == _selectedGenre)
                      .toList();

                if (books.isEmpty)
                  return const Center(
                      child: Text("Bu filtreye uygun kitap yok."));

                return GridView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.55,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 16),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    double gPuan = ((book['hikayePuan'] ?? 0) +
                            (book['karakterPuan'] ?? 0) +
                            (book['yazimDiliPuan'] ?? 0)) /
                        3;

                    return GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  BookDetailScreen(book: book))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Hero(
                              tag: 'book_cover_${book['id']}',
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF4A3762).withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 6,
                                        offset: const Offset(2, 4))
                                  ],
                                  image: (book['coverImage'] != null &&
                                          book['coverImage']
                                              .toString()
                                              .isNotEmpty)
                                      ? DecorationImage(
                                          image: FileImage(
                                              File(book['coverImage'])),
                                          fit: BoxFit.cover)
                                      : null,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(book['title'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Color(0xFF1D1B20))),
                          Text(book['author'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 11)),
                          Row(children: [
                            const Icon(Icons.star_rounded,
                                color: Color(0xFFFFB13B), size: 14),
                            const SizedBox(width: 4),
                            Text(gPuan > 0 ? gPuan.toStringAsFixed(1) : "-",
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4A4458)))
                          ]),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
