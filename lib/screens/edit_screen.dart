import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

// --- แก้ไขการ Import ซ้ำซ้อนให้เหลือแค่แบบเดียว ---
import '../bloc/expense/bloc/expense_event_bloc.dart';
import '../bloc/expense/bloc/expense_event_event.dart';
import '../bloc/expense/bloc/expense_event_state.dart';

class EditScreen extends StatefulWidget {
  final ExpenseLoaded state;

  const EditScreen({Key? key, required this.state}) : super(key: key);

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late List<TextEditingController> controllers;
  late List<Map<String, dynamic>> quizData;

  @override
  void initState() {
    super.initState();
    // สร้าง Controllers ตามจำนวนข้อมูล 15 ช่อง (Index 0 - 14)
    controllers = List.generate(
      15,
      (index) => TextEditingController(text: widget.state.rawData[index]),
    );

    // แก้ไขบั๊ก Index เรียง 0-14 ให้ตรงกับฐานข้อมูล
    quizData = [
      {
        'title': 'ค่าอุปโภคบริโภค',
        'desc': 'ค่าใช้จ่ายสำหรับการดำรงชีพในแต่ละเดือนของคุณโดยประมาณ',
        'fields': [
          {'label': 'ค่าอาหาร/เครื่องดื่ม', 'controller': controllers[0]},
          {'label': 'ค่ายารักษาโรคประจำตัว', 'controller': controllers[1]},
        ],
      },
      {
        'title': 'ค่าใช้จ่ายคงที่',
        'desc': 'ค่าใช้จ่ายคงที่ที่เกิดขึ้นทุกๆเดือนโดยไม่เปลี่ยนแปลง',
        'fields': [
          {'label': 'ค่าเช่าที่พัก', 'controller': controllers[2]},
          {'label': 'ค่าโทรศัพท์รายเดือน', 'controller': controllers[3]},
          {
            'label': 'ค่าบริการอินเตอร์เน็ตรายเดือน',
            'controller': controllers[4],
          },
          {'label': 'ค่าบริการสตรีมมิ่งรายเดือน', 'controller': controllers[5]},
        ],
      },
      {
        'title': 'ค่าเลี้ยงดูบุตร (หากมี)',
        'desc': 'ค่าใช้จ่ายที่คุณใช้สำหรับเลี้ยงดูบุตร',
        'fields': [
          {'label': 'เงินเลี้ยงดูบุตรเล็ก', 'controller': controllers[6]},
          {'label': 'เงินเลี้ยงดูบุตรโต', 'controller': controllers[7]},
        ],
      },
      {
        'title': 'ค่าผ่อนชำระ และ หนี้สิน',
        'desc': 'ค่าใช้จ่ายที่คุณต้องผ่อนชำระในแต่ละเดือน',
        'fields': [
          {'label': 'ค่าผ่อนบ้าน', 'controller': controllers[8]},
          {'label': 'ค่าผ่อนรถ', 'controller': controllers[9]},
          {'label': 'ค่าบัตรเครดิต', 'controller': controllers[10]},
          {'label': 'หนี้สิน', 'controller': controllers[11]},
        ],
      },
      {
        'title': 'ยืนยันข้อมูล',
        'desc': 'ตรวจสอบความถูกต้องก่อนบันทึกรายจ่าย',
        'fields': [],
      },
      {
        'title': 'รายได้ต่อเดือน',
        'desc': 'รายได้ที่คุณได้รับต่อเดือน',
        'fields': [
          {'label': 'รายได้จากอาชีพหลัก', 'controller': controllers[12]},
          {'label': 'รายได้จากอาชีพเสริม', 'controller': controllers[13]},
          {'label': 'รายได้จากการลงทุน', 'controller': controllers[14]},
        ],
      },
      {
        'title': 'ยืนยันข้อมูล',
        'desc': 'ตรวจสอบความถูกต้องก่อนบันทึกรายรับ',
        'fields': [],
      },
    ];
  }

  void _saveToBloc() {
    List<String> newData = controllers.map((c) => c.text).toList();
    context.read<ExpenseEventBloc>().add(
      UpdateExpenseData(newData),
    ); // เช็กชื่อ Bloc ให้ตรงกับของคุณด้วยนะครับ
  }

