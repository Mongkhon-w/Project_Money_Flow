import 'package:equatable/equatable.dart';

abstract class ExpenseEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadExpenseData extends ExpenseEvent {}

class UpdateExpenseData extends ExpenseEvent {
  final List<String> rawData;
  UpdateExpenseData(this.rawData);
}

class UpdateEmerFundRate extends ExpenseEvent {
  final int rate;
  UpdateEmerFundRate(this.rate);
}

class ResetDataEvent extends ExpenseEvent {}

// --- [ส่วนที่เพิ่มใหม่: Event สำหรับรายจ่ายรายวัน] ---
class AddDailyExpense extends ExpenseEvent {
  final double amount;
  final String note;
  AddDailyExpense({required this.amount, required this.note});
}

class DeleteDailyExpense extends ExpenseEvent {
  final String id;
  DeleteDailyExpense(this.id);
}
