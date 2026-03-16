# 📦 Dokumentasi Proyek — Inventaris Barang

---

## 📋 Daftar Isi

1. [Gambaran Umum](#1-gambaran-umum)
2. [Teknologi & Dependensi](#2-teknologi--dependensi)
3. [Struktur Direktori](#3-struktur-direktori)
4. [Arsitektur Aplikasi](#4-arsitektur-aplikasi)
5. [Design System](#5-design-system)
6. [Model Data](#6-model-data)
7. [Controller](#7-controller--state-management)
8. [Fitur & Tampilan](#8-fitur--tampilan)
   - [8.1 Onboarding (Onboarding Screen)](#81-onboarding--onboarding-screen)
   - [8.2 Masuk (Login Screen)](#82-masuk--login-screen)
   - [8.3 Daftar (Register Screen)](#83-daftar--register-screen)
   - [8.4 Halaman Utama (Inventaris Screen)](#84-halaman-utama--inventaris-screen)
   - [8.5 Tambah Barang](#85-tambah-barang--tambah-barang-screen)
   - [8.6 Edit Barang](#86-edit-barang--edit-barang-screen)
9. [Widget Reusable](#9-widget-reusable)
10. [Alur Navigasi](#10-alur-navigasi)
11. [Validasi Form](#11-validasi-form)
12. [Penanganan Error & Dialog](#12-penanganan-error--dialog)
13. [Daftar Widget yang Digunakan](#13-daftar-widget-yang-digunakan)


---

## 1. Gambaran Umum

**Inventaris Barang** adalah aplikasi manajemen inventaris sederhana berbasis Flutter. Aplikasi ini memungkinkan pengguna untuk **mencatat**, **memperbarui**, dan **menghapus** data barang secara efisien melalui antarmuka yang bersih dan intuitif.

### ✨ Fitur Utama
| Fitur | Keterangan |
|---|---|
| **Tambah Barang** | Input data barang baru dengan formulir lengkap |
| **Lihat Daftar** | Tampilkan semua barang dalam bentuk kartu |
| **Edit Barang** | Perbarui informasi barang yang sudah ada |
| **Hapus Barang** | Hapus barang dengan konfirmasi dialog |
| **Foto Barang** | Lampirkan foto dari galeri perangkat |
| **Kategori Otomatis** | Ikon dan warna badge menyesuaikan kategori |

---

## 2. Teknologi & Dependensi

### Framework
- **Flutter SDK** `^3.10.8`
- **Material Design 3** (MD3) dengan `useMaterial3: true`

### Package / Dependensi

| Package | Versi | Fungsi |
|---|---|---|
| `get` | `^4.7.3` | State management, navigasi, snackbar/dialog |
| `image_picker` | `^1.1.2` | Pilih foto dari galeri |
| `supabase_flutter` | latest | Autentikasi dan Storage |
| `flutter_dotenv` | `^5.1.0` | Memuat variabel lingkungan (.env) |

### Dev Dependensi

| Package | Versi | Fungsi |
|---|---|---|
| `flutter_lints` | `^6.0.0` | Lint rules untuk kualitas kode |

---

## 3. Struktur Direktori

```
inventaris_barang/
│
├── lib/
│   ├── main.dart                    # Entry point & konfigurasi aplikasi
│   │
│   ├── controllers/
│   │   └── inventaris_controller.dart   # State management (GetX)
│   │
│   ├── models/
│   │   └── item.dart                # Model data barang & helper functions
│   │
│   ├── screens/
│   │   ├── inventaris_screen.dart       # Halaman utama (daftar barang)
│   │   ├── tambah_barang_screen.dart    # Halaman tambah barang baru
│   │   └── edit_barang_screen.dart      # Halaman edit barang
│   │
│   ├── widgets/
│   │   └── item_card.dart               # Komponen kartu barang (reusable)
│   │
│   └── utils/
│       └── app_colors.dart              # Konstanta warna aplikasi
│
├── pubspec.yaml                     # Konfigurasi dependensi
└── README.md                        # Dokumentasi proyek
```

---

## 4. Arsitektur Aplikasi

Aplikasi menggunakan pola arsitektur **GetX MVC (Model-View-Controller)**:

```
┌─────────────────────────────────────────────────────┐
│                      View (Screens)                  │
│   InventarisScreen  ─  TambahBarangScreen            │
│                        EditBarangScreen              │
└─────────────────┬───────────────────────────────────┘
                  │  Observes & Calls
                  ▼
┌─────────────────────────────────────────────────────┐
│              Controller (GetX)                       │
│            InventarisController                      │
│   addItem() │ updateItem() │ deleteItem()            │
└─────────────────┬───────────────────────────────────┘
                  │  Manages
                  ▼
┌─────────────────────────────────────────────────────┐
│                 Model (Data)                         │
│                 Item (class)                         │
│   name, kode, category, stock, location, foto...     │
└─────────────────────────────────────────────────────┘
```

### Penjelasan Alur
1. **`main.dart`** mendaftarkan `InventarisController` sebagai *singleton* global melalui `initialBinding`.
2. **Screen** (View) mengakses controller melalui `GetView<InventarisController>` atau `Get.find()`.
3. **Controller** menyimpan state daftar barang dalam `RxList<Item>` yang reaktif (`items.obs`).
4. Perubahan data di controller akan otomatis memperbarui UI melalui `Obx(() => ...)`.

---

## 5. Design System

Semua konstanta visual terpusat di `lib/utils/app_colors.dart`.

### Palet Warna

| Nama Konstanta | Hex | Penggunaan |
|---|---|---|
| `primary` | `#E8601C` | Warna utama (tombol, FAB, aksen) |
| `primaryLight` | `#FFF3EE` | Background ringan berbasis primary |
| `background` | `#F5F5F5` | Latar belakang scaffold |
| `white` | `#FFFFFF` | Kartu, AppBar, input field |
| `textPrimary` | `#2D2D2D` | Teks utama / judul |
| `textSecondary` | `#757575` | Teks pendukung / hint |
| `edit` | `#455A64` | Tombol aksi edit (biru-abu) |
| `delete` | `#E8601C` | Tombol aksi hapus (sama dengan primary) |

### Warna Badge Kategori

| Kategori | Warna |
|---|---|
| Elektronik | `#E8601C` (orange) |
| Audio | `#90A4AE` (blue-grey) |
| Furnitur | `#E8601C` (orange) |
| Dekorasi | `#E8601C` (orange) |
| Logistik | `#E8601C` (orange) |

### Tema Global (`main.dart`)
- **`colorSchemeSeed`**: `#E8601C` — menghasilkan palet Material 3 otomatis
- **AppBar**: Background putih bersih, tanpa elevation, teks bold 20px
- **Input Fields**: Rounded corners `12px`, warna primary saat focus

---

## 6. Model Data

**File:** `lib/models/item.dart`

### Class `Item`

```dart
class Item {
  String id;           // ID unik (timestamp millisecond)
  String name;         // Nama barang
  String kodeBarang;   // Kode unik barang (misal: BRG-001)
  String category;     // Kategori barang (huruf kapital)
  int stock;           // Jumlah stok
  String satuan;       // Satuan stok (Pcs, Unit, Set, dsb.)
  String location;     // Lokasi penyimpanan
  DateTime? tanggalMasuk;  // Tanggal masuk barang (opsional)
  Uint8List? imageBytes;   // Data foto barang dalam bytes (opsional)
  IconData icon;       // Icon Material sesuai kategori
  Color iconBgColor;   // Warna latar icon di kartu
  Color categoryColor; // Warna badge label kategori
}
```

### Method `copyWith()`
Digunakan oleh `EditBarangScreen` untuk membuat salinan objek `Item` dengan beberapa field yang diperbarui, tanpa mengubah field lainnya (immutable-style update).

```dart
Item copyWith({ String? name, int? stock, ... }) { ... }
```

### Helper Functions

| Fungsi | Input | Output |
|---|---|---|
| `getIconForCategory(category)` | String kategori | `IconData` yang sesuai |
| `getBgColorForCategory(category)` | String kategori | `Color` latar icon |
| `getCategoryBadgeColor(category)` | String kategori | `Color` badge kategori |

**Pemetaan Ikon per Kategori:**
| Kategori | Icon |
|---|---|
| ELEKTRONIK | `Icons.laptop_mac` |
| AUDIO | `Icons.headphones` |
| FURNITUR | `Icons.chair` |
| DEKORASI | `Icons.watch_later_outlined` |
| LOGISTIK | `Icons.local_shipping` |
| *(lainnya)* | `Icons.inventory_2` |

---

## 7. Controller — State Management
## ⚙️ Konfigurasi Supabase & .env

1) Buat file `.env` di root proyek dan isi:

```
API_URL=YOUR_SUPABASE_URL
API_KEY=YOUR_SUPABASE_ANON_KEY
```

2) Pastikan `.env` diabaikan Git (sudah ada di `.gitignore`).

3) Storage:
   - Bucket: `item_images`
   - Path upload: `public/<userId>/<timestamp>.jpg`
   - Jika bucket tidak publik, buat policy select untuk `public/*` atau gunakan public bucket.

---



**File:** `lib/controllers/inventaris_controller.dart`  
**Pattern:** GetX Controller

```dart
class InventarisController extends GetxController {
  final items = <Item>[].obs;   // RxList — reaktif, otomatis rebuild UI
  ...
}
```

### Daftar Method

---

#### `addItem(Item item)`
Menambahkan barang baru ke dalam daftar inventaris.

```
Dipanggil oleh: InventarisScreen (setelah navigasi dari TambahBarangScreen berhasil)
```

---

#### `updateItem(int index, Item item)`
Mengganti barang pada indeks tertentu dengan data yang sudah diperbarui.

```
Dipanggil oleh: InventarisScreen (setelah navigasi dari EditBarangScreen berhasil)
```

---

#### `deleteItem(int index)`
Menghapus barang dari daftar, lalu menampilkan **Snackbar** konfirmasi berhasil.

```
Snackbar:
  - Judul   : "Berhasil"
  - Pesan   : '"[NamaBarang]" telah dihapus dari inventaris'
  - Warna   : AppColors.primary (orange)
  - Durasi  : 2 detik
  - Posisi  : Bottom
```

---

#### `confirmDelete(int index)` — *async*
Menampilkan **AlertDialog** konfirmasi sebelum menghapus. Memanggil `deleteItem()` hanya jika pengguna menekan tombol "Hapus".

```
Dialog:
  - Judul   : "Hapus Barang?"
  - Tombol  : "Batal" | "Hapus" (merah)
```

---

## 8. Fitur & Tampilan

---

### 8.1 Onboarding — Onboarding Screen

**File:** `lib/screens/onboarding_screen.dart`  
**Widget Type:** `StatelessWidget`

> Halaman pembuka yang menampilkan gambar hero dari aset lokal, judul, deskripsi singkat, dan dua tombol tindakan.

---

#### 🖥️ Tampilan & Komponen UI

<table>
<tr>
<td width="65%" valign="top">

**Hero Image:**
- Sumber: `assets/images/onBoard.jpg` (lokal)
- Ditampilkan di dalam `ClipRRect` radius 24, `BoxFit.cover`

**Headline & Deskripsi:**
- Judul tebal multi-baris: *"Kelola Inventaris dengan Mudah"*
- Deskripsi singkat tiga baris tentang manfaat aplikasi

**Aksi:**
- Tombol **Masuk** (oranye, penuh) → navigasi ke Login
- Tombol **Daftar** (outlined) → navigasi ke Register

</td>
<td width="35%" valign="top" align="center">

> <img width="314" height="605" alt="image" src="https://github.com/user-attachments/assets/2a314eb0-cc89-416a-aab1-3fa49cb87da7" />


</td>
</tr>
</table>

#### ⚙️ Aksi Navigasi

```dart
ElevatedButton(onPressed: () => Get.to(() => const LoginScreen()));
OutlinedButton(onPressed: () => Get.to(() => const RegisterScreen()));
```

---

### 8.2 Masuk — Login Screen

**File:** `lib/screens/login_screen.dart`  
**Widget Type:** `StatefulWidget`

> Form autentikasi untuk pengguna terdaftar.

---

#### 🖥️ Tampilan & Komponen UI

<table>
<tr>
<td width="65%" valign="top">

**AppBar:**
- Judul **"Masuk"**, tombol back

**Header:**
- Ikon kotak arsip dengan latar oranye muda
- Judul **"Selamat Datang"** dan subteks bantuan

**Form:**
- `Email` (validator: wajib, mengandung `@`)
- `Password` dengan toggle sembunyikan/tampilkan (validator: wajib, min. 6)

**Aksi:**
- Tombol **Masuk** dengan indikator loading saat submit
- Teks link: *"Belum punya akun? Daftar"* → ke Register

</td>
<td width="35%" valign="top" align="center">

> <img width="325" height="610" alt="image" src="https://github.com/user-attachments/assets/13a71ab0-f594-4005-bb9a-8a0684ce54ee" />
" />

</td>
</tr>
</table>

#### ⚙️ Aksi Navigasi

```dart
onPressed: _isSubmitting ? null : _login;  // Validasi, lalu _auth.signIn(...)
// Link ke Register:
GestureDetector(onTap: () => Get.to(() => const RegisterScreen()));
```

---

### 8.3 Daftar — Register Screen

**File:** `lib/screens/register_screen.dart`  
**Widget Type:** `StatefulWidget`

> Form pembuatan akun baru dengan validasi lengkap dan konfirmasi password.

---

#### 🖥️ Tampilan & Komponen UI

<table>
<tr>
<td width="65%" valign="top">

**AppBar:**
- Judul **"Daftar Akun"**, tombol back

**Header:**
- Ikon kotak arsip dengan latar oranye muda
- Judul **"Buat Akun Baru"** dan subteks

**Form:**
- `Nama Lengkap` (validator: wajib)
- `Email` (validator: wajib, valid)
- `Kata Sandi` (validator: wajib, min. 6)
- `Konfirmasi Kata Sandi` (validator: sama dengan password)

**Aksi:**
- Tombol **Daftar Sekarang** dengan indikator loading
- Link kembali ke **Masuk**
- Catatan konfirmasi email setelah pendaftaran

</td>
<td width="35%" valign="top" align="center">

>  <img width="330" height="610" alt="image" src="https://github.com/user-attachments/assets/7180d504-c2d4-4532-ba83-b5455b00ee4b" />


</td>
</tr>
</table>

---

### 8.4 Halaman Utama — Inventaris Screen

**File:** `lib/screens/inventaris_screen.dart`  
**Widget Type:** `GetView<InventarisController>` (StatelessWidget + GetX)

> Halaman ini adalah halaman pertama yang dibuka saat aplikasi dijalankan.

---

#### 🖥️ Tampilan & Komponen UI

<table>
<tr>
<td width="65%" valign="top">

**AppBar:**
- Icon inventaris berlatar `primaryLight` di sebelah kiri
- Judul **"Inventaris"** bold di sebelah kanan icon
- Background putih tanpa shadow

**Body — Kondisi Kosong:**
Saat belum ada barang terdaftar, ditampilkan tampilan *empty state*:
- Ikon `inventory_2_outlined` besar berlatar orange muda
- Teks **"Belum ada barang"**
- Teks panduan untuk menekan tombol `+`

**Body — Ada Data:**
Daftar barang ditampilkan menggunakan `ListView.builder` yang memuat widget `ItemCard` untuk setiap item. Daftar ini **reaktif**: otomatis memperbarui tampilan ketika data berubah melalui `Obx(() => ...)`.

**Floating Action Button (FAB):**
- Tombol bulat berwarna `primary` (orange)
- Icon `+` putih
- Mengarahkan ke halaman **Tambah Barang**

</td>
<td width="35%" valign="top" align="center">

<!-- Tambahkan screenshot halaman utama di sini -->
>  <img width="323" height="600" alt="image" src="https://github.com/user-attachments/assets/32dbb8d1-79a8-4da6-bfff-53d15fcca593" /> 


</td>
</tr>
</table>

---

#### ⚙️ Logika Navigasi

```dart
// Navigasi ke Tambah Barang
Future<void> _navigateToTambah() async {
  final result = await Get.to<Item>(() => const TambahBarangScreen());
  if (result != null) {
    controller.addItem(result); // Simpan barang ke daftar
  }
}

// Navigasi ke Edit Barang
Future<void> _navigateToEdit(int index) async {
  final result = await Get.to<Item>(
    () => EditBarangScreen(item: controller.items[index]),
  );
  if (result != null) {
    controller.updateItem(index, result); // Perbarui barang
  }
}
```

**Pola yang digunakan:** Navigasi berbasis *return value* — screen anak mengembalikan objek `Item` ke parent melalui `Get.back(result: item)`.

---

### 8.5 Tambah Barang — Tambah Barang Screen

**File:** `lib/screens/tambah_barang_screen.dart`  
**Widget Type:** `StatefulWidget`

> Formulir untuk mendaftarkan barang baru ke dalam sistem inventaris.

---

#### 🖥️ Tampilan & Komponen UI

<table>
<tr>
<td width="65%" valign="top">

**AppBar:**
- Tombol back kiri dengan logika konfirmasi
- Judul **"Tambah Barang Baru"**

**Header Section:**
- Banner informasi dengan ikon dan deskripsi formulir
- Teks *"Informasi Detail Barang"* dan *"Lengkapi formulir di bawah..."*

**Form Fields (urutan):**

| No | Field | Tipe Input | Validasi |
|----|---|---|---|
| 1 | **Kode Barang** | `TextFormField` | Wajib diisi |
| 2 | **Nama Barang** | `TextFormField` | Wajib diisi |
| 3 | **Kategori** | `DropdownButtonFormField` | Wajib dipilih |
| 4 | **Jumlah Stok** | `TextFormField` (angka) | Wajib, > 0 |
| 5 | **Satuan** | `DropdownButtonFormField` | Wajib dipilih |
| 6 | **Lokasi Penyimpanan** | `TextFormField` | Wajib diisi |
| 7 | **Tanggal Masuk** | Date Picker (read-only) | Wajib dipilih |
| 8 | **Foto Barang** | Image Picker | Opsional |

**Tombol Simpan:**
- `ElevatedButton` lebar penuh
- Label **"Simpan Barang"** dengan ikon simpan
- Warna `primary` (orange)

</td>
<td width="35%" valign="top" align="center">

<!-- Tambahkan screenshot halaman Tambah Barang di sini -->
> <img width="331" height="603" alt="image" src="https://github.com/user-attachments/assets/616eedee-9353-4b6d-ab89-d3462457891f" />

</td>
</tr>
</table>

---

#### ⚙️ Logika & State

**State variables:**
```dart
final _formKey = GlobalKey<FormState>();     // Kunci validasi form
final _kodeController = TextEditingController();
final _namaController = TextEditingController();
final _stokController = TextEditingController();
final _lokasiController = TextEditingController();
DateTime? _tanggalMasuk;       // Tanggal yang dipilih
String? _selectedKategori;     // Kategori yang dipilih
String? _selectedSatuan;       // Satuan yang dipilih
Uint8List? _imageBytes;        // Byte data foto yang dipilih
```

**`_pickImage()`** — Membuka galeri foto menggunakan `ImagePicker`:
- Ukuran maksimal: 800×800 px
- Kualitas kompresi: 80%
- Hasil disimpan sebagai `Uint8List` di `_imageBytes`

**`_pickDate()`** — Membuka kalender Material:
- Range: tahun 2020 — 2030
- Default: tanggal hari ini

**`_simpan()`** — Dipanggil saat tombol **Simpan Barang** ditekan:
1. Validasi form dengan `_formKey.currentState!.validate()`
2. Cek kategori, satuan, tanggal — tampilkan snackbar merah jika kosong
3. Buat objek `Item` baru dengan `id` = `DateTime.now().millisecondsSinceEpoch.toString()`
4. Ikon dan warna ditentukan otomatis dari kategori via helper function
5. Kembalikan item ke parent: `Get.back(result: item)`

**`_hasAnyInput`** (getter) — Mendeteksi apakah form sudah memiliki input untuk memicu dialog konfirmasi saat back.

**`_onWillPop()`** — Dialog konfirmasi **"Batalkan Pengisian?"** jika form sudah ada isian.

---

#### 📋 Daftar Kategori & Satuan

```
Kategori: Elektronik | Audio | Furnitur | Dekorasi | Logistik
Satuan  : Pcs / Buah | Unit | Set | Lusin | Kg
```

---

### 8.6 Edit Barang — Edit Barang Screen

**File:** `lib/screens/edit_barang_screen.dart`  
**Widget Type:** `StatefulWidget`

> Formulir untuk memperbarui data barang yang sudah ada. Diinisialisasi dengan data barang yang dipilih.

---

#### 🖥️ Tampilan & Komponen UI

<table>
<tr>
<td width="65%" valign="top">

**AppBar:**
- Tombol back kiri dengan logika konfirmasi
- Judul **"Edit Barang"**

**Form Fields (urutan):**

| No | Field | Keterangan |
|----|---|---|
| 1 | **Nama Barang** | Pre-filled dengan nilai sebelumnya |
| 2 | **Kategori** | Pre-filled, dropdown pilihan |
| 3 | **Stok Saat Ini** | Pre-filled + suffix teks satuan |
| 4 | **Lokasi Penyimpanan** | Pre-filled dengan nilai sebelumnya |
| 5 | **Edit Foto** | Tampilkan foto saat ini, ketuk untuk ganti |

> **Catatan:** Kode Barang, Satuan, dan Tanggal Masuk **tidak dapat diubah** pada halaman edit untuk menjaga konsistensi data.

**Bottom Action Bar:**
- Tombol **"Batal"** (outlined) — konfirmasi jika ada perubahan
- Tombol **"Update Barang"** (filled, orange) — simpan perubahan

</td>
<td width="35%" valign="top" align="center">

<!-- Tambahkan screenshot halaman Edit Barang di sini -->
<img width="330" height="601" alt="image" src="https://github.com/user-attachments/assets/59f499ed-517b-485b-b822-7cbdc5e9d127" />


</td>
</tr>
</table>

---

#### ⚙️ Logika & State

**State variables:**
```dart
bool _imageChanged = false;  // Penanda apakah foto sudah diganti
```

**Inisialisasi (`initState`):**
```dart
// Pre-fill semua controller dengan data awal
_namaController = TextEditingController(text: widget.item.name);
_stokController  = TextEditingController(text: widget.item.stock.toString());
_lokasiController = TextEditingController(text: widget.item.location);
// Konversi kategori dari UPPERCASE ke Title Case untuk dropdown
final cat = widget.item.category[0] + widget.item.category.substring(1).toLowerCase();
_selectedKategori = _kategoriList.contains(cat) ? cat : null;
_imageBytes = widget.item.imageBytes;
```

**`_hasChanges`** (getter) — Mendeteksi apakah ada perubahan yang dilakukan user. Membandingkan nilai controller saat ini dengan nilai awal di `widget.item`. Memastikan dialog konfirmasi hanya muncul jika benar-benar ada perubahan.

**`_editFoto()`** — Sama seperti `_pickImage()` di TambahBarang, namun juga mengubah flag `_imageChanged = true`.

**`_update()`** — Dipanggil saat tombol **"Update Barang"** ditekan:
1. Validasi form
2. Cek kategori tidak kosong
3. Buat `Item` baru menggunakan `widget.item.copyWith(...)` — **ID dan field yang tidak bisa diubah tetap dipertahankan**
4. Kembalikan ke parent: `Get.back(result: updated)`

**`_onWillPop()`** — Dialog konfirmasi **"Batalkan Perubahan?"** jika ada perubahan yang belum disimpan.

---

## 9. Widget Reusable

### `ItemCard`

**File:** `lib/widgets/item_card.dart`  
**Type:** `StatelessWidget`

Widget kartu yang menampilkan **ringkasan informasi** satu barang dalam daftar inventaris.

---

#### 🖥️ Tampilan & Komponen UI

<table>
<tr>
<td width="65%" valign="top">

**Struktur Visual Kartu:**

```
┌──────────────────────────────────────┐
│  [Foto/Icon]  Nama Barang  [KATEGORI]│
│               📦 Stok: 10 Pcs        │
│               📍 Lokasi: Rak A-1     │
├──────────────────────────────────────┤
│   ✏️ Edit           🗑️ Hapus          │
└──────────────────────────────────────┘
```

**Bagian Atas (Info):**
- Area gambar/icon berukuran 72×72 px, sudut rounded
- Jika `imageBytes` tersedia: tampilkan foto dengan `Image.memory()`
- Jika kosong: tampilkan `IconData` sesuai kategori
- Nama barang (bold, ellipsis jika terlalu panjang)
- Badge kategori (rounded rectangle, warna sesuai kategori)
- Teks stok dengan icon inventori kecil
- Teks lokasi dengan icon pin lokasi kecil

**Bagian Bawah (Aksi):**
- Dibatasi oleh `Divider` horizontal
- Dua tombol `InkWell` dibagi rata: **Edit** (biru-abu) dan **Hapus** (orange)
- Dibatasi oleh `VerticalDivider` di tengah

</td>
<td width="35%" valign="top" align="center">

<!-- Tambahkan screenshot Item Card di sini -->
> <img width="633" height="292" alt="image" src="https://github.com/user-attachments/assets/ea74fb79-370b-4b26-83e1-050f5abe577f" />


</td>
</tr>
</table>

---

#### Props (Constructor Parameters)

| Parameter | Tipe | Keterangan |
|---|---|---|
| `item` | `Item` | Data barang yang ditampilkan *(required)* |
| `onEdit` | `VoidCallback?` | Callback saat tombol Edit ditekan |
| `onDelete` | `VoidCallback?` | Callback saat tombol Hapus ditekan |

---

## 10. Alur Navigasi

```
                    ┌──────────────────────┐
                    │   InventarisScreen    │  ← Halaman Utama
                    │   (GetView)           │
                    └──────┬───────┬────────┘
                           │       │
             Tekan FAB (+) │       │ Tekan "Edit" di ItemCard
                           ▼       ▼
                ┌──────────────┐  ┌──────────────────┐
                │  TambahBarang│  │  EditBarang       │
                │  Screen      │  │  Screen           │
                └──────┬───────┘  └────────┬──────────┘
                       │                   │
            Get.back(result: newItem)   Get.back(result: updatedItem)
                       │                   │
                       └─────────┬─────────┘
                                 ▼
                    controller.addItem()  atau
                    controller.updateItem()
```

**Mekanisme:** GetX digunakan untuk navigasi dengan `Get.to<T>()` yang mendukung *return value* bertipe generik. Pola ini menghindari kebutuhan callback atau event bus.

---

## 11. Validasi Form

### Halaman Tambah Barang

| Field | Aturan Validasi | Pesan Error |
|---|---|---|
| Kode Barang | Tidak boleh kosong | *"Kode barang wajib diisi"* |
| Nama Barang | Tidak boleh kosong | *"Nama barang wajib diisi"* |
| Kategori | Harus dipilih | *"Pilih kategori terlebih dahulu"* (Snackbar) |
| Jumlah Stok | Tidak kosong, angka valid, > 0 | *"Jumlah stok wajib diisi"* / *"Masukkan angka yang valid"* / *"Stok harus lebih dari 0"* |
| Satuan | Harus dipilih | *"Pilih satuan terlebih dahulu"* (Snackbar) |
| Lokasi | Tidak boleh kosong | *"Lokasi penyimpanan wajib diisi"* |
| Tanggal Masuk | Harus dipilih | *"Pilih tanggal masuk terlebih dahulu"* (Snackbar) |
| Foto | —  | *Opsional, tidak divalidasi* |

### Halaman Edit Barang

| Field | Aturan Validasi |
|---|---|
| Nama Barang | Tidak boleh kosong |
| Kategori | Harus dipilih |
| Stok | Tidak kosong, angka valid, > 0 |
| Lokasi | Tidak boleh kosong |

---

## 12. Penanganan Error & Dialog

### Dialog Konfirmasi yang Digunakan

| Situasi | Judul Dialog | Opsi |
|---|---|---|
| Back dari Tambah Barang (ada isian) | *"Batalkan Pengisian?"* | Tetap Mengisi / Ya, Kembali |
| Back dari Edit Barang (ada perubahan) | *"Batalkan Perubahan?"* | Tetap Mengedit / Ya, Kembali |
| Hapus barang | *"Hapus Barang?"* | Batal / Hapus |

### Snackbar Notifikasi

| Kondisi | Judul | Warna |
|---|---|---|
| Barang berhasil dihapus | *"Berhasil"* | Orange (primary) |
| Kategori belum dipilih | *"Peringatan"* | Merah |
| Satuan belum dipilih | *"Peringatan"* | Merah |
| Tanggal belum dipilih | *"Peringatan"* | Merah |

Semua Snackbar menggunakan:
- Posisi: **Bottom**
- Border radius: **12**
- Margin: **16** dari semua sisi
- Teks: **Putih**

---

## 13. Daftar Widget yang Digunakan

Bagian ini mendokumentasikan **semua widget Flutter** — baik bawaan (built-in) maupun kustom — yang digunakan dalam proyek ini, lengkap dengan penjelasan fungsi dan konteks penggunaannya.

---

### 13.1 Widget Struktural & Layout

---

#### `GetMaterialApp`
> **Package:** `get`  
> **Digunakan di:** `main.dart`

Pengganti `MaterialApp` dari paket GetX. Mengaktifkan fitur-fitur GetX seperti navigasi tanpa `context`, snackbar global, dan dialog, serta mendaftarkan tema aplikasi secara global.

```dart
GetMaterialApp(
  title: 'Inventaris Barang',
  initialBinding: BindingsBuilder(...),
  theme: ThemeData(...),
  home: const InventarisScreen(),
)
```

---

#### `Scaffold`
> **Package:** `flutter/material`  
> **Digunakan di:** semua Screen

Kerangka dasar halaman yang menyediakan struktur standar Material Design: `appBar`, `body`, dan `floatingActionButton`. Setiap screen dalam proyek ini dibungkus dengan `Scaffold`.

| Properti yang digunakan | Keterangan |
|---|---|
| `backgroundColor` | Warna latar belakang body (`AppColors.background`) |
| `appBar` | Widget AppBar di bagian atas |
| `body` | Konten utama halaman |
| `floatingActionButton` | FAB bulat orange di `InventarisScreen` |

---

#### `AppBar`
> **Package:** `flutter/material`  
> **Digunakan di:** semua Screen

Bar navigasi di atas halaman. Dikonfigurasi tanpa bayangan (`elevation: 0`) dengan latar putih dan teks judul tebal.

| Properti yang digunakan | Keterangan |
|---|---|
| `backgroundColor` | Warna putih (`AppColors.white`) |
| `elevation` / `scrolledUnderElevation` | Menghilangkan bayangan default |
| `leading` | Widget di kiri (tombol back `IconButton`) |
| `title` | Judul teks halaman |
| `centerTitle` | `false` — judul rata kiri |

---

#### `Column`
> **Package:** `flutter/material`  
> **Digunakan di:** semua file

Menyusun widget-widget secara **vertikal** (dari atas ke bawah). Digunakan secara luas untuk menyusun field form, info barang, dan tombol aksi.

| Properti yang digunakan | Keterangan |
|---|---|
| `crossAxisAlignment` | Perataan horizontal anggota (umumnya `start`) |
| `mainAxisAlignment` | Perataan vertikal (umumnya `center`) |
| `children` | Daftar widget yang disusun |

---

#### `Row`
> **Package:** `flutter/material`  
> **Digunakan di:** semua Screen dan `item_card.dart`

Menyusun widget-widget secara **horizontal** (dari kiri ke kanan). Digunakan untuk baris icon + teks, tombol aksi kartu, dan header form.

---

#### `Container`
> **Package:** `flutter/material`  
> **Digunakan di:** semua file

Widget serbaguna untuk mengatur **ukuran, padding, margin, warna, border, dan shadow** suatu area. Digunakan untuk membuat kartu, badge kategori, kotak icon, dan area foto.

| Properti yang digunakan | Keterangan |
|---|---|
| `width` / `height` | Ukuran tetap atau `double.infinity` |
| `padding` / `margin` | Ruang dalam dan luar |
| `decoration` → `BoxDecoration` | Warna, radius, border, bayangan |
| `child` | Widget di dalam container |

---

#### `Expanded`
> **Package:** `flutter/material`  
> **Digunakan di:** semua Screen dan `item_card.dart`

Membuat widget anak mengisi **sisa ruang tersedia** di dalam `Row` atau `Column`. Digunakan agar teks nama barang tidak meluap dan tombol aksi terbagi rata.

```dart
Expanded(child: Text(item.name, overflow: TextOverflow.ellipsis))
```

---

#### `Flexible`
> **Package:** `flutter/material`  
> **Digunakan di:** `item_card.dart`

Mirip `Expanded`, namun widget anak **tidak wajib mengisi** seluruh ruang yang tersedia. Digunakan untuk teks nama barang agar bisa dipotong dengan ellipsis tanpa memaksa layout.

---

#### `SizedBox`
> **Package:** `flutter/material`  
> **Digunakan di:** semua file

Memberikan **jarak kosong** antara dua widget, atau memaksa widget memiliki ukuran tertentu. Digunakan sebagai spacer vertikal dan horizontal di seluruh proyek.

```dart
const SizedBox(height: 20) // Jarak vertikal antar field form
const SizedBox(width: 12)  // Jarak horizontal antar icon dan teks
```

---

#### `Padding`
> **Package:** `flutter/material`  
> **Digunakan di:** semua file

Menambahkan **ruang dalam (padding)** di sekeliling widget anak. Sering digunakan sebagai pembungkus teks label dan tombol.

---

#### `SingleChildScrollView`
> **Package:** `flutter/material`  
> **Digunakan di:** `tambah_barang_screen.dart`, `edit_barang_screen.dart`

Membuat konten yang panjang dapat di-**scroll secara vertikal**. Penting untuk halaman form agar semua field tetap terlihat ketika keyboard muncul.

---

#### `ListView.builder`
> **Package:** `flutter/material`  
> **Digunakan di:** `inventaris_screen.dart`

Membangun daftar item secara **efisien dan lazy** (hanya merender item yang terlihat). Digunakan untuk menampilkan seluruh daftar barang inventaris.

```dart
ListView.builder(
  itemCount: controller.items.length,
  itemBuilder: (context, index) => ItemCard(item: controller.items[index], ...),
)
```

---

#### `Stack`
> **Package:** `flutter/material`  
> **Digunakan di:** `tambah_barang_screen.dart`, `edit_barang_screen.dart`

Menumpuk widget-widget di **atas satu sama lain**. Digunakan untuk menempatkan tombol hapus (×) di sudut foto yang dipilih, dan badge edit di sudut thumbnail foto.

---

#### `Positioned`
> **Package:** `flutter/material`  
> **Digunakan di:** `tambah_barang_screen.dart`, `edit_barang_screen.dart`

Digunakan **di dalam `Stack`** untuk menempatkan widget pada posisi absolut (atas, kanan, bawah, kiri). Digunakan untuk badge ikon edit pada thumbnail foto.

```dart
Positioned(
  bottom: 0, right: 0,
  child: Container(...), // Badge "edit" orange di pojok foto
)
```

---

#### `IntrinsicHeight`
> **Package:** `flutter/material`  
> **Digunakan di:** `item_card.dart`

Memaksa widget-widget anak dalam sebuah `Row` memiliki **tinggi yang sama** dengan anak yang paling tinggi. Digunakan agar `VerticalDivider` antara tombol Edit dan Hapus memiliki tinggi yang benar.

---

#### `PopScope`
> **Package:** `flutter/material`  
> **Digunakan di:** `tambah_barang_screen.dart`, `edit_barang_screen.dart`

Widget Flutter modern (pengganti `WillPopScope`) untuk **mencegat aksi back** dan menjalankan logika kustom (dialog konfirmasi) sebelum halaman benar-benar ditutup.

```dart
PopScope(
  canPop: false,
  onPopInvokedWithResult: (didPop, result) async {
    final shouldPop = await _onWillPop();
    if (shouldPop) Get.back();
  },
  child: Scaffold(...),
)
```

---

### 13.2 Widget Input & Form

---

#### `Form`
> **Package:** `flutter/material`  
> **Digunakan di:** `tambah_barang_screen.dart`, `edit_barang_screen.dart`

Container untuk mengelompokkan beberapa `FormField` dan memvalidasinya **secara serentak** menggunakan `GlobalKey<FormState>`.

```dart
final _formKey = GlobalKey<FormState>();

Form(
  key: _formKey,
  child: Column(children: [...formFields]),
)

// Memvalidasi semua field sekaligus:
_formKey.currentState!.validate()
```

---

#### `TextFormField`
> **Package:** `flutter/material`  
> **Digunakan di:** `tambah_barang_screen.dart`, `edit_barang_screen.dart`

Input teks satu baris dengan dukungan **validasi otomatis** melalui properti `validator`. Digunakan untuk field Kode Barang, Nama Barang, Jumlah Stok, dan Lokasi Penyimpanan.

| Properti yang digunakan | Keterangan |
|---|---|
| `controller` | `TextEditingController` untuk membaca/menulis nilai |
| `decoration` | `InputDecoration` untuk styling (border, hint, icon) |
| `keyboardType` | `TextInputType.number` untuk field stok |
| `validator` | Fungsi validasi yang mengembalikan pesan error atau `null` |

---

#### `TextEditingController`
> **Package:** `flutter/material`  
> **Digunakan di:** semua Screen

Controller untuk **membaca, menulis, dan memantau** nilai teks dalam `TextFormField`. Harus di-`dispose()` di dalam `dispose()` widget untuk menghindari memory leak.

---

#### `DropdownButtonFormField<T>`
> **Package:** `flutter/material`  
> **Digunakan di:** `tambah_barang_screen.dart`, `edit_barang_screen.dart`

Dropdown pilihan yang terintegrasi dengan sistem validasi `Form`. Digunakan untuk memilih **Kategori** dan **Satuan** barang.

| Properti yang digunakan | Keterangan |
|---|---|
| `value` | Nilai yang saat ini dipilih |
| `items` | Daftar `DropdownMenuItem<String>` |
| `onChanged` | Callback saat pilihan berubah |
| `icon` | Ikon panah dropdown |
| `decoration` | Styling sama dengan `TextFormField` |

---

#### `InputDecoration`
> **Package:** `flutter/material`  
> **Digunakan di:** `tambah_barang_screen.dart`, `edit_barang_screen.dart`

Objek konfigurasi tampilan input field yang digunakan bersama `TextFormField` dan `DropdownButtonFormField`. Dikustomisasi melalui method helper `_buildInputDecoration()`.

| Properti yang digunakan | Keterangan |
|---|---|
| `hintText` | Teks placeholder abu-abu |
| `prefixIcon` / `suffixIcon` | Ikon di kiri/kanan field |
| `filled` + `fillColor` | Latar belakang putih untuk input |
| `border` / `enabledBorder` / `focusedBorder` / `errorBorder` | Border berbeda untuk tiap state |

---

#### `OutlineInputBorder`
> **Package:** `flutter/material`  
> **Digunakan di:** `tambah_barang_screen.dart`, `edit_barang_screen.dart`

Menampilkan **border persegi panjang membulat** di sekeliling input field. Arah border berubah warna sesuai state (normal, fokus, error) melalui properti `borderSide`.

---

#### `GestureDetector`
> **Package:** `flutter/material`  
> **Digunakan di:** `tambah_barang_screen.dart`, `edit_barang_screen.dart`

Mendeteksi gestur sentuhan (tap, drag, dll.) pada widget **apa pun**. Digunakan untuk membuat area foto dan field tanggal menjadi dapat ditekan.

```dart
GestureDetector(
  onTap: _pickDate,
  child: AbsorbPointer(child: TextFormField(...)),
)
```

---

#### `AbsorbPointer`
> **Package:** `flutter/material`  
> **Digunakan di:** `tambah_barang_screen.dart`

**Memblokir semua event** sentuhan ke widget di dalamnya tanpa menyembunyikannya secara visual. Digunakan agar `TextFormField` tanggal tidak bisa diketik langsung — input hanya melalui `GestureDetector` di luar yang membuka Date Picker.

---

### 13.3 Widget Tombol & Aksi

---

#### `FloatingActionButton`
> **Package:** `flutter/material`  
> **Digunakan di:** `inventaris_screen.dart`

Tombol aksi bulat yang melayang di sudut kanan bawah layar. Digunakan sebagai tombol utama untuk **menambah barang baru**.

```dart
FloatingActionButton(
  onPressed: _navigateToTambah,
  backgroundColor: AppColors.primary,
  child: const Icon(Icons.add, color: Colors.white),
)
```

---

#### `ElevatedButton.icon`
> **Package:** `flutter/material`  
> **Digunakan di:** `tambah_barang_screen.dart`, `edit_barang_screen.dart`

Tombol dengan **ikon dan label** bersamaan, memiliki bayangan (elevation). Digunakan untuk tombol **"Simpan Barang"** dan **"Update Barang"** berwarna primary orange.

---

#### `OutlinedButton`
> **Package:** `flutter/material`  
> **Digunakan di:** `edit_barang_screen.dart`

Tombol dengan **border transparan** (tidak memiliki background). Digunakan untuk tombol **"Batal"** di halaman Edit Barang agar tidak terlalu menonjol dibandingkan tombol Update.

---

#### `TextButton`
> **Package:** `flutter/material`  
> **Digunakan di:** `tambah_barang_screen.dart`, `edit_barang_screen.dart`, `inventaris_controller.dart`

Tombol teks tanpa background maupun border. Digunakan untuk tombol-tombol di dalam **AlertDialog** (Batal, Ya Kembali, Hapus).

---

#### `IconButton`
> **Package:** `flutter/material`  
> **Digunakan di:** semua Screen (AppBar)

Tombol berupa ikon yang dapat ditekan, biasanya di dalam `AppBar`. Digunakan sebagai **tombol back** dengan ikon `Icons.arrow_back`.

---

#### `InkWell`
> **Package:** `flutter/material`  
> **Digunakan di:** `item_card.dart`

Membuat widget apa pun menjadi **dapat ditekan** dengan efek ripple Material. Digunakan untuk tombol **Edit** dan **Hapus** di bagian bawah `ItemCard`.

```dart
InkWell(
  onTap: onEdit,
  child: Padding(...), // Area tombol Edit
)
```

---

### 13.4 Widget Tampilan & Visual

---

#### `Text`
> **Package:** `flutter/material`  
> **Digunakan di:** semua file

Widget paling dasar untuk **menampilkan teks**. Dikonfigurasi dengan `TextStyle` untuk ukuran, warna, tebal, dan overflow.

| Properti yang digunakan | Keterangan |
|---|---|
| `style` | `TextStyle` (fontSize, fontWeight, color) |
| `overflow` | `TextOverflow.ellipsis` untuk teks panjang |
| `maxLines` | Batas baris teks |

---

#### `Icon`
> **Package:** `flutter/material`  
> **Digunakan di:** semua file

Menampilkan **ikon Material Design** dari kelas `Icons`. Digunakan secara luas untuk ikon kategori, ikon aksi, dan ikon informasi.

```dart
// Contoh penggunaan dalam proyek:
Icons.inventory_2_rounded   // Header form
Icons.arrow_back            // Tombol back AppBar
Icons.add_a_photo_outlined  // Area upload foto
Icons.edit_outlined         // Tombol edit di ItemCard
Icons.delete_outline        // Tombol hapus di ItemCard
Icons.location_on_outlined  // Ikon lokasi di form dan kartu
Icons.calendar_today_outlined // Ikon field tanggal
```

---

#### `Image.memory`
> **Package:** `flutter/material`  
> **Digunakan di:** `item_card.dart`, `tambah_barang_screen.dart`, `edit_barang_screen.dart`

Menampilkan gambar dari **data byte** (`Uint8List`) yang ada di memori. Digunakan untuk menampilkan foto barang yang dipilih dari galeri.

```dart
Image.memory(
  item.imageBytes!,
  width: 72, height: 72,
  fit: BoxFit.cover,
  errorBuilder: (ctx, err, st) => Icon(item.icon, ...), // Fallback jika error
)
```

---

#### `ClipRRect`
> **Package:** `flutter/material`  
> **Digunakan di:** `item_card.dart`, `tambah_barang_screen.dart`, `edit_barang_screen.dart`

**Memotong widget anak** menggunakan border radius membulat. Digunakan agar foto barang tampil dengan sudut membulat sesuai desain.

```dart
ClipRRect(
  borderRadius: BorderRadius.circular(8),
  child: Image.memory(...),
)
```

---

#### `BoxDecoration`
> **Package:** `flutter/material`  
> **Digunakan di:** semua file

Objek dekorasi untuk `Container` yang mendefinisikan **warna, border radius, border, dan shadow** secara bersamaan.

| Properti yang digunakan | Keterangan |
|---|---|
| `color` | Warna latar |
| `borderRadius` | Membulatkan sudut |
| `border` | Border di sekeliling container |
| `boxShadow` | Bayangan kartu (blur, offset, warna) |
| `shape` | `BoxShape.circle` untuk shape melingkar |

---

#### `BoxShadow`
> **Package:** `flutter/material`  
> **Digunakan di:** `item_card.dart`, `tambah_barang_screen.dart`

Menambahkan **efek bayangan** pada `Container` melalui `BoxDecoration`. Digunakan untuk memberi kesan kedalaman pada kartu barang dan tombol hapus foto.

```dart
boxShadow: [
  BoxShadow(
    color: Colors.black.withValues(alpha: 0.05),
    blurRadius: 8, offset: const Offset(0, 2),
  ),
]
```

---

#### `Divider`
> **Package:** `flutter/material`  
> **Digunakan di:** `item_card.dart`

Menampilkan **garis horizontal tipis** sebagai pemisah antara area info barang dan area tombol aksi di `ItemCard`.

```dart
const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE))
```

---

#### `VerticalDivider`
> **Package:** `flutter/material`  
> **Digunakan di:** `item_card.dart`

Menampilkan **garis vertikal tipis** sebagai pemisah antara tombol Edit dan tombol Hapus di bagian bawah `ItemCard`. Harus dipadukan dengan `IntrinsicHeight` agar tingginya benar.

---

#### `CircularProgressIndicator`
> **Package:** `flutter/material`  
> **Catatan:** Tersedia namun tidak digunakan dalam versi ini karena semua operasi bersifat in-memory (sinkron).

---

### 13.5 Widget Dialog & Notifikasi (GetX)

---

#### `AlertDialog`
> **Package:** `flutter/material`  
> **Digunakan di:** `tambah_barang_screen.dart`, `edit_barang_screen.dart`, `inventaris_controller.dart`

Dialog konfirmasi pop-up yang berhenti di tengah layar. Ditampilkan melalui `Get.dialog<bool>(AlertDialog(...))`.

| Properti yang digunakan | Keterangan |
|---|---|
| `title` | Judul dialog (teks tebal) |
| `content` | Pesan penjelasan |
| `actions` | Deretan tombol (`TextButton`) di bagian bawah |

---

#### `Get.snackbar()`
> **Package:** `get`  
> **Digunakan di:** `tambah_barang_screen.dart`, `edit_barang_screen.dart`, `inventaris_controller.dart`

Menampilkan **notifikasi toast/snackbar** tanpa membutuhkan `BuildContext`. Muncul dari bawah layar dengan tampilan yang dikustomisasi.

| Parameter yang digunakan | Keterangan |
|---|---|
| `snackPosition` | Posisi (`.BOTTOM`) |
| `backgroundColor` | Merah untuk peringatan, orange untuk sukses |
| `colorText` | Warna teks putih |
| `margin` | Jarak dari tepi layar |
| `borderRadius` | Radius sudut membulat |
| `duration` | Durasi tampil (2 detik) |

---

#### `Get.dialog<T>()`
> **Package:** `get`  
> **Digunakan di:** `tambah_barang_screen.dart`, `edit_barang_screen.dart`, `inventaris_controller.dart`

Fungsi GetX untuk menampilkan dialog dan **menunggu hasilnya** (`Future<T?>`). Pengganti `showDialog()` bawaan Flutter yang tidak membutuhkan `BuildContext`.

---

#### `showDatePicker()`
> **Package:** `flutter/material`  
> **Digunakan di:** `tambah_barang_screen.dart`

Fungsi built-in Flutter yang menampilkan **kalender Material Design** untuk memilih tanggal. Mengembalikan `Future<DateTime?>`.

```dart
final picked = await showDatePicker(
  context: context,
  initialDate: DateTime.now(),
  firstDate: DateTime(2020),
  lastDate: DateTime(2030),
);
```

---

### 13.6 Widget Reaktif (GetX)

---

#### `Obx`
> **Package:** `get`  
> **Digunakan di:** `inventaris_screen.dart`

Widget reaktif GetX yang **otomatis membangun ulang** (rebuild) UI ketika nilai `Rx` (observable) yang dibaca di dalamnya berubah. Digunakan untuk memperbarui daftar barang secara real-time.

```dart
Obx(() {
  if (controller.items.isEmpty) {
    return _buildEmptyState(); // Tampilan empty state
  }
  return ListView.builder(...); // Daftar barang
})
```

---

#### `GetView<T>`
> **Package:** `get`  
> **Digunakan di:** `inventaris_screen.dart`

Subclass `StatelessWidget` yang secara otomatis menyediakan properti `controller` bertipe `T`. Meniadakan kebutuhan memanggil `Get.find<InventarisController>()` secara manual.

```dart
class InventarisScreen extends GetView<InventarisController> {
  // 'controller' sudah tersedia otomatis dari GetView
  Widget build(BuildContext context) {
    return Scaffold(body: Obx(() => ...controller.items...));
  }
}
```

---

### 13.7 Ringkasan Semua Widget

| Widget | Package | Digunakan Di |
|---|---|---|
| `GetMaterialApp` | get | main.dart |
| `Scaffold` | flutter/material | Semua Screen |
| `AppBar` | flutter/material | Semua Screen |
| `Column` / `Row` | flutter/material | Semua file |
| `Container` | flutter/material | Semua file |
| `Expanded` / `Flexible` | flutter/material | Semua file |
| `SizedBox` | flutter/material | Semua file |
| `Padding` | flutter/material | Semua file |
| `SingleChildScrollView` | flutter/material | Tambah & Edit Screen |
| `ListView.builder` | flutter/material | inventaris_screen.dart |
| `Stack` / `Positioned` | flutter/material | Tambah & Edit Screen |
| `IntrinsicHeight` | flutter/material | item_card.dart |
| `PopScope` | flutter/material | Tambah & Edit Screen |
| `Form` | flutter/material | Tambah & Edit Screen |
| `TextFormField` | flutter/material | Tambah & Edit Screen |
| `TextEditingController` | flutter/material | Tambah & Edit Screen |
| `DropdownButtonFormField` | flutter/material | Tambah & Edit Screen |
| `InputDecoration` | flutter/material | Tambah & Edit Screen |
| `OutlineInputBorder` | flutter/material | Tambah & Edit Screen |
| `GestureDetector` | flutter/material | Tambah & Edit Screen |
| `AbsorbPointer` | flutter/material | tambah_barang_screen.dart |
| `FloatingActionButton` | flutter/material | inventaris_screen.dart |
| `ElevatedButton.icon` | flutter/material | Tambah & Edit Screen |
| `OutlinedButton` | flutter/material | edit_barang_screen.dart |
| `TextButton` | flutter/material | Dialog (semua) |
| `IconButton` | flutter/material | Semua Screen (AppBar) |
| `InkWell` | flutter/material | item_card.dart |
| `Text` | flutter/material | Semua file |
| `Icon` | flutter/material | Semua file |
| `Image.memory` | flutter/material | Kartu & Form Screen |
| `ClipRRect` | flutter/material | Kartu & Form Screen |
| `BoxDecoration` / `BoxShadow` | flutter/material | Semua file |
| `Divider` / `VerticalDivider` | flutter/material | item_card.dart |
| `AlertDialog` | flutter/material | Dialog Konfirmasi |
| `Get.snackbar()` | get | Controller & Form Screen |
| `Get.dialog<T>()` | get | Dialog Konfirmasi |
| `showDatePicker()` | flutter/material | tambah_barang_screen.dart |
| `Obx` | get | inventaris_screen.dart |
| `GetView<T>` | get | inventaris_screen.dart |

---