  void _showQuizSheet({required int startIndex, required int endIndex}) {
    int currentStep = startIndex;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 25,
            right: 25,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(
                value:
                    (currentStep - startIndex + 1) /
                    (endIndex - startIndex + 1),
              ),
              const SizedBox(height: 30),
              Text(
                quizData[currentStep]['title'],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                quizData[currentStep]['desc'],
                style: const TextStyle(fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              if (quizData[currentStep]['fields'] != null &&
                  (quizData[currentStep]['fields'] as List).isNotEmpty)
                ...(quizData[currentStep]['fields'] as List).map((field) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TextField(
                      controller: field['controller'],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: field['label'],
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  );
                })
              else
                Center(
                  child: Column(
                    children: const [
                      Icon(
                        Icons.check_circle_outline,
                        size: 80,
                        color: Colors.green,
                      ),
                      SizedBox(height: 10),
                      Text("พร้อมบันทึกแล้วใช่ไหม?"),
                    ],
                  ),
                ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (currentStep != startIndex)
                    TextButton(
                      onPressed: () => setSheetState(() => currentStep--),
                      child: const Text(
                        "กลับ",
                        style: TextStyle(
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 20),

                  Row(
                    children: [
                      if (currentStep < endIndex - 1)
                        TextButton(
                          onPressed: () => setSheetState(() => currentStep++),
                          child: const Text(
                            "ข้าม",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ElevatedButton(
                        onPressed: () {
                          if (currentStep < endIndex) {
                            setSheetState(() => currentStep++);
                          } else {
                            _saveToBloc();
                            Navigator.pop(context);
                          }
                        },
                        child: Text(
                          currentStep == endIndex ? "บันทึก" : "ถัดไป",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget ตัวช่วยสำหรับสร้างบรรทัดแสดงข้อมูล (เพื่อลดโค้ดซ้ำซ้อน) ---
  Widget _buildDataRow(String title, String value) {
    String displayValue = value.isEmpty ? '0.00' : value;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[700])),
          Text(
            "฿ $displayValue",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      child: Stack(
        children: [
          // ปุ่มแก้ไขอยู่ด้านบน
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Column(
                children: [
                  SizedBox(
                    width: 350,
                    height: 70,
                    child: ElevatedButton.icon(
                      icon: const Icon(
                        Icons.edit_note,
                        color: Colors.red,
                        size: 24,
                      ),
                      onPressed: () =>
                          _showQuizSheet(startIndex: 0, endIndex: 4),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      label: const Text(
                        "เเก้ไขข้อมูลรายจ่าย",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: 350,
                    height: 70,
                    child: ElevatedButton.icon(
                      icon: const Icon(
                        Icons.edit_note,
                        color: Colors.green,
                        size: 24,
                      ),
                      onPressed: () =>
                          _showQuizSheet(startIndex: 5, endIndex: 6),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      label: const Text(
                        "เเก้ไขข้อมูลรายรับ",
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- DraggableScrollableSheet โฉมใหม่ ดึงข้อมูลจาก BLoC State ---
          DraggableScrollableSheet(
            initialChildSize: 0.65,
            minChildSize: 0.6,
            maxChildSize: 0.97,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: ListView(
                  controller: scrollController,
                  children: [
                    Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Column(
                        children: [
                          const Text("รายจ่ายทั้งหมด ต่อเดือน"),
                          Text(
                            '฿${NumberFormat("#,##0.00").format(widget.state.totalExpense)}',
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const Divider(height: 20, indent: 50, endIndent: 50),
                        ],
                      ),
                    ),

                    // เรียกใช้ฟังก์ชันตัวช่วยเพื่อสร้างบรรทัดรายจ่าย (Index 0-11)
                    _buildDataRow(
                      "ค่าอาหาร/เครื่องดื่ม",
                      widget.state.rawData[0],
                    ),
                    _buildDataRow(
                      "ค่ายารักษาโรคประจำตัว",
                      widget.state.rawData[1],
                    ),
                    const SizedBox(height: 20),
                    _buildDataRow(
                      "ค่าเช่าที่พักรายเดือน",
                      widget.state.rawData[2],
                    ),
                    _buildDataRow(
                      "ค่าโทรศัพท์รายเดือน",
                      widget.state.rawData[3],
                    ),
                    _buildDataRow(
                      "ค่าบริการอินเตอร์เน็ตรายเดือน",
                      widget.state.rawData[4],
                    ),
                    _buildDataRow(
                      "ค่าบริการสตรีมมิ่งรายเดือน",
                      widget.state.rawData[5],
                    ),
                    const SizedBox(height: 20),
                    _buildDataRow(
                      "เงินเลี้ยงดูบุตรเล็ก",
                      widget.state.rawData[6],
                    ),
                    _buildDataRow(
                      "เงินเลี้ยงดูบุตรโต",
                      widget.state.rawData[7],
                    ),
                    const SizedBox(height: 20),
                    _buildDataRow("ค่าผ่อนบ้าน", widget.state.rawData[8]),
                    _buildDataRow("ค่าผ่อนรถ", widget.state.rawData[9]),
                    _buildDataRow("ค่าบัตรเครดิต", widget.state.rawData[10]),
                    _buildDataRow("หนี้สิน", widget.state.rawData[11]),

                    const SizedBox(height: 20),
                    Center(
                      child: Column(
                        children: [
                          const Text("รายรับทั้งหมด ต่อเดือน"),
                          Text(
                            '฿${NumberFormat("#,##0.00").format(widget.state.totalIncome)}',
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const Divider(height: 20, indent: 50, endIndent: 50),
                        ],
                      ),
                    ),

                    // สร้างบรรทัดรายรับ (Index 12-14)
                    _buildDataRow(
                      "รายได้จากอาชีพหลัก",
                      widget.state.rawData[12],
                    ),
                    _buildDataRow(
                      "รายได้จากอาชีพเสริม",
                      widget.state.rawData[13],
                    ),
                    _buildDataRow(
                      "รายได้จากการลงทุน",
                      widget.state.rawData[14],
                    ),

                    const SizedBox(height: 100), // เว้นที่ว่างด้านล่าง
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
