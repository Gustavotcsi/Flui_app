class Goal {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final String category;

  Goal({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.targetDate,
    required this.category,
  });
}
