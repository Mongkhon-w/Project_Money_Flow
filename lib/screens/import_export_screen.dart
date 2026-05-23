import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/expense/bloc/expense_event_bloc.dart';
import '../bloc/expense/bloc/expense_event_event.dart';

class ImportExportScreen extends StatefulWidget {
  final String dataString;

  const ImportExportScreen({Key? key, required this.dataString})
    : super(key: key);

  @override
  State<ImportExportScreen> createState() => _ImportExportScreenState();
}

class _ImportExportScreenState extends State<ImportExportScreen> {
  // --- ฟังก์ชันส่งออกข้อมูล ---
  Future<void> exportData() async {
    List<String> values = widget.dataString.split(',');
    try {
      Map<String, dynamic> backupMap = {
        "1a": values.isNotEmpty ? values[0] : "",
        "1b": values.length > 1 ? values[1] : "",
        "2a": values.length > 2 ? values[2] : "",
        "2b": values.length > 3 ? values[3] : "",
        "2c": values.length > 4 ? values[4] : "",
        "2d": values.length > 5 ? values[5] : "",
        "3a": values.length > 6 ? values[6] : "",
        "3b": values.length > 7 ? values[7] : "",
        "4a": values.length > 8 ? values[8] : "",
        "4b": values.length > 9 ? values[9] : "",
        "4d": values.length > 10 ? values[10] : "",
        "4e": values.length > 11 ? values[11] : "",
        "5a": values.length > 12 ? values[12] : "",
        "5b": values.length > 13 ? values[13] : "",
        "5c": values.length > 14 ? values[14] : "",
        "timestamp": DateTime.now().toIso8601String(),
      };

      String jsonString = jsonEncode(backupMap);
      Uint8List fileBytes = utf8.encode(jsonString);

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'กรุณาเลือกที่เก็บไฟล์สำรอง',
        fileName: 'backup_${DateTime.now().millisecondsSinceEpoch}.json',
        bytes: fileBytes,
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (outputFile != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('สำรองข้อมูลเรียบร้อยแล้ว!')),
        );
      }
    } catch (e) {
      print("Export Error: $e");
    }
  }

  // --- ฟังก์ชันนำเข้าข้อมูล ---
  Future<void> importData() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        String content = utf8.decode(result.files.single.bytes!).trim();
        Map<String, dynamic> importedData = jsonDecode(content);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        List<String> keys = [
          "1a",
          "1b",
          "2a",
          "2b",
          "2c",
          "2d",
          "3a",
          "3b",
          "4a",
          "4b",
          "4d",
          "4e",
          "5a",
          "5b",
          "5c",
        ];
        String valuesString = keys
            .map((k) => importedData[k]?.toString() ?? "")
            .join(',');

        // 1. บันทึกข้อมูลลง SharedPreferences ทับของเดิม
        await prefs.setString('expense_list', valuesString);

        if (!mounted) return;

        // 2. เปลี่ยนชื่อคลาสตรงนี้ให้เป็น ExpenseEventBloc ตามไฟล์ของคุณแล้วครับ
        context.read<ExpenseEventBloc>().add(LoadExpenseData());

        // 3. ปิดหน้าจอ และส่งค่า true กลับไปให้รู้ว่า import สำเร็จ
        Navigator.pop(context, true);
      }
    } catch (e) {
      print("Import Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("ไฟล์เสียหายหรือรูปแบบผิด: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("นำเข้า/ส่งออกข้อมูล")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                "คุณสามารถส่งออกข้อมูลเป็นไฟล์ .json แล้วบันทึกลงบนเครื่องของคุณเพื่อสำรองข้อมูลทั้งหมดบนแอปพลิเคชั่นนี้ และคุณสามารถนำเข้าข้อมูลของคุณจากไฟล์ .json ที่คุณได้บันทึกไว้",
              ),
              const Text(
                "โปรดจำไว้ว่าข้อมูลที่คุณส่งออกนั้น อยู่นอกเหนือความรับผิดชอบของแอปพลิเคชั่น ในกรณีที่ไฟล์ .json ของคุณสูญหาย",
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: importData,
                child: const Text(
                  "นำเข้าข้อมูล",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: exportData,
                child: const Text(
                  "ส่งออกข้อมูล",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
