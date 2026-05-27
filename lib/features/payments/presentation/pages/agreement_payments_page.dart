import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/app_snackbar.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/payment_models.dart';
import '../../data/payment_service.dart';
import 'my_cards_page.dart';

class AgreementPaymentsPage extends ConsumerWidget {
  const AgreementPaymentsPage({
    super.key,
    required this.agreementId,
  });

  final String agreementId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(agreementPaymentsProvider(agreementId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Платежи по договору'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MyCardsPage()),
              );
            },
            icon: const Icon(Icons.credit_card_outlined),
            tooltip: 'Привязать карту',
          ),
        ],
      ),
      body: paymentsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Не удалось загрузить платежи.\n$error'),
          ),
        ),
        data: (payments) {
          if (payments.isEmpty) {
            return const Center(
              child: Text('Платежи по договору пока не созданы.'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(
              agreementPaymentsProvider(agreementId),
            ),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final payment = payments[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                payment.type.label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF001561),
                                ),
                              ),
                            ),
                            _PaymentStatusChip(status: payment.status),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text('Сумма: ${formatMoneyKzt(payment.amount)}'),
                        const SizedBox(height: 4),
                        Text('Срок оплаты: ${formatDateRu(payment.dueDate)}'),
                        if ((payment.description ?? '').trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(payment.description!),
                        ],
                        const SizedBox(height: 12),
                        if (payment.status == PaymentStatus.pending)
                          FilledButton(
                            onPressed: () async {
                              try {
                                final message = await ref
                                    .read(paymentServiceProvider)
                                    .mockPay(payment.id);
                                if (!context.mounted) return;
                                ref.invalidate(
                                  agreementPaymentsProvider(agreementId),
                                );
                                ref.invalidate(paymentRemindersProvider);
                                showAppSnackBar(context, message);
                              } catch (error) {
                                if (!context.mounted) return;
                                showAppSnackBar(
                                  context,
                                  formatUserError(error),
                                  isError: true,
                                );
                              }
                            },
                            child: const Text('Оплатить тестово'),
                          ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: payments.length,
            ),
          );
        },
      ),
    );
  }
}

class _PaymentStatusChip extends StatelessWidget {
  const _PaymentStatusChip({required this.status});

  final PaymentStatus status;

  @override
  Widget build(BuildContext context) {
    Color background;
    Color foreground;

    switch (status) {
      case PaymentStatus.paid:
        background = const Color(0x1422C55E);
        foreground = const Color(0xFF15803D);
        break;
      case PaymentStatus.pending:
        background = AppColors.chipBg;
        foreground = AppColors.chipText;
        break;
      default:
        background = const Color(0x14EF4444);
        foreground = const Color(0xFFDC2626);
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
