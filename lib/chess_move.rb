# frozen_string_literal: true

require_relative 'pieces/pawn'

# Used to move pieces around on a ChessBoard
class ChessMove
  def move_piece(board, rule, origin, dest)
    # origin_piece = board.piece(origin, col: coords[:origin_col], row: coords[:origin_row])
    origin_piece = board.piece(origin)
    unless rule.valid?(board, origin_piece&.color, origin, dest)
      raise ArgumentError, "Expected a valid origin and destination, got #{origin}, #{dest}"
    end

    remove_en_passant(board)
    moved = castle(board, rule, origin, dest)
    moved ||= move_pawn(board, rule, origin, dest)
    generic_move(board, rule, origin, dest) unless moved
    update_pawn_captures(board)
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
      !castle_in_check?(board, rule, king, dest)
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

  def find_castling_rook_destination(rook)
    transition = {
      'a8' => Cell.new('d8'),
      'h8' => Cell.new('f8'),
      'a1' => Cell.new('d1'),
      'h1' => Cell.new('f1')
    }
    transition[rook.input]
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
    return false unless can_castle?(board, rule, origin, dest)

    board.move_piece(origin, dest)
    rook_origin = find_castling_rook(dest)
    rook_dest = find_castling_rook_destination(rook_origin)
    board.move_piece(rook_origin, rook_dest)
    true
  end

  def move_pawn(board, rule, origin, dest)
    # pawn_captures:
    # 1 - after everymove iterate through each pawn.
    #     for each pawn
    # 1 - remove all captures
    # 2 - check potential captures for enemy pieces
    # 3 - add capture if it is an enemy piece.
    # en_passant:
    #  - can only occur immediately following a pawn
    #     makes a move of two squares and it could've been
    #     captured by an enemy pawn if it had only moved one square
    # 1 - before every move remove all en_passants from all remaining pawns
    # 2 - if the move is a pawn and the pawn moves two squares
    #     then check left, and right for a pawn
    # 3 - if either is an enemy pawn
    #     then add en_passant to that pawn
    # promotion
  end

  def generic_move(board, rule, origin, dest)
  end

  def remove_en_passant(board)
    board.each_cell do |cell|
      cell.remove_en_passant if cell.instance_of?(Pawn)
    end
  end

  def update_pawn_captures(board)
  end
end
