# frozen_string_literal: true

require_relative 'chess_piece'

# The Rook piece in chess
class Rook < ChessPiece
  QUEENSIDE_CASTLE = [3, 0].freeze
  KINGSIDE_CASTLE = [-2, 0].freeze

  def initialize(color, side)
    super(color)
    @moved = false
    1.upto(8) do |i|
      add_vertical(i)
      add_horizontal(i)
    end
    add_castling(side)
  end

  def moved=(val)
    @moved = val
    return unless @moved

    remove_castling
  end

  def remove_castling
    remove(KINGSIDE_CASTLE[0], KINGSIDE_CASTLE[1])
    remove(QUEENSIDE_CASTLE[0], QUEENSIDE_CASTLE[1])
  end

  def draw
    @color.eql?(:white) ? '♖' : '♜'
  end

  private

  def add_horizontal(index)
    add(index, 0)
    add(-index, 0)
  end

  def add_vertical(index)
    add(0, index)
    add(0, -index)
  end

  def add_castling(side)
    case side
    when :king
      add(KINGSIDE_CASTLE[0], KINGSIDE_CASTLE[1])
    when :queen
      add(QUEENSIDE_CASTLE[0], QUEENSIDE_CASTLE[1])
    end
  end
end
