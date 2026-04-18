import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../chat/chat_detail_page.dart';
import '../../../people/ui/recommended_user_profile_page.dart';
import '../../data/ai_search_model.dart';
import '../../data/ai_search_providers.dart';

class AiSearchPage extends ConsumerStatefulWidget {
  const AiSearchPage({super.key});

  @override
  ConsumerState<AiSearchPage> createState() => _AiSearchPageState();
}

class _AiSearchPageState extends ConsumerState<AiSearchPage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    await ref
        .read(aiSearchControllerProvider.notifier)
        .search(_controller.text, limit: 20);
  }

  void _openProfile(AiSearchResult result) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RecommendedUserProfilePage(
          user: result.toRecommendedUser(isSaved: false),
        ),
      ),
    );
  }

  void _openChat(AiSearchResult result) {
    final user = result.user;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatDetailPage(
          peerUserId: user.id,
          title: user.displayName,
          imageUrl: user.avatarUrl,
          online: true,
          letter: user.displayName.trim().isNotEmpty
              ? user.displayName.trim()[0]
              : '?',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiSearchControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('AI-поиск соседей'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF001561),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _SearchBar(
                controller: _controller,
                isLoading: state.isLoading,
                onSubmit: _submit,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _SuggestionChip(
                      label: 'Спокойная соседка без животных',
                      onTap: () {
                        _controller.text = 'Спокойная соседка без животных';
                        _submit();
                      },
                    ),
                    _SuggestionChip(
                      label: 'Сосед без курения и с тихим режимом',
                      onTap: () {
                        _controller.text =
                            'Сосед без курения и с тихим режимом';
                        _submit();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: switch (state.status) {
                  AiSearchStatus.initial => const _PlaceholderState(
                      icon: Icons.auto_awesome_outlined,
                      title: 'Опишите идеального соседа',
                      subtitle:
                          'Например: спокойный, не курит, любит чистоту и ищет жилье в центре.',
                    ),
                  AiSearchStatus.loading => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  AiSearchStatus.error => _PlaceholderState(
                      icon: Icons.error_outline,
                      title: 'Не удалось выполнить поиск',
                      subtitle: state.errorMessage ??
                          'Попробуйте отправить запрос еще раз.',
                    ),
                  AiSearchStatus.empty => const _PlaceholderState(
                      icon: Icons.search_off_rounded,
                      title: 'Ничего не найдено',
                      subtitle:
                          'Попробуйте изменить формулировку запроса или сделать его короче.',
                    ),
                  AiSearchStatus.loaded => ListView.separated(
                      itemCount: state.results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final result = state.results[index];
                        return _AiSearchResultCard(
                          result: result,
                          onOpenProfile: () => _openProfile(result),
                          onChat: () => _openChat(result),
                        );
                      },
                    ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.isLoading,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool isLoading;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => onSubmit(),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Например: тихая соседка, не курит, любит порядок',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: isLoading ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Искать'),
          ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF334155),
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}

class _AiSearchResultCard extends StatelessWidget {
  const _AiSearchResultCard({
    required this.result,
    required this.onOpenProfile,
    required this.onChat,
  });

  final AiSearchResult result;
  final VoidCallback onOpenProfile;
  final VoidCallback onChat;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = result.user.avatarUrl;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFE2E8F0),
                backgroundImage:
                    avatarUrl == null ? null : NetworkImage(avatarUrl),
                child: avatarUrl == null
                    ? const Icon(Icons.person, color: Color(0xFF64748B))
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.user.displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF001561),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result.user.city?.trim().isNotEmpty == true
                          ? result.user.city!
                          : 'Город не указан',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF64748B),
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F2FF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${result.matchPercent}%',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if ((result.user.bio ?? '').trim().isNotEmpty)
            Text(
              result.user.bio!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF334155),
                    height: 1.35,
                  ),
            ),
          const SizedBox(height: 12),
          _ExplanationBlock(
            title: 'Почему подходит',
            value: result.explanation.semantic,
          ),
          const SizedBox(height: 8),
          _ExplanationBlock(
            title: 'Образ жизни',
            value: result.explanation.lifestyle,
          ),
          const SizedBox(height: 8),
          _ExplanationBlock(
            title: 'Предпочтения',
            value: result.explanation.preferences,
          ),
          if (result.explanation.matchedFields.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: result.explanation.matchedFields
                  .map(
                    (field) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        field,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF475569),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onOpenProfile,
                  child: const Text('Профиль'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onChat,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Написать'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExplanationBlock extends StatelessWidget {
  const _ExplanationBlock({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          value.trim().isEmpty ? 'Нет деталей' : value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF0F172A),
                height: 1.35,
              ),
        ),
      ],
    );
  }
}

class _PlaceholderState extends StatelessWidget {
  const _PlaceholderState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 46, color: AppColors.primary),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF001561),
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF64748B),
                    height: 1.35,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
