import '../models.dart';

/// DATA CONTOH untuk keperluan tampilan.
/// Nama kantor mengikuti daftar KC Region 04 Palembang yang sebenarnya,
/// namun angka formasi/existing dan nama pegawai di sini masih ilustrasi.
/// Ganti isi dua list di bawah dengan hasil pembacaan file Excel
/// (lihat lib/data/excel_import.dart untuk kerangka impornya).

const List<UnitKerja> mockUnitKerja = [
  // --- KC ---
  UnitKerja(id: 'kc_abunjani', nama: 'KC Abunjani Sipin', jenis: JenisKantor.kc),
  UnitKerja(id: 'kc_prabumulih', nama: 'KC Prabumulih', jenis: JenisKantor.kc),
  UnitKerja(id: 'kc_arivai', nama: 'KC Palembang A. Rivai', jenis: JenisKantor.kc),
  UnitKerja(id: 'kc_sekayu', nama: 'KC Sekayu', jenis: JenisKantor.kc),
  UnitKerja(id: 'kc_lahat', nama: 'KC Lahat', jenis: JenisKantor.kc),

  // --- Anak kantor dari KC Abunjani Sipin ---
  UnitKerja(
    id: 'kcp_martapura',
    nama: 'KCP Martapura',
    jenis: JenisKantor.kcp,
    kcIndukId: 'kc_abunjani',
    formasiCs: 3,
    formasiTeller: 4,
  ),
  UnitKerja(
    id: 'unit_simpangkawat',
    nama: 'Unit Simpang Kawat',
    jenis: JenisKantor.unit,
    kcIndukId: 'kc_abunjani',
    formasiCs: 2,
    formasiTeller: 2,
  ),
  UnitKerja(
    id: 'teras_pasarbaru',
    nama: 'Teras Pasar Baru',
    jenis: JenisKantor.teras,
    kcIndukId: 'kc_abunjani',
    formasiCs: 1,
    formasiTeller: 1,
  ),
  UnitKerja(
    id: 'kk_poltabes',
    nama: 'KK Poltabes Jambi',
    jenis: JenisKantor.kk,
    kcIndukId: 'kc_abunjani',
    formasiCs: 1,
    formasiTeller: 1,
  ),

  // --- Anak kantor dari KC Prabumulih ---
  UnitKerja(
    id: 'kcp_prabu1',
    nama: 'KCP Prabumulih Timur',
    jenis: JenisKantor.kcp,
    kcIndukId: 'kc_prabumulih',
    formasiCs: 2,
    formasiTeller: 3,
    formasiUb: 1,
  ),
  UnitKerja(
    id: 'unit_prabu2',
    nama: 'Unit Prabumulih Barat',
    jenis: JenisKantor.unit,
    kcIndukId: 'kc_prabumulih',
    formasiCs: 2,
    formasiTeller: 2,
  ),
];

const List<Pegawai> mockPegawai = [
  Pegawai(
    pernr: '000001',
    nama: 'Rina Sartika',
    jabatan: 'Customer Service',
    status: StatusPegawai.kontrak,
    unitKerjaId: 'kcp_martapura',
  ),
  Pegawai(
    pernr: '000002',
    nama: 'Dedi Pratama',
    jabatan: 'Teller',
    status: StatusPegawai.magang,
    unitKerjaId: 'kcp_martapura',
  ),
  Pegawai(
    pernr: '000003',
    nama: 'Ayu Yolanda',
    jabatan: 'Universal Banker',
    status: StatusPegawai.kontrak,
    unitKerjaId: 'kcp_prabu1',
  ),
  Pegawai(
    pernr: '000004',
    nama: 'Budi Santoso',
    jabatan: 'Teller',
    status: StatusPegawai.kontrak,
    unitKerjaId: 'unit_simpangkawat',
  ),
  Pegawai(
    pernr: '000005',
    nama: 'Siti Rahma',
    jabatan: 'Customer Service',
    status: StatusPegawai.kontrak,
    unitKerjaId: 'unit_simpangkawat',
  ),
];

/// Data contoh khusus untuk layar "Kontrak akan habis".
/// Tanggalnya dihitung relatif terhadap hari ini (bukan const) supaya
/// selalu terlihat "akan habis dalam beberapa hari" saat aplikasi dibuka.
/// Ganti dengan data pegawai + tanggal kontrak yang sesungguhnya.
List<Pegawai> get mockPegawaiKontrakHabis {
  final now = DateTime.now();
  return [
    Pegawai(
      pernr: '000101',
      nama: 'Rina Sartika',
      jabatan: 'Customer Service',
      status: StatusPegawai.kontrak,
      unitKerjaId: 'kcp_martapura',
      kontrakBerakhir: now.add(const Duration(days: 8)),
    ),
    Pegawai(
      pernr: '000102',
      nama: 'Dedi Pratama',
      jabatan: 'Teller',
      status: StatusPegawai.magang,
      unitKerjaId: 'kcp_martapura',
      kontrakBerakhir: now.add(const Duration(days: 15)),
    ),
    Pegawai(
      pernr: '000103',
      nama: 'Ayu Yolanda',
      jabatan: 'Universal Banker',
      status: StatusPegawai.kontrak,
      unitKerjaId: 'kcp_prabu1',
      kontrakBerakhir: now.add(const Duration(days: 42)),
    ),
    Pegawai(
      pernr: '000104',
      nama: 'Budi Santoso',
      jabatan: 'Teller',
      status: StatusPegawai.kontrak,
      unitKerjaId: 'unit_simpangkawat',
      kontrakBerakhir: now.add(const Duration(days: 75)),
    ),
  ];
}
