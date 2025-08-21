// lib/app/presentation/screens/home/add_expense_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pacote para formatar datas

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  // Controllers para os campos de texto
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  // Variáveis para os outros campos
  DateTime? _dueDate;
  bool _isRecurring = false;
  String? _selectedCategory;
  bool _isLoading = false;

  final List<String> _categories = [
    'Moradia',
    'Alimentação',
    'Transporte',
    'Saúde',
    'Lazer',
    'Educação',
    'Outros'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // Função para abrir o seletor de data
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  // Função para salvar a despesa no Firestore
  Future<void> _saveExpense() async {
    // Validação simples
    if (_nameController.text.isEmpty ||
        _amountController.text.isEmpty ||
        _dueDate == null ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Por favor, preencha todos os campos.'),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance.collection('expenses').add({
        'userId': user.uid, 
        'name': _nameController.text.trim(),
        'amount': double.parse(_amountController.text.trim().replaceAll(',', '.')),
        'dueDate': Timestamp.fromDate(_dueDate!), 
        'isRecurring': _isRecurring,
        'category': _selectedCategory,
        'createdAt': FieldValue.serverTimestamp(), 
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Despesa salva com sucesso!'),
          backgroundColor: Colors.green,
        ));
        Navigator.of(context).pop(); // Volta para a HomeScreen
      }
    } catch (e) {
      print('Erro ao salvar despesa: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Ocorreu um erro ao salvar a despesa.'),
          backgroundColor: Colors.redAccent,
        ));
      }
    } finally {
      if (mounted) { setState(() { _isLoading = false; }); }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Despesa')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nome da Despesa'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _amountController,
            decoration: const InputDecoration(labelText: 'Valor (R\$)', prefixText: 'R\$ '),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 16),
          // Seletor de Categoria
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(labelText: 'Tipo de Gasto'),
            items: _categories.map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _selectedCategory = newValue;
              });
            },
          ),
          const SizedBox(height: 16),
          // Seletor de Data
          Row(
            children: [
              Expanded(
                child: Text(
                  _dueDate == null
                      ? 'Nenhuma data selecionada'
                      : 'Vencimento: ${DateFormat('dd/MM/yyyy').format(_dueDate!)}',
                ),
              ),
              TextButton(
                onPressed: () => _selectDate(context),
                child: const Text('Selecionar Data'),
              ),
            ],
          ),
          // Switch para Recorrência
          SwitchListTile(
            title: const Text('Cobrança Recorrente?'),
            value: _isRecurring,
            onChanged: (bool value) {
              setState(() {
                _isRecurring = value;
              });
            },
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isLoading ? null : _saveExpense,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('SALVAR DESPESA'),
          ),
        ],
      ),
    );
  }
}