require 'chess_piece'

describe ChessPiece do
  subject(:piece) { ChessPiece.new(:white) }

  describe '#color' do
    it 'can access the color of the piece' do
      result = piece.color
      expect(result).to eql(:white)
    end
  end

  describe '#valid?' do
    it 'returns false when the given value is not valid' do
      result = piece.valid?(1, 1)
      expect(result).to be(false)
    end

    it 'returns true when the given value is valid' do
      piece.add(1, 1)
      result = piece.valid?(1, 1)
      expect(result).to be_truthy
    end
  end

  describe '#valid' do
    it 'adds a relative cell to the valid moveset' do
      piece.add(-1, 1)
      result = piece.valid?(-1, 1)
      expect(result).to be_truthy
    end
  end

  describe '#remove' do
    it 'removes an existing relative cell to the valid moveset' do
      rel_col = 1
      rel_row = 1
      piece.add(rel_col, rel_row)
      piece.remove(rel_col, rel_row)
      result = piece.valid?(rel_col, rel_row)
      expect(result).to be(false)
    end
  end
end