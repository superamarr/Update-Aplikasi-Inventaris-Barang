import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/inventaris_controller.dart';
import '../utils/app_colors.dart';
import '../widgets/item_card.dart';
import 'edit_barang_screen.dart';
import 'tambah_barang_screen.dart';
import '../models/item.dart';
import '../controllers/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InventarisScreen extends GetView<InventarisController> {
  const InventarisScreen({super.key});

  Future<void> _navigateToTambah() async {
    await Get.to(() => const TambahBarangScreen());
  }

  Future<void> _navigateToEdit(Item item) async {
    await Get.to(
      () => EditBarangScreen(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final email =
        auth.currentEmail ?? Supabase.instance.client.auth.currentUser?.email ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selamat Datang,',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Obx(() {
                          final name = auth.currentName.isNotEmpty
                              ? auth.currentName
                              : (email.isNotEmpty
                                  ? email.split('@').first
                                  : 'Pengguna');
                          return Text(
                            name,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).textTheme.headlineSmall?.color,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        Get.changeThemeMode(
                          Get.isDarkMode ? ThemeMode.light : ThemeMode.dark,
                        );
                      },
                      icon: Icon(
                        Get.isDarkMode
                            ? Icons.light_mode_outlined
                            : Icons.wb_sunny_outlined,
                        color: Get.isDarkMode ? Colors.yellow : const Color(0xFF1A1C1E),
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () => _showLogoutConfirmation(context, auth),
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: Color(0xFFDC3545),
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                onChanged: controller.updateSearchQuery,
                decoration: InputDecoration(
                  hintText: 'Cari inventaris...',
                  hintStyle: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(0.6),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(0.6),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Obx(() => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      _buildCategoryChip('Semua', 'Semua'),
                      _buildCategoryChip('Elektronik', 'ELEKTRONIK'),
                      _buildCategoryChip('Audio', 'AUDIO'),
                      _buildCategoryChip('Furnitur', 'FURNITUR'),
                      _buildCategoryChip('Dekorasi', 'DEKORASI'),
                      _buildCategoryChip('Logistik', 'LOGISTIK'),
                    ],
                  ),
                )),

            const SizedBox(height: 12),

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.filteredItems.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 100),
                  itemCount: controller.filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = controller.filteredItems[index];
                    return ItemCard(
                      item: item,
                      onEdit: () => _navigateToEdit(item),
                      onDelete: () => controller.confirmDelete(controller.items.indexOf(item)),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToTambah,
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildCategoryChip(String label, String key) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: FilterChip(
        label: Text(label),
        selected: controller.selectedCategory.value.toUpperCase() == key.toUpperCase(),
        onSelected: (val) => controller.updateCategory(key),
        backgroundColor: Theme.of(Get.context!).cardColor,
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: (controller.selectedCategory.value.toUpperCase() == key.toUpperCase())
              ? Colors.white
              : Theme.of(Get.context!).textTheme.bodyMedium?.color,
          fontWeight: (controller.selectedCategory.value.toUpperCase() == key.toUpperCase())
              ? FontWeight.bold
              : FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: (controller.selectedCategory.value.toUpperCase() == key.toUpperCase())
                ? AppColors.primary
                : Theme.of(Get.context!).dividerColor,
          ),
        ),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFFDEEE7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.inventory_2_outlined,
                size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada barang',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Theme.of(Get.context!).textTheme.bodyLarge?.color),
          ),
          const SizedBox(height: 6),
          Text(
            'Tekan tombol + untuk menambahkan\nbarang baru ke inventaris',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13,
                color: Theme.of(Get.context!).textTheme.bodyMedium?.color),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, AuthController auth) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Konfirmasi Logout',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF6C757D))),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              auth.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC3545),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
