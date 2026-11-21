import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../models/user_profile_model.dart';
import '../state/finance_state.dart';
import 'user_avatar_view.dart';

class CreateAccountSheet extends StatefulWidget {
  final FinanceState state;

  const CreateAccountSheet({super.key, required this.state});

  @override
  State<CreateAccountSheet> createState() => _CreateAccountSheetState();
}

class _CreateAccountSheetState extends State<CreateAccountSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

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
    _selectedAvatar = _avatarPresets.first;
    _selectedCurrency = SupportedCurrencies.findByCode(widget.state.currencyCode);
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

  void _handleCreate() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an account name.')),
      );
      return;
    }

    widget.state.createProfile(
      name: name,
      email: email.isNotEmpty ? email : '${name.toLowerCase().replaceAll(' ', '.')}@fintrack.app',
      photoUrl: _selectedAvatar,
      currencyCode: _selectedCurrency.code,
      currencySymbol: _selectedCurrency.symbol,
    );

    Navigator.pop(context); // close create sheet
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceContainerHigh,
        content: Text(
          'Account "$name" created in ${_selectedCurrency.code} (${_selectedCurrency.symbol}) mode with \$0.00 initial balance!',
          style: const TextStyle(color: AppColors.tertiary),
        ),
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
                    const Icon(Icons.person_add_rounded, color: AppColors.primary, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Create New Account',
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

            // 1. Current Photo & Mobile Upload
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      UserAvatarView(
                        photoUrl: _selectedAvatar,
                        size: 68,
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
                    label: const Text('Add Photo'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Presets
            Text(
              'Or Select Preset Avatar',
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

            // 2. Name field
            Text('Full Name', style: AppTypography.labelMedium.copyWith(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderStroke),
              ),
              child: TextField(
                controller: _nameController,
                style: const TextStyle(color: AppColors.onSurface),
                decoration: const InputDecoration(
                  hintText: 'e.g. Personal Account, Elena Rostova',
                  hintStyle: TextStyle(color: AppColors.outline),
                  prefixIcon: Icon(Icons.badge_outlined, color: AppColors.primary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // 3. Email field
            Text('Email Address', style: AppTypography.labelMedium.copyWith(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderStroke),
              ),
              child: TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppColors.onSurface),
                decoration: const InputDecoration(
                  hintText: 'e.g. elena@fintrack.app',
                  hintStyle: TextStyle(color: AppColors.outline),
                  prefixIcon: Icon(Icons.email_outlined, color: AppColors.secondary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // 4. Currency mode selection
            Text('Account Currency Mode', style: AppTypography.labelMedium.copyWith(color: AppColors.onSurfaceVariant)),
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
            const SizedBox(height: 8),
            Text(
              'New accounts start with a clean \$0.00 balance and empty ledger.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.tertiary, fontSize: 11),
            ),
            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: AppColors.onPrimaryContainer,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.check_rounded, size: 20),
                label: const Text(
                  'Create Account',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                onPressed: _handleCreate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
