import 'dart:typed_data'; // Buat Uint8List
import 'package:flutter/foundation.dart' show kIsWeb; // Buat cek Web/Mobile
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:xcore_mobile/screens/login.dart';
import 'package:xcore_mobile/services/auth_service.dart';
import 'package:xcore_mobile/services/profile_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;
  bool _isLoadingUpdate = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  // GANTI File? JADI Uint8List? (Bytes)
  Uint8List? _imageBytes;
  String? _imageFilename;

  final ImagePicker _picker = ImagePicker();
  Map<String, dynamic>? _userData;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      // Baca file sebagai Bytes (ini jalan di Web & Mobile)
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageFilename = pickedFile.name;
      });
    }
  }

  Future<void> _saveProfile(CookieRequest request) async {
    setState(() => _isLoadingUpdate = true);

    try {
      final result = await ProfileService.updateProfile(
        request: request,
        username: _usernameController.text,
        email: _emailController.text,
        bio: _bioController.text,
        // Kirim Bytes, bukan File
        imageBytes: _imageBytes,
        imageFilename: _imageFilename,
      );

      if (result['status'] == 'success') {
        setState(() {
          _isEditing = false;
          _userData = null;
          _imageBytes = null; // Reset
          _imageFilename = null;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: const Color(0xFF4AA69B),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error UI: $e");
    } finally {
      setState(() => _isLoadingUpdate = false);
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performLogout(context);
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout(BuildContext context) async {
    final request = context.read<CookieRequest>();

    // Pastikan pakai URL logout khusus Flutter yang tadi kita buat di Django
    String logoutUrl = kIsWeb
        ? "https://alvin-christian-xcore.pbp.cs.ui.ac.id/logout-flutter/"
        : "http://10.0.2.2:8000/logout-flutter/";

    try {
      // 1. Panggil Logout ke Django
      // Library pbp_django_auth akan otomatis set request.loggedIn = false jika sukses
      await request.logout(logoutUrl);

      // 2. Bersihkan Data Lokal (Opsional, tapi bagus buat cleaning)
      // await AuthService.clearUserData();

      // 3. Update State Lokal Widget
      // Kita kosongkan _userData biar UI-nya bersih
      if (mounted) {
        setState(() {
          _userData = null;
          _isEditing = false;
        });

        // Tampilkan pesan sukses
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Berhasil Logout 👋"),
            backgroundColor: Color(0xFF4AA69B),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint("Logout error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal Logout, coba lagi."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final bool isLoggedIn = request.loggedIn;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: const Color(0xFF4AA69B),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: isLoggedIn
              ? _buildLoggedInView(context, request)
              : _buildLoggedOutView(context),
        ),
      ),
    );
  }

  Widget _buildLoggedInView(BuildContext context, CookieRequest request) {
    if (_userData == null) {
      return FutureBuilder<Map<String, dynamic>>(
        future: ProfileService.getUserProfile(request),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Gagal memuat profil.'));
          }

          _userData = snapshot.data!;
          _usernameController.text = _userData!['username'] ?? '';
          _emailController.text = _userData!['email'] ?? '';
          _bioController.text = _userData!['bio'] ?? '';

          return _buildProfileContent(context, request);
        },
      );
    } else {
      return _buildProfileContent(context, request);
    }
  }

  Widget _buildProfileContent(BuildContext context, CookieRequest request) {
    String? profilePictureUrl = _userData!['profile_picture'];

    // Logic URL Gambar
    if (profilePictureUrl != null && !profilePictureUrl.startsWith('http')) {
      // Kalau Web pake localhost, kalau Mobile pake 10.0.2.2
      String baseUrl = kIsWeb
          ? "https://alvin-christian-xcore.pbp.cs.ui.ac.id"
          : "http://10.0.2.2:8000";
      profilePictureUrl = "$baseUrl$profilePictureUrl";
    }

    // LOGIKA TAMPILAN GAMBAR (PENTING!)
    ImageProvider? imageProvider;
    if (_imageBytes != null) {
      // 1. Prioritas: Gambar yang baru dipilih dari galeri (Memory)
      imageProvider = MemoryImage(_imageBytes!);
    } else if (profilePictureUrl != null) {
      // 2. Jika tidak ada gambar baru, pakai gambar dari server (Network)
      imageProvider = NetworkImage(profilePictureUrl);
    }
    // 3. Jika tidak ada keduanya, nanti pakai Icon Default di bawah

    return Column(
      children: [
        GestureDetector(
          onTap: _isEditing ? _pickImage : null,
          child: Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: const Color(0xFF4AA69B),
                backgroundImage: imageProvider,
                child: (imageProvider == null)
                    ? const Icon(Icons.person, size: 60, color: Colors.white)
                    : null,
              ),
              if (_isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (_isEditing)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              "Tap picture to change",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),

        const SizedBox(height: 24),

        if (_isEditing) ...[
          _buildTextField("Username", _usernameController),
          const SizedBox(height: 16),
          _buildTextField("Email", _emailController),
          const SizedBox(height: 16),
          _buildTextField("Bio", _bioController, maxLines: 4),
          const SizedBox(height: 32),

          if (_isLoadingUpdate)
            const CircularProgressIndicator()
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                        _imageBytes = null; // Reset
                        _imageFilename = null;
                        _usernameController.text = _userData!['username'];
                        _emailController.text = _userData!['email'];
                        _bioController.text = _userData!['bio'];
                      });
                    },
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 36),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _saveProfile(request),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4AA69B),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Save Changes"),
                  ),
                ),
              ],
            ),
        ] else ...[
          Text(
            _userData!['username'] ?? 'User',
            style: const TextStyle(
              fontFamily: 'Nunito Sans',
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _userData!['email'] ?? '',
            style: const TextStyle(
              fontFamily: 'Nunito Sans',
              fontSize: 14,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 24),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Bio",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  (_userData!['bio'] != null &&
                          _userData!['bio'].toString().isNotEmpty)
                      ? _userData!['bio']
                      : "No bio yet. Add one below!",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _isEditing = true),
              label: const Text("Edit Profile"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showLogoutDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF4AA69B),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoggedOutView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_outlined, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text(
            'Anda Belum Login',
            style: TextStyle(
              fontFamily: 'Nunito Sans',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Silakan masuk untuk mengakses fitur profil',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Nunito Sans',
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4AA69B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Login / Masuk',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
