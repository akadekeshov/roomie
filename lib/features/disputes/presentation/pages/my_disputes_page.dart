import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/dispute_models.dart';
import '../../data/dispute_service.dart';
import 'dispute_detail_page.dart';

class MyDisputesPage extends ConsumerWidget {
  const MyDisputesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disputesAsync = ref.watch(myDisputesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Мои жалобы')),
      body: disputesAsync.when(
        loading: () => const Center(
          child: Text(
            'Загрузка жалоб...',
            style: TextStyle(color: AppColors.mutedText),
          ),
        ),
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
            return const Center(
              child: Text(
                'У вас пока нет жалоб',
                style: TextStyle(color: AppColors.mutedText),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myDisputesProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final dispute = disputes[index];
                return _DisputeCard(dispute: dispute);
              },
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: disputes.length,
            ),
          );
        },
      ),
    );
  }
}

class _DisputeCard extends StatelessWidget {
  const _DisputeCard({required this.dispute});

  final DisputeItem dispute;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DisputeDetailPage(dispute: dispute),
          ),
        );
      },
      borderRadius: BorderRadius.circular(18),
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
                      _DirectionBadge(dispute: dispute),
                      const SizedBox(height: 10),
                      Text(
                        dispute.counterpartySubtitle,
                        style: const TextStyle(
                          color: AppColors.mutedText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusChip(status: dispute.status),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              dispute.reason.label,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF001561),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Создана: ${formatDateRu(dispute.createdAt)}',
              style: const TextStyle(color: AppColors.mutedText),
            ),
            if (dispute.reviewedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Рассмотрена: ${formatDateRu(dispute.reviewedAt)}',
                style: const TextStyle(color: AppColors.mutedText),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _SoftChip(label: dispute.decision.label),
                if (dispute.action != DisputeAction.none)
                  _SoftChip(label: dispute.action.label),
              ],
            ),
            if ((dispute.summaryResult ?? '').isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                dispute.summaryResult!,
                style: const TextStyle(
                  color: Color(0xFF001561),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if ((dispute.adminComment ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Комментарий модератора: ${dispute.adminComment}',
                style: const TextStyle(color: AppColors.mutedText),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DirectionBadge extends StatelessWidget {
  const _DirectionBadge({required this.dispute});

  final DisputeItem dispute;

  @override
  Widget build(BuildContext context) {
    final incoming = dispute.direction == DisputeDirection.incoming;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: incoming ? const Color(0xFFFDECEC) : AppColors.searchBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        dispute.directionTitle,
        style: TextStyle(
          color: incoming ? const Color(0xFFC62828) : AppColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
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
