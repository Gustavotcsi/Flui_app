import 'package:flui_app/app/features/goals/domain/entities/goal_entity.dart';
import 'package:flui_app/app/features/goals/domain/repositories/goal_repository.dart';

class UpdateGoal {
  final GoalRepository repository;

  UpdateGoal(this.repository);

  Future<void> call(Goal goal) {
    return repository.updateGoal(goal);
  }
}
