# frozen_string_literal: true

require 'pieces/pawn'

describe Pawn do
  let(:black_pawn) { Pawn.new(:black) }
  let(:white_pawn) { Pawn.new(:white) }

  describe 'moveset' do
    it 'can move one space down if black' do
      result = black_pawn.valid?(0, -1)
      expect(result).to be(true)
    end

    it 'can not move up if black' do
      result = black_pawn.valid?(0, 1)
      expect(result).to be(false)
    end

    it 'can move one space up if white' do
      result = white_pawn.valid?(0, 1)
      expect(result).to be(true)
    end

    it 'can not move down if white' do
      result = white_pawn.valid?(0, -1)
      expect(result).to be(false)
    end

    it 'can move two spaces initially' do
      result = white_pawn.valid?(0, 2)
      expect(result).to be(true)
      result = black_pawn.valid?(0, -2)
      expect(result).to be(true)
    end

    it 'can not move horizontally' do
      result = white_pawn.valid?(2, 0)
      expect(result).to be(false)
    end
  end

  describe '#moved' do
    it 'is initialized as not having moved' do
      result = white_pawn.moved
      expect(result).to be(false)
    end

    it 'can set moved' do
      white_pawn.moved = true
      result = white_pawn.moved
      expect(result).to be(true)
    end

    it 'can not move two spaces after moved is set to true' do
      white_pawn.moved = true
      result = white_pawn.valid?(0, 2)
      expect(result).to be(false)
    end
  end
end