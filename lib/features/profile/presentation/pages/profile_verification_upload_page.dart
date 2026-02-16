import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/dashed_border_container.dart';
import '../widgets/profile_flow_header.dart';

class ProfileVerificationUploadPage extends StatefulWidget {
  const ProfileVerificationUploadPage({super.key});

  @override
  State<ProfileVerificationUploadPage> createState() =>
      _ProfileVerificationUploadPageState();
}

class _ProfileVerificationUploadPageState
    extends State<ProfileVerificationUploadPage> {
  bool _uploaded = false;

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
                        '\u0417\u0430\u0433\u0440\u0443\u0437\u0438\u0442\u0435 \u0441\u0432\u043e\u0439 \u0434\u043e\u043a\u0443\u043c\u0435\u043d\u0442',
                        style: textTheme.headlineSmall?.copyWith(
                          color: const Color(0xFF001561),
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        '\u0414\u043e\u043a\u0443\u043c\u0435\u043d\u0442 \u0438\u0441\u043f\u043e\u043b\u044c\u0437\u0443\u0435\u0442\u0441\u044f \u0442\u043e\u043b\u044c\u043a\u043e \u0434\u043b\u044f\n\u043f\u0440\u043e\u0432\u0435\u0440\u043a\u0438 \u0438 \u043d\u0435 \u043e\u0442\u043e\u0431\u0440\u0430\u0436\u0430\u0435\u0442\u0441\u044f \u0434\u0440\u0443\u0433\u0438\u043c',
                        style: textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFFA0A6B7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _UploadBox(
                        uploaded: _uploaded,
                        onTap: () => setState(() => _uploaded = true),
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
                              '\u0423\u0431\u0435\u0434\u0438\u0442\u0435\u0441\u044c, \u0447\u0442\u043e:',
                              style: textTheme.titleMedium?.copyWith(
                                color: const Color(0xFF001561),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const _BulletLine(
                              text:
                                  '\u0424\u043e\u0442\u043e \u0447\u0451\u0442\u043a\u043e\u0435',
                            ),
                            const SizedBox(height: 6),
                            const _BulletLine(
                              text:
                                  '\u0411\u0435\u0437 \u0431\u043b\u0438\u043a\u043e\u0432',
                            ),
                            const SizedBox(height: 6),
                            const _BulletLine(
                              text:
                                  '\u0412\u0441\u0435 \u043a\u0440\u0430\u044f \u0432\u0438\u0434\u043d\u044b',
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
                label:
                    '\u041e\u0442\u043f\u0440\u0430\u0432\u0438\u0442\u044c \u043d\u0430 \u043f\u0440\u043e\u0432\u0435\u0440\u043a\u0443',
                onPressed: _uploaded ? () => Navigator.of(context).pop() : null,
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
  const _UploadBox({required this.uploaded, required this.onTap});

  final bool uploaded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: DashedBorderContainer(
        color: uploaded ? AppColors.primary : const Color(0xFFC6CAD6),
        radius: 10,
        height: 170,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: uploaded
                    ? const Color(0x1A7C3AED)
                    : const Color(0xFFE3E4E8),
                shape: BoxShape.circle,
              ),
              child: Icon(
                uploaded ? Icons.check : Icons.arrow_downward_rounded,
                color: uploaded ? AppColors.primary : const Color(0xFFA6AABB),
                size: 30,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              uploaded ? 'Документ загружен' : 'Загрузить фото документа',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF001561),
                fontWeight: FontWeight.w600,
              ),
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
          '\u2022',
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
            color: const Color(0xFF4E5884),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
