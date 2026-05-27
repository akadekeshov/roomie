import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/agreement_models.dart';
import '../../data/agreement_service.dart';
import 'agreement_detail_page.dart';

class MyAgreementsPage extends ConsumerWidget {
  const MyAgreementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agreementsAsync = ref.watch(myAgreementsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Мои договоры')),
      body: agreementsAsync.when(
        loading: () => const Center(
          child: Text('Загрузка договоров...'),
        ),
        error: (error, _) => _ErrorState(
          message: 'Не удалось загрузить договоры.\n$error',
          onRetry: () => ref.invalidate(myAgreementsProvider),
        ),
        data: (agreements) {
          if (agreements.isEmpty) {
            return const Center(
              child: Text('У вас пока нет договоров'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myAgreementsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final agreement = agreements[index];
                final otherUser = agreement.otherUser ?? agreement.secondUser;
                return Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AgreementDetailPage(
                            agreementId: agreement.id,
                          ),
                        ),
                      );
                      ref.invalidate(myAgreementsProvider);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: AppColors.avatarPlaceholder,
                                backgroundImage: otherUser.avatarUrl == null
                                    ? null
                                    : NetworkImage(otherUser.avatarUrl!),
                                child: otherUser.avatarUrl == null
                                    ? Text(
                                        otherUser.displayName.characters.first
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          color: Color(0xFF001561),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Договор с: ${otherUser.displayName}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF001561),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Статус: ${agreement.status.label}',
                                      style: const TextStyle(
                                        color: AppColors.mutedText,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _AgreementStatusChip(status: agreement.status),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            agreement.currentUserConfirmed
                                ? 'Вы подтвердили договор'
                                : 'Вы еще не подтвердили договор',
                            style: const TextStyle(
                              color: Color(0xFF001561),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            agreement.otherUserConfirmed
                                ? 'Второй участник подтвердил договор'
                                : 'Ожидает подтверждения второго участника',
                            style: const TextStyle(color: AppColors.mutedText),
                          ),
                          const SizedBox(height: 10),
                          if (agreement.monthlyRent != null)
                            Text(
                              'Аренда: ${formatMoneyKzt(agreement.monthlyRent)}',
                              style: const TextStyle(
                                color: Color(0xFF001561),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if (agreement.depositAmount != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Депозит: ${formatMoneyKzt(agreement.depositAmount)}',
                              style: const TextStyle(
                                color: Color(0xFF001561),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            'Создан: ${formatDateRu(agreement.createdAt)}',
                            style: const TextStyle(color: AppColors.mutedText),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: agreements.length,
            ),
          );
        },
      ),
    );
  }
}

class _AgreementStatusChip extends StatelessWidget {
  const _AgreementStatusChip({required this.status});

  final AgreementStatus status;

  @override
  Widget build(BuildContext context) {
    Color background;
    Color foreground;

    switch (status) {
      case AgreementStatus.active:
        background = const Color(0x1422C55E);
        foreground = const Color(0xFF15803D);
        break;
      case AgreementStatus.pendingConfirmation:
        background = AppColors.chipBg;
        foreground = AppColors.chipText;
        break;
      case AgreementStatus.rejected:
      case AgreementStatus.cancelled:
        background = const Color(0x14EF4444);
        foreground = const Color(0xFFDC2626);
        break;
      default:
        background = const Color(0xFFF4F2FF);
        foreground = const Color(0xFF001561);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }
}
