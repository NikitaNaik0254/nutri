import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import '../screens/settings_screen.dart';
import '../screens/user_recipes_screen.dart';

class NutriProfileScreen extends StatefulWidget {
  const NutriProfileScreen({Key? key}) : super(key: key);

  @override
  State<NutriProfileScreen> createState() => _NutriProfileScreenState();
}

class _NutriProfileScreenState extends State<NutriProfileScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();
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
        // Verify the image exists
        final httpResponse = await http.head(Uri.parse(imageUrl));
        if (httpResponse.statusCode == 200) {
          setState(() => _profileImageUrl = imageUrl);
        } else {
          await _clearInvalidProfilePicture();
        }
      }
    } catch (e) {
      debugPrint('Error loading profile picture: $e');
    } finally {
      setState(() => _isImageLoading = false);
    }
  }

  Future<void> _clearInvalidProfilePicture() async {
    try {
      await _supabase
          .from('profiles')
          .update({'profile_picture_url': null})
          .eq('id', _user!.id);
    } catch (e) {
      debugPrint('Error clearing invalid profile picture: $e');
    }
  }

  Future<void> _pickAndUploadImage() async {
    if (_user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user logged in')));
      return;
    }

    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() => _isLoading = true);

      // Read image bytes
      Uint8List fileBytes = await pickedFile.readAsBytes();
      if (fileBytes.isEmpty) throw Exception('Empty image file');

      // Determine file extension
      String fileExtension = 'jpg'; // default
      if (!kIsWeb) {
        // For mobile/desktop
        final filePath = pickedFile.path.toLowerCase();
        fileExtension = filePath.split('.').last;
      } else {
        // For web - check the mime type
        final mimeType = pickedFile.mimeType?.toLowerCase() ?? 'image/jpeg';
        if (mimeType.contains('jpeg')) {
          fileExtension = 'jpg';
        } else if (mimeType.contains('png')) {
          fileExtension = 'png';
        } else if (mimeType.contains('gif')) {
          fileExtension = 'gif';
        } else if (mimeType.contains('webp')) {
          fileExtension = 'webp';
        }
      }

      // Validate supported formats
      final supportedFormats = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
      if (!supportedFormats.contains(fileExtension)) {
        throw Exception('Please select an image in JPG, PNG, or GIF format');
      }

      // Validate image size (max 2MB)
      if (fileBytes.length > 2 * 1024 * 1024) {
        throw Exception('Image size too large (max 2MB)');
      }

      // Generate unique filename
      final fileName = 'profile_${_user!.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      final filePath = '${_user!.id}/$fileName';

      // Upload to storage
      await _supabase.storage
          .from('profilepictures')
          .uploadBinary(
            filePath,
            fileBytes,
            fileOptions: FileOptions(
              contentType: 'image/$fileExtension',
              upsert: true,
            ),
          );

      // Get public URL
      final imageUrl = _supabase.storage
          .from('profilepictures')
          .getPublicUrl(filePath);

      // Update profile with new image URL
      await _supabase
          .from('profiles')
          .upsert({
            'id': _user!.id,
            'profile_picture_url': imageUrl,
            'updated_at': DateTime.now().toIso8601String(),
          });

      setState(() {
        _profileImageUrl = imageUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated successfully!')));
    } catch (e) {
      debugPrint('Profile picture error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}')));
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                            icon: const Icon(Icons.camera_alt, 
                                color: Colors.white, 
                                size: 20),
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
                  Expanded(
                    child: ListView(
                      children: [
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UserRecipesScreen()),
    );
  },
),
ListTile(
  leading: const Icon(Icons.settings),
  title: Text(
    'Account Settings',
    style: GoogleFonts.poppins(),
  ),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
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
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/login', 
                              (route) => false);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}