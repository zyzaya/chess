# frozen_string_literal: true

# Validates chess movements
class ChessRule
  def valid?(board, color, origin, dest)
    return false unless
      board.on_board?(origin) &&
      board.on_board?(dest) &&
      taken_cell?(board, origin)

    origin_piece = board.piece(origin)

    origin_piece.color.eql?(color) &&
      valid_piece_move?(origin_piece, origin, dest) &&
      !obstructed?(board, origin, dest) &&
      removes_check?(board, origin, dest)
  end

  def check?(board, color)
    enemy = color.eql?(:white) ? :black : :white
    king = find_king(color)
    board.each.with_index do |col, c_i|
      col.each.with_index do |piece, r_i|
        origin = to_input(c_i, r_i)
        return true if
          !piece.nil? &&
          piece.color.eql?(enemy) &&
          valid?(board, enemy, origin, king)
      end
    end
    false
  end

  def removes_check?(board, origin, dest)
    future = board.map { |col| col.map { |cell| cell } }
    origin_col = col(origin)
    origin_row = row(origin)
    future[col(dest)][row(dest)] = board[origin_col][origin_row]
    future[origin_col][origin_row] = nil

    !check?(future, piece(board, origin).color)
  end

  def valid_piece_move?(piece, origin, dest)
    rel_col = col(dest) - col(origin)
    rel_row = row(dest) - row(origin)
    piece.valid?(rel_col, rel_row)
  end

  def taken_cell?(board, cell)
    curr_col = col(cell)
    curr_row = row(cell)
    return false if [curr_col, curr_row].any?(&:nil?)

    !board[curr_col][curr_row].nil?
  end

  def obstructed?(board, origin, dest)
    # for each cell directly between origin and dest
    # if none are taken return true
    # with the exception of the knight all
    # pieces can only move horizontally or diagonally
    # passing.each do |cell| return true unless cell.nil?
    # origin_col = board.col(origin)
    # origin_row = board.row(origin)
    # return false if piece(board, origin).is_a?(Knight)

    # origin_col.upto(col(dest)) do |col|
    #   origin_row.upto(row(dest)) do |row|
    #     return true unless board[col][row].nil?
    #   end
    # end
    # false
    !cells_between(board, origin, dest).all?(&:nil?)
  end

  def cells_between(board, origin, dest)
    col = board.col(origin)
    row = board.row(origin)
    dest_col = board.col(dest)
    dest_row = board.row(dest)
    result = []
    until col >= dest_col && row >= dest_row
      result << board.piece(board.to_input(col, row))
      col += 1 unless col >= dest_col
      row += 1 unless row >= dest_row
    end
    result.drop(1)
  end
end
