import 'dart:ffi' as ffi;
import 'dart:io' show Platform;
import 'package:ffi/ffi.dart';

// Fuego C++ エンジンへの FFI バインディング
// Fuego は軽量 Go エンジン (9x9 最適化)

typedef NativeInitFuego = ffi.Int32 Function();
typedef DartInitFuego = int Function();

typedef NativeGetMove = ffi.Int32 Function(
  ffi.Pointer<ffi.Int32> boardState,
  ffi.Int32 boardSize,
  ffi.Int32 aiLevel,
);
typedef DartGetMove = int Function(
  ffi.Pointer<ffi.Int32> boardState,
  int boardSize,
  int aiLevel,
);

typedef NativeGetMoveCoord = ffi.Void Function(
  ffi.Int32 moveId,
  ffi.Pointer<ffi.Int32> row,
  ffi.Pointer<ffi.Int32> col,
);
typedef DartGetMoveCoord = void Function(
  int moveId,
  ffi.Pointer<ffi.Int32> row,
  ffi.Pointer<ffi.Int32> col,
);

typedef NativeCleanup = ffi.Void Function();
typedef DartCleanup = void Function();

/// Fuego Go エンジン FFI ラッパー
class FuegoNative {
  late ffi.DynamicLibrary _lib;
  late DartInitFuego _initFuego;
  late DartGetMove _getMove;
  late DartGetMoveCoord _getMoveCoord;
  late DartCleanup _cleanup;

  FuegoNative() {
    _loadLibrary();
  }

  void _loadLibrary() {
    try {
      if (Platform.isAndroid) {
        _lib = ffi.DynamicLibrary.open('libfuego.so');
      } else if (Platform.isIOS) {
        _lib = ffi.DynamicLibrary.process();
      } else {
        throw UnsupportedError('Fuego is not supported on ${Platform.operatingSystem}');
      }

      _initFuego = _lib.lookupFunction<NativeInitFuego, DartInitFuego>('fuego_init');
      _getMove = _lib.lookupFunction<NativeGetMove, DartGetMove>('fuego_get_move');
      _getMoveCoord = _lib.lookupFunction<NativeGetMoveCoord, DartGetMoveCoord>('fuego_get_move_coord');
      _cleanup = _lib.lookupFunction<NativeCleanup, DartCleanup>('fuego_cleanup');
    } on Exception catch (e) {
      throw Exception('Failed to load Fuego library: $e');
    }
  }

  /// Fuego エンジンを初期化
  int initialize() {
    return _initFuego();
  }

  /// AI の手を取得
  /// boardState: 1D 配列 (row-major order)
  /// boardSize: ボードサイズ (9, 13, 19)
  /// aiLevel: AI レベル (1-10)
  /// 戻り値: move ID
  int getMove(List<int> boardState, int boardSize, int aiLevel) {
    final nativeBoard = malloc<ffi.Int32>(boardState.length);
    for (int i = 0; i < boardState.length; i++) {
      nativeBoard[i] = boardState[i];
    }

    try {
      return _getMove(nativeBoard, boardSize, aiLevel);
    } finally {
      malloc.free(nativeBoard);
    }
  }

  /// Move ID から座標を取得
  /// moveId: getMove() の戻り値
  /// 戻り値: (row, col)
  (int, int) getMoveCoords(int moveId) {
    final row = malloc<ffi.Int32>();
    final col = malloc<ffi.Int32>();

    try {
      _getMoveCoord(moveId, row, col);
      return (row.value, col.value);
    } finally {
      malloc.free(row);
      malloc.free(col);
    }
  }

  /// エンジンをクリーンアップ
  void cleanup() {
    _cleanup();
  }

  /// エンジンを破棄
  void dispose() {
    cleanup();
  }
}
