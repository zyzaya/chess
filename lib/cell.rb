# frozen_string_literal: true

# describes the location of a cell on a ChessBoard
class Cell
  attr_reader :col, :row, :input

  def initialize(input = nil, **coords)
    coords = to_coords(input) unless input.nil?
    @col = coords[:col]
    @row = coords[:row]
    @input = input.nil? ? to_input(col, row) : input
  end

  def col=(val)
  end

  def row=(val)
  end

  def coords(col, row)
  end

  def input=(val)
  end

  private

  def to_input(col, row)
    return nil unless
      col >= 0 && col <= 7 &&
      row >= 0 && row <= 7

    "#{(col + 'a'.ord).chr}#{row + 1}"
  end

  def to_coords(input)
    input.nil? ? { col: nil, row: nil } : { col: to_col(input), row: to_row(input) }
  end

  def to_col(val)
    return nil unless valid_cell?(val)

    val[0].ord - 'a'.ord
  end

  def to_row(val)
    return nil unless valid_cell?(val)

    val[1].to_i - 1
  end

  def valid_cell?(val)
    val.is_a?(String) &&
      val.length == 2 &&
      val[0].ord >= 'a'.ord &&
      val[0].ord <= 'h'.ord &&
      val[1].to_i >= 1 &&
      val[1].to_i <= 8
  end
end
