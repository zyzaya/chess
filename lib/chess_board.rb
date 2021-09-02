# frozen_string_literal: true

require_relative 'pieces/bishop'
require_relative 'pieces/king'
require_relative 'pieces/knight'
require_relative 'pieces/pawn'
require_relative 'pieces/queen'
require_relative 'pieces/rook'

class ChessBoard

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
    set_bishops(board)
    set_kings(board)
    set_knights(board)
    set_pawns(board)
    set_queens(board)
    set_rooks(board)
    board
  end

  private

  def set_bishops(board)
    board[2][7] = Bishop.new(:black)
    board[5][7] = Bishop.new(:black)
    board[2][0] = Bishop.new(:white)
    board[2][0] = Bishop.new(:white)
  end

  def set_kings(board)
    board[3][7] = King.new(:black)
    board[3][0] = King.new(:white)
  end

  def set_knights(board)
    board[1][7] = Knight.new(:black)
    board[6][7] = Knight.new(:black)
    board[1][0] = Knight.new(:white)
    board[6][0] = Knight.new(:white)
  end

  def set_pawns(board)
    0.upto(6) do |col|
      board[col][6] = Pawn.new(:black)
      board[col][1] = Pawn.new(:white)
    end
  end

  def set_queens(board)
    board[4][7] = Queen.new(:black)
    board[4][0] = Queen.new(:white)
  end

  def set_rooks(board)
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
