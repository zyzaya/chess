# frozen_string_literal: true

# A single piece of a Chess game
class ChessPiece
  attr_reader :color

  def initialize(color)
    @color = color
    @valid = []
  end

  def valid?(rel_row, rel_col)
    @valid.include?([rel_row, rel_col])
  end

  def add(rel_row, rel_col)
    @valid << [rel_row, rel_col] unless valid?(rel_row, rel_col)
  end

  def remove(rel_col, rel_row)
    @valid.delete([rel_col, rel_row])
  end
end
