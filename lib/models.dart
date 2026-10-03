/// Jenis kantor sesuai hierarki: KC membawahi KCP, KK, Unit, dan Teras.
enum JenisKantor { kc, kcp, kk, unit, teras }

extension JenisKantorLabel on JenisKantor {
  String get label {
    switch (this) {
      case JenisKantor.kc:
        return 'KC';
      case JenisKantor.kcp:
        return 'KCP';
      case JenisKantor.kk:
        return 'KK';
      case JenisKantor.unit:
        return 'Unit';
      case JenisKantor.teras:
        return 'Teras';
    }
  }
}

/// Tiga kategori sub unit sesuai hirarki: KCP, KK, dan Unit & Teras.
enum SubUnitCategory { kcp, kk, unitTeras }

extension SubUnitCategoryLabel on SubUnitCategory {
  String get label {
    switch (this) {
      case SubUnitCategory.kcp:
        return 'KCP';
      case SubUnitCategory.kk:
        return 'KK';
      case SubUnitCategory.unitTeras:
        return 'Unit & Teras';
    }
  }
}

/// Satu kantor (KC, KCP, KK, Unit, atau Teras).
/// [kcIndukId] null berarti ini adalah KC itu sendiri (main Unit).
class UnitKerja {
  final String id;
  final String kode;
  final String nama;
  final JenisKantor jenis;
  final String? kcIndukId;
  final int formasiCs;
  final int formasiTeller;
  final int formasiUb;

  const UnitKerja({
    required this.id,
    this.kode = '',
    required this.nama,
    required this.jenis,
    this.kcIndukId,
    this.formasiCs = 0,
    this.formasiTeller = 0,
    this.formasiUb = 0,
  });

  int get formasiTotal => formasiCs + formasiTeller + formasiUb;
}

enum StatusPegawai { kontrak, magang, tetapPensiun36, percobaan }

extension StatusPegawaiLabel on StatusPegawai {
  String get label {
    switch (this) {
      case StatusPegawai.kontrak:
        return 'Kontrak';
      case StatusPegawai.magang:
        return 'Peserta magang';
      case StatusPegawai.tetapPensiun36:
        return 'PT (pensiun 36 th)';
      case StatusPegawai.percobaan:
        return 'Percobaan';
    }
  }
}

class Pegawai {
  final String pernr;
  final String nip;
  final String nama;
  final String jabatan;
  final StatusPegawai status;
  final String unitKerjaId;

  /// Tanggal berakhir kontrak/magang. Null jika tidak ada.
  final DateTime? kontrakBerakhir;

  const Pegawai({
    required this.pernr,
    this.nip = '-',
    required this.nama,
    required this.jabatan,
    required this.status,
    required this.unitKerjaId,
    this.kontrakBerakhir,
  });
}

/// Akun pengguna aplikasi untuk otentikasi login & register.
class UserAccount {
  final String username;
  final String nama;
  final String nip;
  final String email;
  final String role;
  final String? kcId;

  const UserAccount({
    required this.username,
    required this.nama,
    required this.nip,
    required this.email,
    required this.role,
    this.kcId,
  });
}


