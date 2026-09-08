/// Represents the state of a Go board
class BoardState {
  /// Board size (9, 13, or 19)
  final int boardSize;
  /// 2D grid of stones: 0=empty, 1=black, 2=white
  final List<List<int>> stones;
  /// Number of captured black stones
  final int capturedBlack;
  /// Number of captured white stones
  final int capturedWhite;
  /// Whether it's black's turn
  final bool isBlackTurn;
  /// Last move position (row)
  final int? lastMoveRow;
  /// Last move position (col)
  final int? lastMoveCol;

  const BoardState({
    required this.boardSize,
    required this.stones,
    required this.capturedBlack,
    required this.capturedWhite,
    required this.isBlackTurn,
    this.lastMoveRow,
    this.lastMoveCol,
  });

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

  /// Create a copy with optional overrides
  BoardState copyWith({
    int? boardSize,
    List<List<int>>? stones,
    int? capturedBlack,
    int? capturedWhite,
    bool? isBlackTurn,
    int? lastMoveRow,
    int? lastMoveCol,
  }) {
    return BoardState(
      boardSize: boardSize ?? this.boardSize,
      stones: stones ?? this.stones,
      capturedBlack: capturedBlack ?? this.capturedBlack,
      capturedWhite: capturedWhite ?? this.capturedWhite,
      isBlackTurn: isBlackTurn ?? this.isBlackTurn,
      lastMoveRow: lastMoveRow ?? this.lastMoveRow,
      lastMoveCol: lastMoveCol ?? this.lastMoveCol,
    );
  }
}
