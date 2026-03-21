import 'dart:convert';
import 'dart:io'; //important
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart'; //secondary
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(ExpenseApp());

class ExpenseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true, // DEBUG debug debuggggggg
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: Colors.blue[100],
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      home: MainNavigation(),
    );
  }
}




class AnalysisWidget extends StatefulWidget {
  final List<Map<String, dynamic>> expenseData; // map list for piechart

  const AnalysisWidget({super.key, required this.expenseData});

  @override
  _AnalysisWidgetState createState() => _AnalysisWidgetState();
}

class _AnalysisWidgetState extends State<AnalysisWidget> {
  double totalIncome = 0;
  double totalExpense = 0;
  double topExpense = 0.0;
  double topIncome = 0.0;
  double emerfund = 0.0;
  int emerfund_rate = 3;
  String topExpense_n = "n/a";
  String topIncome_n = "n/a";
  int sg_1m_month = 0;
  double sg_1m_year = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      totalIncome = prefs.getDouble('totalIncome') ?? 0.0;
      totalExpense = prefs.getDouble('totalExpense') ?? 0.0;
      topIncome = prefs.getDouble('topIncome') ?? 0.0;
      topExpense = prefs.getDouble('topExpense') ?? 0.0;
      topIncome_n = prefs.getString('topIncome_n') ?? "n/a";
      topExpense_n = prefs.getString('topExpense_n') ?? "n/a";
      emerfund_rate = prefs.getInt('emerfund_rate') ?? 3;
    });
  }


  @override
  Widget build(BuildContext context) {
    double saving = totalIncome - totalExpense;
    double savingRatio = totalIncome > 0 ? (saving / totalIncome) * 100 : 0;
    double emerfund = totalExpense * emerfund_rate;
    double burnrate = totalIncome > 0 ? (totalExpense/totalIncome)*100:0;
    int sg_1m_month = saving > 0 ?(1000000 / saving).ceil():0;
    double sg_1m_year = sg_1m_month / 12;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("สัดส่วน รายรับ-รายจ่าย ของคุณ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),

            Container(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: totalIncome == 0 && totalExpense == 0 ? 1 : totalIncome,
                      color: Colors.green,
                      title: '',
                      radius: 100,
                      titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    PieChartSectionData(
                      value: totalExpense,
                      color: Colors.red,
                      title: '',
                      radius: 100,
                      titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 25),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                ),
                Text("   รายจ่าย : ${NumberFormat("#,###").format(totalExpense)} บาท ต่อ เดือน",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),)
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                ),
                Text("   รายรับ : ${NumberFormat("#,###").format(totalIncome)}บาท ต่อ เดือน",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),)
              ],
            ),
            Divider(height: 20, indent: 50, endIndent: 50),
            Text("สัดส่วน รายจ่ายทั้งหมด", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Column(
              children: [
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: widget.expenseData.map((data) {
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
                  children: widget.expenseData.map((data) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(color: data['color'], shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "${data['name']}",
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
            Divider(height: 20, indent: 50, endIndent: 50),
            Card( // top income
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              margin: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
              child: Container(
                width: double.infinity,
                height: 120,
                padding: EdgeInsets.all(10),
                child:Center(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.red
                        ),
                        child: Text("รายการจ่ายสูงสุด",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.white),)
                      ),
                      SizedBox(height: 10),
                      Text(topExpense_n,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22),),
                      Text("${NumberFormat("#,###.00").format(totalExpense)} บาท/เดือน",style: TextStyle(fontSize: 18),)
                      ],
                    ),
                  ),
                )
              ),
            Card( // top expense
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                margin: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                child: Container(
                  width: double.infinity,
                  height: 120,
                  padding: EdgeInsets.all(10),
                  child:Center(
                    child: Column(
                      children: [
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.green
                            ),
                            child: Text("รายรับสูงสุด",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.white),)
                        ),
                        SizedBox(height: 10),
                        Text(topIncome_n,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22),),
                        Text("${NumberFormat("#,###.00").format(totalIncome)} บาท/เดือน",style: TextStyle(fontSize: 18),)
                      ],
                    ),
                  ),
                )
            ),
          Row(
            children: [
              Expanded(
                  flex: 1,
                  child:Card( // saving
                      color: (totalExpense > totalIncome ? Colors.red[400]:Colors.white),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      margin: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                      child: Container(
                        height: 200,
                        padding: EdgeInsets.all(10),
                        child:Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: (totalExpense > totalIncome ? Colors.red[800]:Colors.blue),
                                  ),
                                  child: Text("เงินเหลือ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.white),textAlign: TextAlign.center,)
                              ),
                              SizedBox(height: 10),
                              Text("${NumberFormat("#,###").format(saving)}",style: TextStyle(fontSize: 35,fontWeight: FontWeight.bold,color: (totalExpense > totalIncome ? Colors.white:Colors.black),),),
                              Text("บาท/เดือน",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: (totalExpense > totalIncome ? Colors.white:Colors.black),),)
                            ],
                          ),
                        ),
                      )
                  ),
              ),
              Expanded(
                flex: 1,
                child:Card( // emergency fund
                    color: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    margin: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                    child: Container(
                      height: 200,
                      padding: EdgeInsets.all(10),
                      child:Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.brown
                                ),
                                child: Text("เงินฉุกเฉิน",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.white),textAlign: TextAlign.center,)
                            ),
                            SizedBox(height: 10),
                            Text("${NumberFormat("#,###").format(emerfund)}",style: TextStyle(fontSize: (emerfund > 1000000? 26:32),fontWeight: FontWeight.bold),),
                            Text("บาท ที่ควรมีสำรองไว้สำหรับ ${emerfund_rate} เดือน",textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),)
                          ],
                        ),
                      ),
                    )
                ),
              ),
            ],
          ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child:Card( // saving
                      color: (burnrate >= 90 ? Colors.red[400]:Colors.white),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      margin: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                      child: Container(
                        height: 200,
                        padding: EdgeInsets.all(10),
                        child:Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: (burnrate >= 90 ? Colors.red[800]:Colors.red),
                                  ),
                                  child: Text("อัตราการใช้จ่าย",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.white),textAlign: TextAlign.center,)
                              ),
                              SizedBox(height: 10),
                              Text("${burnrate.toStringAsFixed(1)}%",style: TextStyle(fontSize: 35,fontWeight: FontWeight.bold,color: (burnrate >= 90 ? Colors.white:Colors.black),),),
                              Text("จากรายได้ทั้งเดือน",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: (burnrate >= 90 ? Colors.white:Colors.black),),)
                            ],
                          ),
                        ),
                      )
                  ),
                ),
                Expanded(
                  flex: 1,
                  child:Card( // emergency fund
                      color: (savingRatio >= 50 ? Colors.yellow[600]:Colors.white),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      margin: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                      child: Container(
                        height: 200,
                        padding: EdgeInsets.all(10),
                        child:Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: (savingRatio >= 50 ? Colors.yellow[700]:Colors.green)
                                  ),
                                  child: Text("อัตราการประหยัด",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.white),textAlign: TextAlign.center,)
                              ),
                              SizedBox(height: 10),
                              Text("${savingRatio.toStringAsFixed(1)}%",style: TextStyle(fontSize: 35,fontWeight: FontWeight.bold,color: (savingRatio >= 50 ? Colors.white:Colors.black)),),
                              Text("จากรายได้ทั้งเดือน",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: (savingRatio >= 50 ? Colors.white:Colors.black)),)
                            ],
                          ),
                        ),
                      )
                  ),
                ),
              ],
            ),
            Divider(height: 20, indent: 50, endIndent: 50),
            Card( // time
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                margin: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                child: Container(
                  width: double.infinity,
                  height: 300,
                  padding: EdgeInsets.all(10),
                  child:Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.grey
                            ),
                            child: Text("ระยะเวลา",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.white),)
                        ),
                        SizedBox(height: 10),
                        Text("${NumberFormat("#,###").format(saving*3)}บาท",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22),),
                        Text("เงินเก็บทั้งหมดต่อ1ไตรมาสของคุณ",style: TextStyle(fontSize: 18),),
                        SizedBox(height: 25),
                        Text("${NumberFormat("#,###").format(saving*12)}บาท",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22),),
                        Text("เงินเก็บทั้งหมดต่อปีของคุณ",style: TextStyle(fontSize: 18),),
                        SizedBox(height: 25),
                        Text("${sg_1m_year.toStringAsFixed(1)}ปี หรือ ${sg_1m_month}เดือน",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22),),
                        Text("สำหรับ 1 ล้านบาทแรกของคุณ",style: TextStyle(fontSize: 18),)
                      ],
                    ),
                  ),
                )
            ),
          ],
        ),
      ),
    );
  }
}
class ResetDataCard extends StatefulWidget {
  final VoidCallback onClear; // ฟังก์ชันที่จะทำงานเมื่อลบสำเร็จ

