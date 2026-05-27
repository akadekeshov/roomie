import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/dispute_models.dart';

class DisputeDetailPage extends StatelessWidget {
  const DisputeDetailPage({
    super.key,
    required this.dispute,
  });

  final DisputeItem dispute;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Детали жалобы')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dispute.directionTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF001561),
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  dispute.counterpartySubtitle,
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(label: dispute.status.label),
                    _InfoChip(label: dispute.reason.label),
                    _InfoChip(label: dispute.decision.label),
                    _InfoChip(label: dispute.action.label),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Участники',
            children: [
              _KeyValueRow(
                label: 'Заявитель',
                value: dispute.reporter?.displayName ?? 'Не указано',
              ),
              _KeyValueRow(
                label: 'Против кого',
                value: dispute.accused?.displayName ?? 'Не указано',
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Описание жалобы',
            children: [
              _KeyValueRow(label: 'Заголовок', value: dispute.title),
              _KeyValueRow(label: 'Причина', value: dispute.reason.label),
              _KeyValueRow(label: 'Описание', value: dispute.description),
            ],
          ),
          if (dispute.evidenceUrls.isNotEmpty) ...[
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Доказательства',
              children: dispute.evidenceUrls
                  .map((item) => _KeyValueRow(label: 'Ссылка', value: item))
                  .toList(),
            ),
          ],
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Результат рассмотрения',
            children: [
              _KeyValueRow(label: 'Статус', value: dispute.status.label),
              _KeyValueRow(label: 'Решение', value: dispute.decision.label),
              _KeyValueRow(
                label: 'Примененное действие',
                value: dispute.action.label,
              ),
              if ((dispute.summaryResult ?? '').isNotEmpty)
                _KeyValueRow(
                  label: 'Результат',
                  value: dispute.summaryResult!,
                ),
              if ((dispute.adminComment ?? '').trim().isNotEmpty)
                _KeyValueRow(
                  label: 'Комментарий модератора',
                  value: dispute.adminComment!,
                ),
              _KeyValueRow(
                label: 'Создана',
                value: formatDateRu(dispute.createdAt),
              ),
              if (dispute.reviewedAt != null)
                _KeyValueRow(
                  label: 'Рассмотрена',
                  value: formatDateRu(dispute.reviewedAt),
                ),
            ],
          ),
          if (dispute.decision == DisputeDecision.needMoreInfo) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Добавление дополнительной информации появится в следующем обновлении.',
                    ),
                  ),
                );
              },
              child: const Text('Добавить информацию'),
            ),
          ],
        ],
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
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
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  const _KeyValueRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
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
            value,
            style: const TextStyle(
              color: Color(0xFF001561),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.searchBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
