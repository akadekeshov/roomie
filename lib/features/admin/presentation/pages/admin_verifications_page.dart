import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/admin_verification_repository.dart';
import '../../../home/data/home_providers.dart';

final adminPendingProvider =
    FutureProvider<List<AdminVerificationItem>>((ref) async {
  return ref.read(adminVerificationRepositoryProvider).pending();
});

class AdminVerificationsPage extends ConsumerWidget {
  const AdminVerificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminPendingProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin • Pending Verifications')),
      body: async.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Нет заявок'));
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(adminPendingProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.email ?? '',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _StatusChip(
                              label: 'Document',
                              ok: (item.documentUrl ?? '').isNotEmpty,
                            ),
                            const SizedBox(width: 10),
                            _StatusChip(
                              label: 'Selfie',
                              ok: (item.selfieUrl ?? '').isNotEmpty,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  await ref
                                      .read(adminVerificationRepositoryProvider)
                                      .approve(item.id);

                                  // ✅ refresh admin list + home recommendations
                                  ref.invalidate(adminPendingProvider);
                                  ref.invalidate(recommendedUsersProvider);

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Approved ✅'),
                                      ),
                                    );
                                  }
                                },
                                child: const Text('Approve'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () async {
                                  await ref
                                      .read(adminVerificationRepositoryProvider)
                                      .reject(item.id);

                                  // ✅ refresh admin list + home recommendations
                                  ref.invalidate(adminPendingProvider);
                                  ref.invalidate(recommendedUsersProvider);

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Rejected ❌'),
                                      ),
                                    );
                                  }
                                },
                                child: const Text('Reject'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.ok});

  final String label;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(
        ok ? Icons.check_circle : Icons.cancel,
        size: 18,
        color: ok ? Colors.green : Colors.red,
      ),
      label: Text(label),
    );
  }
}