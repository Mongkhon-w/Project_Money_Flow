import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ⚠️ ใช้ Relative Import (เรียกไฟล์ที่อยู่ข้างๆ กัน) เพื่อตัดปัญหา Ambiguous Import ทิ้งถาวร
import 'expense_event_event.dart';
import 'expense_event_state.dart';

// ⚠️ เปลี่ยนชื่อคลาสตรงนี้เป็น ExpenseEventBloc ให้ตรงกับไฟล์อื่นๆ
class ExpenseEventBloc extends Bloc<ExpenseEvent, ExpenseState> {
  // ⚠️ เปลี่ยนชื่อ Constructor ให้ตรงกับชื่อคลาส
  ExpenseEventBloc() : super(ExpenseInitial()) {
    on<LoadExpenseData>(_onLoadExpenseData);
    on<UpdateExpenseData>(_onUpdateExpenseData);
    on<UpdateEmerFundRate>(_onUpdateEmerFundRate);
    on<ResetDataEvent>(_onResetData);
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

    emit(
      ExpenseLoaded(
        totalIncome: prefs.getDouble('totalIncome') ?? 0.0,
        totalExpense: prefs.getDouble('totalExpense') ?? 0.0,
        topIncome: prefs.getDouble('topIncome') ?? 0.0,
        topExpense: prefs.getDouble('topExpense') ?? 0.0,
        topIncomeName: prefs.getString('topIncome_n') ?? "n/a",
        topExpenseName: prefs.getString('topExpense_n') ?? "n/a",
        emerFundRate: prefs.getInt('emerfund_rate') ?? 3,
        rawData: rawData,
      ),
    );
  }

  Future<void> _onUpdateExpenseData(
    UpdateExpenseData event,
    Emitter<ExpenseState> emit,
  ) async {
    // โลจิก _calculateTotal() เดิมถูกย้ายมาที่นี่ทั้งหมด
    double tempExpense = 0;
    double tempIncome = 0;
    double temptopExpense = 0;
    double temptopIncome = 0;
    String temptopExpenseName = "n/a";
    String temptopIncomeName = "n/a";

    // สมมติฐานว่าข้อมูลเรียงตามฟอร์ม: 0-11 เป็นรายจ่าย, 12-14 เป็นรายรับ (อ้างอิงจากโค้ดเดิมของคุณ)
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
        // โซนรายรับ
        tempIncome += val;
        if (val > temptopIncome) {
          temptopIncome = val;
          temptopIncomeName = labels[i];
        }
      } else {
        // โซนรายจ่าย
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
    await prefs.setDouble('totalExpense', tempExpense);
    await prefs.setDouble('topIncome', temptopIncome);
    await prefs.setDouble('topExpense', temptopExpense);
    await prefs.setString('topIncome_n', temptopIncomeName);
    await prefs.setString('topExpense_n', temptopExpenseName);

    // โหลดข้อมูลขึ้นมาใหม่
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

  Future<void> _onResetData(
    ResetDataEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    add(LoadExpenseData());
  }
}
