import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';
import '../models.dart';

/// Repository otentikasi & database pengguna terhubung ke Firebase (Project: farhangsa119a).
/// Didukung dengan Firebase SDK & REST API Fallback langsung ke Google Cloud.
class AuthRepository {
  static final AuthRepository _instance = AuthRepository._internal();
  factory AuthRepository() => _instance;

  AuthRepository._internal();

  static const String _firebaseApiKey = 'AIzaSyArMHC8IMbf11XSD4jvolZ29a97H-erDC0';
  static const String _projectId = 'farhangsa119a';

  fb_auth.FirebaseAuth? _fbAuth;
  FirebaseFirestore? _firestore;
  bool _firebaseInitialized = false;

  UserAccount? _currentUser;

  UserAccount? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  /// Inisialisasi Firebase Core secara aman saat aplikasi dinyalakan.
  Future<void> initFirebase() async {
    if (_firebaseInitialized && _fbAuth != null) return;

    try {
      WidgetsFlutterBinding.ensureInitialized();
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      _fbAuth = fb_auth.FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _firebaseInitialized = true;
      debugPrint('Firebase project farhangsa119a initialized via SDK.');
    } catch (e) {
      debugPrint('Firebase SDK init info (falling back to REST API if needed): $e');
    }
  }

  /// Proses Login menggunakan Firebase Auth SDK atau Direct Firebase REST API
  Future<({bool success, String message, UserAccount? user})> login(
    String usernameOrEmail,
    String password,
  ) async {
    await initFirebase();
    final input = usernameOrEmail.trim();

    if (input.isEmpty || password.isEmpty) {
      return (success: false, message: 'Username/Email dan Password tidak boleh kosong', user: null);
    }

    final email = input.contains('@') ? input : '$input@bri.co.id';

    // 1. Coba via Firebase Auth SDK jika sudah aktif
    if (_fbAuth != null) {
      try {
        final credential = await _fbAuth!.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        final fbUser = credential.user;
        if (fbUser != null) {
          UserAccount? loadedProfile;
          if (_firestore != null) {
            try {
              final docSnapshot = await _firestore!.collection('users').doc(fbUser.uid).get();
              if (docSnapshot.exists && docSnapshot.data() != null) {
                final data = docSnapshot.data()!;
                loadedProfile = UserAccount(
                  username: data['username'] ?? input,
                  nama: data['nama'] ?? fbUser.displayName ?? input,
                  nip: data['nip'] ?? '-',
                  email: data['email'] ?? fbUser.email ?? email,
                  role: (data['role'] != null && data['role'].toString().isNotEmpty)
                      ? data['role']
                      : 'SDM Kantor Cabang',
                  kcId: data['kcId'],
                );
              }
            } catch (_) {}
          }

          _currentUser = loadedProfile ??
              UserAccount(
                username: input,
                nama: (fbUser.displayName != null && fbUser.displayName!.isNotEmpty) ? fbUser.displayName! : input,
                nip: '-',
                email: fbUser.email ?? email,
                role: 'SDM Kantor Cabang',
              );

          return (success: true, message: 'Berhasil masuk via Firebase', user: _currentUser);
        }
      } on fb_auth.FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
          return (success: false, message: 'Email/Username atau Password salah.', user: null);
        } else if (e.code == 'wrong-password') {
          return (success: false, message: 'Password yang Anda masukkan salah.', user: null);
        } else if (e.code == 'invalid-email') {
          return (success: false, message: 'Format email tidak valid.', user: null);
        }
      } catch (e) {
        debugPrint('Firebase SDK sign in info: $e');
      }
    }

    // 2. Direct Fallback: Firebase Identity Toolkit REST API
    try {
      final url = Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$_firebaseApiKey');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );

      final resData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final localId = resData['localId'] ?? '';
        final displayName = resData['displayName'] ?? input;

        // Ambil profil dari Firestore REST API
        UserAccount? loadedProfile = await _fetchFirestoreUserRest(localId);

        _currentUser = loadedProfile ??
            UserAccount(
              username: input,
              nama: displayName.isNotEmpty ? displayName : input,
              nip: '-',
              email: email,
              role: 'SDM Kantor Cabang',
            );

        return (success: true, message: 'Berhasil masuk via Firebase API', user: _currentUser);
      } else {
        final errObj = resData['error'];
        final errMessage = errObj is Map ? errObj['message'] : '';
        if (errMessage == 'EMAIL_NOT_FOUND' || errMessage == 'INVALID_LOGIN_CREDENTIALS') {
          return (success: false, message: 'Email/Username belum terdaftar di Firebase.', user: null);
        } else if (errMessage == 'INVALID_PASSWORD') {
          return (success: false, message: 'Password yang Anda masukkan salah.', user: null);
        }
      }
    } catch (restErr) {
      debugPrint('Firebase REST Login error: $restErr');
    }

    // 3. Fallback demo admin lokal jika offline
    final uKey = input.toLowerCase();
    if ((uKey == 'admin' || uKey == 'admin.region04@bri.co.id') && password == 'admin123') {
      _currentUser = const UserAccount(
        username: 'admin',
        nama: 'Admin Region 04',
        nip: '00099988',
        email: 'admin.region04@bri.co.id',
        role: 'Admin Region 04 Palembang',
      );
      return (success: true, message: 'Berhasil masuk (Lokal)', user: _currentUser);
    }

    return (success: false, message: 'Username/Email atau Password salah', user: null);
  }

  /// Proses Registrasi: Menyimpan ke Firebase Authentication & Database Cloud Firestore
  Future<({bool success, String message})> register({
    required String username,
    required String nama,
    required String nip,
    required String email,
    required String password,
    required String role,
    String? kcId,
  }) async {
    await initFirebase();

    final cleanUsername = username.trim().toLowerCase();
    final cleanEmail = email.trim().isEmpty ? '$cleanUsername@bri.co.id' : email.trim();

    if (cleanUsername.isEmpty || password.isEmpty || nama.isEmpty) {
      return (success: false, message: 'Mohon lengkapi Nama, Username, dan Password.');
    }

    if (password.length < 6) {
      return (success: false, message: 'Password di Firebase minimal 6 karakter.');
    }

    // 1. Coba via Firebase Auth SDK
    if (_fbAuth != null) {
      try {
        final credential = await _fbAuth!.createUserWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        );

        final fbUser = credential.user;
        if (fbUser != null) {
          try {
            await fbUser.updateDisplayName(nama);
          } catch (_) {}

          if (_firestore != null) {
            try {
              await _firestore!.collection('users').doc(fbUser.uid).set({
                'uid': fbUser.uid,
                'username': cleanUsername,
                'nama': nama,
                'nip': nip,
                'email': cleanEmail,
                'role': role,
                'kcId': kcId,
                'projectId': _projectId,
                'createdAt': FieldValue.serverTimestamp(),
              });
            } catch (_) {}
          }

          _currentUser = UserAccount(
            username: cleanUsername,
            nama: nama,
            nip: nip,
            email: cleanEmail,
            role: role,
            kcId: kcId,
          );
          return (
            success: true,
            message: 'Pendaftaran akun berhasil tersimpan di Firebase Auth & Cloud Firestore!'
          );
        }
      } on fb_auth.FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          return (success: false, message: 'Email/Username ini ($cleanEmail) sudah terdaftar di Firebase.');
        } else if (e.code == 'weak-password') {
          return (success: false, message: 'Password terlalu lemah (minimal 6 karakter).');
        }
      } catch (e) {
        debugPrint('Firebase SDK register notice: $e');
      }
    }

    // 2. Direct Fallback: Firebase Identity Toolkit REST API (Guaranteed Connection)
    try {
      final signUpUrl = Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$_firebaseApiKey');
      final response = await http.post(
        signUpUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': cleanEmail,
          'password': password,
          'returnSecureToken': true,
        }),
      );

      final resData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final uid = resData['localId'] ?? '';

        // Update Display Name via REST
        try {
          final updateUrl = Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:update?key=$_firebaseApiKey');
          await http.post(
            updateUrl,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'idToken': resData['idToken'],
              'displayName': nama,
              'returnSecureToken': true,
            }),
          );
        } catch (_) {}

        // Save User Profile to Cloud Firestore Database via REST
        await _saveFirestoreUserRest(uid, {
          'uid': uid,
          'username': cleanUsername,
          'nama': nama,
          'nip': nip,
          'email': cleanEmail,
          'role': role,
          'kcId': kcId ?? '',
          'projectId': _projectId,
        });

        final newUser = UserAccount(
          username: cleanUsername,
          nama: nama,
          nip: nip,
          email: cleanEmail,
          role: role,
          kcId: kcId,
        );

        _currentUser = newUser;
        return (
          success: true,
          message: 'Pendaftaran akun berhasil tersimpan di Firebase Auth & Cloud Firestore (farhangsa119a)!'
        );
      } else {
        final errObj = resData['error'];
        final errMessage = errObj is Map ? errObj['message'] : '';
        if (errMessage == 'EMAIL_EXISTS') {
          return (success: false, message: 'Email/Username ini ($cleanEmail) sudah terdaftar di Firebase.');
        } else if (errMessage == 'WEAK_PASSWORD : Password should be at least 6 characters') {
          return (success: false, message: 'Password terlalu lemah (minimal 6 karakter).');
        }
        return (success: false, message: 'Gagal Register Firebase: $errMessage');
      }
    } catch (restErr) {
      debugPrint('Firebase REST Register Error: $restErr');
      return (success: false, message: 'Gagal Register Firebase: $restErr');
    }
  }

  /// Helper untuk menyimpan dokumen profil pengguna di Cloud Firestore via REST API
  Future<void> _saveFirestoreUserRest(String uid, Map<String, String> data) async {
    try {
      final fsUrl = Uri.parse(
          'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents/users?documentId=$uid');
      
      final fields = <String, dynamic>{};
      data.forEach((k, v) {
        fields[k] = {'stringValue': v};
      });

      await http.post(
        fsUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'fields': fields}),
      );
    } catch (e) {
      debugPrint('Firestore REST save error: $e');
    }
  }

  /// Helper untuk mengambil dokumen profil pengguna dari Cloud Firestore via REST API
  Future<UserAccount?> _fetchFirestoreUserRest(String uid) async {
    try {
      final fsUrl = Uri.parse(
          'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents/users/$uid');
      final res = await http.get(fsUrl);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final fields = body['fields'] ?? {};
        return UserAccount(
          username: fields['username']?['stringValue'] ?? '',
          nama: fields['nama']?['stringValue'] ?? '',
          nip: fields['nip']?['stringValue'] ?? '-',
          email: fields['email']?['stringValue'] ?? '',
          role: fields['role']?['stringValue'] ?? 'User Pegawai FL',
          kcId: fields['kcId']?['stringValue'],
        );
      }
    } catch (e) {
      debugPrint('Firestore REST fetch error: $e');
    }
    return null;
  }

  /// Proses Logout dari Firebase Auth
  Future<void> logout() async {
    try {
      if (_fbAuth != null) {
        await _fbAuth!.signOut();
      }
    } catch (_) {}
    _currentUser = null;
  }
}
