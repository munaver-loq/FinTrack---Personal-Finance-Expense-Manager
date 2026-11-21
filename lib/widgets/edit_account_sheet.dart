import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../models/user_profile_model.dart';
import '../state/finance_state.dart';
import 'user_avatar_view.dart';

class EditAccountSheet extends StatefulWidget {
  final FinanceState state;
  final UserProfileModel profile;

  const EditAccountSheet({
    super.key,
    required this.state,
    required this.profile,
  });

  @override
  State<EditAccountSheet> createState() => _EditAccountSheetState();
}

class _EditAccountSheetState extends State<EditAccountSheet> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  final List<String> _avatarPresets = [
    'assets/images/avatar_alex.png',
    'preset_cyan',
    'preset_emerald',
    'preset_violet',
    'preset_amber',
  ];

  late String _selectedAvatar;
  late CurrencyInfo _selectedCurrency;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _emailController = TextEditingController(text: widget.profile.email);
    _selectedAvatar = widget.profile.photoUrl;
    _selectedCurrency = SupportedCurrencies.findByCode(widget.profile.currencyCode);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85,
      );
      if (file != null) {
        setState(() {
          _selectedAvatar = file.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not pick photo: $e')),
        );
      }
    }
  }

  void _showPhotoSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Photo Source',
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppColors.tertiary),
                title: const Text('Take Photo with Camera'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSave() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an account name.')),
      );
      return;
    }

    widget.state.updateProfile(
      id: widget.profile.id,
      name: name,
      email: email.isNotEmpty ? email : widget.profile.email,
      photoUrl: _selectedAvatar,
      currencyCode: _selectedCurrency.code,
      currencySymbol: _selectedCurrency.symbol,
    );

    Navigator.pop(context); // close edit sheet
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceContainerHigh,
        content: Text(
          'Account "$name" updated successfully!',
          style: const TextStyle(color: AppColors.tertiary),
        ),
      ),
    );
  }

  void _handleDelete() {
    if (widget.state.userProfiles.length <= 1) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surfaceContainerHigh,
          title: const Text('Cannot Delete Account'),
          content: const Text(
            'This is the only account in the app. Please create another account before deleting this one.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: Text('Delete "${widget.profile.name}"?'),
        content: const Text(
          'This will permanently delete this account, its balances, category budgets, and transactions from internal storage.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorContainer),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final deletedName = widget.profile.name;
              Navigator.pop(ctx); // Close alert dialog
              Navigator.pop(context); // Close edit sheet
              await widget.state.deleteProfile(widget.profile.id);
              messenger.showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.surfaceContainerHigh,
                  content: Text(
                    'Account "$deletedName" deleted.',
                    style: const TextStyle(color: AppColors.alertDanger),
                  ),
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.onErrorContainer)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.edit_rounded, color: AppColors.primary, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Edit Account',
                      style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.onSurfaceVariant),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 1. Current Photo & Mobile Upload Button
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      UserAvatarView(
                        photoUrl: _selectedAvatar,
                        size: 72,
                        borderColor: AppColors.primary,
                        borderWidth: 2.5,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _showPhotoSourceSheet,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt_rounded, size: 16, color: AppColors.onPrimary),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                    onPressed: _showPhotoSourceSheet,
                    icon: const Icon(Icons.add_a_photo_rounded, size: 18),
                    label: const Text('Choose Photo in Mobile (Gallery/Camera)'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Or Pick from preset avatars
            Text(
              'Or Choose Preset Style',
              style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _avatarPresets.map((avatar) {
                final isSelected = _selectedAvatar == avatar;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedAvatar = avatar;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    child: UserAvatarView(
                      photoUrl: avatar,
                      size: 42,
                      borderColor: isSelected ? AppColors.primary : AppColors.borderStroke,
                      borderWidth: isSelected ? 2.5 : 1,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // 2. Account Name Field
            Text(
              'Account Name',
              style: AppTypography.labelMedium.copyWith(color: AppColors.onSurface),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: AppColors.onSurface),
              decoration: InputDecoration(
                hintText: 'e.g. Alex Nomad, Work Profile',
                hintStyle: const TextStyle(color: AppColors.onSurfaceVariant),
                prefixIcon: const Icon(Icons.badge_rounded, color: AppColors.primary, size: 20),
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 14),

            // 3. Email Field
            Text(
              'Email Address',
              style: AppTypography.labelMedium.copyWith(color: AppColors.onSurface),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: AppColors.onSurface),
              decoration: InputDecoration(
                hintText: 'name@fintrack.app',
                hintStyle: const TextStyle(color: AppColors.onSurfaceVariant),
                prefixIcon: const Icon(Icons.email_rounded, color: AppColors.secondary, size: 20),
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 14),

            // 4. Currency Mode Dropdown
            Text(
              'Account Currency Mode',
              style: AppTypography.labelMedium.copyWith(color: AppColors.onSurface),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderStroke),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<CurrencyInfo>(
                  value: _selectedCurrency,
                  isExpanded: true,
                  dropdownColor: AppColors.surfaceContainerHigh,
                  items: SupportedCurrencies.all.map((c) {
                    return DropdownMenuItem<CurrencyInfo>(
                      value: c,
                      child: Row(
                        children: [
                          Text(c.flag, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 10),
                          Text(
                            '${c.name} (${c.symbol} ${c.code})',
                            style: const TextStyle(color: AppColors.onSurface, fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (newCurr) {
                    if (newCurr != null) {
                      setState(() {
                        _selectedCurrency = newCurr;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 5. Actions (Save Changes & Delete Account)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.alertDanger,
                      side: const BorderSide(color: AppColors.alertDanger),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: const Text('Delete Account'),
                    onPressed: _handleDelete,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: AppColors.onPrimaryContainer,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Save Changes'),
                    onPressed: _handleSave,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
