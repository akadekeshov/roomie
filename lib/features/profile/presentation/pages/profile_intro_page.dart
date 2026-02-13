import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';

class ProfileIntroPage extends StatefulWidget {
  const ProfileIntroPage({super.key});

  @override
  State<ProfileIntroPage> createState() => _ProfileIntroPageState();
}

class _ProfileIntroPageState extends State<ProfileIntroPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  bool _showError = false;

  bool get _isValid =>
      _nameController.text.trim().isNotEmpty &&
      _ageController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_isValid) {
      Navigator.of(context).pushNamed(AppRoutes.gender);
      return;
    }
    setState(() {
      _showError = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.arrow_back_ios_new),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 24,
                                  minHeight: 24,
                                ),
                                iconSize: 18,
                                color: const Color(0xFF001561),
                              ),
                            ),
                            Text(
                              'Roomie',
                              style: textTheme.titleMedium?.copyWith(
                                fontFamily: 'Gilroy',
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF001561),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                'Как вас зовут?',
                                style: textTheme.headlineSmall?.copyWith(
                                  fontFamily: 'Gilroy',
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF001561),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: Text(
                                'Расскажите нам о себе',
                                style: textTheme.bodyLarge?.copyWith(
                                  fontFamily: 'Gilroy',
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0x80001561),
                                ),
                              ),
                            ),
                            const SizedBox(height: 25),
                            const _FieldLabel(text: 'Ваше имя'),
                            const SizedBox(height: 8),
                            _Input(
                              controller: _nameController,
                              hint: 'Калдоев Диас',
                              onChanged: (_) {
                                if (_showError) setState(() => _showError = false);
                              },
                            ),
                            const SizedBox(height: 20),
                            const _FieldLabel(text: 'Ваш возраст'),
                            const SizedBox(height: 8),
                            _Input(
                              controller: _ageController,
                              hint: 'дд.мм.гггг',
                              keyboardType: TextInputType.number,
                              onChanged: (_) {
                                if (_showError) setState(() => _showError = false);
                              },
                            ),
                            const SizedBox(height: 20),
                            if (_showError)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.error,
                                    color: Color(0xFFFF0D0D),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Пожалуйста заполните все поля',
                                    style: textTheme.bodySmall?.copyWith(
                                      fontFamily: 'Gilroy',
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFFFF0D0D),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.resolveWith(
                                (states) =>
                                    _isValid ? const Color(0xFF7C3AED) : const Color(0x4D7C3AED),
                              ),
                              foregroundColor: WidgetStateProperty.resolveWith(
                                (states) => _isValid ? Colors.white : const Color(0x80FFFFFF),
                              ),
                              padding: WidgetStateProperty.all(
                                const EdgeInsets.symmetric(vertical: 14),
                              ),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(99),
                                ),
                              ),
                            ),
                            onPressed: _onContinue,
                            child: const Text(
                              'Продолжить',
                              style: TextStyle(
                                fontFamily: 'Gilroy',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Gilroy',
        fontWeight: FontWeight.w600,
        fontSize: 14,
        height: 18 / 14,
        color: Color(0xFF001561),
      ),
    );
  }
}

class _Input extends StatelessWidget {
  const _Input({
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(
        fontFamily: 'Gilroy',
        fontWeight: FontWeight.w600,
        fontSize: 16,
        height: 20 / 16,
        color: Color(0xFF001561),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontFamily: 'Gilroy',
          fontWeight: FontWeight.w600,
          fontSize: 16,
          height: 20 / 16,
          color: Color(0x33001561),
        ),
        filled: true,
        fillColor: const Color(0x1A7C3AED),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }
}
