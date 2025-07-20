import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

class NutriProfileScreen extends StatefulWidget {
  const NutriProfileScreen({Key? key}) : super(key: key);

  @override
  State<NutriProfileScreen> createState() => _NutriProfileScreenState();
}

class _NutriProfileScreenState extends State<NutriProfileScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  User? _user;
  String? _profileImageUrl;
  bool _isLoading = false;
  bool _isImageLoading = false;

  @override
  void initState() {
    super.initState();
    _user = _supabase.auth.currentUser;
    _loadProfilePicture();
  }

  Future<void> _loadProfilePicture() async {
    if (_user == null) return;
    
    setState(() => _isImageLoading = true);
    try {
      final profileResponse = await _supabase
          .from('profiles')
          .select('profile_picture_url')
          .eq('id', _user!.id)
          .single();
      
      if (profileResponse['profile_picture_url'] != null) {
        final imageUrl = profileResponse['profile_picture_url'] as String;
        // Verify the image exists before setting it
        final httpResponse = await http.head(Uri.parse(imageUrl));
        if (httpResponse.statusCode == 200) {
          setState(() => _profileImageUrl = imageUrl);
        }
      }
    } catch (e) {
      debugPrint('Error loading profile picture: $e');
    } finally {
      setState(() => _isImageLoading = false);
    }
  }

  Future<void> _pickAndUploadImage() async {
  if (_user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No user logged in')));
    return;
  }

  try {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    setState(() => _isLoading = true);

    // Read and validate image
    final fileBytes = await pickedFile.readAsBytes();
    if (fileBytes.isEmpty) throw Exception('Empty image file');

    // Get file extension and handle case sensitivity
    final filePath = pickedFile.path.toLowerCase();
    final fileExtension = filePath.split('.').last;
    
    // Support more common image formats
    final supportedFormats = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];
    if (!supportedFormats.contains(fileExtension)) {
      throw Exception('Unsupported image format: .$fileExtension');
    }

    final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
    final mimeType = 'image/$fileExtension';

    // Upload to storage
    final uploadResponse = await _supabase.storage
        .from('profilepictures')
        .uploadBinary(
          '${_user!.id}/$fileName',
          fileBytes,
          fileOptions: FileOptions(
            contentType: mimeType,
            upsert: true,
          ),
        );

    debugPrint('Upload response: $uploadResponse');

    // Construct URL manually
    final imageUrl = 'https://${_supabase.supabaseUrl.substring(8)}/storage/v1/object/public/profilepictures/${_user!.id}/$fileName';

    // Verify URL
    final httpResponse = await http.head(Uri.parse(imageUrl));
    if (httpResponse.statusCode != 200) {
      throw Exception('Uploaded image not accessible. Status: ${httpResponse.statusCode}');
    }

    // Update profile
    await _supabase
        .from('profiles')
        .update({'profile_picture_url': imageUrl})
        .eq('id', _user!.id);

    setState(() {
      _profileImageUrl = imageUrl;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated successfully!')));
    });
  } catch (e) {
    debugPrint('Profile picture error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')));
  } finally {
    setState(() => _isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutritionist Profile'),
        backgroundColor: Colors.green.shade800,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                _isImageLoading
                    ? const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.green,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.green,
                        backgroundImage: _profileImageUrl != null
                            ? NetworkImage(_profileImageUrl!)
                            : null,
                        child: _profileImageUrl == null
                            ? const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white,
                              )
                            : null,
                      ),
                if (!_isLoading && !_isImageLoading)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green.shade800,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      onPressed: _pickAndUploadImage,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            if (_user != null) ...[
              Text(
                _user!.email ?? 'No email',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Professional Nutritionist',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 30),
            ListTile(
              leading: const Icon(Icons.work_outline),
              title: Text(
                'Professional Information',
                style: GoogleFonts.poppins(),
              ),
              onTap: () {
                // Navigate to professional info
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment_outlined),
              title: Text(
                'My Recipes',
                style: GoogleFonts.poppins(),
              ),
              onTap: () {
                // Navigate to nutritionist's recipes
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(
                'Account Settings',
                style: GoogleFonts.poppins(),
              ),
              onTap: () {
                // Navigate to settings
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(
                'Logout',
                style: GoogleFonts.poppins(),
              ),
              onTap: () async {
                await _supabase.auth.signOut();
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}

extension on SupabaseClient {
  get supabaseUrl => null;
}