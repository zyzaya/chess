# frozen_string_literal: true

require 'pieces/rook'

describe Rook do
  subject(:rook) { Rook.new(:white, :queen) }
  let(:size) { 8 }


  describe 'moveset' do
    it 'can move horizontally to any relative location' do
      1.upto(size) do |i|
        result = rook.valid?(i, 0)
        expect(result).to be(true)
        result = rook.valid?(-i, 0)
        expect(result).to be(true)
      end
    end

    it 'can move vertically to any relative location' do
      1.upto(size) do |i|
        result = rook.valid?(0, i)
        expect(result).to be(true)
        result = rook.valid?(0, -i)
        expect(result).to be(true)
      end
    end

    it 'can not move diagonally' do
      result = rook.valid?(3, 3)
      expect(result).to be(false)  
    end
  end

  describe 'castling' do
    it 'calls #remove_castling if it has moved' do
      expect(rook).to receive(:remove_castling)
      rook.moved = true   
    end
    
    it 'can move -2 horizontally if it starts kingside' do
      kingside_rook = Rook.new(:white, :king)
      result = kingside_rook.valid?(-2, 0)
      expect(result).to be(true)
    end

    it 'can move +2 horizontally if it starts queenside' do
      queenside_rook = Rook.new(:white, :queen)
      result = queenside_rook.valid?(3, 0)
      expect(result).to be(true)
    end
  end

  describe '#remove_castling' do
    it 'removes the ability to castle when queenside' do
      queenside_rook = Rook.new(:white, :queen)
      queenside_rook.remove_castling
      result = queenside_rook.valid?(3, 0)
      expect(result).to be(false)
    end

    it 'removes the ability to castle when kingside' do
      kingside_rook = Rook.new(:white, :king)
      kingside_rook.remove_castling
      result = kingside_rook.valid?(-2, 0)
      expect(result).to be(false)
    end
  end

  describe '#moved' do
    it 'is initialized as not having moved' do
      result = rook.moved
      expect(result).to be(false)
    end

    it 'can set moved' do
      rook.moved = true
      result = rook.moved
      expect(result).to be(true)
    end 
  end
end