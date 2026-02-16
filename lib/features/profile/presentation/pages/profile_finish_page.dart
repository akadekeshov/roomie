import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/dashed_border_container.dart';
import '../widgets/profile_flow_header.dart';
import '../widgets/profile_step_progress.dart';

class ProfileFinishPage extends StatefulWidget {
  const ProfileFinishPage({super.key});

  @override
  State<ProfileFinishPage> createState() => _ProfileFinishPageState();
}

class _ProfileFinishPageState extends State<ProfileFinishPage> {
  final TextEditingController _aboutController = TextEditingController();
  final FocusNode _aboutFocusNode = FocusNode();

  bool _hasPhoto = false;

  static const int _maxChars = 300;

  bool get _isValid => _hasPhoto && _aboutController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _aboutController.addListener(() => setState(() {}));
    _aboutFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _aboutController.dispose();
    _aboutFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            children: [
              const ProfileFlowHeader(
                progress: ProfileStepProgress(activeStep: 4),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Добавьте фото',
                        style: textTheme.headlineSmall?.copyWith(
                          color: const Color(0xFF001561),
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _PhotoPicker(
                        hasPhoto: _hasPhoto,
                        onTap: () => setState(() => _hasPhoto = true),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Коротко о себе',
                        style: textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF4E556F),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _aboutController,
                        focusNode: _aboutFocusNode,
                        maxLines: 5,
                        maxLength: _maxChars,
                        buildCounter:
                            (
                              context, {
                              required int currentLength,
                              required bool isFocused,
                              required int? maxLength,
                            }) => const SizedBox.shrink(),
                        style: const TextStyle(
                          color: Color(0xFF001561),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'Расскажите о своих увлечениях,\nинтересах...',
                          hintStyle: const TextStyle(
                            color: Color(0xFFCED3E0),
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                          contentPadding: const EdgeInsets.all(12),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFC6CAD6),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${_aboutController.text.characters.length}/$_maxChars символов',
                          style: textTheme.bodySmall?.copyWith(
                            color: const Color(0xFFB0B5C5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AppPrimaryButton(
                label: 'Завершить',
                onPressed: _isValid
                    ? () => Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.profileCompleted)
                    : null,
                textStyle: const TextStyle(
                  fontFamily: 'Gilroy',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({required this.hasPhoto, required this.onTap});

  final bool hasPhoto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (hasPhoto) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.network(
            'https://images.unsplash.com/photo-1618641986557-1ecd230959aa?auto=format&fit=crop&w=900&q=80',
            height: 174,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: DashedBorderContainer(
        color: const Color(0xFFBFC4D2),
        radius: 14,
        height: 174,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0x1A7C3AED),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.photo_camera_outlined,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Добавить фото',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF001561),
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Минимум 1 фото',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFFB0B5C5),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
