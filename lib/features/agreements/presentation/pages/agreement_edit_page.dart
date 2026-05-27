import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/agreement_models.dart';
import '../../data/agreement_service.dart';

class AgreementEditPage extends ConsumerStatefulWidget {
  const AgreementEditPage({
    super.key,
    required this.agreementId,
  });

  final String agreementId;

  @override
  ConsumerState<AgreementEditPage> createState() => _AgreementEditPageState();
}

class _AgreementEditPageState extends ConsumerState<AgreementEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _moveInDateController = TextEditingController();
  final _moveOutDateController = TextEditingController();
  final _monthlyRentController = TextEditingController();
  final _depositAmountController = TextEditingController();
  final _houseRulesController = TextEditingController();
  final _guestPolicyController = TextEditingController();
  final _quietHoursController = TextEditingController();
  final _cleaningScheduleController = TextEditingController();
  final _smokingPolicyController = TextEditingController();
  final _petPolicyController = TextEditingController();
  final _noticePeriodController = TextEditingController();
  final _damageResponsibilityController = TextEditingController();
  final _terminationTermsController = TextEditingController();
  final _disputeTermsController = TextEditingController();
  final _firstUserUtilityPercentController = TextEditingController();
  final _secondUserUtilityPercentController = TextEditingController();

  String _utilitySplitType = 'EQUAL';
  bool _housingFound = false;
  bool _saving = false;
  bool _initialized = false;

  @override
  void dispose() {
    _cityController.dispose();
    _addressController.dispose();
    _moveInDateController.dispose();
    _moveOutDateController.dispose();
    _monthlyRentController.dispose();
    _depositAmountController.dispose();
    _houseRulesController.dispose();
    _guestPolicyController.dispose();
    _quietHoursController.dispose();
    _cleaningScheduleController.dispose();
    _smokingPolicyController.dispose();
    _petPolicyController.dispose();
    _noticePeriodController.dispose();
    _damageResponsibilityController.dispose();
    _terminationTermsController.dispose();
    _disputeTermsController.dispose();
    _firstUserUtilityPercentController.dispose();
    _secondUserUtilityPercentController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
      locale: const Locale('ru'),
    );
    if (selected != null) {
      final month = selected.month.toString().padLeft(2, '0');
      final day = selected.day.toString().padLeft(2, '0');
      controller.text = '${selected.year}-$month-$day';
    }
  }

  void _hydrate(RoommateAgreement agreement) {
    if (_initialized) return;
    _initialized = true;
    _cityController.text = agreement.city ?? '';
    _addressController.text = agreement.address ?? '';
    _moveInDateController.text =
        agreement.moveInDate?.toIso8601String().split('T').first ?? '';
    _moveOutDateController.text =
        agreement.moveOutDate?.toIso8601String().split('T').first ?? '';
    _monthlyRentController.text = agreement.monthlyRent?.toString() ?? '';
    _depositAmountController.text = agreement.depositAmount?.toString() ?? '';
    _houseRulesController.text = agreement.houseRules ?? '';
    _guestPolicyController.text = agreement.guestPolicy ?? '';
    _quietHoursController.text = agreement.quietHours ?? '';
    _cleaningScheduleController.text = agreement.cleaningSchedule ?? '';
    _smokingPolicyController.text = agreement.smokingPolicy ?? '';
    _petPolicyController.text = agreement.petPolicy ?? '';
    _noticePeriodController.text = agreement.noticePeriodDays?.toString() ?? '30';
    _damageResponsibilityController.text = agreement.damageResponsibility ?? '';
    _terminationTermsController.text = agreement.terminationTerms ?? '';
    _disputeTermsController.text = agreement.disputeTerms ?? '';
    _firstUserUtilityPercentController.text =
        agreement.firstUserUtilityPercent?.toString() ?? '';
    _secondUserUtilityPercentController.text =
        agreement.secondUserUtilityPercent?.toString() ?? '';
    _utilitySplitType =
        (agreement.utilitySplitType?.isNotEmpty ?? false) ? agreement.utilitySplitType! : 'EQUAL';
    _housingFound = agreement.housingFound;
  }

  Map<String, dynamic> _buildPayload() {
    final payload = <String, dynamic>{
      'city': _cityController.text.trim(),
      'address': _addressController.text.trim(),
      'moveInDate': _moveInDateController.text.trim(),
      'moveOutDate': _moveOutDateController.text.trim(),
      'monthlyRent': int.tryParse(_monthlyRentController.text.trim()),
      'depositAmount': int.tryParse(_depositAmountController.text.trim()),
      'housingFound': _housingFound,
      'utilitySplitType': _utilitySplitType,
      'firstUserUtilityPercent':
          int.tryParse(_firstUserUtilityPercentController.text.trim()),
      'secondUserUtilityPercent':
          int.tryParse(_secondUserUtilityPercentController.text.trim()),
      'houseRules': _houseRulesController.text.trim(),
      'guestPolicy': _guestPolicyController.text.trim(),
      'quietHours': _quietHoursController.text.trim(),
      'cleaningSchedule': _cleaningScheduleController.text.trim(),
      'smokingPolicy': _smokingPolicyController.text.trim(),
      'petPolicy': _petPolicyController.text.trim(),
      'noticePeriodDays': int.tryParse(_noticePeriodController.text.trim()),
      'damageResponsibility': _damageResponsibilityController.text.trim(),
      'terminationTerms': _terminationTermsController.text.trim(),
      'disputeTerms': _disputeTermsController.text.trim(),
    }..removeWhere((key, value) => value == null);

    return payload;
  }

  String? _validatePrimaryFields() {
    final hasRent = (int.tryParse(_monthlyRentController.text.trim()) ?? 0) > 0;
    final hasDeposit =
        (int.tryParse(_depositAmountController.text.trim()) ?? 0) > 0;
    final hasRules = [
      _houseRulesController.text.trim(),
      _guestPolicyController.text.trim(),
      _quietHoursController.text.trim(),
      _cleaningScheduleController.text.trim(),
      _smokingPolicyController.text.trim(),
      _petPolicyController.text.trim(),
      _damageResponsibilityController.text.trim(),
      _terminationTermsController.text.trim(),
      _cityController.text.trim(),
    ].any((value) => value.isNotEmpty);

    if (!hasRent && !hasDeposit && !hasRules) {
      return 'Добавьте хотя бы бюджет, город или правила совместного проживания.';
    }
    if (_disputeTermsController.text.trim().isEmpty) {
      return 'Укажите порядок решения спорных ситуаций.';
    }
    return null;
  }

  Future<void> _saveOnly() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(agreementServiceProvider)
          .updateAgreement(widget.agreementId, _buildPayload());
      if (!mounted) return;
      ref.invalidate(agreementDetailProvider(widget.agreementId));
      ref.invalidate(myAgreementsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Договор сохранен.')),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$error')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _sendForConfirmation() async {
    final validationMessage = _validatePrimaryFields();
    if (validationMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationMessage)),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      await ref
          .read(agreementServiceProvider)
          .updateAgreement(widget.agreementId, _buildPayload());
      await ref
          .read(agreementServiceProvider)
          .sendForConfirmation(widget.agreementId);
      if (!mounted) return;
      ref.invalidate(agreementDetailProvider(widget.agreementId));
      ref.invalidate(myAgreementsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Договор отправлен на подтверждение.'),
        ),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$error')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _cancelAgreement() async {
    setState(() => _saving = true);
    try {
      await ref.read(agreementServiceProvider).cancelAgreement(widget.agreementId);
      if (!mounted) return;
      ref.invalidate(agreementDetailProvider(widget.agreementId));
      ref.invalidate(myAgreementsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Договор отменен.')),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$error')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final agreementAsync = ref.watch(agreementDetailProvider(widget.agreementId));

    return Scaffold(
      appBar: AppBar(title: const Text('Редактирование договора')),
      body: agreementAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Не удалось открыть форму договора.\n$error'),
          ),
        ),
        data: (agreement) {
          _hydrate(agreement);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.searchBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'Это соглашение между будущими соседями. Квартира может быть уже найдена или вы можете искать жилье вместе.',
                      style: TextStyle(
                        color: Color(0xFF001561),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: AppColors.primary,
                    activeTrackColor: AppColors.primary.withValues(alpha: 0.35),
                    title: const Text(
                      'Жилье уже найдено',
                      style: TextStyle(
                        color: Color(0xFF001561),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      _housingFound
                          ? 'Можно указать адрес и планируемую дату начала проживания.'
                          : 'Адрес и дата начала проживания пока не обязательны.',
                      style: const TextStyle(color: AppColors.mutedText),
                    ),
                    value: _housingFound,
                    onChanged: (value) {
                      setState(() => _housingFound = value);
                    },
                  ),
                  _Field(
                    controller: _cityController,
                    label: 'Город для совместного проживания',
                  ),
                  if (_housingFound) ...[
                    _Field(
                      controller: _addressController,
                      label: 'Адрес жилья',
                    ),
                    _Field(
                      controller: _moveInDateController,
                      label: 'Планируемая дата начала совместного проживания',
                      readOnly: true,
                      onTap: () => _pickDate(_moveInDateController),
                    ),
                  ],
                  _Field(
                    controller: _moveOutDateController,
                    label: 'Планируемая дата окончания проживания',
                    readOnly: true,
                    onTap: () => _pickDate(_moveOutDateController),
                  ),
                  _Field(
                    controller: _monthlyRentController,
                    label: 'Ориентир по ежемесячному бюджету',
                    keyboardType: TextInputType.number,
                  ),
                  _Field(
                    controller: _depositAmountController,
                    label: 'Ориентир по депозиту',
                    keyboardType: TextInputType.number,
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: _utilitySplitType,
                    decoration: const InputDecoration(
                      labelText: 'Как делить коммунальные платежи',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'EQUAL', child: Text('Поровну')),
                      DropdownMenuItem(
                        value: 'PERCENTAGE',
                        child: Text('В процентах'),
                      ),
                      DropdownMenuItem(
                        value: 'CUSTOM',
                        child: Text('Индивидуально'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _utilitySplitType = value ?? 'EQUAL');
                    },
                  ),
                  const SizedBox(height: 12),
                  _Field(
                    controller: _firstUserUtilityPercentController,
                    label: 'Процент первого участника',
                    keyboardType: TextInputType.number,
                  ),
                  _Field(
                    controller: _secondUserUtilityPercentController,
                    label: 'Процент второго участника',
                    keyboardType: TextInputType.number,
                  ),
                  _Field(
                    controller: _houseRulesController,
                    label: 'Правила совместного проживания',
                    maxLines: 3,
                  ),
                  _Field(
                    controller: _guestPolicyController,
                    label: 'Правила приглашения гостей',
                    maxLines: 2,
                  ),
                  _Field(
                    controller: _quietHoursController,
                    label: 'Время тишины',
                  ),
                  _Field(
                    controller: _cleaningScheduleController,
                    label: 'График уборки',
                  ),
                  _Field(
                    controller: _smokingPolicyController,
                    label: 'Правила курения',
                  ),
                  _Field(
                    controller: _petPolicyController,
                    label: 'Домашние животные',
                  ),
                  _Field(
                    controller: _noticePeriodController,
                    label: 'Срок предварительного уведомления',
                    keyboardType: TextInputType.number,
                  ),
                  _Field(
                    controller: _damageResponsibilityController,
                    label: 'Ответственность за общее имущество',
                    maxLines: 2,
                  ),
                  _Field(
                    controller: _terminationTermsController,
                    label: 'Порядок прекращения совместного проживания',
                    maxLines: 3,
                  ),
                  _Field(
                    controller: _disputeTermsController,
                    label: 'Решение спорных ситуаций',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: _saving ? null : _saveOnly,
                    child: const Text('Сохранить'),
                  ),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: _saving ? null : _sendForConfirmation,
                    child: const Text('Отправить на подтверждение'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: _saving ? null : _cancelAgreement,
                    child: const Text('Отменить договор'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
