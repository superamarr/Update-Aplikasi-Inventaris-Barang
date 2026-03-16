import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/app_colors.dart';
import '../screens/inventaris_screen.dart';
import '../screens/login_screen.dart';
import '../screens/onboarding_screen.dart';

class AuthController extends GetxController {
  final _client = Supabase.instance.client;
  final String _profilesTable = 'profiles';
  final displayName = ''.obs;

  String? get currentEmail => _client.auth.currentUser?.email;
  String get currentName => displayName.value;

  @override
  void onInit() {
    super.onInit();
    if (_client.auth.currentSession != null) {
      _loadOrCreateProfile();
    } else {
      Get.changeThemeMode(ThemeMode.light);
    }
  }

  Future<void> _loadOrCreateProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    try {
      final result = await _client
          .from(_profilesTable)
          .select('full_name')
          .eq('id', user.id)
          .maybeSingle();
      if (result != null && result['full_name'] != null) {
        displayName.value = (result['full_name'] as String).trim();
        return;
      }
      final metaName = (user.userMetadata?['full_name'] as String?)?.trim();
      final fallback =
          metaName?.isNotEmpty == true ? metaName! : (user.email ?? 'Pengguna').split('@').first;
      await _client.from(_profilesTable).insert({'id': user.id, 'full_name': fallback});
      displayName.value = fallback;
    } catch (e) {
      displayName.value = (user.email ?? 'Pengguna').split('@').first;
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
      await _loadOrCreateProfile();
      Get.offAll(() => const InventarisScreen());
      Get.snackbar(
        'Berhasil',
        'Login berhasil',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase().contains('invalid login')
          ? 'Email atau password yang Anda masukkan salah'
          : e.message;
      Get.snackbar(
        'Gagal',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Terjadi kesalahan saat login',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  Future<void> signUp(String email, String password, {String? fullName}) async {
    try {
      await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          if (fullName != null && fullName.trim().isNotEmpty) 'full_name': fullName.trim(),
        },
      );
      Get.snackbar(
        'Konfirmasi Email',
        'Silakan cek email Anda untuk konfirmasi pendaftaran',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 4),
      );
      Get.offAll(() => const LoginScreen());
    } on AuthException catch (e) {
      Get.snackbar(
        'Gagal',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Terjadi kesalahan saat mendaftar',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      displayName.value = '';
      Get.changeThemeMode(ThemeMode.light);
      Get.offAll(() => const OnboardingScreen());
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Gagal logout',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

}
