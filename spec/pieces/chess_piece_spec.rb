# frozen_string_literal: true

require 'pieces/chess_piece'

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
      expect(result).to be(true)
    end
  end

  describe '#valid' do
    it 'adds a relative cell to the valid moveset' do
      piece.add(-1, 1)
      result = piece.valid?(-1, 1)
      expect(result).to be(true)
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

  describe '#clone' do
    before do
      0.upto(10) { |i| piece.add(i, i + 1) }
    end

    it 'creates a new object' do
      clone = piece.clone
      expect(clone).not_to eql(piece)
      expect(clone.object_id).not_to eql(piece.object_id)
    end

    it 'does a deep copy of board' do
      clone = piece.clone
      original = []
      result = []
      piece.valid.each_index do |i|
        original << piece.valid[i]
        result << clone.valid[i]
      end
      expect(result.each_with_index.none? do |v, i|
        !v.nil? && v.equal?(original[i])
      end).to eql(true)
    end
  end
end
