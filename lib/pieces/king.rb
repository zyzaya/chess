# frozen_string_literal: true

require_relative 'chess_piece'

# The King piece of a Chess game
class King < ChessPiece
  def initialize(color)
    super(color)
    add(-1, 1)
    add(0, 1)
    add(1, 1)
    add(-1, 0)
    add(1, 0)
    add(-1, -1)
    add(0, -1)
    add(1, -1)
  end
end
