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
  final List<String> rawData; // ข้อมูลที่เก็บเป็น String List

  ExpenseLoaded({
    required this.totalIncome,
    required this.totalExpense,
    required this.topIncome,
    required this.topExpense,
    required this.topIncomeName,
    required this.topExpenseName,
    required this.emerFundRate,
    required this.rawData,
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
  ];
}
