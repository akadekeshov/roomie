import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/onboarding_route_mapper.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/dashed_border_container.dart';
import '../../data/onboarding_repository.dart';
import '../widgets/profile_flow_header.dart';
import '../widgets/profile_step_progress.dart';

class ProfileFinishPage extends ConsumerStatefulWidget {
  const ProfileFinishPage({super.key});

  @override
  ConsumerState<ProfileFinishPage> createState() => _ProfileFinishPageState();
}

class _ProfileFinishPageState extends ConsumerState<ProfileFinishPage> {
  final TextEditingController _aboutController = TextEditingController();
  final FocusNode _aboutFocusNode = FocusNode();
  final ImagePicker _imagePicker = ImagePicker();

  String? _photoPath;
  bool _isSubmitting = false;

  static const int _maxChars = 300;

  bool get _hasPhoto => _photoPath != null && _photoPath!.isNotEmpty;
  bool get _isValid => _hasPhoto && _aboutController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _prefillFromStatus();
    _aboutController.addListener(() => setState(() {}));
    _aboutFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _aboutController.dispose();
    _aboutFocusNode.dispose();
    super.dispose();
  }

  Future<void> _prefillFromStatus() async {
    try {
      final status = await ref.read(onboardingRepositoryProvider).getStatus();
      final bio = status.profile['bio'] as String?;
      final photos =
          (status.profile['photos'] as List?)?.whereType<String>().toList() ??
          <String>[];
      if (!mounted) return;
      setState(() {
        if (bio != null && bio.isNotEmpty) {
          _aboutController.text = bio;
        }
        if (photos.isNotEmpty) {
          _photoPath = photos.first;
        }
      });
    } catch (_) {
      // Keep screen usable if prefill fails.
    }
  }

  Future<void> _pickPhoto() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
      maxWidth: 2048,
    );
    if (!mounted || picked == null) return;
    setState(() => _photoPath = picked.path);
  }

  Future<void> _submit() async {
    if (!_isValid || _isSubmitting || _photoPath == null) return;
    setState(() => _isSubmitting = true);
    try {
      final nextStep = await ref
          .read(onboardingRepositoryProvider)
          .submitFinalizeStep(
            FinalizeStepPayload(
              bio: _aboutController.text.trim(),
              photos: <String>[_photoPath!],
            ),
          );
      if (!mounted) return;
      final route = nextStep == null
          ? AppRoutes.profileCompleted
          : OnboardingRouteMapper.fromStep(nextStep);
      Navigator.of(context).pushNamed(route);
    } on DioException catch (e) {
      if (!mounted) return;
      final serverMessage = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message']?.toString())
          : null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(serverMessage ?? 'Не удалось сохранить шаг')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
              ProfileFlowHeader(
                progress: const ProfileStepProgress(activeStep: 4),
                onBack: () => Navigator.of(
                  context,
                ).pushReplacementNamed(AppRoutes.profileSearch),
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
                      _PhotoPicker(photoPath: _photoPath, onTap: _pickPhoto),
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
                onPressed: (_isValid && !_isSubmitting) ? _submit : null,
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
  const _PhotoPicker({required this.photoPath, required this.onTap});

  final String? photoPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoPath != null && photoPath!.isNotEmpty;

    if (hasPhoto) {
      final file = File(photoPath!);
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: file.existsSync()
              ? Image.file(
                  file,
                  height: 174,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : Container(
                  height: 174,
                  width: double.infinity,
                  color: const Color(0xFFE9EBF2),
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_not_supported_outlined),
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
