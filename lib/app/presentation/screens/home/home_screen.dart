// lib/app/presentation/screens/home/home_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flui_app/app/presentation/screens/auth/onboarding_screen.dart';
import 'package:flui_app/app/presentation/screens/home/add_expense_screen.dart';
import 'package:flui_app/app/presentation/screens/home/edit_expense_screen.dart'; // <-- NOVO IMPORT
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  // A função para apagar continua a mesma
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Despesas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Sair',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('expenses')
            .where('userId', isEqualTo: user?.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var expenseDoc = snapshot.data!.docs[index];
              var expenseData = expenseDoc.data() as Map<String, dynamic>;
              
              DateTime dueDate = (expenseData['dueDate'] as Timestamp).toDate();
              String formattedDate = DateFormat('dd/MM/yyyy').format(dueDate);

              return ListTile(
                leading: CircleAvatar(child: Text(expenseData['category'][0])),
                title: Text(expenseData['name']),
                subtitle: Text('${expenseData['category']} - Vence em: $formattedDate'),
                // **A MUDANÇA ESTÁ AQUI**
                // Substituímos o Text do valor pelo PopupMenuButton
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      // Navega para a tela de edição, passando o ID do documento
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EditExpenseScreen(documentId: expenseDoc.id),
                        ),
                      );
                    } else if (value == 'delete') {
                      // Chama a função de apagar
                      _deleteExpense(expenseDoc.id);
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
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
              );
            },
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