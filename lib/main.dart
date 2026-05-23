import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ⚠️ เหลือ Import ไว้แค่แบบเดียว เพื่อป้องกัน Error: Ambiguous Import
import 'bloc/expense/bloc/expense_event_bloc.dart';
import 'bloc/expense/bloc/expense_event_event.dart';
import 'core/app_routes.dart';

void main() {
  runApp(
    // ครอบแอปด้วย BlocProvider เพื่อให้ทุกหน้าสามารถเข้าถึง BLoC ได้
    BlocProvider(
      // ⚠️ แก้ชื่อคลาสให้ตรงกับไฟล์ของคุณ (ExpenseEventBloc)
      create: (context) => ExpenseEventBloc()..add(LoadExpenseData()),
      child: ExpenseApp(),
    ),
  );
}

class ExpenseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: Colors.blue[100],
        ),
      ),
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
