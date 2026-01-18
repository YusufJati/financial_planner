import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/goal.dart';
import '../../../domain/repositories/goal_repository.dart';
import '../../../data/datasources/local/database_service.dart';

// Events
abstract class GoalEvent extends Equatable {
  const GoalEvent();

  @override
  List<Object?> get props => [];
}

class LoadGoals extends GoalEvent {}

class RefreshGoals extends GoalEvent {}

class CreateGoal extends GoalEvent {
  final String name;
  final String? description;
  final double targetAmount;
  final DateTime? targetDate;
  final String icon;
  final String color;

  const CreateGoal({
    required this.name,
    this.description,
    required this.targetAmount,
    this.targetDate,
    this.icon = 'target',
    this.color = '#2563EB',
  });

  @override
  List<Object?> get props =>
      [name, description, targetAmount, targetDate, icon, color];
}

class UpdateGoal extends GoalEvent {
  final Goal goal;

  const UpdateGoal(this.goal);

  @override
  List<Object?> get props => [goal];
}

class DeleteGoal extends GoalEvent {
  final String id;

  const DeleteGoal(this.id);

  @override
  List<Object?> get props => [id];
}

class DepositToGoal extends GoalEvent {
  final String goalId;
  final double amount;

  const DepositToGoal({required this.goalId, required this.amount});

  @override
  List<Object?> get props => [goalId, amount];
}

class WithdrawFromGoal extends GoalEvent {
  final String goalId;
  final double amount;

  const WithdrawFromGoal({required this.goalId, required this.amount});

  @override
  List<Object?> get props => [goalId, amount];
}

// State
class GoalState extends Equatable {
  final bool isLoading;
  final String? error;
  final List<Goal> activeGoals;
  final List<Goal> completedGoals;
  final double totalSavings;
  final Goal? selectedGoal;

  const GoalState({
    this.isLoading = false,
    this.error,
    this.activeGoals = const [],
    this.completedGoals = const [],
    this.totalSavings = 0,
    this.selectedGoal,
  });

  double get totalTarget {
    double total = 0;
    for (final goal in activeGoals) {
      total += goal.targetAmount;
    }
    return total;
  }

  double get overallProgress =>
      totalTarget > 0 ? totalSavings / totalTarget : 0;

  GoalState copyWith({
    bool? isLoading,
    String? error,
    List<Goal>? activeGoals,
    List<Goal>? completedGoals,
    double? totalSavings,
    Goal? selectedGoal,
  }) {
    return GoalState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      activeGoals: activeGoals ?? this.activeGoals,
      completedGoals: completedGoals ?? this.completedGoals,
      totalSavings: totalSavings ?? this.totalSavings,
      selectedGoal: selectedGoal ?? this.selectedGoal,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        error,
        activeGoals,
        completedGoals,
        totalSavings,
        selectedGoal,
      ];
}

// BLoC
class GoalBloc extends Bloc<GoalEvent, GoalState> {
  final GoalRepository _goalRepository;
  final DatabaseService _databaseService;

  GoalBloc({
    required GoalRepository goalRepository,
    required DatabaseService databaseService,
  })  : _goalRepository = goalRepository,
        _databaseService = databaseService,
        super(const GoalState()) {
    on<LoadGoals>(_onLoadGoals);
    on<RefreshGoals>(_onRefreshGoals);
    on<CreateGoal>(_onCreateGoal);
    on<UpdateGoal>(_onUpdateGoal);
    on<DeleteGoal>(_onDeleteGoal);
    on<DepositToGoal>(_onDepositToGoal);
    on<WithdrawFromGoal>(_onWithdrawFromGoal);
  }

  Future<void> _onLoadGoals(
    LoadGoals event,
    Emitter<GoalState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      await _loadData(emit);
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onRefreshGoals(
    RefreshGoals event,
    Emitter<GoalState> emit,
  ) async {
    try {
      await _loadData(emit);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _loadData(Emitter<GoalState> emit) async {
    final results = await Future.wait([
      _goalRepository.getActiveGoals(),
      _goalRepository.getCompletedGoals(),
      _goalRepository.getTotalSavings(),
    ]);

    emit(state.copyWith(
      isLoading: false,
      activeGoals: results[0] as List<Goal>,
      completedGoals: results[1] as List<Goal>,
      totalSavings: results[2] as double,
    ));
  }

  Future<void> _onCreateGoal(
    CreateGoal event,
    Emitter<GoalState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final now = DateTime.now();
      final goal = Goal(
        id: _databaseService.generateId(),
        name: event.name,
        description: event.description,
        targetAmount: event.targetAmount,
        targetDate: event.targetDate,
        icon: event.icon,
        color: event.color,
        createdAt: now,
        updatedAt: now,
      );

      await _goalRepository.createGoal(goal);
      await _loadData(emit);
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onUpdateGoal(
    UpdateGoal event,
    Emitter<GoalState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      await _goalRepository.updateGoal(event.goal.copyWith(
        updatedAt: DateTime.now(),
      ));
      await _loadData(emit);
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onDeleteGoal(
    DeleteGoal event,
    Emitter<GoalState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      await _goalRepository.deleteGoal(event.id);
      await _loadData(emit);
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onDepositToGoal(
    DepositToGoal event,
    Emitter<GoalState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      await _goalRepository.deposit(event.goalId, event.amount);
      await _loadData(emit);
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onWithdrawFromGoal(
    WithdrawFromGoal event,
    Emitter<GoalState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      await _goalRepository.withdraw(event.goalId, event.amount);
      await _loadData(emit);
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
