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

// Adicionamos 'SingleTickerProviderStateMixin' para controlar a animação das abas
class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final user = FirebaseAuth.instance.currentUser;
  
  // Controller para as abas
  late TabController _tabController;

  // Variáveis de estado para os filtros
  String? _selectedFilterCategory;
  bool? _selectedFilterIsPaid; 
  DateTimeRange? _selectedFilterDateRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Inicializa o controller com 2 abas
  }

  @override
  void dispose() {
    _tabController.dispose(); // Limpa o controller ao sair da tela
    super.dispose();
  }

  // As funções _signOut, _deleteExpense, _togglePaidStatus, e _showFilterSheet
  // continuam exatamente as mesmas que já criamos.
  // (O código completo delas está incluído abaixo para garantir)

  Future<void> _signOut() async { /* ... */ }
  Future<void> _deleteExpense(String docId) async { /* ... */ }
  Future<void> _togglePaidStatus(String docId, bool currentStatus) async { /* ... */ }
  void _showFilterSheet() { /* ... */ }

  // NOVO WIDGET REUTILIZÁVEL: Para construir a lista de despesas
  Widget _buildExpenseList(List<DocumentSnapshot> docs) {
    if (docs.isEmpty) {
      return const Center(child: Text("Nenhuma despesa nesta categoria."));
    }

    final now = DateTime.now();
    return ListView.builder(
      itemCount: docs.length,
      itemBuilder: (context, index) {
        var expenseDoc = docs[index];
        var expenseData = expenseDoc.data() as Map<String, dynamic>;
        DateTime dueDate = (expenseData['dueDate'] as Timestamp).toDate();
        String formattedDate = DateFormat('dd/MM/yyyy').format(dueDate);
        bool isPaid = expenseData['isPaid'] ?? false;
        bool isOverdue = dueDate.isBefore(DateTime(now.year, now.month, now.day)) && !isPaid;

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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            return Scaffold( // Adicionamos um Scaffold aqui para ter a AppBar e o FAB
              appBar: AppBar(title: const Text('Minhas Despesas')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/capi-inicio.png', height: 120),
                    const SizedBox(height: 16),
                    const Text('Nenhuma despesa adicionada!', style: TextStyle(fontSize: 18)),
                    const Text('Clique no botão + para começar.'),
                  ],
                ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddExpenseScreen()));
                },
                tooltip: 'Adicionar Despesa',
                child: const Icon(Icons.add),
              ),
            );
          }

          // Lógica de Filtragem (continua a mesma)
          var filteredDocs = allDocs;
          if (_selectedFilterCategory != null) { /* ... */ }
          if (_selectedFilterIsPaid != null) { /* ... */ }
          if (_selectedFilterDateRange != null) { /* ... */ }

          // **NOVA LÓGICA: Divisão entre pagas e não pagas**
          final unpaidExpenses = filteredDocs.where((doc) => !(doc.data() as Map)['isPaid']).toList();
          final paidExpenses = filteredDocs.where((doc) => (doc.data() as Map)['isPaid']).toList();

          // Ordena as listas pela data de vencimento
          unpaidExpenses.sort((a,b) => ((a.data() as Map)['dueDate'] as Timestamp).compareTo((b.data() as Map)['dueDate']));
          paidExpenses.sort((a,b) => ((a.data() as Map)['dueDate'] as Timestamp).compareTo((b.data() as Map)['dueDate']));

          double totalUnpaid = unpaidExpenses.fold(0.0, (sum, doc) => sum + (doc.data() as Map)['amount']);

          return Scaffold(
            appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Minhas Despesas'),
                  Text(
                    'Total Pendente: R\$ ${totalUnpaid.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                  ),
                ],
              ),
              actions: [
                IconButton(icon: const Icon(Icons.filter_list), onPressed: _showFilterSheet, tooltip: 'Filtrar'),
                IconButton(icon: const Icon(Icons.logout), onPressed: _signOut, tooltip: 'Sair'),
              ],
              // **NOVO: Adiciona a barra de abas abaixo da AppBar**
              bottom: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: 'Pendentes (${unpaidExpenses.length})'),
                  Tab(text: 'Pagas (${paidExpenses.length})'),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                // Corpo da Aba "Pendentes"
                _buildExpenseList(unpaidExpenses),
                // Corpo da Aba "Pagas"
                _buildExpenseList(paidExpenses),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddExpenseScreen()));
              },
              tooltip: 'Adicionar Despesa',
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }
}

// DEFINIÇÕES COMPLETAS DAS FUNÇÕES (Para garantir que não falte nada)
extension _HomeScreenStateExtension on _HomeScreenState {
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

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

  Future<void> _togglePaidStatus(String docId, bool currentStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('expenses')
          .doc(docId)
          .update({'isPaid': !currentStatus});
    } catch (e) {
      print('Erro ao atualizar status de pagamento: $e');
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
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
}