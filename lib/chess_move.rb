# frozen_string_literal: true

# Used to move pieces around on a ChessBoard
class ChessMove
  def move_piece(board, rule, origin = nil, dest = nil, **coords)
    origin_piece = board.piece(origin, col: coords[:origin_col], row: coords[:origin_row])
    raise ArgumentError.new(
      "Expected a valid origin and destination, got #{origin}, #{dest}, #{coords}"
    ) unless rule.valid?(board, origin_piece&.color, dest, coords)
    # error if not a valid move

    # tries to castle

    # tries to move a pawn

    # generic move
  end

  def move_castle(board, rule, origin = nil, dest = nil, **coords)
  end

  def move_pawn(board, rule, origin = nil, dest = nil, **coords)
  end

  def generic_move(board, rule, origin = nil, dest = nil, **coords)
  end
end