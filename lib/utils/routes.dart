import '../screens/login_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/monitoring_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/appointments_screen.dart';
import '../screens/data_entry_screen.dart';
import '../screens/recommendations_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/baby_sound_screen.dart';
import '../screens/schedule_feeding_screen.dart';
import '../screens/child_info_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/sleep_timer_screen.dart';
import '../screens/status_screen.dart';
import '../screens/vaccination_schedule_screen.dart';

class AppRoutes {
  static const String login = '/';
  static const String dashboard = '/dashboard';
  static const String monitoring = '/monitoring';
  static const String reports = '/reports';
  static const String appointments = '/appointments';
  static const String dataEntry = '/dataEntry';
  static const String recommendations = '/recommendations';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  static const String babySound = '/babySound';
  static const String feeding = '/feeding';
  static const String childInfo = '/childInfo';
  static const String signup = '/signup';
  static const String sleepTimer = '/sleep-timer';       
  static const String status = '/status'; 
  static const String vaccines = '/vaccines';
  static const String schedule = '/schedule';

  static final routes = {
    login: (context) => LoginScreen(),
    dashboard: (context) => DashboardScreen(),
    monitoring: (context) => MonitoringScreen(),
    reports: (context) => ReportsScreen(),
    appointments: (context) => AppointmentsScreen(),
    dataEntry: (context) => DataEntryScreen(),
    recommendations: (context) => RecommendationsScreen(),
    settings: (context) => SettingsScreen(),
    notifications: (context) => NotificationsScreen(),
    babySound: (context) => BabySoundScreen(),  
    feeding: (context) => const FeedingScheduleScreen(),
    childInfo: (context) => const ChildInfoScreen(),
    signup: (context) => const SignUpScreen(),
    sleepTimer: (context) => const SleepTimerScreen(),
    status: (context) => StatusScreen(),
    vaccines: (context) => const VaccinationScheduleScreen(),
    schedule: (context) => const FeedingScheduleScreen(),
  };
}
