# frozen_string_literal: true

require_relative '../cell'

# A single piece of a Chess game
class ChessPiece
  attr_reader :color, :valid
  attr_accessor :moved

  def initialize(color)
    @color = color
    @valid = []
  end

  def initialize_copy(original)
    super
    @valid = []
    original.valid.each { |v| @valid << v.clone }
  end

  def valid?(col, row)
    @valid.include?(Cell.new(col: col, row: row))
  end

  def add(col, row)
    new_cell = Cell.new(col: col, row: row)
    @valid << new_cell unless @valid.include?(new_cell)
  end

  def remove(col, row)
    @valid.delete(Cell.new(col: col, row: row))
  end

  def relative(origin, dest)
    Cell.new(col: dest.col - origin.col, row: dest.row - origin.row)
  end

  def draw
    '?'
  end
end
