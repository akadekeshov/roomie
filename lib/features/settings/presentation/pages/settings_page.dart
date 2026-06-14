import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_locale.dart';
import '../../../../core/localization/build_context_l10n.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  Future<void> _showLanguageSheet(BuildContext context, WidgetRef ref) async {
    final locale = ref.read(appLocaleProvider);
    final current = AppLanguage.fromCode(locale.languageCode);

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final l10n = context.l10n;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0x1A001561),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.languageApp,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF001561),
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 14),
                _LanguageOptionTile(
                  title: l10n.languageRussian,
                  selected: current == AppLanguage.russian,
                  onTap: () async {
                    await ref
                        .read(appLocaleProvider.notifier)
                        .setLanguage(AppLanguage.russian);
                    if (context.mounted) Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 8),
                _LanguageOptionTile(
                  title: l10n.languageKazakh,
                  selected: current == AppLanguage.kazakh,
                  onTap: () async {
                    await ref
                        .read(appLocaleProvider.notifier)
                        .setLanguage(AppLanguage.kazakh);
                    if (context.mounted) Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = ref.watch(appLocaleProvider);
    final currentLanguage = AppLanguage.fromCode(locale.languageCode);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF001561),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => _showLanguageSheet(context, ref),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.languageApp,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: const Color(0xFF001561),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            currentLanguage == AppLanguage.kazakh
                                ? l10n.languageKazakh
                                : l10n.languageRussian,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.mutedText,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFFA7AEBD),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageOptionTile extends StatelessWidget {
  const _LanguageOptionTile({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0x1A7C3AED) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF001561),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            Icon(
              selected ? Icons.check_rounded : Icons.circle_outlined,
              color: selected ? AppColors.primary : const Color(0xFFA7AEBD),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
