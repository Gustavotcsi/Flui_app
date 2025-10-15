import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flui_app/app/core/theme/app_theme.dart';
import 'package:flui_app/app/features/goals/data/datasources/goal_datasource.dart';
import 'package:flui_app/app/features/goals/data/datasources/goal_datasource_impl.dart';
import 'package:flui_app/app/features/goals/data/repositories/goal_repository_impl.dart';
import 'package:flui_app/app/features/goals/domain/repositories/goal_repository.dart';
import 'package:flui_app/app/features/goals/domain/usecases/add_goal.dart';
import 'package:flui_app/app/features/goals/domain/usecases/delete_goal.dart';
import 'package:flui_app/app/features/goals/domain/usecases/get_goals.dart';
import 'package:flui_app/app/features/goals/domain/usecases/update_goal.dart';
import 'package:flui_app/app/features/goals/presentation/controllers/goals_controller.dart';
import 'package:flui_app/app/presentation/screens/auth/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('pt_BR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirebaseFirestore>(create: (_) => FirebaseFirestore.instance),
        Provider<GoalDatasource>(
          create: (context) =>
              GoalDatasourceImpl(firestore: context.read<FirebaseFirestore>()),
        ),
        Provider<GoalRepository>(
          create: (context) =>
              GoalRepositoryImpl(datasource: context.read<GoalDatasource>()),
        ),
        Provider<AddGoal>(
          create: (context) => AddGoal(context.read<GoalRepository>()),
        ),
        Provider<GetGoals>(
          create: (context) => GetGoals(context.read<GoalRepository>()),
        ),
        Provider<UpdateGoal>(
          create: (context) => UpdateGoal(context.read<GoalRepository>()),
        ),
        Provider<DeleteGoal>(
          create: (context) => DeleteGoal(context.read<GoalRepository>()),
        ),
        ChangeNotifierProvider<GoalsController>(
          create: (context) => GoalsController(
            addGoalUseCase: context.read<AddGoal>(),
            getGoalsUseCase: context.read<GetGoals>(),
            updateGoalUseCase: context.read<UpdateGoal>(),
            deleteGoalUseCase: context.read<DeleteGoal>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Flui',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.mainTheme,
        home: const OnboardingScreen(),
      ),
    );
  }
}
