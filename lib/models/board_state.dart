import 'package:freezed_annotation/freezed_annotation.dart';

part 'board_state.freezed.dart';
part 'board_state.g.dart';

/// Represents the state of a Go board
@freezed
class BoardState with _$BoardState {
  const factory BoardState({
    /// Board size (9, 13, or 19)
    required int boardSize,
    /// 2D grid of stones: 0=empty, 1=black, 2=white
    required List<List<int>> stones,
    /// Number of captured black stones
    required int capturedBlack,
    /// Number of captured white stones
    required int capturedWhite,
    /// Whether it's black's turn
    required bool isBlackTurn,
    /// Last move position (row)
    int? lastMoveRow,
    /// Last move position (col)
    int? lastMoveCol,
  }) = _BoardState;

  factory BoardState.fromJson(Map<String, dynamic> json) =>
      _$BoardStateFromJson(json);

  /// Create an empty board
  factory BoardState.empty({int size = 9}) {
    return BoardState(
      boardSize: size,
      stones: List.generate(size, (_) => List.filled(size, 0)),
      capturedBlack: 0,
      capturedWhite: 0,
      isBlackTurn: true,
    );
  }
}
