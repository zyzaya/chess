# frozen_string_literal: true

# Validates chess movements
class ChessRule
  def valid?(board, color, origin = nil, dest = nil, **coord)
    origin = board.to_input(origin, dest, **coord)
    dest = board.to_input(origin, dest, **coord)
    return false unless board.on_board?(origin) &&
                        board.on_board?(dest) &&
                        taken_cell?(board, origin)

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

  def valid_piece_move?(board, piece, origin, dest)
    rel_col = board.col(dest) - board.col(origin)
    rel_row = board.row(dest) - board.row(origin)
    piece.valid?(rel_col, rel_row)
  end

  def taken_cell?(board, cell)
    curr_col = col(cell)
    curr_row = row(cell)
    return false if [curr_col, curr_row].any?(&:nil?)

    !board[curr_col][curr_row].nil?
  end

  def obstructed?(board, origin, dest)
    !cells_between(board, origin, dest).all?(&:nil?)
  end

  def cells_between(board, origin, dest)
    col = board.col(origin)
    row = board.row(origin)
    dest_col = board.col(dest)
    dest_row = board.row(dest)
    result = []
    until col >= dest_col && row >= dest_row
      result << board.piece(col, row)
      col += 1 unless col >= dest_col
      row += 1 unless row >= dest_row
    end
    result.drop(1)
  end
end