  const ResetDataCard({super.key, required this.onClear});

  @override
  State<ResetDataCard> createState() => _ResetDataCardState();
}

class _ResetDataCardState extends State<ResetDataCard> {
  String confirmText = "";
  bool isInputMatch = false;

  void _checkInput(String value) {
    setState(() {
      confirmText = value;
      isInputMatch = (value == "ตกลง");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red[50],
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 40),
            const Text("ล้างข้อมูลทั้งหมด", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            TextField(
              onChanged: _checkInput,
              decoration: const InputDecoration(
                hintText: "พิมพ์ 'ตกลง' เพื่อลบ",
                border: OutlineInputBorder(),
                fillColor: Colors.white,
                filled: true,
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: isInputMatch ? widget.onClear : null, // ถ้าพิมพ์ถูก ให้เรียกฟังก์ชันลบ
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: const Text("ยืนยันการลบ"),
            ),
          ],
        ),
      ),
    );
  }
}

class importexport extends StatefulWidget {
  final String dataString; // สร้างตัวแปรรับค่า
  importexport({required this.dataString}); // รับค่าผ่าน Constructor

  @override
  State<importexport> createState() => _importexport();
}

class _importexport extends State<importexport> {
  //--- f_Export
  Future<void> exportData() async {
    List<String> values = widget.dataString.split(',');
    try {
      Map<String, dynamic> backupMap = {
        "1a": values.length > 0 ? values[0] : "",
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

      // สำหรับ Mobile (Android/iOS) saveFile with bytes
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'กรุณาเลือกที่เก็บไฟล์สำรอง',
        fileName: 'backup_${DateTime.now().millisecondsSinceEpoch}.json',
        bytes: fileBytes,
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (outputFile != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('สำรองข้อมูลเรียบร้อยแล้ว!')),
        );
      }
    } catch (e) {
      print("Export Error: $e");
    }
  }

  //------ f_Import
  Future<void> importData() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        // 1. Error 172 fixed
        String content = utf8.decode(result.files.single.bytes!).trim();
        Map<String, dynamic> importedData = jsonDecode(content);

        // 2. create list for store data
        SharedPreferences prefs = await SharedPreferences.getInstance();
        List<String> keys = ["1a","1b","2a","2b","2c","2d","3a","3b","4a","4b","4d","4e","5a","5b","5c"];
        String valuesString = keys.map((k) => importedData[k]?.toString() ?? "").join(',');

        await prefs.setString('expense_list', valuesString);

        if (!mounted) return;

        // return
        Navigator.pop(context, true);
      }
    } catch (e) {
      print("Import Error: $e");
      // error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("ไฟล์เสียหายหรือรูปแบบผิด: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("นำเข้า/ส่งออกข้อมูล")),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Text("คุณสามารถส่งออกข้อมูลเป็นไฟล์ .json แล้วบันทึกลงบนเครื่องของคุณเพื่อสำรองข้อมูลทั้งหมดบนแอปพลิเคชั่นนี้ และคุณสามารถนำเข้าข้อมูลของคุณจากไฟล์ .json ที่คุณได้บันทึกไว้"),
                Text("โปรดจำไว้ว่าข้อมูลที่คุณส่งออกนั้น อยู่นอกเหนือความรับผิดชอบของแอปพลิเคชั่น ในกรณีที่ไฟล์ .json ของคุณสูญหาย"),
                SizedBox(height: 50,),
                ElevatedButton(onPressed: importData, child: Text("นำเข้าข้อมูล",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),)),
                SizedBox(height: 50,),
                ElevatedButton(onPressed: exportData, child: Text("ส่งออกข้อมูล",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),)),
              ],
            ),
          ),
        ),
    );
  }
}

