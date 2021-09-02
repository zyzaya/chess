# frozen_string_literal: true

require_relative 'chess_piece'

# The Knight piece in chess. u2658
class Knight < ChessPiece
  def initialize(color)
    super(color)
    add_horizontal
    add_vertical
  end

  private

  def add_horizontal
    add(-2, 1)
    add(-2, -1)
    add(2, 1)
    add(2, -1)
  end

  def add_vertical
    add(-1, 2)
    add(1, 2)
    add(-1, -2)
    add(1, -2)
  end
end
