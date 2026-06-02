import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String _avatarPath = "";

  Future<void> _pickAvatar() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _avatarPath = pickedFile.path);
    }
  }

  Future<void> _login() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lütfen ismini ve mailini gir.")));
      return;
    }

    // Kullanıcı bilgilerini cihazın kalıcı hafızasına kaydediyoruz
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userName', _nameController.text.trim());
    await prefs.setString('userEmail', _emailController.text.trim());
    await prefs.setString('userAvatar', _avatarPath);

    if (mounted) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const MainNavigation()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.auto_stories_rounded,
                  size: 64, color: Color(0xFF6750A4)),
              const SizedBox(height: 16),
              const Text("LibDiary'ye Katıl",
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF4A4458),
                      fontFamily: 'Georgia')),
              const SizedBox(height: 8),
              const Text("Dijital kütüphaneni oluşturmaya başla.",
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 48),

              // PROFİL FOTOĞRAFI SEÇİMİ
              GestureDetector(
                onTap: _pickAvatar,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2EBE1),
                        shape: BoxShape.circle,
                        image: _avatarPath.isNotEmpty
                            ? DecorationImage(
                                image: FileImage(File(_avatarPath)),
                                fit: BoxFit.cover)
                            : null,
                        border: Border.all(
                            color: const Color(0xFF6750A4).withOpacity(0.2),
                            width: 4),
                      ),
                      child: _avatarPath.isEmpty
                          ? const Icon(Icons.person_rounded,
                              size: 64, color: Color(0xFF6750A4))
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                          color: Color(0xFF6750A4), shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt_rounded,
                          color: Colors.white, size: 20),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // İSİM VE MAİL GİRİŞİ
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: "İsmin (Örn: Nazlısu Başak)",
                  prefixIcon:
                      const Icon(Icons.badge_rounded, color: Color(0xFF6750A4)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "E-posta Adresin",
                  prefixIcon:
                      const Icon(Icons.email_rounded, color: Color(0xFF6750A4)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 48),

              // GİRİŞ BUTONU
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A3762),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text("Kütüphaneme Gir",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