class ConfirmResetPage extends StatefulWidget {
  @override
  State<ConfirmResetPage> createState() => _ConfirmResetPageState();
}

class _ConfirmResetPageState extends State<ConfirmResetPage> {
  bool isInputMatch = false;
  Future<void> _clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // จุดที่ทำให้จอดำ
    // if (mounted) {
    //   Navigator.pop(context);
    // }
    // แจ้งเตือนผู้ใช้ก่อนว่าล้างเสร็จแล้ว
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("รีเซ็ทข้อมูลเสร็จสิ้น แอปจะเริ่มต้นใหม่"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1), // ให้โชว์แป๊บเดียวพอ
      ),
    );

    // รอให้ SnackBar โชว์แป๊บนึง แล้วดีดกลับหน้าหลักแบบล้าง State ทิ้งทั้งหมด
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            // ต้องใช้ชื่อคลาสหลัก (MainNavigation) นะครับ
            builder: (context) => MainNavigation(),
          ),
              (route) => false, // ล้างหน้าเก่าทิ้งให้หมด
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ยืนยันการรีเซ็ต")),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),

            child: Column(
              mainAxisSize: MainAxisSize.max, // ให้ Card เล็กพอดีเนื้อหา
              children: [
                Text("นี่คือการรีเซ็ทข้อมูลทั้งหมดในแอปสู่ค่าเริ่มต้น การกระทำนี้ไม่สามารถยกเลิกหรือย้อนกลับได้ หลังจากล้างข้อมูลแล้ว"),
                Text("หากต้องการรีเซ็ทข้อมูลทั้งหมด โปรดพิมพ์ 'ตกลง' เพื่อล้างข้อมูล"),
                SizedBox(height: 30,),
                TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
                    ),
                  ),
                  onChanged: (v) => setState(() => isInputMatch = v == "ตกลง"),
                ),
                SizedBox(height: 30,),
                ElevatedButton(
                  onPressed: isInputMatch ? () {
                    _clearAllData();
                  } : null,
                  child: Text("ล้างข้อมูลทั้งหมด"),
                ),
              ],
            ),
        ),
      ),
    );
  }
}
class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}
class _MainNavigationState extends State<MainNavigation> {
  // --- [ส่วนที่ 1: ตัวแปร (State)] ---
  int _selectedIndex = 0;    // เก็บตำแหน่งหน้าที่เลือก (0-3)
  int currentStep = 0;       // เก็บข้อคำถามปัจจุบันใน Quiz
  int emerfund_rate = 3;
  double totalExpense = 0.0; // ยอดรวมรายจ่าย
  double totalIncome = 0.0;
  double topExpense = 0.0;
  double topIncome = 0.0;
  String topExpense_n = "n/a";
  String topIncome_n = "n/a";

  // Controller สำหรับรับค่าจาก TextField (ใหม่)
  final TextEditingController controller1a = TextEditingController();
  final TextEditingController controller1b = TextEditingController();

  final TextEditingController controller2a = TextEditingController();
  final TextEditingController controller2b = TextEditingController();
  final TextEditingController controller2c = TextEditingController();
  final TextEditingController controller2d = TextEditingController();
  final TextEditingController controller2e = TextEditingController();

  final TextEditingController controller3a = TextEditingController();
  final TextEditingController controller3b = TextEditingController();

  final TextEditingController controller4a = TextEditingController();
  final TextEditingController controller4b = TextEditingController();
  final TextEditingController controller4c = TextEditingController();
  final TextEditingController controller4d = TextEditingController();
  final TextEditingController controller4e = TextEditingController();

  final TextEditingController controller5a = TextEditingController();
  final TextEditingController controller5b = TextEditingController();
  final TextEditingController controller5c = TextEditingController();

