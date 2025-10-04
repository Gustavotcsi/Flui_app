import 'package:flutter/material.dart';
import 'package:flui_app/app/features/goals/domain/entities/goal_entity.dart';
import 'package:flui_app/app/features/goals/presentation/controllers/goals_controller.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddGoalPage extends StatefulWidget {
  const AddGoalPage({super.key});

  @override
  _AddGoalPageState createState() => _AddGoalPageState();
}

class _AddGoalPageState extends State<AddGoalPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _categoryController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Nova Meta')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome da Meta'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome da meta.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _targetAmountController,
                decoration: const InputDecoration(labelText: 'Valor da Meta'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o valor da meta.';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor, insira um número válido.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Categoria'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a categoria.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Data Limite: ${_selectedDate.toLocal()}'.split(' ')[0],
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null && picked != _selectedDate) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                    child: const Text('Selecionar Data'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newGoal = Goal(
                      id: const Uuid().v4(),
                      name: _nameController.text,
                      targetAmount: double.parse(_targetAmountController.text),
                      targetDate: _selectedDate,
                      category: _categoryController.text,
                    );
                    Provider.of<GoalsController>(
                      context,
                      listen: false,
                    ).addGoal(newGoal);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Salvar Meta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
