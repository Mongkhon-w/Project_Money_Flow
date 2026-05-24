import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import BLoC
import '../bloc/expense/bloc/expense_event_bloc.dart';
import '../bloc/expense/bloc/expense_event_event.dart';
import '../bloc/expense/bloc/expense_event_state.dart';

import 'overview_screen.dart';
import 'edit_screen.dart';
import 'analysis_screen.dart';
import 'settings_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseEventBloc, ExpenseState>(
      builder: (context, state) {
        if (state is ExpenseLoading || state is ExpenseInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is ExpenseLoaded) {
          final List<Widget> pages = [
            OverviewScreen(state: state),
            EditScreen(state: state),
            AnalysisScreen(state: state),
            SettingsScreen(state: state),
          ];

          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'MoneyFlow',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              centerTitle: true,
            ),
            body: IndexedStack(index: _selectedIndex, children: pages),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedIndex,
              type: BottomNavigationBarType.fixed,
              onTap: (index) {
                setState(() => _selectedIndex = index);
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'ภาพรวม',
                ),
                BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'แก้ไข'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart),
                  label: 'วิเคราะห์',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'อื่นๆ',
                ),
              ],
            ),
            // ⚠️ ลบ FloatingActionButton ออกจากตรงนี้แล้วครับ
          );
        }

        return const Scaffold(
          body: Center(child: Text("เกิดข้อผิดพลาดในการโหลดข้อมูล")),
        );
      },
    );
  }
}
