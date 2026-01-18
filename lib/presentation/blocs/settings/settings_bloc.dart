import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/datasources/local/database_service.dart';
import '../../../data/services/notification_service.dart';

// Events
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {}

class TestNotification extends SettingsEvent {}

class ToggleDarkMode extends SettingsEvent {
  final bool isDarkMode;
  const ToggleDarkMode(this.isDarkMode);

  @override
  List<Object?> get props => [isDarkMode];
}

class ChangeCurrency extends SettingsEvent {
  final String currencyCode;
  const ChangeCurrency(this.currencyCode);

  @override
  List<Object?> get props => [currencyCode];
}

class ToggleReminder extends SettingsEvent {
  final bool isEnabled;
  const ToggleReminder(this.isEnabled);

  @override
  List<Object?> get props => [isEnabled];
}

class SetReminderTime extends SettingsEvent {
  final TimeOfDay time;
  const SetReminderTime(this.time);

  @override
  List<Object?> get props => [time];
}

// State
class SettingsState extends Equatable {
  final bool isDarkMode;
  final String currencyCode;
  final String currencySymbol;
  final bool reminderEnabled;
  final TimeOfDay reminderTime;
  final bool isLoading;

  const SettingsState({
    this.isDarkMode = false,
    this.currencyCode = 'IDR',
    this.currencySymbol = 'Rp',
    this.reminderEnabled = false,
    this.reminderTime = const TimeOfDay(hour: 20, minute: 0),
    this.isLoading = false,
  });

  SettingsState copyWith({
    bool? isDarkMode,
    String? currencyCode,
    String? currencySymbol,
    bool? reminderEnabled,
    TimeOfDay? reminderTime,
    bool? isLoading,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
        isDarkMode,
        currencyCode,
        currencySymbol,
        reminderEnabled,
        reminderTime,
        isLoading
      ];
}

// BLoC
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final DatabaseService _databaseService;
  final NotificationService _notificationService;

  static const Map<String, String> currencies = {
    'IDR': 'Rp',
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'SGD': 'S\$',
    'MYR': 'RM',
  };

  SettingsBloc({
    required DatabaseService databaseService,
    required NotificationService notificationService,
  })  : _databaseService = databaseService,
        _notificationService = notificationService,
        super(const SettingsState()) {
    on<LoadSettings>(_onLoadSettings);
    on<ToggleDarkMode>(_onToggleDarkMode);
    on<ChangeCurrency>(_onChangeCurrency);
    on<ToggleReminder>(_onToggleReminder);
    on<SetReminderTime>(_onSetReminderTime);
    on<TestNotification>(_onTestNotification);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final isDarkMode = _databaseService.getSetting<bool>('isDarkMode') ?? false;
    final currencyCode =
        _databaseService.getSetting<String>('currencyCode') ?? 'IDR';
    final currencySymbol = currencies[currencyCode] ?? 'Rp';

    final reminderEnabled =
        _databaseService.getSetting<bool>('reminderEnabled') ?? false;
    final reminderHour = _databaseService.getSetting<int>('reminderHour') ?? 20;
    final reminderMinute =
        _databaseService.getSetting<int>('reminderMinute') ?? 0;

    emit(state.copyWith(
      isLoading: false,
      isDarkMode: isDarkMode,
      currencyCode: currencyCode,
      currencySymbol: currencySymbol,
      reminderEnabled: reminderEnabled,
      reminderTime: TimeOfDay(hour: reminderHour, minute: reminderMinute),
    ));

    // Check permission status on load if enabled
    if (reminderEnabled) {
      final hasPermission = await _notificationService.requestPermissions();
      if (!hasPermission) {
        // If permission revoked, disable reminder
        add(const ToggleReminder(false));
      }
    }
  }

  Future<void> _onToggleDarkMode(
    ToggleDarkMode event,
    Emitter<SettingsState> emit,
  ) async {
    await _databaseService.saveSetting('isDarkMode', event.isDarkMode);
    emit(state.copyWith(isDarkMode: event.isDarkMode));
  }

  Future<void> _onChangeCurrency(
    ChangeCurrency event,
    Emitter<SettingsState> emit,
  ) async {
    await _databaseService.saveSetting('currencyCode', event.currencyCode);
    final currencySymbol = currencies[event.currencyCode] ?? 'Rp';
    emit(state.copyWith(
      currencyCode: event.currencyCode,
      currencySymbol: currencySymbol,
    ));
  }

  Future<void> _onToggleReminder(
    ToggleReminder event,
    Emitter<SettingsState> emit,
  ) async {
    if (event.isEnabled) {
      final granted = await _notificationService.requestPermissions();
      if (!granted) {
        // Permission denied
        return;
      }
      await _notificationService.scheduleDailyReminder(
        id: 1,
        title: 'Jangan Lupa Catat Keuanganmu! 📝',
        body: 'Sudahkah kamu mencatat pengeluaran hari ini? Yuk cek sekarang!',
        time: state.reminderTime,
      );
    } else {
      await _notificationService.cancelAllNotifications();
    }

    await _databaseService.saveSetting('reminderEnabled', event.isEnabled);
    emit(state.copyWith(reminderEnabled: event.isEnabled));
  }

  Future<void> _onSetReminderTime(
    SetReminderTime event,
    Emitter<SettingsState> emit,
  ) async {
    await _databaseService.saveSetting('reminderHour', event.time.hour);
    await _databaseService.saveSetting('reminderMinute', event.time.minute);

    if (state.reminderEnabled) {
      await _notificationService.scheduleDailyReminder(
        id: 1,
        title: 'Jangan Lupa Catat Keuanganmu! 📝',
        body: 'Sudahkah kamu mencatat pengeluaran hari ini? Yuk cek sekarang!',
        time: event.time,
      );
    }

    emit(state.copyWith(reminderTime: event.time));
  }

  Future<void> _onTestNotification(
    TestNotification event,
    Emitter<SettingsState> emit,
  ) async {
    final granted = await _notificationService.requestPermissions();
    if (granted) {
      await _notificationService.showInstantNotification(
        id: 999,
        title: 'Test Notification 🔔',
        body: 'This is a test notification to verify the system is working!',
      );
    }
  }
}
