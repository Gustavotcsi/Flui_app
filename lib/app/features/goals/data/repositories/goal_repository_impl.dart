import 'package:flui_app/app/features/goals/data/datasources/goal_datasource.dart';
import 'package:flui_app/app/features/goals/domain/entities/goal_entity.dart';
import 'package:flui_app/app/features/goals/domain/repositories/goal_repository.dart';
import 'package:flui_app/app/features/goals/data/models/goal_model.dart';

class GoalRepositoryImpl implements GoalRepository {
  final GoalDatasource datasource;

  GoalRepositoryImpl({required this.datasource});

  @override
  Future<void> addGoal(Goal goal) async {
    final goalModel = GoalModel(
      id: goal.id,
      name: goal.name,
      targetAmount: goal.targetAmount,
      currentAmount: goal.currentAmount,
      targetDate: goal.targetDate,
      category: goal.category,
    );
    await datasource.addGoal(goalModel);
  }

  @override
  Future<void> deleteGoal(String goalId) async {
    await datasource.deleteGoal(goalId);
  }

  @override
  Stream<List<Goal>> getGoals() {
    return datasource.getGoals();
  }

  @override
  Future<void> updateGoal(Goal goal) async {
    final goalModel = GoalModel(
      id: goal.id,
      name: goal.name,
      targetAmount: goal.targetAmount,
      currentAmount: goal.currentAmount,
      targetDate: goal.targetDate,
      category: goal.category,
    );
    await datasource.updateGoal(goalModel);
  }
}
