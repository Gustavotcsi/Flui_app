import 'package:firebase_auth/firebase_auth.dart';
import 'package:flui_app/app/presentation/screens/auth/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flui_app/app/presentation/screens/home/home_screen.dart';
import 'package:flui_app/app/features/goals/presentation/pages/goals_page.dart';
import 'package:flui_app/app/features/goals/presentation/pages/add_goal_page.dart';
import 'package:flui_app/app/presentation/screens/home/add_expense_screen.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final GlobalKey<HomeScreenState> _homeScreenKey =
      GlobalKey<HomeScreenState>();

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      HomeScreen(key: _homeScreenKey),
      const GoalsPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToAddPage() {
    if (_selectedIndex == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddGoalPage()),
      );
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Minhas Despesas' : 'Minhas Metas'),
        actions: _selectedIndex == 0
            ? [
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () =>
                      _homeScreenKey.currentState?.showFilterSheet(),
                  tooltip: 'Filtrar',
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: _signOut,
                  tooltip: 'Sair',
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: _signOut,
                  tooltip: 'Sair',
                ),
              ],
        automaticallyImplyLeading: false,
      ),
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes),
            label: 'Metas',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddPage,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