  List<Map<String, dynamic>> getExpenseList() { //map => expenseData
    // ฟังก์ชันช่วยแปลงค่าสั้นๆ เพื่อไม่ให้โค้ดรก
    double val(TextEditingController c) => double.tryParse(c.text) ?? 0;
    // for horizontal graph
    List<Map<String, dynamic>> data = [
      if (val(controller1a) > 0) {"name": "อาหาร/เครื่องดื่ม", "amount": val(controller1a), "color": Colors.indigo},
      if (val(controller1b) > 0) {"name": "ยารักษาโรคประจำตัว", "amount": val(controller1b), "color": Colors.indigoAccent},
      if (val(controller2a) > 0) {"name": "ค่าเช่าที่พัก", "amount": val(controller2a), "color": Colors.brown},
      if (val(controller2b) > 0) {"name": "ค่าบริการโทรศัพท์", "amount": val(controller2b), "color": Colors.blue},
      if (val(controller2c) > 0) {"name": "ค่าบริการอินเตอร์เน็ต", "amount": val(controller2c), "color": Colors.green},
      if (val(controller2d) > 0) {"name": "ค่าบริการสตรีมมิ่ง", "amount": val(controller2d), "color": Colors.yellow},
      if (val(controller2e) > 0) {"name": "ค่าสมาชิกบริการ", "amount": val(controller2e), "color": Colors.orange},
      if (val(controller3a) > 0) {"name": "ค่าเลี้ยงดูบุตรเล็ก", "amount": val(controller3a), "color": Colors.pinkAccent},
      if (val(controller3b) > 0) {"name": "ค่าเลี้ยงดูบุตรโต", "amount": val(controller3b), "color": Colors.pink},
      if (val(controller4a) > 0) {"name": "ค่าผ่อนบ้าน", "amount": val(controller4a), "color": Colors.red},
      if (val(controller4b) > 0) {"name": "ค่าผ่อนรถ", "amount": val(controller4b), "color": Colors.red[500]},
      if (val(controller4d) > 0) {"name": "ค่าผ่อนบัตรเครดิต", "amount": val(controller4d), "color": Colors.red[800]},
      if (val(controller4e) > 0) {"name": "หนี้สิน", "amount": val(controller4e), "color": Colors.redAccent},
    ];

    data.sort((a, b) => b['amount'].compareTo(a['amount']));
    return data;
  }

  @override
  void initState() {
    super.initState();
    // เรียกฟังก์ชันโหลดข้อมูลเมื่อหน้าจอถูกสร้างขึ้นใหม่
    _initAppData();
  }

  Future<void> _initAppData() async {
    await _loadData();     // 1. โหลดข้อมูลจาก SharedPreferences เข้า Controller
  }

  //--------------------- f_saveData
  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String dataToSave = "${controller1a.text},${controller1b.text},${controller2a.text},${controller2b.text},${controller2c.text},${controller2d.text},${controller3a.text},${controller3b.text},${controller4a.text},${controller4b.text},${controller4d.text},${controller4e.text},${controller5a.text},${controller5b.text},${controller5c.text}";
    await prefs.setString('expense_list', dataToSave);

