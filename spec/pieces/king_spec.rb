# frozen_string_literal: true

require 'pieces/king'

describe King do
  subject(:king) { King.new(:white) }

  describe 'moveset' do
    it 'can move one square diagonally in any direction' do
      moveset = [[-1, 1], [1, 1], [-1, -1], [1, -1]]
      moveset.each do |move|
        result = king.valid?(move[0], move[1])
        expect(result).to be(true)
      end
    end

    it 'can move one square horizontally in any direction' do
      moveset = [[-1, 0], [1, 0]]
      moveset.each do |move|
        result = king.valid?(move[0], move[1])
        expect(result).to be(true)
      end
    end

    it 'can move one square vertically in any direction' do
      moveset = [[0, 1], [0, -1]]
      moveset.each do |move|
        result = king.valid?(move[0], move[1])
        expect(result).to be(true)
      end
    end

    it 'cannot move seven squares down' do
      result = king.valid?(0, -7)
      expect(result).to be(false)
    end
  end

  describe 'castling' do
    it 'removes the ability to castle if it has moved' do
      expect(king).to receive(:remove_castling)
      king.moved = true
    end

    it 'can castle queenside if it has not moved' do
      result = king.valid?(-2, 0)
      expect(result).to be(true)
    end

    it 'can castle kingside if it has not moved' do
      result = king.valid?(2, 0)
      expect(result).to be(true)
    end
  end

  describe '#remove_castling' do
    it 'removes the ability to castle queenside' do
      king.remove_castling
      result = king.valid?(-3, 0)
      expect(result).to be(false)
    end

    it 'removes the ability to castle kingside' do
      king.remove_castling
      result = king.valid?(2, 0)
      expect(result).to be(false)
    end
  end

  describe 'moved' do
    it 'is initialized as not having moved' do
      result = king.moved
      expect(result).to be(false)
    end

    it 'can set moved' do
      king.moved = true
      result = king.moved
      expect(result).to be(true)
    end
  end

  describe '#castling_rook' do
    it 'returns the related rook for the given destination' do
      destinations = %w[c8 g8 c1 g1]
      rooks = %w[a8 h8 a1 h1]
      destinations.each.with_index do |d, i|
        dest = instance_double('Cell', input: d)
        result = king.castling_rook(dest)
        expect(result.input).to eql(rooks[i])
      end
    end

    it 'returns nil if the destination is not a castling destination' do
      dest = instance_double('Cell', input: 'b7')
      result = king.castling_rook(dest)
      expect(result).to eql(nil)
    end
  end

  describe '#castling_rook_destination' do
    it 'returns the related rook for the given destination' do
      rooks = %w[a8 h8 a1 h1]
      destinations = %w[d8 f8 d1 f1]
      rooks.each.with_index do |d, i|
        rook = instance_double('Cell', input: d)
        result = king.castling_rook_destination(rook)
        expect(result.input).to eql(destinations[i])
      end
    end

    it 'returns nil if the destination is not a castling destination' do
      dest = instance_double('Cell', input: 'b7')
      result = king.castling_rook_destination(dest)
      expect(result).to eql(nil)
    end
  end
end
