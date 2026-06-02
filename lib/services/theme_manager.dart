import 'package:flutter/material.dart';

class ThemeManager {
  // Şalterimiz: false ise gündüz, true ise gece modu
  static final ValueNotifier<bool> isDarkMode = ValueNotifier<bool>(false);

  // --- SOFT RENK MOTORU ---
  static Color get backgroundColor =>
      isDarkMode.value ? const Color(0xFF141218) : const Color(0xFFFDFCF7);
  static Color get cardColor =>
      isDarkMode.value ? const Color(0xFF211F26) : Colors.white;
  static Color get textColor =>
      isDarkMode.value ? const Color(0xFFE6E1E5) : const Color(0xFF4A4458);
  static Color get titleColor =>
      isDarkMode.value ? Colors.white : const Color(0xFF1D1B20);

  // Geçişli Arka Plan Gradyanları
  static List<Color> get bgGradient => isDarkMode.value
      ? [
          const Color(0xFF141218),
          const Color(0xFF1D1A22),
        ] // Gece Modu (Koyu mürdüm/siyah)
      : [
          const Color(0xFFFDFCF7),
          const Color(0xFFF2EBE1),
        ]; // Gündüz Modu (Soft krem)
}
