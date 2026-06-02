import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareStudioScreen extends StatefulWidget {
  final bool isMonthly;
  final String? quoteText;
  final String? author;
  final String? book;
  final List<Map<String, dynamic>>? monthlyBooks;

  const ShareStudioScreen(
      {super.key,
      this.isMonthly = false,
      this.quoteText,
      this.author,
      this.book,
      this.monthlyBooks});

  @override
  State<ShareStudioScreen> createState() => _ShareStudioScreenState();
}

class _ShareStudioScreenState extends State<ShareStudioScreen> {
  final GlobalKey _globalKey = GlobalKey();
  int _selectedTheme = 0;

  final List<List<Color>> _themes = [
    [const Color(0xFFa18cd1), const Color(0xFFfbc2eb)],
    [const Color(0xFFff9a9e), const Color(0xFFfecfef)],
    [const Color(0xFF84fab0), const Color(0xFF8fd3f4)],
    [const Color(0xFFa1c4fd), const Color(0xFFc2e9fb)],
    [const Color(0xFFcfd9df), const Color(0xFFe2ebf0)],
    [const Color(0xFFfbc2eb), const Color(0xFFa6c1ee)],
    [const Color(0xFFa8edea), const Color(0xFFfed6e3)],
    [const Color(0xFFe0c3fc), const Color(0xFF8ec5fc)],
    [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
    [const Color(0xFF43e97b), const Color(0xFF38f9d7)],
    [const Color(0xFFfa709a), const Color(0xFFfee140)],
    [const Color(0xFF30cfd0), const Color(0xFF330867)],
    [const Color(0xFFa8caba), const Color(0xFF5d4157)],
    [const Color(0xFF29323c), const Color(0xFF485563)],
    [const Color(0xFF1e3c72), const Color(0xFF2a5298)],
    [const Color(0xFF09203F), const Color(0xFF537895)],
    [const Color(0xFFB721FF), const Color(0xFF21D4FD)],
    [const Color(0xFFffecd2), const Color(0xFFfcb69f)],
    [const Color(0xFFfdcbf1), const Color(0xFFe6dee9)],
    [const Color(0xFFf093fb), const Color(0xFFf5576c)],
  ];

  Future<void> _captureAndShare() async {
    // 1. Kullanıcıya bilgi ver
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text("Görsel yüksek kalitede hazırlanıyor, lütfen bekleyin... 📸"),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFF6750A4),
      ),
    );

    try {
      // 2. Ekranın resmini çek
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // 3. Dosyayı kaydet
      final directory = await getApplicationDocumentsDirectory();
      final imagePath =
          await File('${directory.path}/libdiary_share.png').create();
      await imagePath.writeAsBytes(pngBytes);

      // İŞTE HATAYI ÇÖZEN KISIM BURASI (iOS için koordinat belirliyoruz)
      final size = MediaQuery.of(context).size;

      // 4. Paylaşım menüsünü aç
      await Share.shareXFiles(
        [XFile(imagePath.path)],
        text: 'LibDiary ile okuma günlüğümden...',
        sharePositionOrigin: Rect.fromLTWH(
            0, 0, size.width, size.height / 2), // Ekranın ortasından açılsın
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Paylaşım başarısız oldu: $e"),
              backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D1B20),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Paylaşım Stüdyosu",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
              icon: const Icon(Icons.share, color: Color(0xFFFFB13B), size: 28),
              onPressed: _captureAndShare)
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          RepaintBoundary(
            key: _globalKey,
            child: Container(
              width: 320,
              height: 500,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _themes[_selectedTheme]),
                  borderRadius: BorderRadius.circular(24)),
              child: widget.isMonthly
                  ? _buildMonthlyContent()
                  : _buildQuoteContent(),
            ),
          ),
          const Spacer(),
          const Text("Tema Seç (20 Çeşit)",
              style: TextStyle(
                  color: Colors.white70, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _themes.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => setState(() => _selectedTheme = index),
                  child: Container(
                    width: 50,
                    height: 50,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: _themes[index]),
                        border: Border.all(
                            color: _selectedTheme == index
                                ? Colors.white
                                : Colors.transparent,
                            width: 3)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildQuoteContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("“",
            style: TextStyle(
                fontSize: 64,
                height: 0.5,
                color: Colors.white70,
                fontWeight: FontWeight.w900,
                fontFamily: 'Georgia')),
        Text(widget.quoteText ?? "",
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 22,
                color: Colors.white,
                height: 1.5,
                fontStyle: FontStyle.italic,
                fontFamily: 'Georgia')),
        const SizedBox(height: 24),
        Container(width: 40, height: 1, color: Colors.white54),
        const SizedBox(height: 24),
        Text(widget.author ?? "",
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        Text(widget.book ?? "",
            style: const TextStyle(fontSize: 14, color: Colors.white70)),
        const Spacer(),
        _buildLogo(),
      ],
    );
  }

  Widget _buildMonthlyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text("Bu Ay Okuduklarım",
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Georgia')),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: widget.monthlyBooks!.length > 5
                ? 5
                : widget.monthlyBooks!.length,
            itemBuilder: (context, index) {
              var book = widget.monthlyBooks![index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    const Icon(Icons.bookmark, color: Colors.white70, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(book['title'],
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          Text(book['author'],
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12))
                        ])),
                  ],
                ),
              );
            },
          ),
        ),
        _buildLogo(),
      ],
    );
  }

  Widget _buildLogo() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.auto_stories_rounded, color: Colors.white54, size: 18),
        SizedBox(width: 8),
        Text("LibDiary",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.white54,
                letterSpacing: 1.5)),
      ],
    );
  }
}
