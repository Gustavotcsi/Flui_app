import 'package:flui_app/app/features/goals/domain/repositories/goal_repository.dart';

class DeleteGoal {
  final GoalRepository repository;

  DeleteGoal(this.repository);

  Future<void> call(String goalId) {
    return repository.deleteGoal(goalId);
  }
}
