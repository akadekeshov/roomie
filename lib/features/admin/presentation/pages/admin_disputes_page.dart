import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/app_snackbar.dart';
import '../../../../core/utils/formatters.dart';
import '../../../disputes/data/dispute_models.dart';
import '../../../disputes/data/dispute_service.dart';

class AdminDisputesPage extends ConsumerStatefulWidget {
  const AdminDisputesPage({super.key});

  @override
  ConsumerState<AdminDisputesPage> createState() => _AdminDisputesPageState();
}

class _AdminDisputesPageState extends ConsumerState<AdminDisputesPage> {
  DisputeStatus? _statusFilter;
  DisputeReason? _reasonFilter;

  @override
  Widget build(BuildContext context) {
    final disputesAsync = ref.watch(
      adminDisputesProvider({
        'status': _statusFilter?.apiValue,
        'reason': _reasonFilter?.apiValue,
      }),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Жалобы пользователей')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<DisputeStatus?>(
                    initialValue: _statusFilter,
                    decoration: const InputDecoration(labelText: 'Статус'),
                    items: [
                      const DropdownMenuItem<DisputeStatus?>(
                        value: null,
                        child: Text('Все'),
                      ),
                      ...DisputeStatus.values.map(
                        (status) => DropdownMenuItem<DisputeStatus?>(
                          value: status,
                          child: Text(status.label),
                        ),
                      ),
                    ],
                    onChanged: (value) => setState(() => _statusFilter = value),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<DisputeReason?>(
                    initialValue: _reasonFilter,
                    decoration: const InputDecoration(labelText: 'Причина'),
                    items: [
                      const DropdownMenuItem<DisputeReason?>(
                        value: null,
                        child: Text('Все'),
                      ),
                      ...DisputeReason.values.map(
                        (reason) => DropdownMenuItem<DisputeReason?>(
                          value: reason,
                          child: Text(reason.label),
                        ),
                      ),
                    ],
                    onChanged: (value) => setState(() => _reasonFilter = value),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: disputesAsync.when(
              loading: () => const Center(child: Text('Загрузка жалоб...')),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Не удалось загрузить жалобы.\n$error',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              data: (disputes) {
                if (disputes.isEmpty) {
                  return const Center(child: Text('Жалобы не найдены.'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemBuilder: (context, index) {
                    final dispute = disputes[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => _openReviewDialog(context, dispute),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        dispute.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF001561),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Заявитель: ${dispute.reporter?.displayName ?? 'Не указано'}',
                                        style: const TextStyle(
                                          color: AppColors.mutedText,
                                        ),
                                      ),
                                      Text(
                                        'Против кого: ${dispute.accused?.displayName ?? 'Не указано'}',
                                        style: const TextStyle(
                                          color: AppColors.mutedText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _StatusChip(status: dispute.status),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _SoftChip(label: dispute.reason.label),
                                _SoftChip(label: dispute.decision.label),
                                if (dispute.action != DisputeAction.none)
                                  _SoftChip(label: dispute.action.label),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Создана: ${formatDateRu(dispute.createdAt)}',
                              style:
                                  const TextStyle(color: AppColors.mutedText),
                            ),
                            if ((dispute.summaryResult ?? '').isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                dispute.summaryResult!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF001561),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: disputes.length,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openReviewDialog(
    BuildContext context,
    DisputeItem dispute,
  ) async {
    var selectedDecision = dispute.decision == DisputeDecision.none
        ? DisputeDecision.accepted
        : dispute.decision;
    var selectedAction =
        dispute.action == DisputeAction.none ? DisputeAction.warning : dispute.action;
    final commentController =
        TextEditingController(text: dispute.adminComment ?? '');
    final restrictionController = TextEditingController(
      text: dispute.action == DisputeAction.temporaryRestriction &&
              dispute.actionExpiresAt != null &&
              dispute.reviewedAt != null
          ? '${dispute.actionExpiresAt!.difference(dispute.reviewedAt!).inDays.clamp(1, 365)}'
          : '7',
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setStateDialog) {
            final needsAction = selectedDecision == DisputeDecision.accepted;
            final needsRestrictionDays =
                selectedAction == DisputeAction.temporaryRestriction;

            return AlertDialog(
              title: Text(dispute.title),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Заявитель: ${dispute.reporter?.displayName ?? 'Не указано'}',
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Против кого: ${dispute.accused?.displayName ?? 'Не указано'}',
                    ),
                    const SizedBox(height: 6),
                    Text('Причина: ${dispute.reason.label}'),
                    const SizedBox(height: 6),
                    Text('Описание: ${dispute.description}'),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<DisputeDecision>(
                      initialValue: selectedDecision,
                      decoration: const InputDecoration(labelText: 'Решение'),
                      items: const [
                        DropdownMenuItem(
                          value: DisputeDecision.accepted,
                          child: Text('Подтвердить жалобу'),
                        ),
                        DropdownMenuItem(
                          value: DisputeDecision.rejected,
                          child: Text('Отклонить жалобу'),
                        ),
                        DropdownMenuItem(
                          value: DisputeDecision.needMoreInfo,
                          child: Text('Запросить дополнительную информацию'),
                        ),
                      ],
                      onChanged: (value) {
                        setStateDialog(() {
                          selectedDecision =
                              value ?? DisputeDecision.accepted;
                        });
                      },
                    ),
                    if (needsAction) ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<DisputeAction>(
                        initialValue: selectedAction,
                        decoration:
                            const InputDecoration(labelText: 'Действие'),
                        items: const [
                          DropdownMenuItem(
                            value: DisputeAction.warning,
                            child: Text('Предупреждение'),
                          ),
                          DropdownMenuItem(
                            value: DisputeAction.temporaryRestriction,
                            child: Text('Временное ограничение'),
                          ),
                          DropdownMenuItem(
                            value: DisputeAction.accountBan,
                            child: Text('Блокировка аккаунта'),
                          ),
                          DropdownMenuItem(
                            value: DisputeAction.agreementCancelled,
                            child: Text('Отменить договор'),
                          ),
                          DropdownMenuItem(
                            value: DisputeAction.paymentRequired,
                            child: Text('Требуется оплата'),
                          ),
                          DropdownMenuItem(
                            value: DisputeAction.profileFlagged,
                            child: Text('Пометить профиль'),
                          ),
                        ],
                        onChanged: (value) {
                          setStateDialog(() {
                            selectedAction = value ?? DisputeAction.warning;
                          });
                        },
                      ),
                    ],
                    if (needsRestrictionDays) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: restrictionController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Срок ограничения в днях',
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Комментарий модератора',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Назад'),
                ),
                FilledButton(
                  onPressed: () async {
                    final comment = commentController.text.trim();
                    final navigator = Navigator.of(dialogContext);

                    if ((selectedDecision == DisputeDecision.accepted ||
                            selectedDecision == DisputeDecision.rejected) &&
                        comment.isEmpty) {
                      showAppSnackBar(
                        context,
                        'Комментарий модератора обязателен для этого решения.',
                        isError: true,
                      );
                      return;
                    }

                    if (
                        selectedDecision == DisputeDecision.accepted &&
                        selectedAction == DisputeAction.none) {
                      showAppSnackBar(
                        context,
                        'Выберите действие для подтвержденной жалобы.',
                        isError: true,
                      );
                      return;
                    }

                    if (selectedAction == DisputeAction.agreementCancelled &&
                        (dispute.agreementId == null ||
                            dispute.agreementId!.isEmpty)) {
                      showAppSnackBar(
                        context,
                        'Эта жалоба не связана с договором.',
                        isError: true,
                      );
                      return;
                    }

                    final restrictionDays =
                        int.tryParse(restrictionController.text.trim());
                    if (selectedAction == DisputeAction.temporaryRestriction &&
                        (restrictionDays == null || restrictionDays <= 0)) {
                      showAppSnackBar(
                        context,
                        'Укажите корректный срок ограничения.',
                        isError: true,
                      );
                      return;
                    }

                    try {
                      await ref.read(disputeServiceProvider).resolveDispute(
                            disputeId: dispute.id,
                            decision: selectedDecision,
                            action: needsAction
                                ? selectedAction
                                : DisputeAction.none,
                            adminComment: comment,
                            restrictionDays: needsRestrictionDays
                                ? restrictionDays
                                : null,
                          );
                      if (!mounted) return;
                      ref.invalidate(
                        adminDisputesProvider({
                          'status': _statusFilter?.apiValue,
                          'reason': _reasonFilter?.apiValue,
                        }),
                      );
                      ref.invalidate(myDisputesProvider);
                      navigator.pop();
                    } catch (error) {
                      if (!mounted) return;
                      showAppSnackBar(
                        this.context,
                        formatUserError(error),
                        isError: true,
                      );
                    }
                  },
                  child: const Text('Сохранить решение'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final DisputeStatus status;

  @override
  Widget build(BuildContext context) {
    Color background;
    Color foreground;

    switch (status) {
      case DisputeStatus.resolved:
        background = const Color(0x1422C55E);
        foreground = const Color(0xFF15803D);
        break;
      case DisputeStatus.rejected:
      case DisputeStatus.closed:
        background = const Color(0x14EF4444);
        foreground = const Color(0xFFDC2626);
        break;
      case DisputeStatus.inReview:
      case DisputeStatus.open:
        background = AppColors.searchBg;
        foreground = AppColors.primary;
        break;
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

class _SoftChip extends StatelessWidget {
  const _SoftChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF4E5884),
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
