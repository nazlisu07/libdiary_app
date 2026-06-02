import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/physics.dart';
import 'package:image_picker/image_picker.dart';
import '../services/database_helper.dart';

class AddBookScreen extends StatefulWidget {
  final Map<String, dynamic>? bookToEdit; // EĞER DOLUYSA DÜZENLEME MODU ÇALIŞIR

  const AddBookScreen({super.key, this.bookToEdit});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen>
    with TickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _pageController = TextEditingController();
  final _summaryController = TextEditingController();
  final _reviewController = TextEditingController();
  final _playlistController = TextEditingController();

  String _selectedVibe = "Fantastik";
  String _selectedStatus = "Okunacak";
  String _coverImagePath = "";

  double _hikayePuan = 0.0;
  double _karakterPuan = 0.0;
  double _yazimDiliPuan = 0.0;

  final List<String> _genres = [
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

  final List<Map<String, TextEditingController>> _quotesList = [];

  bool _isLightOn = false;
  double _pullAmount = 0.0;
  late AnimationController _springController;
  late AnimationController _swingController;
  late Animation<double> _swingAnimation;

  final PageController _wizardController = PageController();
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _springController = AnimationController(
        vsync: this, lowerBound: 0, upperBound: double.infinity);
    _springController.addListener(
        () => setState(() => _pullAmount = _springController.value));
    _swingController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    _swingAnimation = Tween<double>(begin: 0.15, end: 0.0).animate(
        CurvedAnimation(parent: _swingController, curve: Curves.elasticOut));

    // EĞER DÜZENLEME MODUNDAYSAK BİLGİLERİ DOLDUR
    if (widget.bookToEdit != null) {
      final b = widget.bookToEdit!;
      _titleController.text = b['title'] ?? "";
      _authorController.text = b['author'] ?? "";
      _pageController.text = (b['sayfaSayisi'] ?? 0).toString();
      _summaryController.text = b['summary'] ?? "";
      _reviewController.text = b['review'] ?? "";
      _playlistController.text = b['playlistUrl'] ?? "";
      _selectedVibe = _genres.contains(b['vibe']) ? b['vibe'] : "Fantastik";
      _selectedStatus = ["Okunacak", "Okunuyor", "Okundu"].contains(b['status'])
          ? b['status']
          : "Okunacak";
      _coverImagePath = b['coverImage'] ?? "";
      _hikayePuan = b['hikayePuan'] ?? 0.0;
      _karakterPuan = b['karakterPuan'] ?? 0.0;
      _yazimDiliPuan = b['yazimDiliPuan'] ?? 0.0;

      // Alıntıları veritabanından çekip listeye ekle
      DatabaseHelper.instance.getQuotesForBook(b['id']).then((quotes) {
        if (quotes.isNotEmpty) {
          setState(() {
            for (var q in quotes) {
              _quotesList.add({
                "quote": TextEditingController(text: q['text']),
                "page": TextEditingController(text: q['page'].toString()),
              });
            }
          });
        } else {
          _quotesList.add({
            "quote": TextEditingController(),
            "page": TextEditingController()
          });
        }
      });
    } else {
      _quotesList.add(
          {"quote": TextEditingController(), "page": TextEditingController()});
    }
  }

  @override
  void dispose() {
    _springController.dispose();
    _swingController.dispose();
    for (var q in _quotesList) {
      q["quote"]!.dispose();
      q["page"]!.dispose();
    }
    super.dispose();
  }

