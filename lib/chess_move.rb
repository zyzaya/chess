# frozen_string_literal: true

# Used to move pieces around on a ChessBoard
class ChessMove
  def move_piece(board, rule, origin = nil, dest = nil, **coords)
    origin_piece = board.piece(origin, col: coords[:origin_col], row: coords[:origin_row])
    raise ArgumentError.new(
      "Expected a valid origin and destination, got #{origin}, #{dest}, #{coords}"
    ) unless rule.valid?(board, origin_piece&.color, dest, coords)
    return if move_castle(board, origin, dest, **coords)

    return if move_pawn(board, rule, origin, dest, **coords)

    generic_move(board, rule, origin, dest, **coords)
  end

  def move_castle(board, rule, origin = nil, dest = nil, **coords)
    return false unless
      is_castle(board, rule, origin, dest, **coords) &&
      can_castle(board, rule, origin, dest, **coords)
    
    castle(board, rule, origin, dest, **coords)
    true
  end

  def is_castle(board, origin = nil, dest = nil, **coords)
    origin_coords = board.to_coords(origin, col: coords[:origin_col], row: coords[:origin_row])
    origin_piece = board.piece(**origin_coords)
    return false unless origin_piece.instance_of?(King)

    dest_coords = board.to_coords(dest, col: coords[:dest_col], row: coords[:dest_row])
    rel_col = dest_coords[:col] - origin_coords[:col]
    rel_row = dest_coords[:row] - origin_coords[:row]
    rel_row == 0 && [-3, 2].include?(rel_col)
  end

  def can_castle(board, rule, origin = nil, dest = nil, **coords)
    # king has not moved
    # rook has not moved
    # origin -> rook is not obstructed
    # none of the pieces from origin to dest are in check
  end

  def castle(board, rule, origin = nil, dest = nil, **coords)
  end

  def move_pawn(board, rule, origin = nil, dest = nil, **coords)
  end

  def generic_move(board, rule, origin = nil, dest = nil, **coords)
  end
end