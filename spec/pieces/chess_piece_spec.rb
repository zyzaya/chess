# frozen_string_literal: true

require 'pieces/chess_piece'

describe ChessPiece do
  subject(:piece) { ChessPiece.new(:white) }
  let(:cell) { instance_double('Cell', col: 1, row: 1) }

  describe '#color' do
    it 'can access the color of the piece' do
      result = piece.color
      expect(result).to eql(:white)
    end
  end

  describe '#valid?' do
    it 'returns false when the given value is not valid' do
      result = piece.valid?(cell.col, cell.row)
      expect(result).to be(false)
    end

    it 'returns true when the given value is valid' do
      piece.add(cell.col, cell.row)
      result = piece.valid?(cell.col, cell.row)
      expect(result).to be(true)
    end
  end

  describe '#remove' do
    it 'removes an existing relative cell to the valid moveset' do
      piece.add(cell.col, cell.row)
      piece.remove(cell.col, cell.row)
      result = piece.valid?(cell.col, cell.row)
      expect(result).to be(false)
    end
  end

  describe '#clone' do
    before do
      piece.add(cell.col, cell.row)
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

  describe '#relative' do
    let(:origin) { instance_double('Cell', col: 3, row: 6) }
    let(:dest) { instance_double('Cell', col: 2, row: 8) }

    it 'returns a cell' do
      result = piece.relative(origin, dest)
      expect(result).to be_instance_of(Cell)
    end

    it 'returns a cell with the column set to the difference between origin and dest columns' do
      result = piece.relative(origin, dest)
      expect(result.col).to eql(-1)
    end

    it 'returns a cell with the row set to the difference between origin and dest rows' do
      result = piece.relative(origin, dest)
      expect(result.row).to eql(2)
    end
  end
end
