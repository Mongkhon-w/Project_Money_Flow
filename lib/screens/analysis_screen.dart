import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

// เปลี่ยน import นี้ให้ตรงกับ path ของคุณ
import '../bloc/expense/bloc/expense_event_state.dart';

class AnalysisScreen extends StatelessWidget {
  final ExpenseLoaded state;

  const AnalysisScreen({Key? key, required this.state}) : super(key: key);

  // ฟังก์ชันแปลง rawData จาก State ให้เป็น List สำหรับ PieChart
  List<Map<String, dynamic>> _getExpenseList() {
    double val(int index) => double.tryParse(state.rawData[index]) ?? 0;

    List<Map<String, dynamic>> data = [
      if (val(0) > 0)
        {"name": "อาหาร/เครื่องดื่ม", "amount": val(0), "color": Colors.indigo},
      if (val(1) > 0)
        {
          "name": "ยารักษาโรคประจำตัว",
          "amount": val(1),
          "color": Colors.indigoAccent,
        },
      if (val(2) > 0)
        {"name": "ค่าเช่าที่พัก", "amount": val(2), "color": Colors.brown},
      if (val(3) > 0)
        {"name": "ค่าบริการโทรศัพท์", "amount": val(3), "color": Colors.blue},
      if (val(4) > 0)
        {
          "name": "ค่าบริการอินเตอร์เน็ต",
          "amount": val(4),
          "color": Colors.green,
        },
      if (val(5) > 0)
        {
          "name": "ค่าบริการสตรีมมิ่ง",
          "amount": val(5),
          "color": Colors.yellow,
        },
      if (val(6) > 0)
        {"name": "ค่าสมาชิกบริการ", "amount": val(6), "color": Colors.orange},
      if (val(7) > 0)
        {
          "name": "ค่าเลี้ยงดูบุตรเล็ก",
          "amount": val(7),
          "color": Colors.pinkAccent,
        },
      if (val(8) > 0)
        {"name": "ค่าเลี้ยงดูบุตรโต", "amount": val(8), "color": Colors.pink},
      if (val(9) > 0)
        {"name": "ค่าผ่อนบ้าน", "amount": val(9), "color": Colors.red},
      if (val(10) > 0)
        {"name": "ค่าผ่อนรถ", "amount": val(10), "color": Colors.red[500]},
      if (val(11) > 0)
        {"name": "หนี้สิน", "amount": val(11), "color": Colors.redAccent},
    ];

    data.sort((a, b) => b['amount'].compareTo(a['amount']));
    return data;
  }

