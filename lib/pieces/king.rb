# frozen_string_literal: true

require_relative 'chess_piece'

# The King piece of a Chess game
class King < ChessPiece
  attr_reader :moved

  QUEENSIDE_CASTLE = [-3, 0].freeze
  KINGSIDE_CASTLE = [2, 0].freeze

  def initialize(color)
    super(color)
    @moved = false
    add_diagonal
    add_horizontal
    add_vertical
    add_castling
  end

  def moved=(val)
    @moved = val
    return unless @moved
    
    remove_castling
  end

  def remove_castling
    
  end

  private

  def add_diagonal
    add(-1, 1)
    add(1, 1)
    add(-1, -1)
    add(1, -1)
  end

  def add_horizontal
    add(0, 1)
    add(0, -1)
  end

  def add_vertical
    add(-1, 0)
    add(1, 0)
  end

  def add_castling
    add(QUEENSIDE_CASTLE[0], QUEENSIDE_CASTLE[1])
    add(KINGSIDE_CASTLE[0], KINGSIDE_CASTLE[1])
  end
end
