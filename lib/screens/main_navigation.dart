import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import BLoC
import '../bloc/expense/bloc/expense_event_bloc.dart';
import '../bloc/expense/bloc/expense_event_state.dart';

// Import หน้าจอทั้ง 4 ที่เราแยกไฟล์ไว้
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
  // หน้าที่เดียวที่ MainNavigation ต้องจำคือ "ตอนนี้อยู่แท็บไหน" (0, 1, 2, 3)
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // ⚠️ แก้ไขชื่อคลาสตรงนี้เป็น ExpenseEventBloc และ ExpenseEventState ให้ตรงกับไฟล์ของคุณ
    return BlocBuilder<ExpenseEventBloc, ExpenseState>(
      builder: (context, state) {
        // ⚠️ หมายเหตุ: ถ้าในไฟล์ expense_event_state.dart ของคุณตั้งชื่อคลาสเป็นอย่างอื่น
        // เช่น ExpenseEventLoading หรือ ExpenseEventInitial ให้แก้ตรงบรรทัด if นี้ด้วยนะครับ
        if (state is ExpenseLoading || state is ExpenseInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // เมื่อข้อมูลโหลดเสร็จแล้ว (ถ้าตั้งชื่อคลาสต่างไปจากนี้ ให้แก้ตรงนี้ด้วยครับ)
        if (state is ExpenseLoaded) {
          // เตรียมหน้าจอทั้ง 4 หน้า และส่งตัวแปร state เข้าไปให้แต่ละหน้าใช้งาน
          final List<Widget> pages = [
            OverviewScreen(state: state), // หน้า 0: ภาพรวม
            EditScreen(state: state), // หน้า 1: แก้ไขข้อมูล
            AnalysisScreen(state: state), // หน้า 2: วิเคราะห์กราฟ
            SettingsScreen(state: state), // หน้า 3: ตั้งค่า
          ];

          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'MoneyFlow',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              centerTitle: true,
            ),
            // แสดงหน้าจอตามแท็บที่เลือก
            body: IndexedStack(index: _selectedIndex, children: pages),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedIndex,
              type: BottomNavigationBarType.fixed,
              onTap: (index) {
                // เปลี่ยนหน้าโดยอัปเดตแค่ _selectedIndex
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
          );
        }

        // กรณีเกิด Error (ถ้ามี)
        return const Scaffold(
          body: Center(child: Text("เกิดข้อผิดพลาดในการโหลดข้อมูล")),
        );
      },
    );
  }
}