  @override
  Widget build(BuildContext context) {
    // การคำนวณสูตรต่างๆ
    double saving = state.totalIncome - state.totalExpense;
    double savingRatio = state.totalIncome > 0
        ? (saving / state.totalIncome) * 100
        : 0;
    double emerfund = state.totalExpense * state.emerFundRate;
    double burnrate = state.totalIncome > 0
        ? (state.totalExpense / state.totalIncome) * 100
        : 0;
    int sg1mMonth = saving > 0 ? (1000000 / saving).ceil() : 0;
    double sg1mYear = sg1mMonth / 12;

    List<Map<String, dynamic>> expenseData = _getExpenseList();

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const Text(
            "สัดส่วน รายรับ-รายจ่าย ของคุณ",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // กราฟวงกลมวงแรก (รายรับ-รายจ่าย)
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: state.totalIncome == 0 && state.totalExpense == 0
                        ? 1
                        : state.totalIncome,
                    color: Colors.green,
                    title: '',
                    radius: 100,
                  ),
                  PieChartSectionData(
                    value: state.totalExpense,
                    color: Colors.red,
                    title: '',
                    radius: 100,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 25),

          // ป้ายบอกสี (รายรับ-รายจ่าย)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
              ),
              Text(
                "   รายจ่าย : ${NumberFormat("#,###").format(state.totalExpense)} บาท ต่อ เดือน",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                ),
              ),
              Text(
                "   รายรับ : ${NumberFormat("#,###").format(state.totalIncome)} บาท ต่อ เดือน",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const Divider(height: 20, indent: 50, endIndent: 50),

          // กราฟวงกลมวงที่สอง (สัดส่วนรายจ่ายทั้งหมด)
          const Text(
            "สัดส่วน รายจ่ายทั้งหมด",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: expenseData.map((data) {
                      return PieChartSectionData(
                        value: data['amount'].toDouble(),
                        color: data['color'],
                        title: '',
                        radius: 50,
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 25,
                runSpacing: 15,
                children: expenseData.map((data) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: data['color'],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "${data['name']}",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
          const Divider(height: 20, indent: 50, endIndent: 50),

          // Card รายการจ่ายสูงสุด
          Card(
            color: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Container(
              width: double.infinity,
              height: 120,
              padding: const EdgeInsets.all(10),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.red,
                      ),
                      child: const Text(
                        "รายการจ่ายสูงสุด",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      state.topExpenseName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    Text(
                      "${NumberFormat("#,###.00").format(state.topExpense)} บาท/เดือน",
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Card รายรับสูงสุด
          Card(
            color: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Container(
              width: double.infinity,
              height: 120,
              padding: const EdgeInsets.all(10),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.green,
                      ),
                      child: const Text(
                        "รายรับสูงสุด",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      state.topIncomeName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    Text(
                      "${NumberFormat("#,###.00").format(state.topIncome)} บาท/เดือน",
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Row สำหรับ เงินเหลือ / เงินฉุกเฉิน
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Card(
                  color: (state.totalExpense > state.totalIncome
                      ? Colors.red[400]
                      : Colors.white),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 15,
                  ),
                  child: Container(
                    height: 200,
                    padding: const EdgeInsets.all(10),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: (state.totalExpense > state.totalIncome
                                  ? Colors.red[800]
                                  : Colors.blue),
                            ),
                            child: const Text(
                              "เงินเหลือ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            NumberFormat("#,###").format(saving),
                            style: TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                              color: (state.totalExpense > state.totalIncome
                                  ? Colors.white
                                  : Colors.black),
                            ),
                          ),
                          Text(
                            "บาท/เดือน",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: (state.totalExpense > state.totalIncome
                                  ? Colors.white
                                  : Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 15,
                  ),
                  child: Container(
                    height: 200,
                    padding: const EdgeInsets.all(10),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.brown,
                            ),
                            child: const Text(
                              "เงินฉุกเฉิน",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            NumberFormat("#,###").format(emerfund),
                            style: TextStyle(
                              fontSize: (emerfund > 1000000 ? 26 : 32),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "บาท ที่ควรมีสำรองไว้สำหรับ ${state.emerFundRate} เดือน",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Row สำหรับ อัตราการใช้จ่าย / อัตราการประหยัด
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Card(
                  color: (burnrate >= 90 ? Colors.red[400] : Colors.white),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 15,
                  ),
                  child: Container(
                    height: 200,
                    padding: const EdgeInsets.all(10),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: (burnrate >= 90
                                  ? Colors.red[800]
                                  : Colors.red),
                            ),
                            child: const Text(
                              "อัตราการใช้จ่าย",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "${burnrate.toStringAsFixed(1)}%",
                            style: TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                              color: (burnrate >= 90
                                  ? Colors.white
                                  : Colors.black),
                            ),
                          ),
                          Text(
                            "จากรายได้ทั้งเดือน",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: (burnrate >= 90
                                  ? Colors.white
                                  : Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Card(
                  color: (savingRatio >= 50
                      ? Colors.yellow[600]
                      : Colors.white),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 15,
                  ),
                  child: Container(
                    height: 200,
                    padding: const EdgeInsets.all(10),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: (savingRatio >= 50
                                  ? Colors.yellow[700]
                                  : Colors.green),
                            ),
                            child: const Text(
                              "อัตราการประหยัด",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "${savingRatio.toStringAsFixed(1)}%",
                            style: TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                              color: (savingRatio >= 50
                                  ? Colors.white
                                  : Colors.black),
                            ),
                          ),
                          Text(
                            "จากรายได้ทั้งเดือน",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: (savingRatio >= 50
                                  ? Colors.white
                                  : Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20, indent: 50, endIndent: 50),

          // Card ระยะเวลา
          Card(
            color: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Container(
              width: double.infinity,
              height: 300,
              padding: const EdgeInsets.all(10),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey,
                      ),
                      child: const Text(
                        "ระยะเวลา",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "${NumberFormat("#,###").format(saving * 3)}บาท",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    const Text(
                      "เงินเก็บทั้งหมดต่อ 1 ไตรมาสของคุณ",
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 25),
                    Text(
                      "${NumberFormat("#,###").format(saving * 12)}บาท",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    const Text(
                      "เงินเก็บทั้งหมดต่อปีของคุณ",
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 25),
                    Text(
                      "${sg1mYear.toStringAsFixed(1)}ปี หรือ $sg1mMonth เดือน",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    const Text(
                      "สำหรับ 1 ล้านบาทแรกของคุณ",
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
