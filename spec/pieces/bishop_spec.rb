# frozen_string_literal: true

require 'pieces/bishop'

describe Bishop do
  subject(:bishop) { Bishop.new(:white) }
  let(:size) { 8 }

  describe 'moveset' do
    it 'can move diagonally to any relative location' do
      1.upto(size) do |i|
        result = bishop.valid?(-i, i)
        expect(result).to be(true)
        result = bishop.valid?(i, i)
        expect(result).to be(true)
        result = bishop.valid?(-i, -i)
        expect(result).to be(true)
        result = bishop.valid?(i, -i)
        expect(result).to be(true)
      end
    end

    it 'can not move horizontally' do
      result = bishop.valid?(0, 5)
      expect(result).to be(false)
    end
  end
end