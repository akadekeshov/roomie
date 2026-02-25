import 'package:flutter/material.dart';

import 'package:roommate_app/features/home/presentation/pages/home_page.dart';
import 'package:roommate_app/features/saved/saved_page.dart';
import 'package:roommate_app/features/chat/chat_page.dart';
import 'package:roommate_app/features/profile/presentation/pages/profile_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class MainShellController {
  static final MainShellController instance = MainShellController._();

  MainShellController._();

  void Function(int index)? changeTab;
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    MainShellController.instance.changeTab = (i) {
      setState(() => _currentIndex = i);
    };
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const HomePage(),
      const SavedPage(),
      const ChatsPage(),
      const ProfilePage(), 
    
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onChanged: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentIndex, required this.onChanged});

  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0x14000000))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavIcon(
            icon: Icons.home_rounded,
            selected: currentIndex == 0,
            onTap: () => onChanged(0),
          ),
          _NavIcon(
            icon: Icons.favorite_border,
            selected: currentIndex == 1,
            onTap: () => onChanged(1),
          ),
          _NavIcon(
            icon: Icons.chat_bubble_outline,
            selected: currentIndex == 2,
            onTap: () => onChanged(2),
          ),
          _NavIcon(
            icon: Icons.person_outline,
            selected: currentIndex == 3,
            onTap: () => onChanged(3),
          ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF7C3AED) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: selected ? Colors.white : const Color(0xFF7A7A7A),
          size: 24,
        ),
      ),
    );
  }
}