  double get _genelPuan {
    double toplam = _hikayePuan + _karakterPuan + _yazimDiliPuan;
    return toplam > 0 ? toplam / 3 : 0.0;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _coverImagePath = pickedFile.path);
  }

  Widget _buildTextField(
      String label, TextEditingController controller, String hint,
      {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6750A4))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: const TextStyle(
              color: Color(0xFF4A4458), fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
                color: Colors.grey[400], fontWeight: FontWeight.normal),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.1))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide:
                    const BorderSide(color: Color(0xFF6750A4), width: 2)),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> items,
      Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6750A4))),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.withOpacity(0.1))),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF6750A4)),
              style: const TextStyle(
                  color: Color(0xFF4A4458),
                  fontSize: 15,
                  fontWeight: FontWeight.w500),
              items: items
                  .map((String item) =>
                      DropdownMenuItem<String>(value: item, child: Text(item)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPostItField(String label, TextEditingController controller,
      String hint, Color color, double rotation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6750A4))),
        const SizedBox(height: 12),
        Transform.rotate(
          angle: rotation,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(2),
                  topRight: Radius.circular(24),
                  bottomLeft: Radius.circular(2),
                  bottomRight: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(4, 4))
              ],
            ),
            child: TextField(
              controller: controller,
              maxLines: 5,
              style: const TextStyle(
                  color: Color(0xFF4A4458), fontSize: 15, height: 1.5),
              decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                      color: const Color(0xFF4A4458).withOpacity(0.4)),
                  border: InputBorder.none),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildRatingBar(
      {required String label,
      required double currentRating,
      required Function(double) onRatingChanged}) {
    double starSize = 28.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF4A4458),
                      fontWeight: FontWeight.bold)),
              Text(currentRating.toStringAsFixed(1),
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6750A4))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(10, (index) {
              int starNumber = index + 1;
              IconData iconData = currentRating >= starNumber
                  ? Icons.star_rounded
                  : currentRating >= starNumber - 0.5
                      ? Icons.star_half_rounded
                      : Icons.star_outline_rounded;
              return GestureDetector(
                onTapDown: (details) {
                  double tapPosition = details.localPosition.dx;
                  onRatingChanged(
                      starNumber - (tapPosition < (starSize / 2) ? 0.5 : 0.0));
                },
                child: Icon(iconData,
                    color: const Color(0xFFFFB13B), size: starSize),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveLamp() {
    return Positioned(
      top: 50,
      right: 30,
      child: AnimatedBuilder(
          animation: _swingAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _swingAnimation.value,
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  Icon(
                      _isLightOn
                          ? Icons.lightbulb_rounded
                          : Icons.lightbulb_outline_rounded,
                      size: 40,
                      color: _isLightOn
                          ? const Color(0xFFFFB13B)
                          : const Color(0xFF4A4458).withOpacity(0.5)),
                  GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        _pullAmount += details.delta.dy;
                        if (_pullAmount < 0) _pullAmount = 0;
                        if (_pullAmount > 100) _pullAmount = 100;
                      });
                    },
                    onPanEnd: (details) {
                      if (_pullAmount > 40) {
                        setState(() => _isLightOn = !_isLightOn);
                        _swingController.forward(from: 0.0);
                      }
                      final spring = SpringDescription(
                          mass: 1, stiffness: 400, damping: 10);
                      final simulation =
                          SpringSimulation(spring, _pullAmount, 0, 0);
                      _springController.animateWith(simulation);
                    },
                    child: Column(
                      children: [
                        Container(
                            width: 2,
                            height: 30 + _pullAmount,
                            color: const Color(0xFF4A4458).withOpacity(0.3)),
                        Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                                color: _isLightOn
                                    ? const Color(0xFFFFB13B)
                                    : const Color(0xFF4A4458),
                                shape: BoxShape.circle,
                                boxShadow: _isLightOn
                                    ? [
                                        BoxShadow(
                                            color: const Color(0xFFFFB13B)
                                                .withOpacity(0.5),
                                            blurRadius: 8)
                                      ]
                                    : [])),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding:
          const EdgeInsets.only(left: 24, right: 24, top: 120, bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.bookToEdit != null ? "Kitabı Düzenle" : "Kitabın Kimliği",
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF4A4458))),
          const SizedBox(height: 24),
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                width: 130,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10))
                  ],
                  image: _coverImagePath.isNotEmpty
                      ? DecorationImage(
                          image: FileImage(File(_coverImagePath)),
                          fit: BoxFit.cover)
                      : null,
                ),
                child: _coverImagePath.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                    color: const Color(0xFF6750A4)
                                        .withOpacity(0.1),
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.add_a_photo_rounded,
                                    size: 32, color: Color(0xFF6750A4)))
                          ])
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildTextField("Kitap Adı", _titleController, "Örn: Simyacı"),
          _buildTextField("Yazar", _authorController, "Örn: Paulo Coelho"),
          Row(children: [
            Expanded(
                flex: 2,
                child: _buildTextField(
                    "Sayfa Sayısı", _pageController, "Örn: 184",
                    isNumber: true)),
            const SizedBox(width: 16),
            Expanded(
                flex: 3,
                child: _buildDropdownField(
                    "Durum",
                    _selectedStatus,
                    ["Okunacak", "Okunuyor", "Okundu"],
                    (val) => setState(() => _selectedStatus = val!)))
          ]),
          _buildDropdownField("Tür (Vibe)", _selectedVibe, _genres,
              (val) => setState(() => _selectedVibe = val!)),
          _buildTextField("Müzik Listesi URL'si (Playlist)",
              _playlistController, "Spotify/Apple Music linkini yapıştır..."),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding:
          const EdgeInsets.only(left: 24, right: 24, top: 120, bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Benim Dünyam",
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF4A4458))),
          const SizedBox(height: 24),
          _buildPostItField(
              "Kitap Özeti",
              _summaryController,
              "Sence bu kitap kısaca ne anlatıyor?",
              const Color(0xFFFFF7D6),
              -0.015),
          _buildPostItField("Genel Yorumun", _reviewController,
              "Bu kitap sana ne hissettirdi?", const Color(0xFFFCE4EC), 0.015),
          const SizedBox(height: 8),
          const Text("Puanlama (10 Üzerinden)",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A4458))),
          const SizedBox(height: 16),
          _buildRatingBar(
              label: "Hikaye Kurgusu",
              currentRating: _hikayePuan,
              onRatingChanged: (val) => setState(() => _hikayePuan = val)),
          _buildRatingBar(
              label: "Karakterler",
              currentRating: _karakterPuan,
              onRatingChanged: (val) => setState(() => _karakterPuan = val)),
          _buildRatingBar(
              label: "Yazım Dili",
              currentRating: _yazimDiliPuan,
              onRatingChanged: (val) => setState(() => _yazimDiliPuan = val)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFF6750A4).withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5))
                ],
                border: Border.all(
                    color: const Color(0xFF6750A4).withOpacity(0.1))),
            child: Row(
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
                  Text(_genelPuan.toStringAsFixed(1),
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A4458)))
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding:
          const EdgeInsets.only(left: 24, right: 24, top: 120, bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Altı Çizilenler",
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF4A4458))),
          const SizedBox(height: 8),
          const Text(
              "Kitaptan unutmak istemediğin satırları ve sayfa numaralarını buraya bırak.",
              style: TextStyle(color: Colors.grey, fontSize: 15)),
          const SizedBox(height: 24),
          Column(
            children: _quotesList.asMap().entries.map((entry) {
              int index = entry.key;
              var item = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withOpacity(0.1))),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        flex: 4,
                        child: TextField(
                            controller: item["quote"],
                            maxLines: null,
                            decoration: InputDecoration(
                                hintText: "Alıntıyı buraya yaz...",
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                border: InputBorder.none,
                                isDense: true))),
                    Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey.withOpacity(0.2),
                        margin: const EdgeInsets.symmetric(horizontal: 12)),
                    Expanded(
                        flex: 1,
                        child: TextField(
                            controller: item["page"],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                hintText: "Sayfa",
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                border: InputBorder.none,
                                isDense: true))),
                    if (_quotesList.length > 1)
                      IconButton(
                          icon: const Icon(Icons.remove_circle_outline,
                              color: Colors.redAccent),
                          onPressed: () =>
                              setState(() => _quotesList.removeAt(index)))
                  ],
                ),
              );
            }).toList(),
          ),
          Center(
            child: TextButton.icon(
              onPressed: () => setState(() => _quotesList.add({
                    "quote": TextEditingController(),
                    "page": TextEditingController()
                  })),
              icon: const Icon(Icons.add_circle, color: Color(0xFF6750A4)),
              label: const Text("Yeni Alıntı Ekle",
                  style: TextStyle(
                      color: Color(0xFF6750A4),
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF7),
      body: Stack(
        children: [
          PageView(
            controller: _wizardController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) => setState(() => _currentStep = index),
            children: [_buildStep1(), _buildStep2(), _buildStep3()],
          ),
          IgnorePointer(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                  gradient: _isLightOn
                      ? RadialGradient(
                          center: const Alignment(0.8, -0.8),
                          radius: 1.5,
                          colors: [
                              const Color(0xFFFFD54F).withOpacity(0.25),
                              Colors.transparent
                            ])
                      : const RadialGradient(
                          colors: [Colors.transparent, Colors.transparent])),
            ),
          ),
          Positioned(
              top: 50,
              left: 16,
              child: IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: Color(0xFF4A4458), size: 32),
                  onPressed: () => Navigator.maybePop(context))),
          _buildInteractiveLamp(),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0xFF6750A4).withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, -5))
                  ]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    TextButton(
                        onPressed: () => _wizardController.previousPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOutBack),
                        child: const Text("Geri Dön",
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)))
                  else
                    const SizedBox(width: 80),
                  ElevatedButton(
                    onPressed: () async {
                      if (_currentStep < 2) {
                        _wizardController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOutBack);
                      } else {
                        Map<String, dynamic> row = {
                          'title': _titleController.text.trim().isEmpty
                              ? "İsimsiz Kitap"
                              : _titleController.text.trim(),
                          'author': _authorController.text.trim().isEmpty
                              ? "Bilinmeyen Yazar"
                              : _authorController.text.trim(),
                          'coverImage': _coverImagePath,
                          'vibe': _selectedVibe,
                          'status': _selectedStatus,
                          'sayfaSayisi':
                              int.tryParse(_pageController.text) ?? 0,
                          'hikayePuan': _hikayePuan,
                          'karakterPuan': _karakterPuan,
                          'yazimDiliPuan': _yazimDiliPuan,
                          'summary': _summaryController.text,
                          'review': _reviewController.text,
                          'playlistUrl': _playlistController.text,
                        };

                        try {
                          int bookId;
                          if (widget.bookToEdit != null) {
                            // DÜZENLEME MODU KAYDI
                            row['id'] = widget.bookToEdit!['id'];
                            await DatabaseHelper.instance.updateBook(row);
                            bookId = row['id'];
                            // Eski alıntıları sil, yenilerini kaydet
                            await DatabaseHelper.instance
                                .deleteQuotesForBook(bookId);
                          } else {
                            // YENİ KİTAP KAYDI
                            bookId =
                                await DatabaseHelper.instance.insertBook(row);
                          }

                          for (var q in _quotesList) {
                            if (q["quote"]!.text.isNotEmpty) {
                              await DatabaseHelper.instance.insertQuote({
                                'bookId': bookId,
                                'text': q["quote"]!.text,
                                'page': q["page"]!.text
                              });
                            }
                          }
                          if (mounted)
                            Navigator.of(context).pop(
                                true); // true gönderdik ki önceki sayfa yenilensin
                        } catch (e) {
                          if (mounted)
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Hata: $e")));
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A3762),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        elevation: _currentStep == 2 ? 8 : 0,
                        shadowColor: const Color(0xFF6750A4).withOpacity(0.5)),
                    child: Text(
                        widget.bookToEdit != null && _currentStep == 2
                            ? "Güncelle ✨"
                            : (_currentStep == 2
                                ? "Kütüphaneye Ekle ✨"
                                : "İleri"),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
