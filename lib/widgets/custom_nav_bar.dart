import 'package:flutter/material.dart';
import '../utils/routes.dart';

class CustomNavBar extends StatelessWidget {
  const CustomNavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;

    return BottomNavigationBar(
      backgroundColor: color,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      type: BottomNavigationBarType.fixed,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.videocam),
          label: 'Monitor',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_active),
          label: 'Alerts',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.baby_changing_station),
          label: 'Sounds',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
      currentIndex: 0,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushNamed(context, AppRoutes.dashboard);
            break;
          case 1:
            Navigator.pushNamed(context, AppRoutes.monitoring);
            break;
          case 2:
            Navigator.pushNamed(context, AppRoutes.notifications);
            break;
          case 3:
            Navigator.pushNamed(context, AppRoutes.babySound);
            break;
          case 4:
            Navigator.pushNamed(context, AppRoutes.settings);
            break;
        }
      },
    );
  }
}
