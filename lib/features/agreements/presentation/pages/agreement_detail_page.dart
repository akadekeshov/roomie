import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/user_brief.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../disputes/presentation/pages/create_dispute_page.dart';
import '../../../payments/presentation/pages/agreement_payments_page.dart';
import '../../../profile/data/me_repository.dart';
import '../../data/agreement_models.dart';
import '../../data/agreement_service.dart';
import 'agreement_edit_page.dart';

class AgreementDetailPage extends ConsumerWidget {
  const AgreementDetailPage({
    super.key,
    required this.agreementId,
  });

  final String agreementId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agreementAsync = ref.watch(agreementDetailProvider(agreementId));
    final me = ref.watch(meProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Детали договора')),
      body: agreementAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => _AgreementErrorState(
          message: 'Не удалось загрузить договор.\n$error',
          onRetry: () => ref.invalidate(agreementDetailProvider(agreementId)),
        ),
        data: (agreement) {
          final currentUserId = me?.id ?? '';
          final isCreator = agreement.creatorId == currentUserId;
          final canEditDraft =
              agreement.status == AgreementStatus.draft && isCreator;
          final canSendForConfirmation =
              agreement.status == AgreementStatus.draft && isCreator;
          final canCancel = agreement.status == AgreementStatus.draft
              ? isCreator
              : agreement.status == AgreementStatus.pendingConfirmation;
          final canConfirm = agreement.status ==
                  AgreementStatus.pendingConfirmation &&
              !agreement.currentUserConfirmed;
          final canReject = agreement.status ==
                  AgreementStatus.pendingConfirmation &&
              !agreement.currentUserConfirmed;
          final canOpenPayments = agreement.status == AgreementStatus.active;
          final otherUser = agreement.otherUser ??
              (agreement.firstUserId == currentUserId
                  ? agreement.secondUser
                  : agreement.firstUser);
          final canCreateDispute = otherUser.id.isNotEmpty;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(agreementDetailProvider(agreementId));
              ref.invalidate(myAgreementsProvider);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Договор с пользователем ${otherUser.displayName}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF001561),
                      ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _AgreementStatusChip(status: agreement.status),
                    const SizedBox(width: 10),
                    Text(
                      'Создан: ${formatDateRu(agreement.createdAt)}',
                      style: const TextStyle(color: AppColors.mutedText),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Формат договоренности',
                  children: [
                    _InfoRow(
                      label: 'Сценарий',
                      value: agreement.housingFound
                          ? 'Жилье уже найдено'
                          : 'Пока ищем жилье вместе',
                    ),
                    if (!agreement.housingFound)
                      const _CompactNotice(
                        text:
                            'Это соглашение между будущими соседями, а не договор аренды. Адрес и дата начала проживания могут появиться позже.',
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  title: 'Участники',
                  children: [
                    _ParticipantTile(
                      title: 'Первый участник',
                      user: agreement.firstUser,
                    ),
                    const SizedBox(height: 12),
                    _ParticipantTile(
                      title: 'Второй участник',
                      user: agreement.secondUser,
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      label: 'Создатель договора',
                      value: agreement.creator.displayName,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  title: 'Подтверждение',
                  children: [
                    _StatusLine(
                      text: agreement.currentUserConfirmed
                          ? 'Вы подтвердили договор'
                          : 'Вы еще не подтвердили договор',
                      isPositive: agreement.currentUserConfirmed,
                    ),
                    const SizedBox(height: 8),
                    _StatusLine(
                      text: agreement.otherUserConfirmed
                          ? 'Второй участник подтвердил договор'
                          : 'Второй участник еще не подтвердил договор',
                      isPositive: agreement.otherUserConfirmed,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.searchBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        agreement.status ==
                                    AgreementStatus.pendingConfirmation &&
                                !agreement.currentUserConfirmed
                            ? 'Ожидает вашего подтверждения'
                            : 'Договор станет активным только после подтверждения обеими сторонами.',
                        style: const TextStyle(
                          color: Color(0xFF001561),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  title: 'Основные условия',
                  children: [
                    _InfoRow(
                      label: 'Город для совместного проживания',
                      value: agreement.city,
                    ),
                    if (agreement.housingFound)
                      _InfoRow(label: 'Адрес жилья', value: agreement.address),
                    if (agreement.housingFound)
                      _InfoRow(
                        label:
                            'Планируемая дата начала совместного проживания',
                        value: formatDateRu(agreement.moveInDate),
                      ),
                    _InfoRow(
                      label: 'Планируемая дата окончания проживания',
                      value: formatDateRu(agreement.moveOutDate),
                    ),
                    _InfoRow(
                      label: 'Ориентир по ежемесячному бюджету',
                      value: formatMoneyKzt(agreement.monthlyRent),
                    ),
                    _InfoRow(
                      label: 'Ориентир по депозиту',
                      value: formatMoneyKzt(agreement.depositAmount),
                    ),
                    _InfoRow(
                      label: 'Как делить коммунальные платежи',
                      value: agreementUtilitySplitLabel(agreement.utilitySplitType),
                    ),
                    _InfoRow(
                      label: 'Срок предварительного уведомления',
                      value: agreement.noticePeriodDays == null
                          ? 'Не указано'
                          : '${agreement.noticePeriodDays} дней',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  title: 'Правила и условия',
                  children: [
                    _InfoRow(
                      label: 'Правила совместного проживания',
                      value: agreement.houseRules,
                    ),
                    _InfoRow(
                      label: 'Правила приглашения гостей',
                      value: agreement.guestPolicy,
                    ),
                    _InfoRow(label: 'Время тишины', value: agreement.quietHours),
                    _InfoRow(
                      label: 'График уборки',
                      value: agreement.cleaningSchedule,
                    ),
                    _InfoRow(
                      label: 'Правила курения',
                      value: agreement.smokingPolicy,
                    ),
                    _InfoRow(
                      label: 'Домашние животные',
                      value: agreement.petPolicy,
                    ),
                    _InfoRow(
                      label: 'Ответственность за общее имущество',
                      value: agreement.damageResponsibility,
                    ),
                    _InfoRow(
                      label: 'Порядок прекращения совместного проживания',
                      value: agreement.terminationTerms,
                    ),
                    _InfoRow(
                      label: 'Решение спорных ситуаций',
                      value: agreement.disputeTerms,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (agreement.status == AgreementStatus.rejected)
                  const _NoticeBanner(text: 'Договор отклонен')
                else if (agreement.status == AgreementStatus.cancelled)
                  const _NoticeBanner(text: 'Договор отменен')
                else if (agreement.status == AgreementStatus.active)
                  const _NoticeBanner(text: 'Договор активен')
                else if (agreement.status ==
                        AgreementStatus.pendingConfirmation &&
                    agreement.currentUserConfirmed)
                  const _NoticeBanner(
                    text: 'Ожидаем подтверждения второго участника',
                  ),
                if (agreement.status == AgreementStatus.rejected ||
                    agreement.status == AgreementStatus.cancelled ||
                    agreement.status == AgreementStatus.active ||
                    (agreement.status ==
                            AgreementStatus.pendingConfirmation &&
                        agreement.currentUserConfirmed))
                  const SizedBox(height: 12),
                if (canEditDraft) ...[
                  FilledButton.icon(
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              AgreementEditPage(agreementId: agreement.id),
                        ),
                      );
                      ref.invalidate(agreementDetailProvider(agreementId));
                      ref.invalidate(myAgreementsProvider);
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Редактировать'),
                  ),
                  const SizedBox(height: 10),
                ],
                if (canSendForConfirmation) ...[
                  FilledButton.icon(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        await ref
                            .read(agreementServiceProvider)
                            .sendForConfirmation(agreement.id);
                        ref.invalidate(agreementDetailProvider(agreementId));
                        ref.invalidate(myAgreementsProvider);
                        messenger.showSnackBar(
                          const SnackBar(
                            content:
                                Text('Договор отправлен на подтверждение.'),
                          ),
                        );
                      } catch (error) {
                        messenger.showSnackBar(
                          SnackBar(content: Text('$error')),
                        );
                      }
                    },
                    icon: const Icon(Icons.send_outlined),
                    label: const Text('Отправить на подтверждение'),
                  ),
                  const SizedBox(height: 10),
                ],
                if (canConfirm) ...[
                  FilledButton.icon(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        await ref
                            .read(agreementServiceProvider)
                            .confirmAgreement(agreement.id);
                        ref.invalidate(agreementDetailProvider(agreementId));
                        ref.invalidate(myAgreementsProvider);
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Договор подтвержден.'),
                          ),
                        );
                      } catch (error) {
                        messenger.showSnackBar(
                          SnackBar(content: Text('$error')),
                        );
                      }
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Подтвердить договор'),
                  ),
                  const SizedBox(height: 10),
                ],
                if (canReject) ...[
                  OutlinedButton.icon(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        await ref
                            .read(agreementServiceProvider)
                            .rejectAgreement(agreement.id);
                        ref.invalidate(agreementDetailProvider(agreementId));
                        ref.invalidate(myAgreementsProvider);
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Договор отклонен.'),
                          ),
                        );
                      } catch (error) {
                        messenger.showSnackBar(
                          SnackBar(content: Text('$error')),
                        );
                      }
                    },
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Отклонить договор'),
                  ),
                  const SizedBox(height: 10),
                ],
                if (canCancel) ...[
                  OutlinedButton.icon(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        await ref
                            .read(agreementServiceProvider)
                            .cancelAgreement(agreement.id);
                        ref.invalidate(agreementDetailProvider(agreementId));
                        ref.invalidate(myAgreementsProvider);
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Договор отменен.'),
                          ),
                        );
                      } catch (error) {
                        messenger.showSnackBar(
                          SnackBar(content: Text('$error')),
                        );
                      }
                    },
                    icon: const Icon(Icons.block_outlined),
                    label: const Text('Отменить договор'),
                  ),
                  const SizedBox(height: 10),
                ],
                if (canOpenPayments) ...[
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AgreementPaymentsPage(
                            agreementId: agreement.id,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.receipt_long_outlined),
                    label: const Text('Посмотреть платежи'),
                  ),
                  const SizedBox(height: 10),
                ],
                if (canCreateDispute)
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CreateDisputePage(
                            agreementId: agreement.id,
                            accusedId: otherUser.id,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.report_gmailerrorred_outlined),
                    label: const Text('Подать жалобу'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AgreementErrorState extends StatelessWidget {
  const _AgreementErrorState({
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF001561),
                  ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  const _ParticipantTile({
    required this.title,
    required this.user,
  });

  final String title;
  final UserBrief user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.avatarPlaceholder,
          backgroundImage:
              user.avatarUrl == null ? null : NetworkImage(user.avatarUrl!),
          child: user.avatarUrl == null
              ? Text(
                  user.displayName.characters.first.toUpperCase(),
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
                title,
                style: const TextStyle(
                  color: AppColors.mutedText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                user.displayName,
                style: const TextStyle(
                  color: Color(0xFF001561),
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (user.subtitle.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  user.subtitle,
                  style: const TextStyle(color: AppColors.mutedText),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final display = (value ?? '').trim().isEmpty ? 'Не указано' : value!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.mutedText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            display,
            style: const TextStyle(
              color: Color(0xFF001561),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({
    required this.text,
    required this.isPositive,
  });

  final String text;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isPositive ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isPositive ? const Color(0xFF16A34A) : AppColors.mutedText,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF001561),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _NoticeBanner extends StatelessWidget {
  const _NoticeBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.searchBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF001561),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CompactNotice extends StatelessWidget {
  const _CompactNotice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.mutedText,
          height: 1.4,
        ),
      ),
    );
  }
}
