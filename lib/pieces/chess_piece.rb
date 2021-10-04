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
    @valid << Cell.new(col: col, row: row) unless valid?(col, row)
  end

  def remove(col, row)
    @valid.delete(Cell.new(col: col, row: row))
  end

  def draw
    '?'
  end
end
