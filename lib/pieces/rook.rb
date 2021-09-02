# frozen_string_literal: true

require_relative 'chess_piece'

# The Rook piece in chess
class Rook < ChessPiece
  def initialize(color)
    super(color)
    1.upto(8) do |i|
      add_vertical(i)
      add_horizontal(i)
    end
  end

  private

  def add_horizontal(index)
    add(index, 0)
    add(-index, 0)
  end

  def add_vertical(index)
    add(0, index)
    add(0, -index)
  end
end