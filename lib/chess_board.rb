# frozen_string_literal: true

require_relative 'pieces/bishop'
require_relative 'pieces/king'
require_relative 'pieces/knight'
require_relative 'pieces/pawn'
require_relative 'pieces/queen'
require_relative 'pieces/rook'

# A Chess board
class ChessBoard
  def to_input(original_col, original_row)
    return nil unless
      original_col >= 0 && original_col <= 8 &&
      original_row >= 0 && original_row <= 7

    "#{(original_col + 'a'.ord).chr}#{original_row + 1}"
  end

  def col(val)
    return nil unless valid_cell(val)

    val[0].ord - 'a'.ord
  end

  def row(val)
    return nil unless valid_cell(val)

    val[1].to_i - 1
  end

  def reset_board
    board = Array.new(8).map { Array.new(8, nil) }
    setup_bishops(board)
    setup_kings(board)
    setup_knights(board)
    setup_pawns(board)
    setup_queens(board)
    setup_rooks(board)
    board
  end

  def valid?(board, color, origin, dest)
    return false unless
      on_board?(origin) && on_board?(dest) && taken_cell?(board, origin)

    origin_piece = board[col(origin)][row(origin)]

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

  def piece(board, cell)
    return nil unless on_board?(cell)

    board[col(cell)][row(cell)]
  end

  def find_king(color)
  end

  def removes_check?(board, origin, dest)
    future = board.map { |col| col.map { |cell| cell } }
    origin_col = col(origin)
    origin_row = row(origin)
    future[col(dest)][row(dest)] = board[origin_col][origin_row]
    future[origin_col][origin_row] = nil

    !check?(future, piece(board, origin).color)
  end

  def on_board?(cell)
    curr_col = col(cell)
    curr_row = row(cell)
    return false if [curr_col, curr_row].any?(&:nil?)

    curr_col >= 0 && curr_col < 8 &&
      curr_row >= 0 && curr_row < 8
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
    origin_col = col(origin)
    origin_row = row(origin)
    return false if piece(board, origin).is_a?(Knight)

    origin_col.upto(col(dest)) do |col|
      origin_row.upto(row(dest)) do |row|
        return true unless board[col][row].nil?
      end
    end
    false
  end

  private

  def setup_bishops(board)
    board[2][7] = Bishop.new(:black)
    board[5][7] = Bishop.new(:black)
    board[2][0] = Bishop.new(:white)
    board[2][0] = Bishop.new(:white)
  end

  def setup_kings(board)
    board[3][7] = King.new(:black)
    board[3][0] = King.new(:white)
  end

  def setup_knights(board)
    board[1][7] = Knight.new(:black)
    board[6][7] = Knight.new(:black)
    board[1][0] = Knight.new(:white)
    board[6][0] = Knight.new(:white)
  end

  def setup_pawns(board)
    0.upto(6) do |col|
      board[col][6] = Pawn.new(:black)
      board[col][1] = Pawn.new(:white)
    end
  end

  def setup_queens(board)
    board[4][7] = Queen.new(:black)
    board[4][0] = Queen.new(:white)
  end

  def setup_rooks(board)
    board[0][7] = Rook.new(:black, :left)
    board[7][7] = Rook.new(:black, :right)
    board[0][0] = Rook.new(:white, :left)
    board[7][0] = Rook.new(:white, :right)
  end

  def valid_cell(val)
    val.is_a?(String) &&
      val.length == 2 &&
      val[0].ord >= 'a'.ord &&
      val[0].ord <= 'h'.ord &&
      val[1].to_i >= 1 &&
      val[1].to_i <= 8
  end
end
