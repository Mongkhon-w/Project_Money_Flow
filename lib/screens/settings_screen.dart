import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ⚠️ เคลียร์ Import ที่ซ้ำซ้อนออกให้เหลือแค่แบบเดียวครับ
import '../bloc/expense/bloc/expense_event_bloc.dart';
import '../bloc/expense/bloc/expense_event_event.dart';
import '../bloc/expense/bloc/expense_event_state.dart';

import '../core/app_routes.dart'; // เพื่อเรียก Navigate

class SettingsScreen extends StatelessWidget {
  final ExpenseLoaded state;

  const SettingsScreen({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              vertical: 20.0,
              horizontal: 25.0,
            ),
            child: Column(
              children: [
                const Text(
                  "เงินสำรองฉุกเฉิน",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment<int>(value: 3, label: Text('3 เดือน')),
                    ButtonSegment<int>(value: 6, label: Text('6 เดือน')),
                    ButtonSegment<int>(value: 9, label: Text('9 เดือน')),
                  ],
                  // ดึงค่า selected จาก State
                  selected: {state.emerFundRate},
                  onSelectionChanged: (Set<int> newSelection) {
                    // ⚠️ แก้ไขชื่อคลาสให้ตรงกับ BLoC ของคุณ (ExpenseEventBloc)
                    context.read<ExpenseEventBloc>().add(
                      UpdateEmerFundRate(newSelection.first),
                    );
                  },
                ),
                const SizedBox(height: 40),
                const Text(
                  "การจัดการข้อมูล",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                ListTile(
                  title: const Text("นำเข้า/สำรอง ข้อมูล"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {
                    // ส่ง rawData เป็น String ไปหน้า ImportExport
                    Navigator.pushNamed(
                      context,
                      AppRoutes.importExport,
                      arguments: state.rawData.join(','),
                    );
                  },
                ),
                ListTile(
                  title: const Text("นโยบายความเป็นส่วนตัว"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "ข้อมูลทางการเงินของคุณถูกเก็บไว้ในเครื่องของคุณเท่านั้น",
                        ),
                        backgroundColor: Colors.indigo,
                      ),
                    );
                  },
                ),
                ListTile(
                  title: const Text(
                    "รีเซ็ทข้อมูล",
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.reset);
                  },
                ),
              ],
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 20.0),
          child: Column(
            children: [
              Text(
                "MoneyFlow",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Version 1.0.3",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
