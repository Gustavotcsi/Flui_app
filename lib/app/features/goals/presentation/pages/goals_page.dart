import 'package:flutter/material.dart';
import 'package:flui_app/app/features/goals/presentation/widgets/goal_card.dart';
import 'package:flui_app/app/features/goals/presentation/controllers/goals_controller.dart';
import 'package:flui_app/app/features/goals/domain/entities/goal_entity.dart';
import 'package:provider/provider.dart';

class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final goalsController = Provider.of<GoalsController>(context);

    return StreamBuilder<List<Goal>>(
      stream: goalsController.getGoals(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/capi-cadastro.png', height: 120),
                const SizedBox(height: 16),
                const Text(
                  'Nenhuma meta adicionada!',
                  style: TextStyle(fontSize: 18),
                ),
                const Text('Clique no botão + para começar a cadastrar.'),
              ],
            ),
          );
        }
        final goals = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: goals.length,
          itemBuilder: (context, index) {
            return GoalCard(goal: goals[index]);
          },
        );
      },
    );
  }
}
