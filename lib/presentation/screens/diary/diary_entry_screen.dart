import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/themes/colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/diary_entry.dart';
import '../../blocs/diary/diary_bloc.dart';
import '../../widgets/common/stylish_header.dart';
import '../../widgets/common/modern_dialogs.dart';

class DiaryEntryScreen extends StatefulWidget {
  final DateTime date;
  final DiaryEntry? entry;

  const DiaryEntryScreen({
    super.key,
    required this.date,
    this.entry,
  });

  @override
  State<DiaryEntryScreen> createState() => _DiaryEntryScreenState();
}

class _DiaryEntryScreenState extends State<DiaryEntryScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  String? _selectedMood;
  final List<String> _tags = [];
  final TextEditingController _tagController = TextEditingController();

  final List<String> _moods = ['😊', '😐', '😟', '😢', '😡', '🤑', '😴'];

  bool get isEditing => widget.entry != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry?.title ?? '');
    _contentController =
        TextEditingController(text: widget.entry?.content ?? '');
    _selectedMood = widget.entry?.mood;
    if (widget.entry?.tags != null) {
      _tags.addAll(widget.entry!.tags);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<DiaryBloc, DiaryState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          context.pop();
        }
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            StylishHeader(
              title: isEditing ? 'Edit Catatan' : 'Tambah Catatan',
              subtitle: DateFormat('EEEE, d MMMM yyyy').format(widget.date),
              showBackArrow: true,
              actions: [
                if (isEditing)
                  IconButton(
                    onPressed: _confirmDelete,
                    icon: const Icon(Icons.delete_outline, color: AppColors.expense),
                  ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Daily cashflow summary (readonly)
                    _buildCashflowSummary(context, isDark),
                    const SizedBox(height: 24),
                    // Mood selector
                    _buildMoodSelector(isDark),
                    const SizedBox(height: 24),
                    // Title
                    _buildTitleField(isDark),
                    const SizedBox(height: 16),
                    // Content
                    _buildContentField(isDark),
                    const SizedBox(height: 24),
                    // Tags
                    _buildTagsSection(isDark),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomBar(context, isDark),
      ),
    );
  }

  Widget _buildCashflowSummary(BuildContext context, bool isDark) {
    final state = context.watch<DiaryBloc>().state;
    final dateKey =
        '${widget.date.year}-${widget.date.month.toString().padLeft(2, '0')}-${widget.date.day.toString().padLeft(2, '0')}';
    final cashflow = state.dailyCashflows.firstWhere(
      (c) => c.dateKey == dateKey,
      orElse: () => DailyCashflow(date: widget.date, income: 0, expense: 0),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Hari Ini',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                  icon: Icons.arrow_downward,
                  label: 'Masuk',
                  amount: cashflow.income,
                  color: AppColors.income,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMiniStat(
                  icon: Icons.arrow_upward,
                  label: 'Keluar',
                  amount: cashflow.expense,
                  color: AppColors.expense,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMiniStat(
                  icon: cashflow.net >= 0 ? Icons.trending_up : Icons.trending_down,
                  label: 'Selisih',
                  amount: cashflow.net,
                  color: cashflow.net >= 0 ? AppColors.income : AppColors.expense,
                  isDark: isDark,
                  showSign: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required IconData icon,
    required String label,
    required double amount,
    required Color color,
    required bool isDark,
    bool showSign = false,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${showSign && amount > 0 ? '+' : ''}${CurrencyFormatter.formatCompact(amount)}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildMoodSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bagaimana perasaanmu hari ini?',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: _moods.map((mood) {
            final isSelected = _selectedMood == mood;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedMood = isSelected ? null : mood;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withAlpha(26)
                      : (isDark ? AppColors.surfaceDark : AppColors.surface),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? AppColors.borderDark : AppColors.border),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  mood,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTitleField(bool isDark) {
    return TextField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Judul (opsional)',
        hintText: 'Berikan judul singkat...',
        filled: true,
        fillColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
      ),
      textCapitalization: TextCapitalization.sentences,
    );
  }

  Widget _buildContentField(bool isDark) {
    return TextField(
      controller: _contentController,
      decoration: InputDecoration(
        labelText: 'Catatan',
        hintText: 'Tulis catatan keuanganmu hari ini...',
        alignLabelWithHint: true,
        filled: true,
        fillColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
      ),
      maxLines: 6,
      textCapitalization: TextCapitalization.sentences,
    );
  }

  Widget _buildTagsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags (opsional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._tags.map((tag) => Chip(
                  label: Text('#$tag'),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () {
                    setState(() {
                      _tags.remove(tag);
                    });
                  },
                )),
            if (_tags.length < 5)
              ActionChip(
                avatar: const Icon(Icons.add, size: 16),
                label: const Text('Tambah'),
                onPressed: () => _showAddTagDialog(isDark),
              ),
          ],
        ),
      ],
    );
  }

  void _showAddTagDialog(bool isDark) {
    _tagController.clear();
    showAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Tag'),
        content: TextField(
          controller: _tagController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nama tag...',
            prefixText: '# ',
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              final tag = _tagController.text.trim();
              if (tag.isNotEmpty && !_tags.contains(tag)) {
                setState(() {
                  _tags.add(tag);
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
      ),
      child: BlocBuilder<DiaryBloc, DiaryState>(
        builder: (context, state) {
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: state.isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(isEditing ? 'Simpan Perubahan' : 'Simpan Catatan'),
            ),
          );
        },
      ),
    );
  }

  void _save() {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Catatan tidak boleh kosong')),
      );
      return;
    }

    if (isEditing) {
      final updated = widget.entry!.copyWith(
        title: _titleController.text.trim(),
        content: content,
        mood: _selectedMood,
        tags: _tags,
        updatedAt: DateTime.now(),
      );
      context.read<DiaryBloc>().add(UpdateDiaryEntry(updated));
    } else {
      context.read<DiaryBloc>().add(CreateDiaryEntry(
            date: widget.date,
            title: _titleController.text.trim(),
            content: content,
            mood: _selectedMood,
            tags: _tags,
          ));
    }
  }

  void _confirmDelete() {
    showAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Catatan?'),
        content: const Text('Catatan ini akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<DiaryBloc>().add(DeleteDiaryEntry(widget.entry!.id));
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
