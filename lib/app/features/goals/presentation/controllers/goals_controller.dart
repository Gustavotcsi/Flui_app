import 'package:flutter/material.dart';
import 'package:flui_app/app/features/goals/domain/entities/goal_entity.dart';
import 'package:flui_app/app/features/goals/domain/usecases/add_goal.dart';
import 'package:flui_app/app/features/goals/domain/usecases/delete_goal.dart';
import 'package:flui_app/app/features/goals/domain/usecases/get_goals.dart';
import 'package:flui_app/app/features/goals/domain/usecases/update_goal.dart';

class GoalsController extends ChangeNotifier {
  final AddGoal addGoalUseCase;
  final GetGoals getGoalsUseCase;
  final UpdateGoal updateGoalUseCase;
  final DeleteGoal deleteGoalUseCase;

  GoalsController({
    required this.addGoalUseCase,
    required this.getGoalsUseCase,
    required this.updateGoalUseCase,
    required this.deleteGoalUseCase,
  });

  Stream<List<Goal>> getGoals() {
    return getGoalsUseCase();
  }

  Future<void> addGoal(Goal goal) async {
    await addGoalUseCase(goal);
  }

  Future<void> updateGoal(Goal goal) async {
    await updateGoalUseCase(goal);
  }

  Future<void> deleteGoal(String goalId) async {
    await deleteGoalUseCase(goalId);
  }

  Future<void> addFundsToGoal(Goal goal, double amount) async {
    final newAmount = goal.currentAmount + amount;
    final updatedGoal = Goal(
      id: goal.id,
      name: goal.name,
      targetAmount: goal.targetAmount,
      currentAmount: newAmount,
      targetDate: goal.targetDate,
      category: goal.category,
    );
    await updateGoal(updatedGoal);
    notifyListeners();
  }
}
