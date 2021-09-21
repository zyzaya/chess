# frozen_string_literal: true

require 'chess_game'

describe ChessGame do
  let(:chess_game) { ChessGame.new }
  
  describe '#initialize' do
    it 'initializes a ChessRule' do
      expect(chess_game.rule).to be_instance_of(ChessRule)
    end

    it 'initializes a ChessBoard' do
      expect(chess_game.board).to be_instance_of(ChessBoard)
    end

    it 'initializes a ChessInput' do
      expect(chess_game.input).to be_instance_of(ChessInput)
    end
  end
end