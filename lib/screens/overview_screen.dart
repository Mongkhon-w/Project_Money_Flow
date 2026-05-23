import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ⚠️ ลบการ Import แบบ package:flutter01/... ออกไปแล้ว เพื่อป้องกัน Ambiguous Import
import '../bloc/expense/bloc/expense_event_state.dart';

class OverviewScreen extends StatelessWidget {
  final ExpenseLoaded state;

  const OverviewScreen({Key? key, required this.state}) : super(key: key);

  Map<String, dynamic> _getStatusData(double ratio) {
    if (state.totalExpense == 0 && state.totalIncome == 0) {
      return {
        'title': "ไม่ระบุ",
        'desc': "แต่วิเคราะห์อะไรไม่ได้เพราะยังไม่มีข้อมูล",
        'advisor':
            "ตอนนี้ยังไม่มีข้อมูลทางการเงินของคุณ กด 'แก้ไข' เพื่อเริ่มกรอกข้อมูลกันเถอะ!",
        'color': Colors.grey,
        'image':
            'asset/image/bg5.png', // ตรวจสอบ path รูปภาพให้ตรงกับโปรเจกต์คุณ
      };
    } else if (ratio >= 55) {
      return {
        'title': "มั่งคั่ง",
        'desc': "เก็บเงินเก่งแล้วอย่าลืมให้รางวัลตัวเองด้วยนะ",
        'advisor':
            "การเงินของคุณยอดเยี่ยมมาก หากคุณสามารถรักษามาตรฐานแบบนี้ไว้ เงินล้านไม่ไกลเกินฝัน",
        'color': Colors.amber,
        'image': 'asset/image/bg.png',
      };
    } else if (ratio >= 35) {
      return {
        'title': "สบายตัว",
        'desc': "การเงินกำลังดี อย่าลืมศึกษาเรื่องการลงทุนด้วยนะ",
        'advisor':
            "วางแผนดีมาก! คุณเก็บเงินได้ตามมาตรฐานแล้ว อย่าลืมศึกษาเรื่องการลงทุนเพื่อให้เงินงอกเงยขึ้นกว่าเดิมนะ",
        'color': Colors.greenAccent,
        'image': 'asset/image/bg2.png',
      };
    } else if (ratio > 10) {
      return {
        'title': "ก็พอไหว",
        'desc': "ถึงจะพอไหวแต่การเงินของคุณยังไม่มั่นคง",
        'advisor':
            "จะเรียกว่าใช้แบบเดือนชนเดือนก็ได้ การเงินของคุณยังไม่มั่นคง ลองมองหารายได้เพิ่มหรือลดรายจ่ายที่ไม่จำเป็นออกไป เพื่อให้สัดส่วนรายรับและรายจ่ายดีขึ้น",
        'color': Colors.orange,
        'image': 'asset/image/bg3.png',
      };
    } else {
      return {
        'title': "อันตราย",
        'desc': "การเงินของคุณกำลังแย่รีบแก้ไขด่วน",
        'advisor':
            "คุณแทบไม่มีเงินพอสำหรับรายจ่ายฉุกเฉินเลย คุณกำลังเผชิญหน้ากับวิกฤตทางการเงิน คุณต้องมองหารายรับเพิ่ม และ ตรวจสอบในหน้าวิเคราะห์ว่ารายจ่ายไหนสูงที่สุด",
        'color': Colors.redAccent,
        'image': 'asset/image/bg4.png',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    double saving = state.totalIncome - state.totalExpense;
    double savingRatio = state.totalIncome > 0
        ? (saving / state.totalIncome) * 100
        : 0;

    final status = _getStatusData(savingRatio);

    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.blueGrey, // ใส่สีเผื่อกรณีโหลดรูปไม่ขึ้น
            image: DecorationImage(
              image: AssetImage(status['image']),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "สถานะทางการเงินของคุณ",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                Text(
                  status['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: Text(
                    "คุณเก็บเงินได้ ${savingRatio.toStringAsFixed(1)}% ต่อเดือน ${status['desc']}",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.55,
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text("ภาพรวมการเงินของคุณ"),
                  const Text("หักภาระค่าใช้จ่ายแล้ว คุณจะมีเงินเหลือใช้"),
                  Text(
                    NumberFormat("#,###").format(saving),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text("บาท ต่อ เดือน"),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 80,
                    width: double.infinity,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "รายรับ",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                "${NumberFormat("#,###").format(state.totalIncome)}บ./เดือน",
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const VerticalDivider(
                          color: Colors.grey,
                          thickness: 2,
                          width: 20,
                          indent: 10,
                          endIndent: 10,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "รายจ่าย",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                "${NumberFormat("#,###").format(state.totalExpense)}บ./เดือน",
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Card(
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    margin: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 200,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                              color: Colors.blue,
                            ),
                            child: const Center(
                              child: Text(
                                "คำแนะนำ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(15),
                            child: Text(
                              status['advisor'],
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
