import 'package:flui_app/app/features/goals/domain/entities/goal_entity.dart';

abstract class GoalRepository {
  Future<void> addGoal(Goal goal);
  Future<void> updateGoal(Goal goal);
  Future<void> deleteGoal(String goalId);
  Stream<List<Goal>> getGoals();
}
