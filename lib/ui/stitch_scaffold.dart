import 'package:flutter/material.dart';

import 'stitch_theme.dart';

enum StitchNavItem { reveal, clue, discuss, vote }

class StitchScaffold extends StatelessWidget {
  const StitchScaffold({
    super.key,
    required this.title,
    required this.body,
    this.bottomItem,
    this.actions = const [],
  });

  final String title;
  final Widget body;
  final StitchNavItem? bottomItem;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(4),
          child: SizedBox(
            height: 4,
            child: ColoredBox(color: StitchColors.secondaryContainer),
          ),
        ),
      ),
      body: body,
      bottomNavigationBar: bottomItem == null
          ? null
          : BottomNavigationBar(
              currentIndex: bottomItem!.index,
              selectedItemColor: StitchColors.tertiary,
              unselectedItemColor: StitchColors.onSurfaceVariant,
              backgroundColor: StitchColors.surfaceContainer,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.visibility),
                  label: 'Reveal',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.edit_note),
                  label: 'Clue',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.forum),
                  label: 'Discuss',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.how_to_vote),
                  label: 'Vote',
                ),
              ],
              onTap: (_) {},
            ),
    );
  }
}

class ChunkyButton extends StatelessWidget {
  const ChunkyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.background = StitchColors.primary,
    this.foreground = StitchColors.onPrimary,
    this.shadow = const Color(0xFF66002C),
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color background;
  final Color foreground;
  final Color shadow;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        disabledBackgroundColor: background.withValues(alpha: 0.3),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Colors.black, width: 3),
        ),
        elevation: 0,
      ).copyWith(shadowColor: WidgetStatePropertyAll(shadow)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          if (icon != null) ...[const SizedBox(width: 8), Icon(icon)],
        ],
      ),
    );
  }
}
