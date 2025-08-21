// lib/app/presentation/screens/home/home_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flui_app/app/presentation/screens/auth/onboarding_screen.dart';
import 'package:flui_app/app/presentation/screens/home/add_expense_screen.dart';
import 'package:flui_app/app/presentation/screens/home/edit_expense_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;

  // Variáveis de estado para os filtros
  String? _selectedFilterCategory;
  bool? _selectedFilterIsPaid; // bool nulo para "Todos" (true=Pagas, false=Não Pagas)
  DateTimeRange? _selectedFilterDateRange;

  // Função para fazer logout
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  // Função para apagar a despesa
  Future<void> _deleteExpense(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('expenses').doc(docId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Despesa apagada!'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print('Erro ao apagar despesa: $e');
    }
  }

  // Função para marcar despesa como paga ou não paga
  Future<void> _togglePaidStatus(String docId, bool currentStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('expenses')
          .doc(docId)
          .update({'isPaid': !currentStatus}); // Inverte o status atual
    } catch (e) {
      print('Erro ao atualizar status de pagamento: $e');
    }
  }

  // Função para mostrar a planilha de filtros
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        // Usamos StatefulBuilder para que a planilha tenha seu próprio estado interno
        // sem precisar reconstruir a tela inteira a cada seleção.
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
              child: Wrap(
                runSpacing: 16,
                children: [
                  const Text('Filtrar Despesas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  DropdownButtonFormField<String>(
                    value: _selectedFilterCategory,
                    decoration: const InputDecoration(labelText: 'Categoria'),
                    items: ['Moradia', 'Alimentação', 'Transporte', 'Saúde', 'Lazer', 'Educação', 'Outros']
                        .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                        .toList(),
                    onChanged: (value) => setModalState(() => _selectedFilterCategory = value),
                  ),
                  const SizedBox(height: 10),
                  Text("Status", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                  SegmentedButton<bool?>(
                    segments: const [
                      ButtonSegment(value: null, label: Text('Todas')),
                      ButtonSegment(value: true, label: Text('Pagas')),
                      ButtonSegment(value: false, label: Text('Não Pagas')),
                    ],
                    selected: {_selectedFilterIsPaid},
                    onSelectionChanged: (selection) => setModalState(() => _selectedFilterIsPaid = selection.first),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(_selectedFilterDateRange == null
                        ? 'Filtrar por Período'
                        : '${DateFormat('dd/MM/yy').format(_selectedFilterDateRange!.start)} - ${DateFormat('dd/MM/yy').format(_selectedFilterDateRange!.end)}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setModalState(() => _selectedFilterDateRange = picked);
                      }
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          // Limpa os filtros na HomeScreen e fecha a planilha
                          setState(() {
                            _selectedFilterCategory = null;
                            _selectedFilterIsPaid = null;
                            _selectedFilterDateRange = null;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Limpar Filtros'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          // Aplica os filtros na HomeScreen e fecha a planilha
                          setState(() {});
                          Navigator.pop(context);
                        },
                        child: const Text('Aplicar'),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Despesas'),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: _showFilterSheet, tooltip: 'Filtrar'),
          IconButton(icon: const Icon(Icons.logout), onPressed: () => _signOut(), tooltip: 'Sair'),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('expenses')
            .where('userId', isEqualTo: user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          var allDocs = snapshot.data?.docs ?? [];

          if (allDocs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/capi-inicio.png', height: 120),
                  const SizedBox(height: 16),
                  const Text('Nenhuma despesa adicionada!', style: TextStyle(fontSize: 18)),
                  const Text('Clique no botão + para começar.'),
                ],
              ),
            );
          }

          // Lógica de Filtragem no lado do cliente
          var filteredDocs = allDocs;
          if (_selectedFilterCategory != null) {
            filteredDocs = filteredDocs.where((d) => (d.data() as Map)['category'] == _selectedFilterCategory).toList();
          }
          if (_selectedFilterIsPaid != null) {
            filteredDocs = filteredDocs.where((d) => (d.data() as Map)['isPaid'] == _selectedFilterIsPaid).toList();
          }
          if (_selectedFilterDateRange != null) {
            filteredDocs = filteredDocs.where((d) {
              DateTime dueDate = ((d.data() as Map)['dueDate'] as Timestamp).toDate();
              return dueDate.isAfter(_selectedFilterDateRange!.start.subtract(const Duration(days: 1))) &&
                     dueDate.isBefore(_selectedFilterDateRange!.end.add(const Duration(days: 1)));
            }).toList();
          }
          
          filteredDocs.sort((a, b) {
            DateTime dateA = ((a.data() as Map)['dueDate'] as Timestamp).toDate();
            DateTime dateB = ((b.data() as Map)['dueDate'] as Timestamp).toDate();
            return dateA.compareTo(dateB);
          });

          // Lógica de cálculo do total
          double totalFiltered = filteredDocs.fold(0.0, (sum, doc) {
            return sum + ((doc.data() as Map<String, dynamic>)['amount'] as num);
          });

          String totalLabel = 'Despesas Totais:';
          if (_selectedFilterCategory != null || _selectedFilterIsPaid != null || _selectedFilterDateRange != null) {
            totalLabel = 'Total Filtrado:';
          }

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      totalLabel,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                    Text(
                      'R\$ ${totalFiltered.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filteredDocs.isEmpty
                    ? const Center(child: Text("Nenhuma despesa encontrada com esses filtros."))
                    : ListView.builder(
                        itemCount: filteredDocs.length,
                        itemBuilder: (context, index) {
                          var expenseDoc = filteredDocs[index];
                          var expenseData = expenseDoc.data() as Map<String, dynamic>;
                          DateTime dueDate = (expenseData['dueDate'] as Timestamp).toDate();
                          String formattedDate = DateFormat('dd/MM/yyyy').format(dueDate);
                          bool isPaid = expenseData['isPaid'] ?? false;
                          bool isOverdue = dueDate.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)) && !isPaid;

                          Color titleColor = Colors.black87;
                          if (isPaid) {
                            titleColor = Colors.green;
                          } else if (isOverdue) {
                            titleColor = Colors.red;
                          }

                          return ListTile(
                            leading: CircleAvatar(child: Text(expenseData['category'][0])),
                            title: Text(
                              expenseData['name'],
                              style: TextStyle(
                                color: titleColor,
                                fontWeight: FontWeight.bold,
                                decoration: isPaid ? TextDecoration.lineThrough : TextDecoration.none,
                              ),
                            ),
                            subtitle: Text('${expenseData['category']} - Vence em: $formattedDate'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'R\$ ${expenseData['amount'].toStringAsFixed(2)}',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: titleColor),
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      Navigator.of(context).push(MaterialPageRoute(
                                        builder: (context) => EditExpenseScreen(documentId: expenseDoc.id),
                                      ));
                                    } else if (value == 'delete') {
                                      _deleteExpense(expenseDoc.id);
                                    } else if (value == 'pay') {
                                      _togglePaidStatus(expenseDoc.id, isPaid);
                                    }
                                  },
                                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                    PopupMenuItem<String>(
                                      value: 'pay',
                                      child: Row(children: [
                                        Icon(isPaid ? Icons.undo : Icons.check, size: 20),
                                        const SizedBox(width: 8),
                                        Text(isPaid ? 'Desfazer Pag.' : 'Pagar'),
                                      ]),
                                    ),
                                    const PopupMenuItem<String>(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('Editar')])),
                                    const PopupMenuItem<String>(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 20), SizedBox(width: 8), Text('Excluir')])),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
          );
        },
        tooltip: 'Adicionar Despesa',
        child: const Icon(Icons.add),
      ),
    );
  }
}