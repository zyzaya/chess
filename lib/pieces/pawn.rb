# frozen_string_literal: true

require_relative 'chess_piece'

# The Pawn piece in chess. u2659
class Pawn < ChessPiece
  def initialize(color)
    super(color)
    @moved = false
    @en_passant = []
    case color
    when :black
      add(0, -1)
      add(0, -2)
    when :white
      add(0, 1)
      add(0, 2)
    end
  end

  def valid?(col, row)
    super(col, row) || @en_passant.include?(Cell.new(col: col, row: row))
  end

  def moved=(val)
    @moved = val
    return unless val

    case @color
    when :black
      remove(0, -2)
    when :white
      remove(0, 2)
    end
  end

  def add_all_captures(board, col, row)
    right = capture_cell(col, row, :right)
    left = capture(col, row, :left)
    enemy = @color.eql?(:black) ? :white : :black
    add_capture(:left) if
      board.on_board?(left) &&
      board.piece(left)&.color.eql?(enemy)
    add_capture(:right) if
      board.on_board?(right) &&
      board.piece(right)&.color.eql?(enemy)
  end

  def capture_cell(col, row, side)
    cell = Cell.new(col: col, row: row)
    case @color
    when :black then cell.row -= 1
    when :white then cell.row += 1
    end
    case side
    when :left then cell.col -= 1
    when :right then cell.col += 1
    end
    cell
  end

  def add_capture(side)
    case @color
    when :black
      case side
      when :left then add(-1, -1)
      when :right then add(1, -1)
      end
    when :white
      case side
      when :left then add(-1, 1)
      when :right then add(1, 1)
      end
    end
  end

  def remove_capture(side)
    case @color
    when :black
      case side
      when :left then remove(-1, -1)
      when :right then remove(1, -1)
      end
    when :white
      case side
      when :left then remove(-1, 1)
      when :right then remove(1, 1)
      end
    end
  end

  def en_passant(side)
    row = case @color
          when :black then -1
          when :white then 1 end
    col = case side
          when :left then -1
          when :right then 1 end
    new_cell = Cell.new(col: col, row: row)
    @en_passant << new_cell unless @en_passant.include?(new_cell)
  end

  def remove_en_passant
    @en_passant.clear
  end

  def draw
    @color.eql?(:white) ? '♙' : '♟︎'
  end
end
