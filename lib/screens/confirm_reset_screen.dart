import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// แก้ไขเครื่องหมาย // ออกให้เหลือสแลชตัวเดียวแล้วครับ
import '../bloc/expense/bloc/expense_event_bloc.dart';
import '../bloc/expense/bloc/expense_event_event.dart';

class ConfirmResetScreen extends StatefulWidget {
  const ConfirmResetScreen({Key? key}) : super(key: key);

  @override
  State<ConfirmResetScreen> createState() => _ConfirmResetScreenState();
}

class _ConfirmResetScreenState extends State<ConfirmResetScreen> {
  // 1. ประกาศตัวแปร isInputMatch ไว้ที่นี่
  bool isInputMatch = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ยืนยันการรีเซ็ต")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const Text(
                "นี่คือการรีเซ็ทข้อมูลทั้งหมดในแอปสู่ค่าเริ่มต้น การกระทำนี้ไม่สามารถยกเลิกหรือย้อนกลับได้ หลังจากล้างข้อมูลแล้ว",
              ),
              const Text(
                "หากต้องการรีเซ็ทข้อมูลทั้งหมด โปรดพิมพ์ 'ตกลง' เพื่อล้างข้อมูล",
              ),
              const SizedBox(height: 30),

              // TextField สำหรับพิมพ์คำว่า "ตกลง"
              TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey[300]!,
                      width: 1.5,
                    ),
                  ),
                ),
                onChanged: (value) {
                  // 2. อัปเดตสถานะตัวแปรเมื่อมีการพิมพ์
                  setState(() {
                    isInputMatch = (value == "ตกลง");
                  });
                },
              ),
              const SizedBox(height: 30),

              // 3. โค้ดปุ่มของคุณที่จับเข้ามาอยู่ใน Build method อย่างถูกต้อง
              ElevatedButton(
                onPressed: isInputMatch
                    ? () {
                        // ส่ง Event ไปเคลียร์ข้อมูลผ่าน BLoC
                        // หมายเหตุ: ถ้าคลาส Bloc ของคุณชื่อ ExpenseEventBloc ให้แก้ตรงนี้ด้วยนะครับ
                        context.read<ExpenseEventBloc>().add(ResetDataEvent());

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("รีเซ็ทข้อมูลเสร็จสิ้น"),
                            backgroundColor: Colors.green,
                          ),
                        );
                        // เด้งกลับไปหน้าก่อนหน้า (Settings)
                        Navigator.pop(context);
                      }
                    : null, // ถ้าพิมพ์ไม่ตรงปุ่มจะกดไม่ได้ (เป็นสีเทา)
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text("ล้างข้อมูลทั้งหมด"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
