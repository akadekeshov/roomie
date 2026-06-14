import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_text_localizer.dart';
import '../../../../core/localization/build_context_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/dispute_models.dart';
import '../../data/dispute_service.dart';
import 'dispute_detail_page.dart';

class MyDisputesPage extends ConsumerWidget {
  const MyDisputesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final disputesAsync = ref.watch(myDisputesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.disputesTitle)),
      body: disputesAsync.when(
        loading: () => Center(
          child: Text(
            l10n.disputesLoading,
            style: const TextStyle(color: AppColors.mutedText),
          ),
        ),
        error: (_, __) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l10n.disputesLoadError,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (disputes) {
          if (disputes.isEmpty) {
            return Center(
              child: Text(
                l10n.disputesEmpty,
                style: const TextStyle(color: AppColors.mutedText),
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
    final l10n = context.l10n;

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
                        localizeDisputeCounterpartySubtitle(context, dispute),
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
              dispute.reason.localizedLabel(l10n),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF001561),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.disputeCreatedAt(formatLocalizedDate(context, dispute.createdAt)),
              style: const TextStyle(color: AppColors.mutedText),
            ),
            if (dispute.reviewedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                l10n.disputeReviewedAt(
                  formatLocalizedDate(context, dispute.reviewedAt),
                ),
                style: const TextStyle(color: AppColors.mutedText),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _SoftChip(label: dispute.decision.localizedLabel(l10n)),
                if (dispute.action != DisputeAction.none)
                  _SoftChip(label: dispute.action.localizedLabel(l10n)),
              ],
            ),
            if ((localizeDisputeSummary(context, dispute) ?? '').isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                localizeDisputeSummary(context, dispute)!,
                style: const TextStyle(
                  color: Color(0xFF001561),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if ((dispute.adminComment ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                l10n.disputeAdminComment(dispute.adminComment!.trim()),
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
        localizeDisputeDirectionTitle(context, dispute),
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
    final l10n = context.l10n;
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
        status.localizedLabel(l10n),
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
