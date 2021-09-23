# frozen_string_literal: true

require_relative 'chess_piece'

# The Bishop piece in chess. u2657
class Bishop < ChessPiece
  def initialize(color)
    super(color)
    1.upto(8) do |i|
      add(-i, i)
      add(i, i)
      add(-i, -i)
      add(i, -i)
    end
  end

  def draw
    @color.eql?(:white) ? '♗' : '♝'
  end
end
