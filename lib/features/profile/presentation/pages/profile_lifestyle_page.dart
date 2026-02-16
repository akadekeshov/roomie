import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../widgets/profile_flow_header.dart';
import '../widgets/profile_step_progress.dart';

class ProfileLifestylePage extends StatefulWidget {
  const ProfileLifestylePage({super.key});

  @override
  State<ProfileLifestylePage> createState() => _ProfileLifestylePageState();
}

class _ProfileLifestylePageState extends State<ProfileLifestylePage> {
  final Map<int, int> _selectedByGroup = <int, int>{};

  bool get _isValid => _selectedByGroup.length == 5;

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
                progress: ProfileStepProgress(activeStep: 2),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\u0412\u0430\u0448 \u043e\u0431\u0440\u0430\u0437 \u0436\u0438\u0437\u043d\u0438',
                        style: textTheme.headlineSmall?.copyWith(
                          color: const Color(0xFF001561),
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _PairRow(
                        left: _LifestyleOption(
                          group: 0,
                          value: 0,
                          label: '\u0421\u043e\u0432\u0430',
                          icon: Icons.nightlight_outlined,
                        ),
                        right: _LifestyleOption(
                          group: 0,
                          value: 1,
                          label:
                              '\u0416\u0430\u0432\u043e\u0440\u043e\u043d\u043e\u043a',
                          icon: Icons.wb_sunny_outlined,
                        ),
                        selectedByGroup: _selectedByGroup,
                        onSelect: (group, value) =>
                            setState(() => _selectedByGroup[group] = value),
                      ),
                      const SizedBox(height: 10),
                      _PairRow(
                        left: _LifestyleOption(
                          group: 1,
                          value: 0,
                          label:
                              '\u041b\u044e\u0431\u043b\u044e \u0442\u0438\u0448\u0438\u043d\u0443',
                          icon: Icons.volume_off_outlined,
                        ),
                        right: _LifestyleOption(
                          group: 1,
                          value: 1,
                          label:
                              '\u041b\u044e\u0431\u043b\u044e \u0433\u043e\u0441\u0442\u0435\u0439',
                          icon: Icons.celebration_outlined,
                        ),
                        selectedByGroup: _selectedByGroup,
                        onSelect: (group, value) =>
                            setState(() => _selectedByGroup[group] = value),
                      ),
                      const SizedBox(height: 10),
                      _PairRow(
                        left: _LifestyleOption(
                          group: 2,
                          value: 0,
                          label:
                              '\u0418\u043d\u0442\u0440\u043e\u0432\u0435\u0440\u0442',
                          icon: Icons.person_outline,
                        ),
                        right: _LifestyleOption(
                          group: 2,
                          value: 1,
                          label:
                              '\u042d\u043a\u0441\u0442\u0440\u0430\u0432\u0435\u0440\u0442',
                          icon: Icons.chat_bubble_outline,
                        ),
                        selectedByGroup: _selectedByGroup,
                        onSelect: (group, value) =>
                            setState(() => _selectedByGroup[group] = value),
                      ),
                      const SizedBox(height: 10),
                      _PairRow(
                        left: _LifestyleOption(
                          group: 3,
                          value: 0,
                          label: '\u041a\u0443\u0440\u044e',
                          icon: Icons.smoking_rooms,
                        ),
                        right: _LifestyleOption(
                          group: 3,
                          value: 1,
                          label: '\u041d\u0435 \u043a\u0443\u0440\u044e',
                          icon: Icons.smoke_free,
                        ),
                        selectedByGroup: _selectedByGroup,
                        onSelect: (group, value) =>
                            setState(() => _selectedByGroup[group] = value),
                      ),
                      const SizedBox(height: 10),
                      _PairRow(
                        left: _LifestyleOption(
                          group: 4,
                          value: 0,
                          label:
                              '\u0421 \u0436\u0438\u0432\u043e\u0442\u043d\u044b\u043c\u0438',
                          icon: Icons.pets_outlined,
                        ),
                        right: _LifestyleOption(
                          group: 4,
                          value: 1,
                          label:
                              '\u0411\u0435\u0437 \u0436\u0438\u0432\u043e\u0442\u043d\u044b\u0445',
                          icon: Icons.block,
                        ),
                        selectedByGroup: _selectedByGroup,
                        onSelect: (group, value) =>
                            setState(() => _selectedByGroup[group] = value),
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
                      ).pushNamed(AppRoutes.profileSearch)
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

class _PairRow extends StatelessWidget {
  const _PairRow({
    required this.left,
    required this.right,
    required this.selectedByGroup,
    required this.onSelect,
  });

  final _LifestyleOption left;
  final _LifestyleOption right;
  final Map<int, int> selectedByGroup;
  final void Function(int group, int value) onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _LifestyleCard(
            option: left,
            selected: selectedByGroup[left.group] == left.value,
            onTap: () => onSelect(left.group, left.value),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _LifestyleCard(
            option: right,
            selected: selectedByGroup[right.group] == right.value,
            onTap: () => onSelect(right.group, right.value),
          ),
        ),
      ],
    );
  }
}

class _LifestyleCard extends StatelessWidget {
  const _LifestyleCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _LifestyleOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        height: 86,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFFC6CAD6),
          ),
          color: selected ? const Color(0x147C3AED) : Colors.transparent,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              option.icon,
              size: 22,
              color: selected ? AppColors.primary : const Color(0xFF9AA1B9),
            ),
            const SizedBox(height: 10),
            Text(
              option.label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: const Color(0xFF001561),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LifestyleOption {
  const _LifestyleOption({
    required this.group,
    required this.value,
    required this.label,
    required this.icon,
  });

  final int group;
  final int value;
  final String label;
  final IconData icon;
}
