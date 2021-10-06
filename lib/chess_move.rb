# frozen_string_literal: true

require_relative 'pieces/pawn'
require_relative 'pieces/bishop'
require_relative 'pieces/knight'
require_relative 'pieces/queen'
require_relative 'pieces/rook'

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
    moved ||= move_pawn(board, origin, dest)
    board.move_piece(origin, dest) unless moved
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
    rook_cell = king.castling_rook(dest)
    return false if king.moved || board.piece(rook_cell)&.moved

    !rule.obstructed?(board, origin, rook_cell) &&
      !castle_in_check?(board, rule, king, dest)
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
    king = board.piece(origin)
    rook_origin = king.castling_rook(dest)
    rook_dest = king.castling_rook_destination(rook_origin)
    board.move_piece(rook_origin, rook_dest)
    true
  end

  def move_pawn(board, input, origin, dest)
    piece = board.piece(origin)
    return false unless piece.instance_of?(Pawn)

    board.move_piece(origin, dest)
    update_en_passant(board, dest) if piece.double_move?(origin, dest)
    promote_piece(dest, input) if piece.promote?(dest)
    # if piece.promote?(dest)
    #   case input.promote
    #   when 'bishop' then board.force_piece(dest, Bishop.new(piece.color))
    #   when 'knight' then board.force_piece(dest, Bishop.new(piece.color))
    #   when 'queen' then board.force_piece(dest, Bishop.new(piece.color))
    #   when 'rook' then board.force_piece(dest, Bishop.new(piece.color))
    #   end
    # end
    # promotion
    # if piece (dest) is at final row (determine by pawn.promote?)
    # ask the user for which piece to promote to
    # - can only promot to queen, knight, rook, or bishop
    # set dest to that piece of the original color.
    true
  end

  def promote_piece(cell, input)
  end

  def remove_en_passant(board)
    board.each_cell do |cell|
      cell.remove_en_passant if cell.instance_of?(Pawn)
    end
  end

  def update_en_passant(board, cell)
    piece = board.piece(cell)
    enemy = piece.color.eql?(:black) ? :white : :black
    left = cell.adjacent(:left)
    right = cell.adjacent(:right)
    piece.en_passant(:right) if board.piece(left)&.color.eql?(enemy)
    piece.en_passant(:left) if board.piece(right)&.color.eql?(enemy)
  end

  def update_pawn_captures(board)
    board.each_cell do |piece, col, row|
      next unless piece.instance_of?(Pawn)

      piece.remove_capture(:left)
      piece.remove_capture(:right)
      piece.add_all_captures(board, col, row)
    end
  end
end
