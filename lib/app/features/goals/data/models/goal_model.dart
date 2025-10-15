import 'package:flui_app/app/features/goals/domain/entities/goal_entity.dart';

class GoalModel extends Goal {
  GoalModel({
    required super.id,
    required super.name,
    required super.targetAmount,
    super.currentAmount = 0.0,
    required super.targetDate,
    required super.category,
  });  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'],
      name: json['name'],
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num).toDouble(),
      targetDate: DateTime.parse(json['targetDate']),
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'targetDate': targetDate.toIso8601String(),
      'category': category,
    };
  }
}
