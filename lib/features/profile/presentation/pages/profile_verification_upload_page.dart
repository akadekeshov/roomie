import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/dashed_border_container.dart';
<<<<<<< HEAD
import '../widgets/profile_flow_header.dart';
import 'package:roommate_app/features/profile/data/verification_repository.dart';
=======
import '../../data/onboarding_repository.dart';
import '../widgets/profile_flow_header.dart';
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750

class ProfileVerificationUploadPage extends ConsumerStatefulWidget {
  const ProfileVerificationUploadPage({super.key});

  @override
  ConsumerState<ProfileVerificationUploadPage> createState() =>
      _ProfileVerificationUploadPageState();
}

class _ProfileVerificationUploadPageState
    extends ConsumerState<ProfileVerificationUploadPage> {
  final ImagePicker _imagePicker = ImagePicker();

  String? _documentPath;
<<<<<<< HEAD
  String? _selfiePath;

  bool _isSubmitting = false;

  bool get _canSubmit =>
      _documentPath != null &&
      _documentPath!.isNotEmpty &&
      _selfiePath != null &&
      _selfiePath!.isNotEmpty &&
      !_isSubmitting;
=======
  bool _isSubmitting = false;

  bool get _uploaded => _documentPath != null && _documentPath!.isNotEmpty;
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750

  Future<void> _pickDocument() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
      maxWidth: 2048,
    );
    if (!mounted || picked == null) return;
    setState(() => _documentPath = picked.path);
  }

<<<<<<< HEAD
  Future<void> _pickSelfie() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
      maxWidth: 2048,
    );
    if (!mounted || picked == null) return;
    setState(() => _selfiePath = picked.path);
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;

    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(verificationRepositoryProvider);

      await repo.uploadDocument(File(_documentPath!));
      await repo.uploadSelfie(File(_selfiePath!));
      await repo.submit();

      if (!mounted) return;
      if (!mounted) return;

showDialog(
  context: context,
  barrierDismissible: false,
  builder: (context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 42,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Документы отправлены!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Мы проверим данные в течение 24 часов.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text(
                  'Готово',
                  style: TextStyle( 
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  },
);
=======
  Future<void> _submit() async {
    if (!_uploaded || _isSubmitting || _documentPath == null) return;

    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(onboardingRepositoryProvider)
          .uploadVerificationDocument(_documentPath!);
      await ref.read(onboardingRepositoryProvider).submitVerification();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Документ отправлен на проверку')),
      );
      Navigator.of(context).pop();
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
    } on DioException catch (e) {
      if (!mounted) return;
      final serverMessage = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message']?.toString())
          : null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
<<<<<<< HEAD
          content: Text(serverMessage ?? 'Не удалось отправить документы'),
=======
          content: Text(serverMessage ?? 'Не удалось отправить документ'),
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
        ),
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
              const ProfileFlowHeader(title: 'Профиль'),
              const SizedBox(height: 14),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Загрузите свой документ',
                        style: textTheme.headlineSmall?.copyWith(
                          color: const Color(0xFF001561),
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Документ используется только для\nпроверки и не отображается другим',
                        style: textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFFA0A6B7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 14),
<<<<<<< HEAD

                      // DOCUMENT
                      _UploadBox(path: _documentPath, onTap: _pickDocument),
                      const SizedBox(height: 18),

                      // SELFIE
                      Text(
                        'Сделайте селфи',
                        style: textTheme.headlineSmall?.copyWith(
                          color: const Color(0xFF001561),
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _UploadBox(path: _selfiePath, onTap: _pickSelfie),
                      const SizedBox(height: 14),

=======
                      _UploadBox(path: _documentPath, onTap: _pickDocument),
                      const SizedBox(height: 14),
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                        decoration: BoxDecoration(
                          color: const Color(0x147C3AED),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Убедитесь, что:',
                              style: textTheme.titleMedium?.copyWith(
                                color: const Color(0xFF001561),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const _BulletLine(text: 'Фото чёткое'),
                            const SizedBox(height: 6),
                            const _BulletLine(text: 'Без бликов'),
                            const SizedBox(height: 6),
                            const _BulletLine(text: 'Все края видны'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AppPrimaryButton(
<<<<<<< HEAD
                label: _isSubmitting ? 'Отправка...' : 'Отправить на проверку',
                onPressed: _canSubmit ? _submit : null,
=======
                label: 'Отправить на проверку',
                onPressed: (_uploaded && !_isSubmitting) ? _submit : null,
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
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

class _UploadBox extends StatelessWidget {
  const _UploadBox({required this.path, required this.onTap});

  final String? path;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final uploaded = path != null && path!.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: DashedBorderContainer(
        color: uploaded ? AppColors.primary : const Color(0xFFC6CAD6),
        radius: 10,
        height: 170,
        child: uploaded
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(path!),
                  width: double.infinity,
                  height: 170,
                  fit: BoxFit.cover,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE3E4E8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_downward_rounded,
                      color: Color(0xFFA6AABB),
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
<<<<<<< HEAD
                    'Загрузить фото',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF001561),
                          fontWeight: FontWeight.w600,
                        ),
=======
                    'Загрузить фото документа',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF001561),
                      fontWeight: FontWeight.w600,
                    ),
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
                  ),
                ],
              ),
      ),
    );
  }
}

class _BulletLine extends StatelessWidget {
  const _BulletLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          '•',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
<<<<<<< HEAD
                color: const Color(0xFF4E5884),
                fontWeight: FontWeight.w500,
              ),
=======
            color: const Color(0xFF4E5884),
            fontWeight: FontWeight.w500,
          ),
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
        ),
      ],
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
