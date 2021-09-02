# frozen_string_literal: true

require 'chess_board'

describe ChessBoard do
  subject(:board) { ChessBoard.new }

  describe '#col' do
    it 'returns one less than the integer of the second character' do
      result = board.col('b2')
      expect(result).to eql(1)
    end

    it 'returns nil if it is not given a string' do
      result = board.col(2)
      expect(result).to be(nil)
    end

    it 'returns nil if it is given a string longer than 2 characters' do
      result = board.col('b2b2')
      expect(result).to be(nil)
    end

    it 'returns nil if it is given input off the board' do
      result = board.col('b9')
      expect(result).to be(nil)
    end
  end
end