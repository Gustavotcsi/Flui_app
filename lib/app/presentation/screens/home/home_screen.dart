// lib/app/presentation/screens/home/home_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flui_app/app/presentation/screens/home/edit_expense_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:pie_chart/pie_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final user = FirebaseAuth.instance.currentUser;
  DateTime _selectedDate = DateTime.now();
  late TabController _tabController;
  String? _selectedFilterCategory;
  bool? _selectedFilterIsPaid;
  DateTimeRange? _selectedFilterDateRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _selectMonth(BuildContext context) {
    showMonthPicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    ).then((date) {
      if (date != null) {
        setState(() {
          _selectedDate = date;
        });
      }
    });
  }

  void showPaymentSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        });

        return Dialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/animations/payment_success.json',
                  repeat: false,
                  width: 150,
                  height: 150,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Pagamento Realizado!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnalysisTab(List<DocumentSnapshot> docs) {
    if (docs.isEmpty) {
      return const Center(
          child: Text("Nenhuma despesa para analisar neste mês."));
    }

    Map<String, double> dataMap = {};
    for (var doc in docs) {
      var data = doc.data() as Map<String, dynamic>;
      String category = data['category'];
      double amount = data['amount'];
      dataMap[category] = (dataMap[category] ?? 0) + amount;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Distribuição de Gastos por Categoria',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          PieChart(
            dataMap: dataMap,
            animationDuration: const Duration(milliseconds: 800),
            chartLegendSpacing: 32,
            chartRadius: MediaQuery.of(context).size.width / 2.5,
            initialAngleInDegree: 0,
            chartType: ChartType.ring,
            ringStrokeWidth: 32,
            centerText: "Gastos",
            legendOptions: const LegendOptions(
              showLegendsInRow: false,
              legendPosition: LegendPosition.right,
              showLegends: true,
              legendTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            chartValuesOptions: const ChartValuesOptions(
              showChartValueBackground: true,
              showChartValues: true,
              showChartValuesInPercentage: true,
              showChartValuesOutside: false,
              decimalPlaces: 1,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteExpense(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('expenses')
          .doc(docId)
          .delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Despesa apagada!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Em vez de print, use um logger ou remova
    }
  }

  Future<void> _togglePaidStatus(String docId, bool currentStatus) async {
    try {
      if (!currentStatus) {
        // Marcar como paga e registrar a data de pagamento
        await FirebaseFirestore.instance
            .collection('expenses')
            .doc(docId)
            .update({'isPaid': true, 'paidAt': Timestamp.now()});
        if (mounted) {
          showPaymentSuccessDialog(context);
        }
      } else {
        // Desfazer pagamento (marcar como não paga e remover a data de pagamento)
        await FirebaseFirestore.instance
            .collection('expenses')
            .doc(docId)
            .update({'isPaid': false, 'paidAt': null});
      }
    } catch (e) {
      // Em vez de print, use um logger ou remova
    }
  }

  void showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Wrap(
                runSpacing: 16,
                children: [
                  const Text(
                    'Filtrar Despesas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedFilterCategory,
                    decoration: const InputDecoration(labelText: 'Categoria'),
                    items:
                        [
                              'Moradia',
                              'Alimentação',
                              'Transporte',
                              'Saúde',
                              'Lazer',
                              'Educação',
                              'Outros',
                            ]
                            .map(
                              (cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              ),
                            )
                            .toList(),
                    onChanged: (value) =>
                        setModalState(() => _selectedFilterCategory = value),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Status",
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  SegmentedButton<bool?>(
                    segments: const [
                      ButtonSegment(value: null, label: Text('Todas')),
                      ButtonSegment(value: true, label: Text('Pagas')),
                      ButtonSegment(value: false, label: Text('Não Pagas')),
                    ],
                    selected: {_selectedFilterIsPaid},
                    onSelectionChanged: (selection) => setModalState(
                      () => _selectedFilterIsPaid = selection.first,
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      _selectedFilterDateRange == null
                          ? 'Filtrar por Período'
                          : '${DateFormat('dd/MM/yy').format(_selectedFilterDateRange!.start)} - ${DateFormat('dd/MM/yy').format(_selectedFilterDateRange!.end)}',
                    ),
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
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildExpenseList(List<DocumentSnapshot> docs) {
    if (docs.isEmpty) {
      return const Center(child: Text("Nenhuma despesa para exibir."));
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
        bool isOverdue =
            dueDate.isBefore(DateTime(now.year, now.month, now.day)) && !isPaid;

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
              decoration: isPaid
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
          subtitle: Text(
            '${expenseData['category']} - Vence em: $formattedDate',
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'R\$ ${expenseData['amount'].toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            EditExpenseScreen(documentId: expenseDoc.id),
                      ),
                    );
                  } else if (value == 'delete') {
                    _deleteExpense(expenseDoc.id);
                  } else if (value == 'pay') {
                    _togglePaidStatus(expenseDoc.id, isPaid);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'pay',
                    child: Row(
                      children: [
                        Icon(isPaid ? Icons.undo : Icons.check, size: 20),
                        const SizedBox(width: 8),
                        Text(isPaid ? 'Desfazer Pag.' : 'Pagar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20),
                        SizedBox(width: 8),
                        Text('Excluir'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDashboard(double totalUnpaid, double totalPaidThisMonth) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                const Text(
                  'Total Pendente',
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
                const SizedBox(height: 8),
                Text(
                  'R\$ ${totalUnpaid.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                const Text(
                  'Pago este Mês',
                  style: TextStyle(fontSize: 16, color: Colors.green),
                ),
                const SizedBox(height: 8),
                Text(
                  'R\$ ${totalPaidThisMonth.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
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
          return Scaffold(
            appBar: AppBar(
              title: const Text('Minhas Despesas'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectMonth(context),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: showFilterSheet,
                ),
              ],
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/capi-inicio.png', height: 120),
                  const SizedBox(height: 16),
                  const Text(
                    'Nenhuma despesa adicionada!',
                    style: TextStyle(fontSize: 18),
                  ),
                  const Text('Clique no botão + para começar.'),
                ],
              ),
            ),
          );
        }

        // Filtro por mês selecionado
        var monthDocs = allDocs.where((d) {
          DateTime dueDate =
              ((d.data() as Map)['dueDate'] as Timestamp).toDate();
          return dueDate.year == _selectedDate.year &&
              dueDate.month == _selectedDate.month;
        }).toList();

        var filteredDocs = monthDocs;
        if (_selectedFilterCategory != null) {
          filteredDocs = filteredDocs
              .where(
                (d) => (d.data() as Map)['category'] == _selectedFilterCategory,
              )
              .toList();
        }
        if (_selectedFilterIsPaid != null) {
          filteredDocs = filteredDocs
              .where(
                (d) => (d.data() as Map)['isPaid'] == _selectedFilterIsPaid,
              )
              .toList();
        }
        if (_selectedFilterDateRange != null) {
          filteredDocs = filteredDocs.where((d) {
            DateTime dueDate = ((d.data() as Map)['dueDate'] as Timestamp)
                .toDate();
            return dueDate.isAfter(
                  _selectedFilterDateRange!.start.subtract(
                    const Duration(days: 1),
                  ),
                ) &&
                dueDate.isBefore(
                  _selectedFilterDateRange!.end.add(const Duration(days: 1)),
                );
          }).toList();
        }

        final unpaidExpenses = filteredDocs
            .where((doc) => !(doc.data() as Map)['isPaid'])
            .toList();
        final paidExpenses = filteredDocs
            .where((doc) => (doc.data() as Map)['isPaid'])
            .toList();

        unpaidExpenses.sort(
          (a, b) => ((a.data() as Map)['dueDate'] as Timestamp).compareTo(
            (b.data() as Map)['dueDate'],
          ),
        );
        paidExpenses.sort(
          (a, b) => ((b.data() as Map)['dueDate'] as Timestamp).compareTo(
            (a.data() as Map)['dueDate'],
          ),
        );

        double totalUnpaid = unpaidExpenses.fold(
          0.0,
          (previousValue, doc) => previousValue + (doc.data() as Map)['amount'],
        );

        final startOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
        double totalPaidThisMonth = paidExpenses
            .where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final paidDate = data['paidAt'] != null
                  ? (data['paidAt'] as Timestamp).toDate()
                  : (data['dueDate'] as Timestamp).toDate();

              return paidDate.isAfter(startOfMonth) ||
                  paidDate.isAtSameMomentAs(startOfMonth);
            })
            .fold(
                0.0,
                (previousValue, doc) =>
                    previousValue + (doc.data() as Map)['amount']);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mês: ${DateFormat.yMMMM('pt_BR').format(_selectedDate)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectMonth(context),
                      ),
                      IconButton(
                        icon: const Icon(Icons.filter_list),
                        onPressed: showFilterSheet,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _buildDashboard(totalUnpaid, totalPaidThisMonth),
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: 'Pendentes (${unpaidExpenses.length})'),
                Tab(text: 'Pagas (${paidExpenses.length})'),
                const Tab(text: 'Análise'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildExpenseList(unpaidExpenses),
                  _buildExpenseList(paidExpenses),
                  _buildAnalysisTab(monthDocs),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
