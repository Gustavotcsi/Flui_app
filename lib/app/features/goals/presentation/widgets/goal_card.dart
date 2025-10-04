import 'package:flutter/material.dart';
import 'package:flui_app/app/features/goals/domain/entities/goal_entity.dart';
import 'package:flui_app/app/features/goals/presentation/controllers/goals_controller.dart';
import 'package:provider/provider.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;

  const GoalCard({super.key, required this.goal});

  void _showAddFundsDialog(BuildContext context) {
    final TextEditingController amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Adicionar à meta "${goal.name}"'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Valor a economizar',
                prefixText: 'R\$ ',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira um valor.';
                }
                if (double.tryParse(value.replaceAll(',', '.')) == null) {
                  return 'Por favor, insira um número válido.';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final amount = double.parse(
                    amountController.text.replaceAll(',', '.'),
                  );
                  final goalsController = Provider.of<GoalsController>(
                    context,
                    listen: false,
                  );
                  goalsController.addFundsToGoal(goal, amount);
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double progress = goal.currentAmount / goal.targetAmount;
    if (progress.isNaN || progress.isInfinite) {
      progress = 0.0;
    }

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              goal.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Meta: R\$ ${goal.targetAmount.toStringAsFixed(2)}'),
            Text('Economizado: R\$ ${goal.currentAmount.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${(progress * 100).toStringAsFixed(1)}% alcançado'),
                ElevatedButton.icon(
                  onPressed: () => _showAddFundsDialog(context),
                  icon: const Icon(Icons.savings_outlined),
                  label: const Text('Economizei'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
