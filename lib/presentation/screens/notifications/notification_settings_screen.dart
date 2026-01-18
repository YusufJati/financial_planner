import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/settings/settings_bloc.dart';
import '../../../app/themes/colors.dart';
import '../../widgets/common/modern_dialogs.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Daily Reminders'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Hero Image / Illustration
              Center(
                child: Container(
                  height: 180,
                  width: 180,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_active_outlined,
                    size: 80,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const Text(
                'Stay on Track',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Get daily reminders to log your expenses and income so you never lose track of your finances.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Toggle Switch Card
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SwitchListTile(
                  value: state.reminderEnabled,
                  onChanged: (value) {
                    context.read<SettingsBloc>().add(ToggleReminder(value));
                    if (value) {
                      showSuccessDialog(
                        context: context,
                        title: 'Reminders Encended! 🔔',
                        message: 'Kami akan mengingatkanmu setiap hari.',
                        buttonText: 'OK',
                      );
                    }
                  },
                  title: const Text(
                    'Daily Reminders',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Receive a notification every day'),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: state.reminderEnabled
                          ? Colors.green.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.notifications,
                      color: state.reminderEnabled ? Colors.green : Colors.grey,
                    ),
                  ),
                  activeThumbColor: AppColors.primary,
                ),
              ),

              const SizedBox(height: 16),

              // Time Picker Card
              AnimatedOpacity(
                opacity: state.reminderEnabled ? 1.0 : 0.5,
                duration: const Duration(milliseconds: 300),
                child: IgnorePointer(
                  ignoring: !state.reminderEnabled,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: state.reminderTime,
                        );
                        if (picked != null && context.mounted) {
                          context
                              .read<SettingsBloc>()
                              .add(SetReminderTime(picked));
                        }
                      },
                      title: const Text(
                        'Reminder Time',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text('When do you want to be reminded?'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          state.reminderTime.format(context),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.access_time_filled,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Test Notification Button
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  onTap: () {
                    context.read<SettingsBloc>().add(TestNotification());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Testing notification...'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.notification_important_rounded,
                      color: Colors.orange,
                    ),
                  ),
                  title: const Text(
                    'Test Notification',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Try sending a notification now'),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey),
                ),
              ),

              const SizedBox(height: 24),
              if (state.reminderEnabled)
                Center(
                  child: Text(
                    'Next reminder at ${state.reminderTime.format(context)}',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
