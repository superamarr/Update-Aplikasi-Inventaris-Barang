import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/inventaris_controller.dart';
import '../models/item.dart';
import '../utils/app_colors.dart';

class TambahBarangScreen extends StatefulWidget {
  const TambahBarangScreen({super.key});

  @override
  State<TambahBarangScreen> createState() => _TambahBarangScreenState();
}

class _TambahBarangScreenState extends State<TambahBarangScreen> {
  final _formKey = GlobalKey<FormState>();
  final _kodeController = TextEditingController();
  final _namaController = TextEditingController();
  final _stokController = TextEditingController();
  final _lokasiController = TextEditingController();
  DateTime? _tanggalMasuk;
  String? _selectedKategori;
  String? _selectedSatuan;
  Uint8List? _imageBytes;
  bool _isSaving = false;
  late InventarisController _inventarisController;

  final List<String> _kategoriList = [
    'Elektronik',
    'Audio',
    'Furnitur',
    'Dekorasi',
    'Logistik',
  ];

  final List<String> _satuanList = [
    'Pcs / Buah',
    'Unit',
    'Set',
    'Lusin',
    'Kg',
  ];

  bool get _hasAnyInput {
    return _kodeController.text.isNotEmpty ||
        _namaController.text.isNotEmpty ||
        _stokController.text.isNotEmpty ||
        _lokasiController.text.isNotEmpty ||
        _selectedKategori != null ||
        _selectedSatuan != null ||
        _tanggalMasuk != null ||
        _imageBytes != null;
  }

  @override
  void initState() {
    super.initState();
    _inventarisController = Get.find<InventarisController>();
  }

  @override
  void dispose() {
    _kodeController.dispose();
    _namaController.dispose();
    _stokController.dispose();
    _lokasiController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (!_hasAnyInput) return true;
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Batalkan Pengisian?'),
        content: const Text(
          'Data yang sudah diisi akan hilang. Apakah Anda yakin ingin kembali?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Tetap Mengisi'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: AppColors.delete),
            child: const Text('Ya, Kembali'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _tanggalMasuk = picked;
      });
    }
  }

  Future<void> _simpan() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    Get.dialog(
      const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Menyimpan data...'),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final category = _selectedKategori!.toUpperCase();
      final userId = Supabase.instance.client.auth.currentUser?.id; 
      final item = Item(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _namaController.text.trim(),
        userId: userId,
        kodeBarang: _kodeController.text.trim(),
        category: category,
        stock: int.parse(_stokController.text.trim()),
        satuan: _selectedSatuan!,
        location: _lokasiController.text.trim(),
        tanggalMasuk: _tanggalMasuk,
        imageBytes: _imageBytes,
        icon: getIconForCategory(category),
        iconBgColor: getBgColorForCategory(category),
        categoryColor: getCategoryBadgeColor(category),
      );

      await _inventarisController.createItem(item);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Theme.of(context).cardColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop) {
          Get.back();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).cardColor,
          elevation: 0,
          scrolledUnderElevation: 1,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop) {
                Get.back();
              }
            },
          ),
          title: Text(
            'Tambah Barang Baru',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  color: Theme.of(context).cardColor,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.inventory_2_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informasi Detail Barang',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Lengkapi formulir di bawah untuk mendaftarkan barang baru ke sistem.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildLabel('Nama Barang'),
                      TextFormField(
                        controller: _namaController,
                        decoration: _buildInputDecoration(
                          hintText: 'Masukkan nama barang',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama barang wajib diisi';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),
                      _buildLabel('Kode Barang'),
                      TextFormField(
                        controller: _kodeController,
                        decoration: _buildInputDecoration(
                          hintText: 'Contoh: ELK-001',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Kode barang wajib diisi';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),
                      _buildLabel('Kategori'),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedKategori,
                        decoration: _buildInputDecoration(
                          hintText: 'Pilih Kategori',
                        ),
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.textSecondary,
                        ),
                        items: _kategoriList.map((item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedKategori = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Kategori wajib dipilih';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),
                      _buildLabel('Jumlah Stok'),
                      TextFormField(
                        controller: _stokController,
                        keyboardType: TextInputType.number,
                        decoration: _buildInputDecoration(
                          hintText: 'Masukkan jumlah stok',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Jumlah stok wajib diisi';
                          }
                          final stok = int.tryParse(value.trim());
                          if (stok == null) {
                            return 'Masukkan angka yang valid';
                          }
                          if (stok <= 0) {
                            return 'Stok harus lebih dari 0';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),
                      _buildLabel('Satuan'),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedSatuan,
                        decoration: _buildInputDecoration(
                          hintText: 'Pcs / Buah',
                        ),
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.textSecondary,
                        ),
                        items: _satuanList.map((item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSatuan = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Satuan wajib dipilih';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),
                      _buildLabel('Lokasi Penyimpanan'),
                      TextFormField(
                        controller: _lokasiController,
                        decoration: _buildInputDecoration(
                          hintText: 'Contoh: Rak A-12, Lantai 2',
                          prefixIcon: const Icon(
                            Icons.location_on_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Lokasi penyimpanan wajib diisi';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),
                      _buildLabel('Tanggal Masuk'),
                      GestureDetector(
                        onTap: _pickDate,
                        child: AbsorbPointer(
                          child: TextFormField(
                            decoration: _buildInputDecoration(
                              hintText: _tanggalMasuk != null
                                  ? '${_tanggalMasuk!.day.toString().padLeft(2, '0')}/${_tanggalMasuk!.month.toString().padLeft(2, '0')}/${_tanggalMasuk!.year}'
                                  : 'dd/mm/yyyy',
                              prefixIcon: const Icon(
                                Icons.calendar_today_outlined,
                                color: AppColors.textSecondary,
                                size: 20,
                              ),
                              suffixIcon: const Icon(
                                Icons.calendar_month_outlined,
                                color: AppColors.textSecondary,
                                size: 20,
                              ),
                            ),
                            validator: (value) {
                              if (_tanggalMasuk == null) {
                                return 'Tanggal masuk wajib dipilih';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      _buildLabel('Foto Barang'),
                      Row(
                        children: [
                          if (_imageBytes != null) ...[
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.memory(
                                    _imageBytes!,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: -4,
                                  right: -4,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _imageBytes = null;
                                      });
                                    },
                                    child: Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        size: 14,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                          ],
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 1.5,
                                ),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo_outlined,
                                    size: 24,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Tambah',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _simpan,
                          icon: const Icon(Icons.save, color: Colors.white),
                          label: const Text(
                            'Simpan Barang',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
