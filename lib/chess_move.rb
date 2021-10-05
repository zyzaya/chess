# frozen_string_literal: true

# Used to move pieces around on a ChessBoard
class ChessMove
  def move_piece(board, rule, origin, dest)
    # origin_piece = board.piece(origin, col: coords[:origin_col], row: coords[:origin_row])
    origin_piece = board.piece(origin)
    raise ArgumentError.new(
      "Expected a valid origin and destination, got #{origin}, #{dest}"
    ) unless rule.valid?(board, origin_piece&.color, origin, dest)
    return if move_castle(board, rule, origin, dest)

    return if move_pawn(board, rule, origin, dest)

    generic_move(board, rule, origin, dest)
  end

  def move_castle(board, rule, origin, dest)
    return false unless
      castling?(board, origin, dest) &&
      can_castle?(board, origin, dest)

    castle(board, rule, origin, dest)
    true
  end

  def castling?(board, origin, dest)
    origin_piece = board.piece(origin)
    return false unless origin_piece.instance_of?(King)

    rel_col = dest.col - origin.col
    rel_row = dest.row - origin.row
    rel_row.zero? && [-3, 2].include?(rel_col)
  end

  def can_castle?(board, origin, dest)
    return false unless castling?(board, origin, dest)

    king = board.piece(origin)
    rook_cell = find_castling_rook(board, origin, dest)
    return false if king.moved || board.piece(rook_cell).moved

    !castle_obstructed?(board, origin, rook_cell) &&
      !castle_in_check?(board, king, rook_cell)
    # king (origin) has not moved
    # rook (find_castling_rook(origin, dest)) has not moved
    # origin -> rook is not obstructed
    # none of the pieces from origin to dest are in check
  end

  def find_castling_rook(board, origin, dest)
  end

  def castle_obstructed?(board, king, rook)
  end

  def castle_in_check?(board, king, rook)
  end

  def castle(board, rule, origin, dest)
  end

  def move_pawn(board, rule, origin, dest)
  end

  def generic_move(board, rule, origin, dest)
  end
end
