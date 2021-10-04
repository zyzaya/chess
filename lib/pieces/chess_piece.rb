# frozen_string_literal: true

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

  def valid?(cell)
    @valid.include?(cell)
  end

  def add(cell)
    @valid << cell unless valid?(cell)
  end

  def remove(cell)
    @valid.delete(cell)
  end

  def draw
    '?'
  end
end
