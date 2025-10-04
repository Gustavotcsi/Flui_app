import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flui_app/app/features/goals/data/datasources/goal_datasource.dart';
import 'package:flui_app/app/features/goals/data/models/goal_model.dart';

class GoalDatasourceImpl implements GoalDatasource {
  final FirebaseFirestore firestore;

  GoalDatasourceImpl({required this.firestore});

  @override
  Future<void> addGoal(GoalModel goal) async {
    await firestore.collection('goals').doc(goal.id).set(goal.toJson());
  }

  @override
  Future<void> deleteGoal(String goalId) async {
    await firestore.collection('goals').doc(goalId).delete();
  }

  @override
  Stream<List<GoalModel>> getGoals() {
    return firestore.collection('goals').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => GoalModel.fromJson(doc.data()))
          .toList();
    });
  }

  @override
  Future<void> updateGoal(GoalModel goal) async {
    await firestore.collection('goals').doc(goal.id).update(goal.toJson());
  }
}
