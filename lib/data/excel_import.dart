import 'dart:typed_data';
import 'package:excel/excel.dart';
import '../models.dart';

class ExcelImportResult {
  final List<UnitKerja> unitKerjaList;
  final List<Pegawai> pegawaiList;

  ExcelImportResult({
    required this.unitKerjaList,
    required this.pegawaiList,
  });
}

/// Fungsi untuk membaca data dari bytes file Excel (.xlsx) secara dinamis.
ExcelImportResult parseExcelBytes(Uint8List bytes) {
  final excel = Excel.decodeBytes(bytes);

  final Map<String, UnitKerja> unitMap = {};
  final List<UnitKerja> unitList = [];
  final List<Pegawai> pegawaiList = [];

  String sanitize(dynamic val) {
    if (val == null) return '';
    if (val is Data) return val.value?.toString().trim() ?? '';
    return val.toString().trim();
  }

  String makeId(String prefix, String text) {
    final clean = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return '${prefix}_$clean';
  }

  int parseIntVal(dynamic val) {
    final s = sanitize(val);
    return int.tryParse(s) ?? 0;
  }

  StatusPegawai parseStatus(dynamic val) {
    final s = sanitize(val).toLowerCase();
    if (s.contains('magang')) return StatusPegawai.magang;
    if (s.contains('pensiun') || s.contains('pt')) return StatusPegawai.tetapPensiun36;
    if (s.contains('percobaan')) return StatusPegawai.percobaan;
    return StatusPegawai.kontrak;
  }

  // 1. Process F KANCA
  final sheetKanca = excel.tables['F KANCA'];
  if (sheetKanca != null) {
    for (int r = 3; r < sheetKanca.maxRows; r++) {
      final row = sheetKanca.rows[r];
      if (row.length <= 3) continue;
      final kode = sanitize(row[2]?.value);
      final nama = sanitize(row[3]?.value);
      if (nama.isEmpty) continue;

      final formasiCs = parseIntVal(row.length > 6 ? row[6]?.value : 0);
      final formasiTeller = parseIntVal(row.length > 9 ? row[9]?.value : 0);
      final formasiUb = parseIntVal(row.length > 12 ? row[12]?.value : 0);

      final id = makeId('kc', nama);
      final u = UnitKerja(
        id: id,
        kode: kode,
        nama: nama,
        jenis: JenisKantor.kc,
        kcIndukId: null,
        formasiCs: formasiCs,
        formasiTeller: formasiTeller,
        formasiUb: formasiUb,
      );
      unitMap[id] = u;
      unitList.add(u);
    }
  }

  // 2. Process F KCP
  final sheetKcp = excel.tables['F KCP'];
  if (sheetKcp != null) {
    for (int r = 3; r < sheetKcp.maxRows; r++) {
      final row = sheetKcp.rows[r];
      if (row.length <= 5) continue;
      final namaKc = sanitize(row[3]?.value);
      final kode = sanitize(row[4]?.value);
      final nama = sanitize(row[5]?.value);
      if (nama.isEmpty || namaKc.isEmpty) continue;

      final formasiCs = parseIntVal(row.length > 8 ? row[8]?.value : 0);
      final formasiTeller = parseIntVal(row.length > 11 ? row[11]?.value : 0);

      final kcId = makeId('kc', namaKc);
      final id = makeId('kcp', '${nama}_$kode');
      final u = UnitKerja(
        id: id,
        kode: kode,
        nama: nama,
        jenis: JenisKantor.kcp,
        kcIndukId: kcId,
        formasiCs: formasiCs,
        formasiTeller: formasiTeller,
        formasiUb: 0,
      );
      unitMap[id] = u;
      unitList.add(u);
    }
  }

  // 3. Process F KK
  final sheetKk = excel.tables['F KK'];
  if (sheetKk != null) {
    for (int r = 3; r < sheetKk.maxRows; r++) {
      final row = sheetKk.rows[r];
      if (row.length <= 5) continue;
      final namaKc = sanitize(row[3]?.value);
      final kode = sanitize(row[4]?.value);
      final nama = sanitize(row[5]?.value);
      if (nama.isEmpty || namaKc.isEmpty) continue;

      final formasiCs = parseIntVal(row.length > 7 ? row[7]?.value : 0);
      final formasiTeller = parseIntVal(row.length > 10 ? row[10]?.value : 0);

      final kcId = makeId('kc', namaKc);
      final id = makeId('kk', '${nama}_$kode');
      final u = UnitKerja(
        id: id,
        kode: kode,
        nama: nama,
        jenis: JenisKantor.kk,
        kcIndukId: kcId,
        formasiCs: formasiCs,
        formasiTeller: formasiTeller,
        formasiUb: 0,
      );
      unitMap[id] = u;
      unitList.add(u);
    }
  }

  // 4. Process F UNIT
  final sheetUnit = excel.tables['F UNIT'];
  if (sheetUnit != null) {
    for (int r = 3; r < sheetUnit.maxRows; r++) {
      final row = sheetUnit.rows[r];
      if (row.length <= 6) continue;
      final namaKc = sanitize(row[3]?.value);
      final kode = sanitize(row[4]?.value);
      final nama = sanitize(row[6]?.value);
      if (nama.isEmpty || namaKc.isEmpty) continue;

      final formasiCs = parseIntVal(row.length > 7 ? row[7]?.value : 0);
      final formasiTeller = parseIntVal(row.length > 10 ? row[10]?.value : 0);

      final kcId = makeId('kc', namaKc);
      final isTeras = nama.toUpperCase().startsWith('TERAS');
      final jenis = isTeras ? JenisKantor.teras : JenisKantor.unit;
      final prefix = isTeras ? 'teras' : 'unit';
      final id = makeId(prefix, '${nama}_$kode');

      final u = UnitKerja(
        id: id,
        kode: kode,
        nama: nama,
        jenis: jenis,
        kcIndukId: kcId,
        formasiCs: formasiCs,
        formasiTeller: formasiTeller,
        formasiUb: 0,
      );
      unitMap[id] = u;
      unitList.add(u);
    }
  }

  // Helper unit matching for employees
  String matchUnitId(String kcNama, String ukerText, String typeStr) {
    final kcId = makeId('kc', kcNama);
    final ukerUpper = ukerText.toUpperCase();
    if (typeStr == 'kc' || ukerUpper.startsWith('KC ')) return kcId;

    final candidates = unitMap.values.where((u) => u.kcIndukId == kcId || u.id == kcId);
    for (final c in candidates) {
      final cUpper = c.nama.toUpperCase();
      if (cUpper == ukerUpper) return c.id;
      if (c.kode.isNotEmpty && ukerUpper.contains(c.kode)) return c.id;
      final cClean = cUpper.replaceAll(RegExp(r'^(KCP|KK|UNIT|TERAS)\s+'), '');
      final uClean = ukerUpper.replaceAll(RegExp(r'^(U_\d+_|K_\d+_|KCP|KK|UNIT|TERAS)\s+'), '');
      if (cClean.isNotEmpty && uClean.isNotEmpty && (cClean == uClean || cUpper.contains(uClean) || ukerUpper.contains(cClean))) {
        return c.id;
      }
    }
    return kcId;
  }

  void parseEmployeeSheet(Sheet? sheet, String typeStr) {
    if (sheet == null) return;
    if (sheet.maxRows <= 1) return;

    // Map headers
    final headerRow = sheet.rows[0];
    final headers = headerRow.map((c) => sanitize(c?.value).toUpperCase()).toList();

    final pernrIdx = headers.indexOf('PERNR');
    final nipIdx = headers.indexOf('NIP');
    final nameIdx = headers.indexOf('COMPLETENAME');
    final jobIdx = headers.indexOf('JOBDESC');
    final psaIdx = headers.indexOf('PSADESC');
    final mcIdx = headers.indexOf('MCTEXT');
    final orgIdx = headers.indexOf('ORGDESC');
    final esgIdx = headers.indexOf('ESGDESC');

    for (int r = 1; r < sheet.maxRows; r++) {
      final row = sheet.rows[r];
      final nama = nameIdx >= 0 && nameIdx < row.length ? sanitize(row[nameIdx]?.value) : '';
      if (nama.isEmpty) continue;

      final kcNama = psaIdx >= 0 && psaIdx < row.length ? sanitize(row[psaIdx]?.value) : '';
      final ukerText = mcIdx >= 0 && mcIdx < row.length && sanitize(row[mcIdx]?.value).isNotEmpty
          ? sanitize(row[mcIdx]?.value)
          : (orgIdx >= 0 && orgIdx < row.length ? sanitize(row[orgIdx]?.value) : '');

      final unitId = matchUnitId(kcNama, ukerText, typeStr);
      final pernr = pernrIdx >= 0 && pernrIdx < row.length ? sanitize(row[pernrIdx]?.value) : '';
      final nip = nipIdx >= 0 && nipIdx < row.length ? sanitize(row[nipIdx]?.value) : '-';
      final jabatan = jobIdx >= 0 && jobIdx < row.length ? sanitize(row[jobIdx]?.value) : 'Pegawai';
      final status = esgIdx >= 0 && esgIdx < row.length ? parseStatus(row[esgIdx]?.value) : StatusPegawai.kontrak;

      pegawaiList.add(
        Pegawai(
          pernr: pernr.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : pernr,
          nip: nip.isEmpty ? '-' : nip,
          nama: nama,
          jabatan: jabatan,
          status: status,
          unitKerjaId: unitId,
        ),
      );
    }
  }

  parseEmployeeSheet(excel.tables['KC'], 'kc');
  parseEmployeeSheet(excel.tables['KCP'], 'kcp');
  parseEmployeeSheet(excel.tables['KK'], 'kk');
  parseEmployeeSheet(excel.tables['UNIT'], 'unit');
  parseEmployeeSheet(excel.tables['TERAS'], 'teras');

  return ExcelImportResult(
    unitKerjaList: unitList,
    pegawaiList: pegawaiList,
  );
}
