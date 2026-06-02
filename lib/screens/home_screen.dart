import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = "Okur";

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? "Okur";
      if (userName.contains(' ')) {
        userName =
            userName.split(' ')[0]; // Uzun isimleri bölüp sadece ilk ismi alır
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Merhaba, $userName 👋",
                style: const TextStyle(
                    color: Color(0xFF1D1B20),
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            const Text("Bugün ne okumak istersin?",
                style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<Map<String, dynamic>?>(
              future: DatabaseHelper.instance.getDailyQuote(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                      height: 150,
                      child: Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF6750A4))));
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                        color: const Color(0xFFFFF7D6),
                        borderRadius: BorderRadius.circular(24)),
                    child: const Text(
                        "Henüz bir alıntı eklemedin. Kitap eklerken yazdığın alıntılar her gün burada görünecek! ✨",
                        style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF4A4458),
                            fontStyle: FontStyle.italic)),
                  );
                }

                var randomQuote = snapshot.data!;
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7D6),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Bugünün Alıntısı",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6750A4))),
                      const SizedBox(height: 12),
                      const Text("“",
                          style: TextStyle(
                              fontSize: 40,
                              height: 0.5,
                              color: Color(0xFF6750A4),
                              fontWeight: FontWeight.w900)),
                      Text(randomQuote['text'],
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4A4458),
                              height: 1.4)),
                      const SizedBox(height: 12),
                      Text(
                          "– ${randomQuote['bookAuthor']}, ${randomQuote['bookTitle']} (s. ${randomQuote['page']})",
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                              fontStyle: FontStyle.italic)),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            const Text("Son Eklenen Kitaplar",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D1B20))),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: DatabaseHelper.instance.getBooks(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text("Henüz kitap eklemedin.",
                            style: TextStyle(color: Colors.grey)));
                  }
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var book = snapshot.data![index];
                      return Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child: Container(
                                    decoration: BoxDecoration(
                                        color: const Color(0xFF4A3762),
                                        borderRadius: BorderRadius.circular(12),
                                        image: (book['coverImage'] != null &&
                                                book['coverImage']
                                                    .toString()
                                                    .isNotEmpty)
                                            ? DecorationImage(
                                                image: FileImage(
                                                    File(book['coverImage'])),
                                                fit: BoxFit.cover)
                                            : null))),
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
      ),
    );
  }
}
