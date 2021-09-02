# frozen_string_literal: true

require 'pieces/rook'

describe Rook do
  subject(:rook) { Rook.new(:white) }
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
end