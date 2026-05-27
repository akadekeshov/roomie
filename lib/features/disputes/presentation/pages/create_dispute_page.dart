import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/app_snackbar.dart';
import '../../data/dispute_models.dart';
import '../../data/dispute_service.dart';

class CreateDisputePage extends ConsumerStatefulWidget {
  const CreateDisputePage({
    super.key,
    this.agreementId,
    this.conversationId,
    required this.accusedId,
  });

  final String? agreementId;
  final String? conversationId;
  final String accusedId;

  @override
  ConsumerState<CreateDisputePage> createState() => _CreateDisputePageState();
}

class _CreateDisputePageState extends ConsumerState<CreateDisputePage> {
  final _titleController =
      TextEditingController(text: 'Жалоба на пользователя');
  final _descriptionController = TextEditingController();
  final _evidenceController = TextEditingController();
  final List<String> _evidenceUrls = [];
  DisputeReason _reason = DisputeReason.rudeBehavior;
  bool _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _evidenceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) {
      showAppSnackBar(context, 'Укажите заголовок жалобы.', isError: true);
      return;
    }

    if (description.isEmpty) {
      showAppSnackBar(context, 'Опишите проблему.', isError: true);
      return;
    }

    setState(() => _submitting = true);
    final navigator = Navigator.of(context);

    try {
      final message = await ref.read(disputeServiceProvider).createDispute(
            agreementId: widget.agreementId,
            conversationId: widget.conversationId,
            accusedId: widget.accusedId,
            reason: _reason,
            title: title,
            description: description,
            evidenceUrls: _evidenceUrls,
          );
      if (!mounted) return;
      ref.invalidate(myDisputesProvider);
      showAppSnackBar(context, message);
      navigator.pop();
    } catch (error) {
      if (!mounted) return;
      showAppSnackBar(context, formatUserError(error), isError: true);
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  void _addEvidence() {
    final value = _evidenceController.text.trim();
    if (value.isEmpty) return;
    setState(() => _evidenceUrls.add(value));
    _evidenceController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Подать жалобу')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<DisputeReason>(
              initialValue: _reason,
              decoration: const InputDecoration(labelText: 'Причина жалобы'),
              items: DisputeReason.values
                  .map(
                    (reason) => DropdownMenuItem(
                      value: reason,
                      child: Text(reason.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => _reason = value ?? DisputeReason.rudeBehavior);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Заголовок'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Описание'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _evidenceController,
              decoration: const InputDecoration(
                labelText: 'Доказательства',
                hintText: 'Ссылка на фото, видео или документ',
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: _addEvidence,
              child: const Text('Добавить ссылку'),
            ),
            if (_evidenceUrls.isNotEmpty) ...[
              const SizedBox(height: 10),
              ..._evidenceUrls.map(
                (item) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ListTile(
                    title: Text(item),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() => _evidenceUrls.remove(item));
                      },
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.searchBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Жалоба будет рассмотрена модератором. Прикладывайте только реальные доказательства.',
                style: TextStyle(
                  color: Color(0xFF001561),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submitting ? null : _submit,
                child: Text(
                  _submitting ? 'Отправляем...' : 'Отправить жалобу',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