    // final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('totalIncome', totalIncome);
    await prefs.setDouble('totalExpense', totalExpense);
    await prefs.setDouble('topExpense', topExpense);
    await prefs.setDouble('topIncome', topIncome);
    await prefs.setString('topExpense_n', topExpense_n);
    await prefs.setString('topIncome_n', topIncome_n);
    await prefs.setInt('emerfund_rate', emerfund_rate);
  }
  // ------------------ f_loadData
  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? savedList = prefs.getString('expense_list');
    List<String> values = savedList != null ? savedList.split(',') : [];

    setState(() {

      totalIncome = prefs.getDouble('totalIncome') ?? 0.0;
      totalExpense = prefs.getDouble('totalExpense') ?? 0.0;
      topIncome = prefs.getDouble('topIncome') ?? 0.0;
      topExpense = prefs.getDouble('topExpense') ?? 0.0;
      topIncome_n = prefs.getString('topIncome_n') ?? "n/a";
      topExpense_n = prefs.getString('topExpense_n') ?? "n/a";
      emerfund_rate = prefs.getInt('emerfund_rate') ?? 3;

      if (values.length >= 15) {
        controller1a.text = values[0];
        controller1b.text = values[1];
        controller2a.text = values[2];
        controller2b.text = values[3];
        controller2c.text = values[4];
        controller2d.text = values[5];
        controller3a.text = values[6];
        controller3b.text = values[7];
        controller4a.text = values[8];
        controller4b.text = values[9];
        controller4d.text = values[10];
        controller4e.text = values[11];
        controller5a.text = values[12];
        controller5b.text = values[13];
        controller5c.text = values[14];
      }
    });
  }

  late final List<Map<String,dynamic>> quizData = [
    {
      'title': 'ค่าอุปโภคบริโภค',
      'desc': 'ค่าใช้จ่ายสำรับการดำรงชีพในแต่ละเดือนของคุณโดยประมาณ กรอกข้อมูลเท่าทีจำเป็น',
      'fields': [
        {'label': 'ค่าอาหาร/เครื่องดืม', 'controller': controller1a},
        {'label': 'ค่ายารักษาโรคประจำตัว', 'controller': controller1b},
      ],
    },
    {
      'title': 'ค่าใช้จ่ายคงที',
      'desc': 'ค่าใช้จ่ายคงที่ที่เกิดขึ้นทุกๆเดือนโดยไม่เปลี่ยนแปลง กรอกข้อมูลเท่าทีจำเป็น',
      'fields': [
        {'label': 'ค่าเช่าที่พัก', 'controller': controller2a},
        {'label': 'ค่าโทรศัพท์รายเดือน', 'controller': controller2b},
        {'label': 'ค่าบริการอินเตอร์เน็ตรายเดือน', 'controller': controller2c},
        {'label': 'ค่าบริการสตรีมมิ่งรายเดือน', 'controller': controller2d},
        {'label': 'ค่าสมาชิกรายเดือนจากบริการต่างๆ', 'controller': controller2e},
      ],
    },
    {
      'title': 'ค่าเลี้ยงดูบุตร(หากมี)',
      'desc': 'ค่าใช้จ่ายที่คุณใช้สำหรับเลี้ยงดูบุตรในแต่ละเดือนของคุณโดยประมาณ กรอกข้อมูลเท่าทีจำเป็น',
      'fields': [
        {'label': 'เงินเลี้ยงดูบุตรเล็ก(ค่านม/ผ้าอ้อม)', 'controller': controller3a},
        {'label': 'เงินเลี้ยงดูบุตรโต(ค่าที่พัก/ค่ากินอยู่สำหรับบุตร)', 'controller': controller3b},
      ],
    },
    {
      'title': 'ค่าผ่อนชำระ และ หนี้สิน',
      'desc': 'ค่าใช้จ่ายที่คุณต้องผ่อนชำระในแต่ละเดือน รวมถึงหนี้สินที่คุณจะต้องจ่ายในทุกๆเดือน กรอกข้อมูลเท่าทีจำเป็น หมายเหตุ : หากหัวข้อนั้นมีการชำระมากกว่า 1 รายการ ผู้ใช้จะต้องรวมให้เป็นก้อนเดียว.',
      'fields': [
        {'label': 'ค่าผ่อนบ้าน', 'controller': controller4a},
        {'label': 'ค่าผ่อนรถ', 'controller': controller4b},
        // {'label': 'ค่าผ่อนสินค้า', 'controller': controller4c},
        {'label': 'ค่าบัตรเครดิต', 'controller': controller4d},
        {'label': 'หนี้สิน', 'controller': controller4e},
      ],
    },
    {
      'title': 'ยืนยันข้อมูล',
      'desc': 'ตรวจสอบความถูกต้องก่อนบันทึกรายจ่ายทั้งหมดของคุณ',
      'fields': [],
    },
    {
      'title': 'รายได้ต่อเดือน',
      'desc': 'รายได้ที่คุณได้รับต่อเดือน จากแหล่งรายได้ของคุณ กรอกข้อมูลเท่าที่จำเป็น',
      'fields': [
        {'label': 'รายได้จากอาชีพหลัก', 'controller': controller5a},
        {'label': 'รายได้จากอาชีพเสริม', 'controller': controller5b},
        {'label': 'รายได้จากการลงทุน', 'controller': controller5c},
      ],
    },
    {
      'title': 'ยืนยันข้อมูล',
      'desc': 'ตรวจสอบความถูกต้องก่อนบันทึกรายจ่ายทั้งหมดของคุณ',
      'fields': [],
    },
  ];

  void goToImportExport() async {
    // รวมข้อมูลเป็น String เหมือนเดิม
    //String dataStringA = "${controller1a.text},${controller1b.text},${controller2a.text},${controller2b.text},${controller2c.text},${controller2d.text},${controller3a.text},${controller3b.text},${controller4a.text},${controller4b.text},${controller4d.text},${controller4e.text},${controller5a.text},${controller5b.text},${controller5c.text}";

    // เปิดหน้าสำรองข้อมูล
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => importexport(dataString: dataStringA)),
    // );

    //------- 19/2 bugfix
    String dataStringA = "${controller1a.text},${controller1b.text},${controller2a.text},${controller2b.text},${controller2c.text},${controller2d.text},${controller3a.text},${controller3b.text},${controller4a.text},${controller4b.text},${controller4d.text},${controller4e.text},${controller5a.text},${controller5b.text},${controller5c.text}";
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => importexport(dataString: dataStringA)),
    );
    if (result == true) {
      print("result ถูกเรียกแล้วสัส");
      _refreshData();
    }
    //--------
  }
  //-------- 19/2 bug fix
  Future<void> _refreshData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // 1. ดึงค่าล่าสุด (บรรทัดนี้ไม่ได้ใช้จริง ลบออกหรือคอมเมนต์ไว้ก็ได้ครับ)
    //String? storedData = prefs.getString('expense_list');

    // 2. โหลดข้อมูลให้เสร็จ "นอก" setState
    await _loadData();
    print("loadData ถูกเรียกแล้วสัส");

    // 3. พอข้อมูลในตัวแปรพร้อมแล้ว ค่อยสั่งวาดหน้าจอใหม่และคำนวณ
    setState(() {
      _calculateTotal();
      print("calculate ถูกเรียกแล้วสัส");
    });

  }
  //--------
  void _calculateTotal() {
    setState(() {
      double tempExpense = 0;
      double tempIncome = 0;
      double temptopExpense = 0;
      double temptopIncome = 0;
      String temptopExpense_n = "n/a";
      String temptopIncome_n = "n/a";

      for (var section in quizData) {
        bool sec_income = section['title'] == "รายได้ต่อเดือน";
        for (var field in section['fields']) {
          final controller = field['controller'] as TextEditingController;
          final label = field['label'] as String;
          double value = double.tryParse(controller.text) ?? 0;

          if (sec_income) {
            tempIncome += value;
            if (value > temptopIncome) {
              temptopIncome = value;
              temptopIncome_n = label;
            }
          } else {
            tempExpense += value;
            if (value > temptopExpense) {
              temptopExpense = value;
              temptopExpense_n = label;
            }
          }
        }
      }

      totalExpense = tempExpense;
      totalIncome = tempIncome;
      topIncome = temptopIncome;
      topExpense = temptopExpense;
      topIncome_n = temptopIncome_n;
      topExpense_n = temptopExpense_n;
    });

    _saveData();
  }

  int selectedMonths = 3;
  void updateEmergencyMonths(int months) {
    setState(() {
      emerfund_rate = months;
    });
    //_saveSetting(months); <<<===== อะไรของมึง?
    _saveData();
  }

  String confirmText = "";
  bool isInputMatch = false;

  void _checkInput(String value) {
    setState(() {
      confirmText = value;
      isInputMatch = (value == "ตกลง");
    });
  }

  // ฟังก์ชันแสดงแบบสอบถาม (Quiz Form)
  void _showQuizSheet({required int startIndex, required int endIndex}) {
    int currentStep = startIndex;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // ยอมให้แผ่นกระดาษดันขึ้นตามคีย์บอร์ด
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        // ใช้ setSheetState เพื่อสั่ง Re-build เฉพาะภายใน BottomSheet
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom, // ดันเนื้อหาหนีคีย์บอร์ด
              left: 25, right: 25, top: 20),
          child: Column(
              mainAxisSize: MainAxisSize.min, // ให้สูงเท่าที่จำเป็น
              children: [
                LinearProgressIndicator(value: (currentStep - startIndex + 1) / (endIndex - startIndex + 1)),
                SizedBox(height: 30),

                Text(
                    quizData[currentStep]['title'],
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                ),
                Text(
                    quizData[currentStep]['desc'],
                    style: TextStyle(fontSize: 15)
                ),
                SizedBox(height: 30),
                if (quizData[currentStep]['fields'] != null && quizData[currentStep]['fields'].isNotEmpty)
                  ...(quizData[currentStep]['fields'] as List).map((field) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TextField(
                        controller: field['controller'],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: field['label'],
                          border: OutlineInputBorder(),
                        ),
                      ),
                    );
                  })
                else
                // ยืนยัน
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
                        SizedBox(height: 10),
                        Text("พร้อมบันทึกแล้วใช่ไหม?"),
                      ],
                    ),
                  ),

              SizedBox(height: 20),

              // Button >:)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (currentStep != 0 && currentStep != 5)
                    TextButton(
                        onPressed: ()=> setSheetState(()=> currentStep--),
                        child: Text("กลับ", style: TextStyle(color: Colors.deepOrange,fontWeight: FontWeight.bold)),
                    )
                  else
                    SizedBox(width:20),
                  Row(
                    children: [
                      if (currentStep < endIndex - 1)
                        TextButton(
                          onPressed: ()=> setSheetState(()=> currentStep++),
                          child: Text("ข้าม", style: TextStyle(color: Colors.grey,)),
                        ),

                      ElevatedButton(
                        onPressed: (){
                          if (currentStep < endIndex) {
                            setSheetState(()=> currentStep++);
                          }else{
                            _calculateTotal();
                            Navigator.pop(context);
                          }
                        },
                        child: Text( currentStep == endIndex? "ถัดไป":"บันทึก"),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> getStatusData(double ratio) {
    if (totalExpense == 0 && totalIncome == 0) {
      return {
        'title': "ไม่ระบุ",
        'desc': "แต่วิเคราะห์อะไรไม่ได้เพราะยังไม่มีข้อมูล",
        'advisor': "ตอนนี้ยังไม่มีข้อมูลทางการเงินของคุณ กด 'แก้ไข' เพื่อเริ่มกรอกข้อมูลกันเถอะ!",
        'color': Colors.grey,
        'image': 'asset/image/bg5.png',
      };
    } else if (ratio >= 55) {
      return {
        'title': "มั่งคั่ง",
        'desc': "เก็บเงินเก่งแล้วอย่าลืมให้รางวัลตัวเองด้วยนะ",
        'advisor': "การเงินของคุณยอดเยี่ยมมาก หากคุณสามารถรักษามาตรฐานแบบนี้ไว้ เงินล้านไม่ไกลเกินฝัน",
        'color': Colors.amber,
        'image': 'asset/image/bg.png',
      };
    } else if (ratio >= 35) {
      return {
        'title': "สบายตัว",
        'desc': "การเงินกำลังดี อย่าลืมศึกษาเรื่องการลงทุนด้วยนะ",
        'advisor': "วางแผนดีมาก! คุณเก็บเงินได้ตามมาตรฐานแล้ว อย่าลืมศึกษาเรื่องการลงทุนเพื่อให้เงินงอกเงิยขึ้นกว่าเดิมนะ",
        'color': Colors.greenAccent,
        'image': 'asset/image/bg2.png',
      };
    } else if (ratio > 10) {
      return {
        'title': "ก็พอไหว",
        'desc': "ถึงจะพอไหวแต่การเงินของคุณยังไม่มั่นคง",
        'advisor': "จะเรียกว่าใช้แบบเดือนชนเดือนก็ได้ การเงินของคุณยังไม่มั่นคง ลองมองหารายได้เพิ่มหรือลดรายจ่ายที่ไม่จำเป็นออกไป เพื่อให้สัดส่วนรายรับและรายจ่ายดีขึ้น",
        'color': Colors.orange,
        'image': 'asset/image/bg3.png',
      };
    } else {
      return {
        'title': "อันตราย",
        'desc': "การเงินของคุณกำลังแย่รีบแก้ไขด่วน",
        'advisor': "คุณแทบไม่มีเงินพอสำหรับรายจ่ายฉุกเฉินเลย คุณกำลังเผชิญหน้ากับวิกฤตทางการเงิน คุณต้องมองหารายรับเพิ่ม และ ตรวจสอบในหน้าวิเคราะห์ว่ารายจ่ายไหนสูงที่สุด",
        'color': Colors.redAccent,
        'image': 'asset/image/bg4.png',
      };
    }
  }

  // --- [ส่วนที่ 3: การสร้างหน้าจอ (UI)] ---

  @override
  Widget build(BuildContext context) {
    IndexedStack(
      index: _selectedIndex,
      children: [
        AnalysisWidget(expenseData: getExpenseList()), // create data
      ],
    );

    // VAL N FORMULA
    double saving = totalIncome - totalExpense;
    double savingRatio = totalIncome > 0 ? (saving / totalIncome) * 100 : 0;
    double emerfund = totalExpense * emerfund_rate;
    double burnrate = totalIncome > 0 ? (totalExpense/totalIncome)*100:0;

    final status = getStatusData(savingRatio);
    final String ow_title = status['title'];
    final String ow_desc = status['desc'];
    final Color ow_color = status['color'];
    final String ow_image = status['image'];
    final String ow_advisor = status['advisor'];

    // รายการหน้าจอที่ใช้แสดงผลใน Body
    final List<Widget> pages = [
      // หน้า 0: Overview
      Stack(
        children: [
          Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(ow_image),
                  fit: BoxFit.cover,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("สถานะทางการเงินของคุณ", style: TextStyle(color: Colors.white70, fontSize: 16)),
                    Text(ow_title, style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: Text(
                        "คุณเก็บเงินได้ ${savingRatio.toStringAsFixed(1)}% ต่อเดือน $ow_desc",
                        style: TextStyle(color: Colors.white70, fontSize: 18,fontWeight:FontWeight.bold),
                        // softWrap: true,
                      ),
                    ),
                  ],
                ),
              )
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
              child: SingleChildScrollView( //กันไว้
                child: Column(
                  children: [
                    const Text("ภาพรวมการเงินของคุณ"),
                    const Text("หักภาระค่าใช้จ่ายแล้ว คุณจะมีเงินเหลือใช้"),
                    Text(
                      NumberFormat("#,###").format(saving),
                      style: const TextStyle(color: Colors.black, fontSize: 50, fontWeight: FontWeight.bold),
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
                                const Text("รายรับ", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15)),
                                Text("${NumberFormat("#,###").format(totalIncome)}บ./เดือน", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18)),
                              ],
                            ),
                          ),
                          const VerticalDivider(color: Colors.grey, thickness: 2, width: 20, indent: 10, endIndent: 10),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("รายจ่าย", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15)),
                                Text("${NumberFormat("#,###").format(totalExpense)}บ./เดือน", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Card(
                      color: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      child: Container(
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
                                child: Text("คำแนะนำ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15),
                              child: Text(ow_advisor, style: const TextStyle(fontSize: 18)),
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
      ),
      // หน้า 1: Edit
      Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.grey[300],
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Column(
                    children:[
                      SizedBox(
                      width: 350,
                      height: 70,
                      child: ElevatedButton.icon(
                          icon: Icon(Icons.edit_note, color: Colors.red, size: 24),
                          onPressed: () => _showQuizSheet(startIndex: 0, endIndex: 4),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                          ),
                          label : Text("เเก้ไขข้อมูลรายจ่าย",style: TextStyle(color: Colors.red,fontSize: 20,fontWeight: FontWeight.bold),)
                        ),
                      ),
                      SizedBox(height: 30,),
                      SizedBox(
                        width: 350,
                        height: 70,
                        child: ElevatedButton.icon(
                            icon: Icon(Icons.edit_note, color: Colors.green, size: 24),
                            onPressed: () => _showQuizSheet(startIndex: 5, endIndex: 6),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                            ),
                            label: Text("เเก้ไขข้อมูลรายรับ",style: TextStyle(color: Colors.green,fontSize: 20,fontWeight: FontWeight.bold),)
                        ),
                      ),
                      SizedBox(height: 30,),
                    ]
                  ),
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.65, // เริ่มต้นที่ 60% ของความสูงจอ
            minChildSize: 0.6,     // ยุบลงมาต่ำสุดได้ที่ 50%
            maxChildSize: 0.97,
            builder: (context, scrollController){
              return Container(
                decoration: BoxDecoration(
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
                    SizedBox(height: 20),
                    Center(
                      child: Column(
                          children: [
                            Text("รายจ่ายทั้งหมด ต่อเดือน"),
                            Text('฿${NumberFormat("#,##0.00").format(totalExpense)}', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.red)),
                            Divider(height: 20, indent: 50, endIndent: 50),
                          ],
                        ),
                      ),

                    // --- กลุ่มที่ 1 ---
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("ค่าอาหาร/เครื่องดื่ม", style: TextStyle(color: Colors.grey[700])),
                          Text("฿ ${controller1a.text.isEmpty ? '0.00' : controller1a.text}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("ค่ายารักษาโรคประจำตัว", style: TextStyle(color: Colors.grey[700])),
                          Text("฿ ${controller1b.text.isEmpty ? '0.00' : controller1b.text}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("ค่าเช่าที่พักรายเดือน", style: TextStyle(color: Colors.grey[700])),
                          Text("฿ ${controller2a.text.isEmpty ? '0.00' : controller2a.text}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("ค่าโทรศัพท์รายเดือน", style: TextStyle(color: Colors.grey[700])),
                          Text("฿ ${controller2b.text.isEmpty ? '0.00' : controller2b.text}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("ค่าบริการอินเตอร์เน็ตรายเดือน", style: TextStyle(color: Colors.grey[700])),
                          Text("฿ ${controller2c.text.isEmpty ? '0.00' : controller2c.text}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("ค่าบริการสตรีมมิ่งรายเดือน", style: TextStyle(color: Colors.grey[700])),
                          Text("฿ ${controller2d.text.isEmpty ? '0.00' : controller2d.text}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("ค่าสมาชิกรายเดือนจากบริการต่างๆ", style: TextStyle(color: Colors.grey[700])),
                          Text("฿ ${controller2e.text.isEmpty ? '0.00' : controller2e.text}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("เงินเลี้ยงดูบุตรเล็ก", style: TextStyle(color: Colors.grey[700])),
                          Text("฿ ${controller3a.text.isEmpty ? '0.00' : controller3a.text}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("เงินเลี้ยงดูบุตรโต", style: TextStyle(color: Colors.grey[700])),
                          Text("฿ ${controller3b.text.isEmpty ? '0.00' : controller3b.text}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("ค่าผ่อนบ้าน", style: TextStyle(color: Colors.grey[700])),
                          Text("฿ ${controller4a.text.isEmpty ? '0.00' : controller4a.text}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("ค่าผ่อนรถ", style: TextStyle(color: Colors.grey[700])),
                          Text("฿ ${controller4b.text.isEmpty ? '0.00' : controller4b.text}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("ค่าบัตรเครดิต", style: TextStyle(color: Colors.grey[700])),
                          Text("฿ ${controller4d.text.isEmpty ? '0.00' : controller4d.text}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("หนี้สิน", style: TextStyle(color: Colors.grey[700])),
                          Text("฿ ${controller4e.text.isEmpty ? '0.00' : controller4e.text}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: Column(
                        children: [
                          Text("รายรับทั้งหมด ต่อเดือน"),
                          Text('฿${NumberFormat("#,##0.00").format(totalIncome)}', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.green)),
                          Divider(height: 20, indent: 50, endIndent: 50),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0 ,horizontal: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("รายได้จากอาชีพหลัก", style: TextStyle(color: Colors.grey[700])),
                          Text(
                            "฿ ${controller5a.text.isEmpty ? '0.00' : controller5a.text}",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0 ,horizontal: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("รายได้จากอาชีพเสริม", style: TextStyle(color: Colors.grey[700])),
                          Text(
                            "฿ ${controller5a.text.isEmpty ? '0.00' : controller5b.text}",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0 ,horizontal: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("รายได้จากการลงทุน", style: TextStyle(color: Colors.grey[700])),
                          Text(
                            "฿ ${controller5a.text.isEmpty ? '0.00' : controller5c.text}",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 100,),
                  ],
                ),
              );
            }
          ),
        ],
      ),
      // หน้า 2: Graph
      AnalysisWidget(expenseData: getExpenseList()),
      // หน้า 3 - ต่างคัา้าพเเบยำไนด
      Center(
        child: Column(
          children: [
            // ส่วนเนื้อหาหลัก
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 25.0),
                child: Column(
                  children: [
                    const Text("เงินสำรองฉุกเฉิน", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    SegmentedButton<int>(
                      segments: const <ButtonSegment<int>>[
                        ButtonSegment<int>(value: 3, label: Text('3 เดือน')),
                        ButtonSegment<int>(value: 6, label: Text('6 เดือน')),
                        ButtonSegment<int>(value: 9, label: Text('9 เดือน')),
                      ],
                      selected: <int>{selectedMonths},
                      onSelectionChanged: (Set<int> newSelection) {
                        setState(() {
                          updateEmergencyMonths(newSelection.first);
                          selectedMonths = newSelection.first;
                        });
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
                          if (states.contains(WidgetState.selected)) return Colors.blue[100];
                          return null;
                        }),
                      ),
                    ),
                    const SizedBox(height: 40), // ระยะห่างระหว่างกลุ่ม

                    const Text("การจัดการข้อมูล", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),

                    ListTile(
                      // leading: const Icon(Icons.shield_outlined, color: Colors.indigo),
                      title: const Text("นำเข้า/สำรอง ข้อมูล"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () {
                        // String dataStringA = "${controller1a.text},${controller1b.text},${controller2a.text},${controller2b.text},${controller2c.text},${controller2d.text},${controller3a.text},${controller3b.text},${controller4a.text},${controller4b.text},${controller4d.text},${controller4e.text},${controller5a.text},${controller5b.text},${controller5c.text}";
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => importexport(dataString: dataStringA), // ส่งข้อมูลไปที่นี่
                        //   ),
                        // );
                        goToImportExport();
                      },
                    ),
                    // ปุ่ม Privacy Policy (ใช้ท่า SnackBar ที่คุยกัน)
                    ListTile(
                      // leading: const Icon(Icons.shield_outlined, color: Colors.indigo),
                      title: const Text("นโยบายความเป็นส่วนตัว"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("ข้อมูลทางการเงินของคุณถูกเก็บไว้ในเครื่องของคุณเท่านั้น"),
                            backgroundColor: Colors.indigo,
                            // behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),

                    // ปุ่มคืนค่าเริ่มต้น
                    ListTile(
                      //leading: const Icon(Icons.refresh, color: Colors.redAccent),
                      title: const Text("รีเซ็ทข้อมูล", style: TextStyle(color: Colors.redAccent)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ConfirmResetPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ส่วนท้าย (Version Info)
            const Padding(
              padding: EdgeInsets.only(bottom: 20.0),
              child: Column(
                children: [
                  Text("MoneyFlow", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  Text("Version 1.0.3", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text('MoneyFlow',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),), centerTitle: true),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ภาพรวม'),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'แก้ไข'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'วิเคราะห์'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'อื่นๆ'),
        ],
      ),
    );
  }
}