import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import 'package:roommate_app/features/home/data/listing_model.dart';
import 'package:roommate_app/features/saved/data/saved_providers.dart';
import 'package:roommate_app/features/saved/data/saved_repository.dart';
import '../main/main_shell.dart';

class SavedProfilePage extends ConsumerWidget {
  const SavedProfilePage({super.key, required this.listing});

  final Listing listing;

  void _msg(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль объявления')),
      body: ListView(
        children: [
          if (listing.firstImageUrl.isNotEmpty)
            AspectRatio(
              aspectRatio: 1.2,
              child: Image.network(
                listing.firstImageUrl,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              height: 200,
              color: AppColors.avatarPlaceholder,
              child: const Icon(
                Icons.home_rounded,
                size: 64,
                color: AppColors.mutedText,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF001561),
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${listing.ownerDisplayName} · ${listing.displayLocation}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.mutedText,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  listing.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                _Row(label: 'Адрес', value: listing.address),
                _Row(label: 'Город', value: listing.city),
                _Row(label: 'Тип', value: listing.roomType),
                _Row(
                  label: 'Цена',
                  value: '${listing.price.toStringAsFixed(0)} ₸',
                ),
                if (listing.amenities.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Удобства: ${listing.amenities.join(', ')}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        await ref
                            .read(savedRepositoryProvider)
                            .unsave(listing.id);
                        ref.invalidate(savedListingsProvider);
                        _msg(context, 'Удалено из сохранённых');
                        if (context.mounted) {
                          Navigator.pop(context);
                          MainShellController.instance.changeTab?.call(0);
                        }
                      } catch (_) {
                        _msg(context, 'Не удалось удалить');
                      }
                    },
                    icon: const Icon(Icons.favorite_border),
                    label: const Text('Удалить из сохранённых'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedText,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
