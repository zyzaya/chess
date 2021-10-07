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
    if on_board?(val)
      @col = val
      @input = to_input(@col, @row)
    else
      @col = nil
      @input = nil
    end
  end

  def row=(val)
    if on_board?(val)
      @row = val
      @input = to_input(@col, @row)
    else
      @row = nil
      @input = nil
    end
  end

  def coords(col, row)
    @col = nil
    @row = nil
    @col = col if on_board?(col)
    @row = row if on_board?(row)
    @input = to_input(@col, @row)
  end

  def input=(val)
    @input = val
    @col = to_col(val)
    @row = to_row(val)
  end

  def ==(other)
    other.instance_of?(Cell) && other.col == @col && other.row == @row
  end

  def adjacent(side)
    new_col = @col
    new_row = @row
    case side
    when :left then new_col -= 1
    when :right then new_col += 1
    when :up then new_row += 1
    when :down then new_row -= 1
    end
    Cell.new(col: new_col, row: new_row)
  end

  private

  def to_input(col, row)
    return nil unless on_board?(col) && on_board?(row)

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

  def on_board?(val)
    !val.nil? && val >= 0 && val <= 7
  end

  def valid_cell?(val)
    val.is_a?(String) &&
      val.length == 2 &&
      val[0].ord >= 'a'.ord &&
      val[0].ord <= 'h'.ord &&
      val[1].to_i >= 1 &&
      val[1].to_i <= 8
  end

  def to_s
    "#{@input}: (#{@col}, #{@row})"
  end
end
