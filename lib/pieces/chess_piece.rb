# frozen_string_literal: true

# A single piece of a Chess game
class ChessPiece
  attr_reader :color

  def initialize(color)
    @color = color
    @valid = []
  end

  def valid?(col, row)
    @valid.include?([col, row])
  end

  def add(col, row)
    @valid << [col, row] unless @valid.include?([col, row])
  end

  def remove(col, row)
    @valid.delete([col, row])
  end
end
