import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({required this.title, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isFemale = themeProvider.isFemaleTheme;
    final color = Theme.of(context).colorScheme.primary;

    return AppBar(
      title: Text(title),
      backgroundColor: color,
      elevation: 0,
      actions: [
        IconButton(
          onPressed: () {
            themeProvider.toggleTheme();
          },
          tooltip: isFemale ? 'Switch to Boy Theme' : 'Switch to Girl Theme',
          icon: const Icon(Icons.color_lens),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
