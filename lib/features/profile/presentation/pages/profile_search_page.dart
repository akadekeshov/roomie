import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../data/profile_search_options.dart';
import '../widgets/profile_flow_header.dart';
import '../widgets/profile_step_progress.dart';

class ProfileSearchPage extends StatefulWidget {
  const ProfileSearchPage({super.key});

  @override
  State<ProfileSearchPage> createState() => _ProfileSearchPageState();
}

class _ProfileSearchPageState extends State<ProfileSearchPage> {
  static const double _budgetMin = 50000;
  static const double _budgetMax = 500000;

  RangeValues _budget = const RangeValues(110000, 220000);
  String? _district;
  String? _term;
  String? _gender;

  bool get _isValid => _district != null && _term != null && _gender != null;

  String _formatMoney(double value) {
    final digits = value.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final reverseIndex = digits.length - i;
      buffer.write(digits[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            children: [
              const ProfileFlowHeader(
                progress: ProfileStepProgress(activeStep: 3),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\u041a\u043e\u0433\u043e \u0432\u044b \u0438\u0449\u0435\u0442\u0435 ?',
                        style: textTheme.headlineSmall?.copyWith(
                          color: const Color(0xFF001561),
                          fontWeight: FontWeight.w700,
                          fontSize: 36 / 2,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _Label(
                        text:
                            '\u0411\u044e\u0434\u0436\u0435\u0442 \u043d\u0430 \u0430\u0440\u0435\u043d\u0434\u0443',
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor: const Color(0xFFE0E3EA),
                          thumbColor: Colors.white,
                          overlayColor: const Color(0x227C3AED),
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 7,
                          ),
                          trackHeight: 5,
                        ),
                        child: RangeSlider(
                          values: _budget,
                          min: _budgetMin,
                          max: _budgetMax,
                          divisions: 45,
                          onChanged: (values) =>
                              setState(() => _budget = values),
                        ),
                      ),
                      Text(
                        '\u041e\u0442 ${_formatMoney(_budget.start)} \u0434\u043e ${_formatMoney(_budget.end)} \u0442\u0433/\u043c\u0435\u0441\u044f\u0446',
                        style: textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFFB0B5C5),
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 22),
                      _Label(text: '\u0420\u0430\u0439\u043e\u043d'),
                      const SizedBox(height: 8),
                      _DropdownField(
                        value: _district,
                        hint:
                            '\u0412\u044b\u0431\u0435\u0440\u0438\u0442\u0435 \u0440\u0430\u0439\u043e\u043d',
                        items: ProfileSearchOptions.districts,
                        onChanged: (value) => setState(() => _district = value),
                      ),
                      const SizedBox(height: 20),
                      _Label(
                        text:
                            '\u041f\u043e\u043b \u0441\u043e\u0436\u0438\u0442\u0435\u043b\u044f',
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _GenderChip(
                              label:
                                  '\u041c\u0443\u0436\u0441\u043a\u043e\u0439',
                              selected: _gender == 'male',
                              onTap: () => setState(() => _gender = 'male'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _GenderChip(
                              label:
                                  '\u0416\u0435\u043d\u0441\u043a\u0438\u0439',
                              selected: _gender == 'female',
                              onTap: () => setState(() => _gender = 'female'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _GenderChip(
                              label:
                                  '\u041d\u0435\u0432\u0430\u0436\u043d\u043e',
                              selected: _gender == 'any',
                              onTap: () => setState(() => _gender = 'any'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _Label(
                        text:
                            '\u0421\u0440\u043e\u043a \u043f\u0440\u043e\u0436\u0438\u0432\u0430\u043d\u0438\u044f',
                      ),
                      const SizedBox(height: 8),
                      _DropdownField(
                        value: _term,
                        hint:
                            '\u0412\u044b\u0431\u0435\u0440\u0438\u0442\u0435 \u0441\u0440\u043e\u043a',
                        items: ProfileSearchOptions.terms,
                        onChanged: (value) => setState(() => _term = value),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.primary,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '\u041c\u044b \u0438\u0441\u043f\u043e\u043b\u044c\u0437\u0443\u0435\u043c \u044d\u0442\u0438 \u0434\u0430\u043d\u043d\u044b\u0435 \u0442\u043e\u043b\u044c\u043a\u043e \u0434\u043b\u044f \u043f\u043e\u0434\u0431\u043e\u0440\u0430',
                              style: textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFFB0B5C5),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AppPrimaryButton(
                label:
                    '\u041f\u0440\u043e\u0434\u043e\u043b\u0436\u0438\u0442\u044c',
                onPressed: _isValid
                    ? () => Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.profileFinish)
                    : null,
                textStyle: const TextStyle(
                  fontFamily: 'Gilroy',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: const Color(0xFF4E556F),
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
    );
  }
}

class _DropdownField extends StatefulWidget {
  const _DropdownField({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  final String? value;
  final String hint;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  State<_DropdownField> createState() => _DropdownFieldState();
}

class _DropdownFieldState extends State<_DropdownField> {
  final GlobalKey _fieldKey = GlobalKey();

  Future<void> _openMenu() async {
    final context = _fieldKey.currentContext;
    if (context == null) return;

    final box = context.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final width = box.size.width;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        box.localToGlobal(Offset.zero, ancestor: overlay),
        box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    final selected = await showMenu<String>(
      context: context,
      position: position,
      elevation: 10,
      color: Colors.white,
      constraints: BoxConstraints(
        minWidth: width,
        maxWidth: width,
        maxHeight: 310,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      items: widget.items
          .map(
            (item) => PopupMenuItem<String>(
              value: item,
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        color: const Color(0xFF1F2435),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        fontFamily: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.fontFamily,
                      ),
                    ),
                  ),
                  if (widget.value == item)
                    const Icon(Icons.check, color: AppColors.primary, size: 18),
                ],
              ),
            ),
          )
          .toList(),
    );

    if (!mounted || selected == null) return;
    widget.onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = widget.value != null;

    return InkWell(
      key: _fieldKey,
      onTap: _openMenu,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFC6CAD6)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.value ?? widget.hint,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: hasValue
                      ? const Color(0xFF001561)
                      : const Color(0xFFB0B5C5),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF9AA1B9),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  const _GenderChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFFC6CAD6),
          ),
          color: selected ? const Color(0x147C3AED) : Colors.transparent,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF001561),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
