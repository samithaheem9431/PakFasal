import 'package:flutter/material.dart';

import '../../features/ai_query/presentation/screens/ai_query_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/crop_calendar/presentation/screens/crop_calendar_screen.dart';
import '../../features/home/presentation/screens/home_dashboard_screen.dart';
import '../../features/learning/presentation/screens/learning_dashboard_screen.dart';
import '../../features/marketplace/presentation/screens/marketplace_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/sensor/presentation/screens/sensor_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/weather/presentation/screens/weather_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const forgotPassword = '/forgot-password';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const learning = '/learning';
  static const weather = '/weather';
  static const aiQuery = '/ai-query';
  static const sensor = '/sensor';
  static const profile = '/profile';
  static const marketplace = '/marketplace';
  static const cropCalendar = '/crop-calendar';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _materialRoute(const SplashScreen());
      case login:
        return _materialRoute(const LoginScreen());
      case signup:
        return _materialRoute(const SignupScreen());
      case forgotPassword:
        return _materialRoute(const ForgotPasswordScreen());
      case onboarding:
        return _materialRoute(const OnboardingScreen());
      case home:
        return _materialRoute(const HomeDashboardScreen());
      case learning:
        return _materialRoute(const LearningDashboardScreen());
      case weather:
        return _materialRoute(const WeatherScreen());
      case aiQuery:
        return _materialRoute(const AiQueryScreen());
      case sensor:
        return _materialRoute(const SensorScreen());
      case profile:
        return _materialRoute(const ProfileScreen());
      case marketplace:
        return _materialRoute(const MarketplaceScreen());
      case cropCalendar:
        return _materialRoute(const CropCalendarScreen());
      default:
        return _materialRoute(const SplashScreen());
    }
  }

  static MaterialPageRoute _materialRoute(Widget child) {
    return MaterialPageRoute(builder: (_) => child);
  }
}
