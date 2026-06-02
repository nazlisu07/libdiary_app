import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_helper.dart';
import '../services/theme_manager.dart';
import 'share_studio_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _vibeData = [];

  String userName = "";
  String userEmail = "";
  String userAvatar = "";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    var stats = await DatabaseHelper.instance.getOverallStats();
    var vibes = await DatabaseHelper.instance.getVibeDistribution();
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _stats = stats;
      _vibeData = vibes;
      userName = prefs.getString('userName') ?? "Kullanıcı";
      userEmail = prefs.getString('userEmail') ?? "mail@libdiary.com";
      userAvatar = prefs.getString('userAvatar') ?? "";
    });
  }

  void _showMonthlySummary(BuildContext context) async {
    var monthlyBooks = await DatabaseHelper.instance.getMonthlyBooks();
    if (!context.mounted) return;

    if (monthlyBooks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bu ay henüz kitap eklemedin!")));
      return;
    }

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ShareStudioScreen(
            isMonthly: true,
            monthlyBooks: monthlyBooks,
          ),
        ));
  }

  Widget _buildStatBox(String value, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
          color: ThemeManager.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.15 : 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: ThemeManager.textColor)),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white60 : Colors.grey[600])),
        ],
      ),
    );
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
              title: Text("Profil & İstatistikler",
                  style: TextStyle(
                      color: ThemeManager.titleColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold))),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            color: ThemeManager.cardColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10)
                            ]),
                        child: Container(
                          height: 72,
                          width: 72,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6750A4),
                            shape: BoxShape.circle,
                            image: userAvatar.isNotEmpty
                                ? DecorationImage(
                                    image: FileImage(File(userAvatar)),
                                    fit: BoxFit.cover)
                                : null,
                          ),
                          child: userAvatar.isEmpty
                              ? Center(
                                  child: Text(
                                      userName.isNotEmpty
                                          ? userName[0].toUpperCase()
                                          : "N",
                                      style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)))
                              : null,
                        )),
                    const SizedBox(width: 16),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(userName,
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: ThemeManager.textColor)),
                          Text(userEmail,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.white60
                                      : Colors.grey[600]))
                        ])),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                      color: ThemeManager.cardColor,
                      borderRadius: BorderRadius.circular(20)),
                  child: SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text("Gece Modu",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: ThemeManager.textColor)),
                    subtitle: Text(
                        isDark
                            ? "Karanlık okuma modu aktif"
                            : "Açık tema aktif",
                        style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : Colors.grey)),
                    secondary: Icon(
                        isDark
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        color: const Color(0xFF6750A4)),
                    activeColor: const Color(0xFF6750A4),
                    value: isDark,
                    onChanged: (bool value) =>
                        ThemeManager.isDarkMode.value = value,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                        child: _buildStatBox("${_stats['totalBooks'] ?? 0}",
                            "Toplam Kitap", isDark)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildStatBox(
                            "${_stats['readBooks'] ?? 0}", "Okuduğum", isDark)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildStatBox(
                            "${_stats['totalQuotes'] ?? 0}", "Alıntı", isDark)),
                  ],
                ),
                const SizedBox(height: 32),
                const Text("En Çok Okuduğum Türler",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6750A4))),
                const SizedBox(height: 16),
                Container(
                  height: 220,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: ThemeManager.cardColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                            color:
                                Colors.black.withOpacity(isDark ? 0.15 : 0.03),
                            blurRadius: 15,
                            offset: const Offset(0, 5))
                      ]),
                  child: _vibeData.isEmpty
                      ? const Center(child: Text("Yeterli veri yok."))
                      : PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            sections: _vibeData.asMap().entries.map((entry) {
                              int index = entry.key;
                              var data = entry.value;
                              List<Color> colors = [
                                const Color(0xFF6750A4),
                                const Color(0xFFFFB13B),
                                const Color(0xFF4A3762),
                                Colors.teal,
                                Colors.pink
                              ];
                              return PieChartSectionData(
                                  color: colors[index % colors.length],
                                  value: (data['count'] as int).toDouble(),
                                  title: data['vibe'].toString(),
                                  radius: 50,
                                  titleStyle: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white));
                            }).toList(),
                          ),
                        ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showMonthlySummary(context),
                    icon: const Icon(Icons.calendar_month_rounded,
                        color: Colors.white),
                    label: const Text("Bu Ay Okuduklarım Özeti",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFB13B),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20))),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}
