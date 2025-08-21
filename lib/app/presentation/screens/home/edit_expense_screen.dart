// lib/app/presentation/screens/home/edit_expense_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditExpenseScreen extends StatefulWidget {
  final String documentId; // Recebe o ID do documento a ser editado

  const EditExpenseScreen({super.key, required this.documentId});

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  DateTime? _dueDate;
  bool _isRecurring = false;
  String? _selectedCategory;
  bool _isLoading = false;

  final List<String> _categories = [
    'Moradia', 'Alimentação', 'Transporte', 'Saúde', 'Lazer', 'Educação', 'Outros'
  ];

  @override
  void initState() {
    super.initState();
    _loadExpenseData(); // Carrega os dados da despesa ao iniciar a tela
  }

  // Função para carregar os dados existentes do Firestore
  Future<void> _loadExpenseData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('expenses')
          .doc(widget.documentId)
          .get();
      
      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = data['name'];
          _amountController.text = data['amount'].toString();
          _dueDate = (data['dueDate'] as Timestamp).toDate();
          _isRecurring = data['isRecurring'];
          _selectedCategory = data['category'];
        });
      }
    } catch (e) {
      print("Erro ao carregar dados: $e");
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _dueDate) {
      setState(() { _dueDate = picked; });
    }
  }

  // Função para ATUALIZAR a despesa
  Future<void> _updateExpense() async {
    if (_nameController.text.isEmpty || _amountController.text.isEmpty || _dueDate == null || _selectedCategory == null) {
      // ... (validação continua a mesma)
      return;
    }

    setState(() { _isLoading = true; });

    try {
      await FirebaseFirestore.instance.collection('expenses').doc(widget.documentId).update({
        'name': _nameController.text.trim(),
        'amount': double.parse(_amountController.text.trim().replaceAll(',', '.')),
        'dueDate': Timestamp.fromDate(_dueDate!),
        'isRecurring': _isRecurring,
        'category': _selectedCategory,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Despesa atualizada com sucesso!'),
          backgroundColor: Colors.green,
        ));
        Navigator.of(context).pop();
      }
    } catch (e) {
      // ... (lógica de erro continua a mesma)
    } finally {
      if (mounted) { setState(() { _isLoading = false; }); }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Despesa')),
      body: _isLoading && _nameController.text.isEmpty // Mostra loading inicial
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nome da Despesa')),
                const SizedBox(height: 16),
                TextFormField(controller: _amountController, decoration: const InputDecoration(labelText: 'Valor (R\$)', prefixText: 'R\$ '), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Tipo de Gasto'),
                  items: _categories.map((String category) => DropdownMenuItem<String>(value: category, child: Text(category))).toList(),
                  onChanged: (newValue) { setState(() { _selectedCategory = newValue; }); },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: Text(_dueDate == null ? 'Nenhuma data selecionada' : 'Vencimento: ${DateFormat('dd/MM/yyyy').format(_dueDate!)}')),
                    TextButton(onPressed: () => _selectDate(context), child: const Text('Selecionar Data')),
                  ],
                ),
                SwitchListTile(
                  title: const Text('Cobrança Recorrente?'),
                  value: _isRecurring,
                  onChanged: (bool value) { setState(() { _isRecurring = value; }); },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _updateExpense,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('ATUALIZAR DESPESA'),
                ),
              ],
            ),
    );
  }
}