import 'package:flui_app/app/features/goals/domain/entities/goal_entity.dart';
import 'package:flui_app/app/features/goals/domain/repositories/goal_repository.dart';

class AddGoal {
  final GoalRepository repository;

  AddGoal(this.repository);

  Future<void> call(Goal goal) {
    return repository.addGoal(goal);
  }
}
