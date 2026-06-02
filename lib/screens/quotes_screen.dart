import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../services/theme_manager.dart';
import 'share_studio_screen.dart'; // Stüdyo eklendi!

class QuotesScreen extends StatefulWidget {
  const QuotesScreen({super.key});

  @override
  State<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedTab = "Tüm";
  late Future<List<Map<String, dynamic>>> _quotesFuture;

  @override
  void initState() {
    super.initState();
    _loadQuotes();
  }

  // İŞTE KIRMIZI EKRANI ÇÖZEN KOD BURASI!
  void _loadQuotes() {
    final future = DatabaseHelper.instance.getAllQuotes();
    setState(() {
      _quotesFuture = future;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeManager.isDarkMode,
      builder: (context, isDark, child) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text("Alıntılarım",
                  style: TextStyle(
                      color: ThemeManager.titleColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold))),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                      color: ThemeManager.cardColor,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                            color:
                                Colors.black.withOpacity(isDark ? 0.1 : 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4))
                      ]),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() {}),
                    style: TextStyle(color: ThemeManager.textColor),
                    decoration: InputDecoration(
                        hintText: "Alıntılarda ara... (Örn: Güneş)",
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        prefixIcon:
                            const Icon(Icons.search, color: Color(0xFF6750A4)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: ["Tüm", "Favorilerim"].map((tab) {
                    bool isSelected = _selectedTab == tab;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedTab = tab),
                      child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF4A3762)
                                  : ThemeManager.cardColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : Colors.grey.withOpacity(0.2))),
                          child: Text(tab,
                              style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : ThemeManager.textColor,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal))),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _quotesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting)
                      return const Center(child: CircularProgressIndicator());
                    if (!snapshot.hasData || snapshot.data!.isEmpty)
                      return Center(
                          child: Text("Henüz hiç alıntı yok.",
                              style: TextStyle(color: ThemeManager.textColor)));

                    var list = snapshot.data!;
                    if (_selectedTab == "Favorilerim")
                      list = list.where((q) => q["isFavorite"] == 1).toList();
                    String query = _searchController.text.toLowerCase().trim();
                    if (query.isNotEmpty)
                      list = list
                          .where((q) => q["text"]
                              .toString()
                              .toLowerCase()
                              .contains(query))
                          .toList();

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        var quote = list[index];
                        bool isFav = quote["isFavorite"] == 1;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              color: ThemeManager.cardColor,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4))
                              ]),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text("“",
                                      style: TextStyle(
                                          fontSize: 40,
                                          height: 0.5,
                                          color: Color(0xFF6750A4),
                                          fontWeight: FontWeight.w900)),
                                  const Spacer(),
                                  GestureDetector(
                                      onTap: () async {
                                        await DatabaseHelper.instance
                                            .toggleQuoteFavorite(
                                                quote["id"], isFav ? 0 : 1);
                                        _loadQuotes();
                                      },
                                      child: Icon(
                                          isFav
                                              ? Icons.favorite_rounded
                                              : Icons.favorite_border_rounded,
                                          color: isFav
                                              ? Colors.redAccent
                                              : Colors.grey[400]))
                                ],
                              ),
                              Text(quote["text"],
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: ThemeManager.textColor,
                                      height: 1.5,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                      child: Text(
                                          "${quote["bookTitle"]} – ${quote["bookAuthor"]}",
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[600],
                                              fontStyle: FontStyle.italic))),
                                  Text("s. ${quote["page"]}",
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF6750A4))),
                                  const SizedBox(width: 12),

                                  // --- YENİ STÜDYOYU AÇAN PAYLAŞ BUTONU ---
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ShareStudioScreen(
                                                    quoteText: quote["text"],
                                                    author: quote["bookAuthor"],
                                                    book: quote["bookTitle"]),
                                          ));
                                    },
                                    child: const Icon(Icons.share_outlined,
                                        size: 20, color: Color(0xFF6750A4)),
                                  ),
                                ],
                              )
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
      },
    );
  }
}
