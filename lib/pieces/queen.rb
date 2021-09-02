require_relative 'chess_piece'

class Queen < ChessPiece
  def initialize(color)
    super(color)
    1.upto(8) do |i|
      add_diagonal(i)
      add_horizontal(i)
      add_vertical(i)
    end
  end

  private

  def add_diagonal(i)
    add(-i, i)
    add(i, i)
    add(-i, -i)
    add(i, -i)
  end

  def add_horizontal(i)
    add(0, i)
    add(0, -i)
  end

  def add_vertical(i)
    add(i, 0)
    add(-i, 0)
  end
end