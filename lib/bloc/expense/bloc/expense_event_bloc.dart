import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'expense_event_event.dart';
import 'expense_event_state.dart';

class ExpenseEventBloc extends Bloc<ExpenseEvent, ExpenseState> {
  ExpenseEventBloc() : super(ExpenseInitial()) {
    on<LoadExpenseData>(_onLoadExpenseData);
    on<UpdateExpenseData>(_onUpdateExpenseData);
    on<UpdateEmerFundRate>(_onUpdateEmerFundRate);
    on<ResetDataEvent>(_onResetData);
    // --- [เพิ่ม Event ใหม่] ---
    on<AddDailyExpense>(_onAddDailyExpense);
    on<DeleteDailyExpense>(_onDeleteDailyExpense);
  }

  Future<void> _onLoadExpenseData(
    LoadExpenseData event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());
    final prefs = await SharedPreferences.getInstance();

    String? savedList = prefs.getString('expense_list');
    List<String> rawData = savedList != null
        ? savedList.split(',')
        : List.filled(15, "");

    // --- [โหลดรายจ่ายรายวันจาก JSON] ---
    String? dailyStr = prefs.getString('daily_expenses');
    List<Map<String, dynamic>> dailyExpenses = [];
    double totalDailyExpense = 0.0;

    if (dailyStr != null) {
      List<dynamic> decoded = jsonDecode(dailyStr);
      dailyExpenses = decoded.map((e) => e as Map<String, dynamic>).toList();
      // คำนวณยอดรวมรายวัน
      for (var item in dailyExpenses) {
        totalDailyExpense += (item['amount'] as num).toDouble();
      }
    }

    // คำนวณรายจ่ายสุทธิ (รายจ่ายคงที่จากหน้าแก้ไข + รายจ่ายรายวัน)
    double fixedExpense = prefs.getDouble('totalExpense') ?? 0.0;
    double overallExpense = fixedExpense + totalDailyExpense;

    emit(
      ExpenseLoaded(
        totalIncome: prefs.getDouble('totalIncome') ?? 0.0,
        totalExpense: overallExpense, // ใช้ยอดรวมใหม่
        topIncome: prefs.getDouble('topIncome') ?? 0.0,
        topExpense: prefs.getDouble('topExpense') ?? 0.0,
        topIncomeName: prefs.getString('topIncome_n') ?? "n/a",
        topExpenseName: prefs.getString('topExpense_n') ?? "n/a",
        emerFundRate: prefs.getInt('emerfund_rate') ?? 3,
        rawData: rawData,
        dailyExpenses: dailyExpenses,
        totalDailyExpense: totalDailyExpense,
      ),
    );
  }

  Future<void> _onUpdateExpenseData(
    UpdateExpenseData event,
    Emitter<ExpenseState> emit,
  ) async {
    double tempExpense = 0;
    double tempIncome = 0;
    double temptopExpense = 0;
    double temptopIncome = 0;
    String temptopExpenseName = "n/a";
    String temptopIncomeName = "n/a";

    List<String> labels = [
      "ค่าอาหาร/เครื่องดื่ม",
      "ค่ายารักษาโรค",
      "ค่าเช่าที่พัก",
      "ค่าโทรศัพท์",
      "ค่าเน็ต",
      "ค่าสตรีมมิ่ง",
      "ค่าสมาชิก",
      "ค่าดูแลบุตรเล็ก",
      "ค่าดูแลบุตรโต",
      "ค่าผ่อนบ้าน",
      "ค่าผ่อนรถ",
      "หนี้สิน",
      "รายได้หลัก",
      "รายได้เสริม",
      "รายได้ลงทุน",
    ];

    for (int i = 0; i < event.rawData.length; i++) {
      double val = double.tryParse(event.rawData[i]) ?? 0;
      if (i >= 12) {
        tempIncome += val;
        if (val > temptopIncome) {
          temptopIncome = val;
          temptopIncomeName = labels[i];
        }
      } else {
        tempExpense += val;
        if (val > temptopExpense) {
          temptopExpense = val;
          temptopExpenseName = labels[i];
        }
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('expense_list', event.rawData.join(','));
    await prefs.setDouble('totalIncome', tempIncome);
    await prefs.setDouble(
      'totalExpense',
      tempExpense,
    ); // เซฟเฉพาะค่าใช้จ่ายคงที่
    await prefs.setDouble('topIncome', temptopIncome);
    await prefs.setDouble('topExpense', temptopExpense);
    await prefs.setString('topIncome_n', temptopIncomeName);
    await prefs.setString('topExpense_n', temptopExpenseName);

    add(LoadExpenseData());
  }

  Future<void> _onUpdateEmerFundRate(
    UpdateEmerFundRate event,
    Emitter<ExpenseState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('emerfund_rate', event.rate);
    add(LoadExpenseData());
  }

  // --- [ฟังก์ชันเพิ่ม/ลบ รายจ่ายรายวัน] ---
  Future<void> _onAddDailyExpense(
    AddDailyExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    if (state is! ExpenseLoaded) return;
    final currentState = state as ExpenseLoaded;

    final newExpense = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'amount': event.amount,
      'note': event.note,
      'date': DateTime.now().toIso8601String(),
    };

    // เอาของเดิมมา แล้วเพิ่มของใหม่ต่อท้าย
    final updatedList = List<Map<String, dynamic>>.from(
      currentState.dailyExpenses,
    )..insert(0, newExpense);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('daily_expenses', jsonEncode(updatedList));

    add(LoadExpenseData()); // สั่งรีโหลดเพื่อคำนวณใหม่
  }

  Future<void> _onDeleteDailyExpense(
    DeleteDailyExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    if (state is! ExpenseLoaded) return;
    final currentState = state as ExpenseLoaded;

    // กรองเอาเฉพาะอันที่ ID ไม่ตรงกับที่กดลบ
    final updatedList = currentState.dailyExpenses
        .where((item) => item['id'] != event.id)
        .toList();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('daily_expenses', jsonEncode(updatedList));

    add(LoadExpenseData());
  }

  Future<void> _onResetData(
    ResetDataEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    add(LoadExpenseData());
  }
}
