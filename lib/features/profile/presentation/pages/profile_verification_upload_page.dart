import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/localization/build_context_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/dashed_border_container.dart';
import '../../data/verification_repository.dart';
import '../widgets/profile_flow_header.dart';

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
  String? _selfiePath;
  bool _isSubmitting = false;

  bool get _canSubmit =>
      !_isSubmitting &&
      (_documentPath?.trim().isNotEmpty ?? false) &&
      (_selfiePath?.trim().isNotEmpty ?? false);

  Future<void> _pickDocument() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
      maxWidth: 2048,
    );
    if (!mounted || picked == null) return;
    setState(() => _documentPath = picked.path);
  }

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
    final l10n = context.l10n;
    if (!_canSubmit) return;

    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(verificationRepositoryProvider);

      await repo.uploadDocument(File(_documentPath!));
      await repo.uploadSelfie(File(_selfiePath!));
      await repo.submit();

      if (!mounted) return;

      await showDialog<void>(
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
                  Text(
                    l10n.profileVerificationSuccessTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.profileVerificationSuccessSubtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
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
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        l10n.done,
                        style: const TextStyle(
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

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorGeneric)),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            children: [
              ProfileFlowHeader(title: l10n.profileTitle),
              const SizedBox(height: 14),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.profileVerificationUploadTitle,
                        style: textTheme.headlineSmall?.copyWith(
                          color: const Color(0xFF001561),
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        l10n.profileVerificationUploadSubtitle,
                        style: textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFFA0A6B7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _UploadBox(
                        path: _documentPath,
                        onTap: _pickDocument,
                        label: l10n.profileVerificationUploadDocumentLabel,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        l10n.profileVerificationUploadSelfieTitle,
                        style: textTheme.headlineSmall?.copyWith(
                          color: const Color(0xFF001561),
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _UploadBox(
                        path: _selfiePath,
                        onTap: _pickSelfie,
                        label: l10n.profileVerificationUploadSelfieLabel,
                      ),
                      const SizedBox(height: 14),
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
                              l10n.profileVerificationChecklistTitle,
                              style: textTheme.titleMedium?.copyWith(
                                color: const Color(0xFF001561),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _BulletLine(
                              text: l10n.profileVerificationChecklistClearPhoto,
                            ),
                            const SizedBox(height: 6),
                            _BulletLine(
                              text: l10n.profileVerificationChecklistNoGlare,
                            ),
                            const SizedBox(height: 6),
                            _BulletLine(
                              text: l10n.profileVerificationChecklistAllEdges,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AppPrimaryButton(
                label: _isSubmitting
                    ? l10n.profileVerificationSubmitting
                    : l10n.profileVerificationSubmit,
                onPressed: _canSubmit ? _submit : null,
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
  const _UploadBox({
    required this.path,
    required this.onTap,
    required this.label,
  });

  final String? path;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    final hasFile = path != null && path!.trim().isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: DashedBorderContainer(
        radius: 18,
        color: const Color(0xFFD6DAE6),
        height: hasFile ? 250 : 150,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              if (hasFile) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(
                    File(path!),
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
              ] else ...[
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: Color(0x147C3AED),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_a_photo_outlined,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF001561),
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

class _BulletLine extends StatelessWidget {
  const _BulletLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Icon(
            Icons.circle,
            size: 6,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF55607E),
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }
}
