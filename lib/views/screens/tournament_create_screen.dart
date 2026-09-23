import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/models/tournament.dart';
import 'package:goen/viewmodels/index.dart';
import 'package:goen/config/theme.dart';

final _logger = Logger();

/// トーナメント作成/編集画面。[editing]を渡すと編集モードになり、既存の
/// 大会情報を編集する（形式は編集不可 - 参加者がその形式を見て参加登録
/// しているため。編集はTournamentService.updateTournamentが「開催予定」
/// の間のみ許可する）。
class TournamentCreateScreen extends ConsumerStatefulWidget {
  final Tournament? editing;

  const TournamentCreateScreen({Key? key, this.editing}) : super(key: key);

  @override
  ConsumerState<TournamentCreateScreen> createState() => _TournamentCreateScreenState();
}

class _TournamentCreateScreenState extends ConsumerState<TournamentCreateScreen> {
  late final _nameController =
      TextEditingController(text: widget.editing?.name);
  late final _descriptionController =
      TextEditingController(text: widget.editing?.description);
  late int _maxParticipants = widget.editing?.maxParticipants ?? 8;
  late int _boardSize = widget.editing?.boardSize ?? 19;
  late String _format = widget.editing?.format ?? 'single_elimination';
  late DateTime _startDate =
      widget.editing?.startDate ?? DateTime.now().add(const Duration(days: 1));
  late DateTime _endDate =
      widget.editing?.endDate ?? DateTime.now().add(const Duration(days: 8));
  bool _isSubmitting = false;

  bool get _isEditing => widget.editing != null;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sumi,
      appBar: AppBar(
        title: Text(_isEditing ? '大会を編集' : 'トーナメントを作成'),
        backgroundColor: AppColors.sumiSurface,
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
              style: const TextStyle(color: AppColors.washi),
              decoration: _inputDecoration('例: 週末杯'),
            ),
            const SizedBox(height: 16),
            _buildLabel('説明'),
            TextField(
              controller: _descriptionController,
              style: const TextStyle(color: AppColors.washi),
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
            if (_isEditing)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '形式は作成後に変更できません',
                  style: TextStyle(color: AppColors.washiDim, fontSize: 12),
                ),
              ),
            _buildFormatOption(
              value: 'single_elimination',
              icon: Icons.account_tree,
              title: 'シングルエリミネーション',
              subtitle: '負けたら終わり。勝ち上がり式のトーナメント表。',
            ),
            const SizedBox(height: 8),
            _buildFormatOption(
              value: 'round_robin',
              icon: Icons.repeat,
              title: '総当たり戦',
              subtitle: '参加者全員と1回ずつ対局し、勝ち数が最も多い人が優勝。',
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
                  backgroundColor: AppColors.kin,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _isEditing ? '変更を保存する' : '大会を作成する',
                        style: const TextStyle(color: AppColors.sumi, fontWeight: FontWeight.bold),
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
      child: Text(text, style: const TextStyle(color: AppColors.washi, fontWeight: FontWeight.bold)),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.washiDim),
      filled: true,
      fillColor: AppColors.washi.withOpacity(0.05),
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
            selectedColor: AppColors.kin,
            backgroundColor: AppColors.sumiCard,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFormatOption({
    required String value,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final selected = _format == value;
    return InkWell(
      onTap: _isEditing ? null : () => setState(() => _format = value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? AppColors.kin : Colors.white24,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: selected
              ? AppColors.kin.withOpacity(_isEditing ? 0.05 : 0.1)
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? AppColors.kin : AppColors.washiDim, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppColors.washi, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: AppColors.washiDim, fontSize: 12)),
                ],
              ),
            ),
            if (selected) const Icon(Icons.check_circle, color: AppColors.kin, size: 18),
          ],
        ),
      ),
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
              style: const TextStyle(color: AppColors.washi),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ログインが必要です')),
      );
      return;
    }
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
      if (_isEditing) {
        await ref.read(updateTournamentProvider)(
          tournamentId: widget.editing!.id,
          uid: currentUser.uid,
          name: name,
          description: _descriptionController.text.trim(),
          startDate: _startDate,
          endDate: _endDate,
          maxParticipants: _maxParticipants,
          boardSize: _boardSize,
        );
        if (!mounted) return;
        ref.invalidate(activeTournamentsProvider);
        ref.invalidate(userTournamentsProvider(currentUser.uid));
        Navigator.of(context).pop(true);
        return;
      }

      final tournament = await ref.read(createTournamentProvider)(
        name: name,
        description: _descriptionController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        maxParticipants: _maxParticipants,
        format: _format,
        createdByUid: currentUser.uid,
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
      _logger.e('Error ${_isEditing ? "updating" : "creating"} tournament: $e');
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
