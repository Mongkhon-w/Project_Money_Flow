import 'package:flutter/material.dart';
import '../screens/main_navigation.dart';
import '../screens/import_export_screen.dart';
import '../screens/confirm_reset_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String importExport = '/import_export';
  static const String reset = '/reset';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => MainNavigation());
      // สร้าง Route อื่นๆ ที่นี่ เพื่อให้เรียกใช้งานง่ายขึ้น
      // case importExport:
      //   return MaterialPageRoute(builder: (_) => ImportExportScreen());
      default:
        return MaterialPageRoute(
          builder: (_) =>
              Scaffold(body: Center(child: Text('Route Not Found'))),
        );
    }
  }
}
