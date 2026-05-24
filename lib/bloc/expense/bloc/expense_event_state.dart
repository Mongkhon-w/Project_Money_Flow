import 'package:equatable/equatable.dart';

abstract class ExpenseState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpenseLoaded extends ExpenseState {
  final double totalIncome;
  final double totalExpense;
  final double topIncome;
  final double topExpense;
  final String topIncomeName;
  final String topExpenseName;
  final int emerFundRate;
  final List<String> rawData;

  // --- [ส่วนที่เพิ่มใหม่: เก็บข้อมูลรายวัน] ---
  final List<Map<String, dynamic>> dailyExpenses;
  final double totalDailyExpense;

  ExpenseLoaded({
    required this.totalIncome,
    required this.totalExpense,
    required this.topIncome,
    required this.topExpense,
    required this.topIncomeName,
    required this.topExpenseName,
    required this.emerFundRate,
    required this.rawData,
    required this.dailyExpenses,
    required this.totalDailyExpense,
  });

  @override
  List<Object?> get props => [
    totalIncome,
    totalExpense,
    topIncome,
    topExpense,
    topIncomeName,
    topExpenseName,
    emerFundRate,
    rawData,
    dailyExpenses,
    totalDailyExpense,
  ];
}
