# Rekap Pemenuhan FL (Flutter)

Aplikasi mobile offline untuk satu pengguna: memantau pemenuhan formasi
frontliner (CS, Teller, Universal Banker) di kantor-kantor di bawah KC
(KCP, KK, Unit, Teras), menggantikan rekap manual di Excel.

## Cara menjalankan

```
flutter pub get
flutter run
```

Membutuhkan Flutter SDK sudah terpasang (`flutter --version` untuk mengecek).

## Struktur proyek

```
lib/
  main.dart                  Entry point
  theme.dart                 Warna dan ThemeData
  models.dart                Model UnitKerja, Pegawai, enum JenisKantor/StatusPegawai
  data/
    mock_data.dart           DATA CONTOH (ganti dengan hasil impor Excel)
    repository.dart          Perhitungan existing/gap dari pegawai + formasi
    excel_import.dart        Kerangka fungsi impor Excel (belum diimplementasikan)
  widgets/
    common_widgets.dart      StatCard, MenuIconButton, OfficeGapTile, EmployeeTile
  screens/
    beranda_screen.dart      Dashboard: ringkasan + kantor perlu perhatian
    detail_kc_screen.dart    Tab KCP / KK / Unit / Teras di bawah satu KC
    detail_kantor_screen.dart  Daftar pegawai satu kantor
    kontrak_screen.dart      Pegawai yang kontrak/magangnya akan habis
```

## Status saat ini

- Tampilan dan navigasi sudah lengkap sesuai layar yang didiskusikan.
- Data masih **contoh** (lihat `lib/data/mock_data.dart`), belum dari file
  Excel asli.
- Existing dan GAP **dihitung otomatis** dari data pegawai + formasi
  (lihat `RekapRepository`), tidak disimpan manual seperti di Excel.

## Langkah selanjutnya yang disarankan

1. Implementasikan `lib/data/excel_import.dart` memakai package `excel`
   untuk membaca file rekap sesungguhnya (sheet KC/KCP/KK/UNIT/TERAS).
2. Simpan hasil impor ke database lokal (disarankan `sqflite` atau
   `drift`) supaya data tetap ada setelah aplikasi ditutup.
3. Tambahkan kolom tanggal kontrak/magang pada data sumber, supaya
   `kontrak_screen.dart` menghitung dari data asli, bukan data contoh.
4. Tambahkan fitur cari pegawai dan ekspor laporan (tombol menu sudah
   disiapkan di beranda, tinggal diisi).
5. Tambahkan penguncian aplikasi (PIN/biometrik) karena data berisi
   nama dan identitas pegawai.
