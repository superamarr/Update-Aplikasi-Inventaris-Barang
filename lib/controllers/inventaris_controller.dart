import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/item.dart';
import '../utils/app_colors.dart';

class InventarisController extends GetxController {
  final items = <Item>[].obs;
  final isLoading = false.obs;
  final _client = Supabase.instance.client;
  final String _table = 'inventaris';
  final String _bucket = 'item_images';

  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'Semua'.obs;

  List<Item> get filteredItems {
    return items.where((item) {
      final sel = selectedCategory.value;
      final isCategoryMatch = sel == 'Semua' || item.category == sel.toUpperCase();
      final q = searchQuery.value.trim().toLowerCase();
      final isSearchMatch = q.isEmpty ||
          item.name.toLowerCase().contains(q) ||
          item.kodeBarang.toLowerCase().contains(q) ||
          item.location.toLowerCase().contains(q);
      return isCategoryMatch && isSearchMatch;
    }).toList();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void updateCategory(String category) {
    selectedCategory.value = category;
  }

  @override
  void onInit() {
    super.onInit();
    fetchItems();
  }

  Future<String?> _uploadImage(String id, Uint8List bytes) async {
    try {
      final fileName = '${id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final uid = _client.auth.currentUser?.id;
      final path = uid != null ? 'public/$uid/$fileName' : 'public/$fileName';
      
      debugPrint('Mencoba upload ke Bucket: $_bucket, Path: $path');

      await _client.storage.from(_bucket).uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );

      final imageUrl = _client.storage.from(_bucket).getPublicUrl(path);
      debugPrint('Berhasil Upload! Public URL: $imageUrl');
      return imageUrl;
    } catch (e) {
      debugPrint('GAGAL UPLOAD: $e');
      return null;
    }
  }

  void _showSuccessDialog(String title, String message) {
    Get.back(closeOverlays: true); 
    Future.delayed(const Duration(milliseconds: 100), () {
      Get.dialog(
        barrierDismissible: false,
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Column(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 64),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(message, textAlign: TextAlign.center),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Selesai'),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _showErrorDialog(String title, String message) {
    Get.back(closeOverlays: true);
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            const Icon(Icons.error, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Future<void> fetchItems() async {
    try {
      isLoading.value = true;
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .order('id', ascending: false);
          
      final data = response as List<dynamic>;
      items.assignAll(data.map((e) => Item.fromMap(e as Map<String, dynamic>)));
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Gagal memuat data dari Supabase: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createItem(Item item) async {
    try {
      debugPrint('Mulai proses createItem untuk: ${item.name}');
      String? imageUrl;
      if (item.imageBytes != null) {
        debugPrint('Mencoba mengunggah gambar...');
        imageUrl = await _uploadImage(item.id.toString(), item.imageBytes!);
        debugPrint('Hasil upload gambar (URL): $imageUrl');
        if (imageUrl == null) {
          _showErrorDialog(
            'Upload Gagal',
            'Gagal mengunggah gambar ke penyimpanan. Pastikan koneksi dan kebijakan bucket benar.',
          );
          return false;
        }
      }

      final userId = _client.auth.currentUser?.id;
      final newItem = item.copyWith(imageUrl: imageUrl, userId: userId);
      final data = newItem.toMap(includeId: false);
      debugPrint('Menyimpan data ke tabel $_table: $data');
      
      await _client.from(_table).insert(data);
      debugPrint('Berhasil insert ke database');
      
      await fetchItems();
      debugPrint('Berhasil fetchItems setelah insert');

      _showSuccessDialog(
        'Berhasil!',
        'Barang "${item.name}" telah berhasil disimpan ke inventaris.',
      );

      return true;
    } catch (e) {
      debugPrint('ERROR DI createItem: $e');
      _showErrorDialog(
        'Gagal Menyimpan',
        'Terjadi kesalahan saat menyimpan data: $e',
      );
      return false;
    }
  }

  Future<bool> updateItemRemote(Item item) async {
    try {
      debugPrint('Mulai proses updateItemRemote untuk: ${item.name}');
      String? imageUrl = item.imageUrl;
      if (item.imageBytes != null) {
        debugPrint('Mencoba mengunggah gambar baru...');
        imageUrl = await _uploadImage(item.id.toString(), item.imageBytes!);
        debugPrint('Hasil upload gambar baru (URL): $imageUrl');
      }

      final updatedItem = item.copyWith(imageUrl: imageUrl);
      final data = updatedItem.toMap(includeId: false);
      debugPrint('Memperbarui data di tabel $_table dengan ID ${item.id}: $data');
      
      await _client
          .from(_table)
          .update(data)
          .eq('id', item.id);
      debugPrint('Berhasil update di database');
      
      await fetchItems();
      debugPrint('Berhasil fetchItems setelah update');

      _showSuccessDialog(
        'Pembaruan Berhasil!',
        'Data "${item.name}" telah berhasil diperbarui.',
      );

      return true;
    } catch (e) {
      debugPrint('ERROR DI updateItemRemote: $e');
      _showErrorDialog(
        'Pembaruan Gagal',
        'Gagal memperbarui data: $e',
      );
      return false;
    }
  }

  Future<void> deleteItem(int index) async {
    final id = items[index].id;
    final itemName = items[index].name;
    try {
      await _client.from(_table).delete().eq('id', id);
      items.removeAt(index);
      Get.snackbar(
        'Berhasil',
        '"$itemName" telah dihapus dari inventaris',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Gagal menghapus data dari Supabase',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  Future<void> confirmDelete(int index) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Hapus Barang?'),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${items[index].name}"? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: AppColors.delete),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (result == true) {
      await deleteItem(index);
    }
  }
}
