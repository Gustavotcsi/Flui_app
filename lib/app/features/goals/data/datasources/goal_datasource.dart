import 'package:flui_app/app/features/goals/data/models/goal_model.dart';

abstract class GoalDatasource {
  Future<void> addGoal(GoalModel goal);
  Future<void> updateGoal(GoalModel goal);
  Future<void> deleteGoal(String goalId);
  Stream<List<GoalModel>> getGoals();
}
