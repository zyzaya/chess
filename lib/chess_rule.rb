# frozen_string_literal: true

# Validates chess movements
class ChessRule
  def valid?(board, color, origin = nil, dest = nil, **coords)
    origin = board.to_input(origin, col: coords[:origin_col], row: coords[:origin_row])
    dest = board.to_input(dest, col: coords[:dest_col], row: coords[:dest_col])
    return false unless taken_cell?(board, origin)

    origin_piece = board.piece(origin)

    origin_piece.color.eql?(color) &&
      valid_piece_move?(board, origin_piece, origin, dest) &&
      !obstructed?(board, origin, dest) &&
      removes_check?(board, origin, dest)
  end

  def check?(board, color)
    enemy = color.eql?(:white) ? :black : :white
    0.upto(7) do |col|
      0.upto(7) do |row|
        return true if
          board.piece(col, row).color.eql?(enemy) &&
          capture_king?(board, col, row)
      end
    end
    false
  end

  def checkmate?(board, color)
    enemy = color.eql?(:white) ? :black : :white
    king = find_king(board, color)
    0.upto(7) do |col|
      0.upto(7) do |row|
        piece = board.piece(col, row)
        next unless !piece.nil? && piece.color.eql?(enemy)

        piece.valid.each do |v|
          origin = board.to_input(v[0], v[1])
          return false unless obstructed?(board, origin, king)
        end
      end
    end
    true
  end

  def capture_king?(board, col, row)
    piece = board.piece(col, row)
    enemy = piece.color ? :black : :white
    king = find_king(board, enemy)
    piece.valid?(board.col(king), board.row(king))
  end

  def find_king(board, color)
    0.upto(7) do |col|
      0.upto(7) do |row|
        piece = board.piece(col, row)
        return board.to_input(col, row) if !piece.nil? && piece.color.eql?(color)
      end
    end
  end

  def removes_check?(board, origin, dest)
    future = board.clone
    future.move_piece(origin, dest)
    !check?(future, board.piece(origin).color)
  end

  def valid_piece_move?(board, piece, origin = nil, dest = nil, **coords)
    origin = board.to_coords(origin, col: coords[:origin_col], row: coords[:origin_row])
    dest = board.to_coords(dest, col: coords[:dest_col], row: coords[:dest_col])
    # rel_col = board.col(dest) - board.col(origin)
    # rel_row = board.row(dest) - board.row(origin)
    rel_col = dest[:col] - origin[:col]
    rel_row = dest[:row] - origin[:row]
    piece.valid?(rel_col, rel_row)
  end

  def taken_cell?(board, cell = nil, **coords)
    return false unless board.on_board?(cell, **coords)

    !board.piece(cell, **coords).nil?
  end

  def obstructed?(board, origin = nil, dest = nil, **coords)
    !cells_between(board, origin, dest, **coords).all?(&:nil?)
  end

  def cells_between(board, origin = nil, dest = nil, **coords)
    origin = board.to_coords(origin, col: coords[:origin_col], row: coords[:origin_row])
    dest = board.to_coords(dest, col: coords[:dest_col], row: coords[:dest_col])
    col = origin[:col]
    row = origin[:row]
    result = []
    until col >= dest[:col] && row >= dest[:row]
      result << board.piece(col: col, row: row)
      col += 1 unless col >= dest[:col]
      row += 1 unless row >= dest[:row]
    end
    result.drop(1)
  end
end
