import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../dashboard/dashboard_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  final UserModel user;

  const ProfileSetupScreen({
    required this.user,
    Key? key,
  }) : super(key: key);

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _authService = AuthService();
  final _storageService = StorageService();
  late TextEditingController _bioController;
  late TextEditingController _rateController;

  List<String> _skills = [];
  XFile? _profileImage;
  bool _isLoading = false;

  final List<String> _availableSkills = [
    'Design',
    'Writing',
    'Coding',
    'Video Editing',
    'Marketing',
    'SEO',
    'Copywriting',
    'Social Media',
    'Data Analysis',
    'Consulting',
  ];

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController(text: widget.user.bio ?? '');
    _rateController = TextEditingController(
      text: widget.user.hourlyRate?.toString() ?? '',
    );
    _skills = List.from(widget.user.skills);
  }

  @override
  void dispose() {
    _bioController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await _storageService.pickImage();
    if (image != null) {
      setState(() => _profileImage = image);
    }
  }

  void _addSkill(String skill) {
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
      });
      print("Skill added: $skill");
      print("Selected skills: $_skills");
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _skills.remove(skill);
    });
    print("Skill removed: $skill");
  }

  Future<void> _saveProfile() async {
    if (_skills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one skill')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? profileImageUrl = widget.user.profileImage;

      if (_profileImage != null) {
        profileImageUrl = await _storageService.uploadProfileImage(
          userId: widget.user.id,
          image: _profileImage!,
        );
      }

      await _authService.updateUserProfile(
        userId: widget.user.id,
        data: {
          'skills': _skills,
          'bio': _bioController.text.trim(),
          'hourlyRate': _rateController.text.isNotEmpty
              ? int.tryParse(_rateController.text)
              : null,
          'profileImage': profileImageUrl,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Profile saved successfully!')),
        );
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          AppStrings.completeProfile,
          style: TextStyle(color: AppColors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.greyLight,
                    shape: BoxShape.circle,
                    image: _profileImage != null
                        ? DecorationImage(
                            image: AssetImage(_profileImage!.path),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _profileImage == null
                      ? Icon(
                          Icons.camera_alt,
                          size: 48,
                          color: AppColors.grey,
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Skills Section
            Text(
              'Skills (Required)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 12),

            // Selected Skills (Chips)
            if (_skills.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _skills
                    .map(
                      (skill) => Chip(
                        label: Text(skill),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => _removeSkill(skill),
                        backgroundColor:
                            AppColors.primaryLight.withOpacity(0.2),
                      ),
                    )
                    .toList(),
              )
            else
              Text(
                'No skills added yet',
                style: TextStyle(color: Colors.grey.shade600),
              ),

            const SizedBox(height: 16),

            // Add Skills - Grid of Buttons (FIXED!)
            Text(
              'Select skills to add:',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableSkills
                  .where((skill) => !_skills.contains(skill))
                  .map(
                    (skill) => ActionChip(
                      label: Text(skill),
                      onPressed: () => _addSkill(skill),
                      backgroundColor: Colors.blue.shade100,
                      side: BorderSide(color: Colors.blue.shade300),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 24),

            // Hourly Rate
            TextFormField(
              controller: _rateController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Hourly Rate (Optional)',
                prefixText: '\$ ',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Bio
            TextFormField(
              controller: _bioController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'About You (Optional)',
                hintText: 'Tell us about yourself...',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Text(
                        'Complete Profile',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
