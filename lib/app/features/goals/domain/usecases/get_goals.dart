import 'package:flui_app/app/features/goals/domain/entities/goal_entity.dart';
import 'package:flui_app/app/features/goals/domain/repositories/goal_repository.dart';

class GetGoals {
  final GoalRepository repository;

  GetGoals(this.repository);

  Stream<List<Goal>> call() {
    return repository.getGoals();
  }
}
