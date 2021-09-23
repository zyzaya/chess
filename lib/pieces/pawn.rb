# frozen_string_literal: true

require_relative 'chess_piece'

# The Pawn piece in chess. u2659
class Pawn < ChessPiece
  attr_reader :moved
  
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
    super(col, row) || @en_passant.include?([col, row])
  end

  def moved=(val)
    @moved = val
    return unless val

    case color
    when :black
      remove(0, -2)
    when :white
      remove(0, 2)
    end
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
    row =
      if @color.eql?(:black) then -1
      elsif @color.eql?(:white) then 1 end
    col =
      if side.eql?(:left) then -1
      elsif side.eql?(:right) then 1 end
    unless @en_passant.include?([col, row])
      @en_passant << [col, row]
    end
  end

  def remove_en_passant
    @en_passant.clear
  end

  def draw
    @color.eql?(:white) ? '♙' : '♟︎'
  end
end
