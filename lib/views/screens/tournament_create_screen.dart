import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/viewmodels/index.dart';

final _logger = Logger();

/// トーナメント作成画面
class TournamentCreateScreen extends ConsumerStatefulWidget {
  const TournamentCreateScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TournamentCreateScreen> createState() => _TournamentCreateScreenState();
}

class _TournamentCreateScreenState extends ConsumerState<TournamentCreateScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _maxParticipants = 8;
  int _boardSize = 19;
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime _endDate = DateTime.now().add(const Duration(days: 8));
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('トーナメントを作成'),
        backgroundColor: Colors.grey[900],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('大会名'),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('例: 週末杯'),
            ),
            const SizedBox(height: 16),
            _buildLabel('説明'),
            TextField(
              controller: _descriptionController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: _inputDecoration('大会の説明を入力'),
            ),
            const SizedBox(height: 16),
            _buildLabel('碁盤サイズ'),
            _buildChipRow(
              options: const [9, 13, 19],
              selected: _boardSize,
              labelBuilder: (v) => '$v路盤',
              onSelected: (v) => setState(() => _boardSize = v),
            ),
            const SizedBox(height: 16),
            _buildLabel('最大参加人数'),
            _buildChipRow(
              options: const [4, 8, 16, 32],
              selected: _maxParticipants,
              labelBuilder: (v) => '$v人',
              onSelected: (v) => setState(() => _maxParticipants = v),
            ),
            const SizedBox(height: 16),
            _buildLabel('形式'),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_tree, color: Colors.amber, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'シングルエリミネーション（トーナメント表形式）',
                      style: TextStyle(color: Colors.grey[300], fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildLabel('開始日'),
            _buildDatePicker(_startDate, (date) => setState(() => _startDate = date)),
            const SizedBox(height: 16),
            _buildLabel('終了日'),
            _buildDatePicker(_endDate, (date) => setState(() => _endDate = date)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[600],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        '大会を作成する',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[600]),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildChipRow({
    required List<int> options,
    required int selected,
    required String Function(int) labelBuilder,
    required ValueChanged<int> onSelected,
  }) {
    return Row(
      children: options.map((value) {
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(labelBuilder(value)),
            selected: selected == value,
            onSelected: (_) => onSelected(value),
            selectedColor: Colors.amber[600],
            backgroundColor: Colors.grey[800],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDatePicker(DateTime date, ValueChanged<DateTime> onPicked) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) onPicked(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.grey, size: 16),
            const SizedBox(width: 8),
            Text(
              '${date.year}/${date.month}/${date.day}',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('大会名を入力してください')),
      );
      return;
    }
    if (_endDate.isBefore(_startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('終了日は開始日より後にしてください')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final tournament = await ref.read(createTournamentProvider)(
        name: name,
        description: _descriptionController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        maxParticipants: _maxParticipants,
        format: 'single_elimination',
        boardSize: _boardSize,
      );

      if (!mounted) return;
      if (tournament != null) {
        ref.invalidate(activeTournamentsProvider);
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('作成できませんでした')),
        );
      }
    } catch (e) {
      _logger.e('Error creating tournament: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
