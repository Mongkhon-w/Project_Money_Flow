import 'package:equatable/equatable.dart';

abstract class ExpenseEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadExpenseData extends ExpenseEvent {}

class UpdateExpenseData extends ExpenseEvent {
  final List<String> rawData; // ข้อมูลจาก 15 TextControllers
  UpdateExpenseData(this.rawData);
}

class UpdateEmerFundRate extends ExpenseEvent {
  final int rate;
  UpdateEmerFundRate(this.rate);
}

class ResetDataEvent extends ExpenseEvent {}
