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
    return false unless can_castle?(board, rule, origin, dest)

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

  def can_castle?(board, rule, origin, dest)
    return false unless castling?(board, origin, dest)

    king = board.piece(origin)
    rook_cell = find_castling_rook(dest)
    return false if king.moved || board.piece(rook_cell)&.moved

    !rule.obstructed?(board, origin, rook_cell) &&
      !castle_in_check?(board, king, dest)
  end

  def find_castling_rook(dest)
    transition = {
      'c8' => Cell.new('a8'),
      'g8' => Cell.new('h8'),
      'c1' => Cell.new('a1'),
      'g1' => Cell.new('h1')
    }
    transition[dest.input]
  end

  def castle_in_check?(board, rule, king, dest)
    color = board.piece(king).color
    min = [king.col, dest.col].min
    max = [king.col, dest.col].max
    future = board.clone
    origin = king
    cell = Cell.new(col: 0, row: 0)
    (min + 1).upto(max - 1) do |c|
      cell.col = c
      future.move_piece(origin, cell)
      origin.input = dest.input
      return true if rule.check?(board, color)
    end
    false
  end

  def castle(board, rule, origin, dest)
  end

  def move_pawn(board, rule, origin, dest)
  end

  def generic_move(board, rule, origin, dest)
  end
end
