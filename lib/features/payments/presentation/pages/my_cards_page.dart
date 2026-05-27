import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/app_snackbar.dart';
import '../../data/payment_service.dart';

class MyCardsPage extends ConsumerStatefulWidget {
  const MyCardsPage({super.key});

  @override
  ConsumerState<MyCardsPage> createState() => _MyCardsPageState();
}

class _MyCardsPageState extends ConsumerState<MyCardsPage> {
  final _cardLast4Controller = TextEditingController();
  final _cardBrandController = TextEditingController(text: 'VISA');
  bool _loading = false;

  @override
  void dispose() {
    _cardLast4Controller.dispose();
    _cardBrandController.dispose();
    super.dispose();
  }

  Future<void> _bindCard() async {
    setState(() => _loading = true);
    try {
      final message = await ref.read(paymentServiceProvider).bindMockCard(
            cardLast4: _cardLast4Controller.text.trim(),
            cardBrand: _cardBrandController.text.trim(),
          );
      if (!mounted) return;
      ref.invalidate(myCardsProvider);
      _cardLast4Controller.clear();
      showAppSnackBar(context, message);
    } catch (error) {
      if (!mounted) return;
      showAppSnackBar(context, formatUserError(error), isError: true);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardsAsync = ref.watch(myCardsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Мои карты')),
      body: cardsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Не удалось загрузить карты.\n$error'),
          ),
        ),
        data: (cards) {
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myCardsProvider),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.searchBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Text(
                    'Это тестовая карта для дипломного MVP. Реальные платежи не выполняются.',
                    style: TextStyle(
                      color: Color(0xFF001561),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _cardLast4Controller,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  decoration: const InputDecoration(
                    labelText: 'Последние 4 цифры карты',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _cardBrandController,
                  decoration: const InputDecoration(
                    labelText: 'Тип карты',
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _loading ? null : _bindCard,
                  child: const Text('Привязать карту'),
                ),
                const SizedBox(height: 18),
                if (cards.isEmpty)
                  const Text('У вас пока нет привязанных карт.')
                else
                  ...cards.map(
                    (card) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        child: ListTile(
                          title: Text(card.maskedPan),
                          subtitle: Text(card.cardBrand ?? 'UNKNOWN'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              await ref
                                  .read(paymentServiceProvider)
                                  .removeCard(card.id);
                              ref.invalidate(myCardsProvider);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
