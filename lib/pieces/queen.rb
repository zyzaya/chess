# frozen_string_literal: true

require_relative 'chess_piece'

# The Queen piece in chess.
class Queen < ChessPiece
  def initialize(color)
    super(color)
    1.upto(8) do |i|
      add_diagonal(i)
      add_horizontal(i)
      add_vertical(i)
    end
  end

  private

  def add_diagonal(index)
    add(-index, index)
    add(index, index)
    add(-index, -index)
    add(index, -index)
  end

  def add_horizontal(index)
    add(0, index)
    add(0, -index)
  end

  def add_vertical(index)
    add(index, 0)
    add(-index, 0)
  end
end
