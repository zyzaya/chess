# frozen_string_literal: true

require 'chess_game'

describe ChessGame do
  let(:game) { ChessGame.new }
  
  describe '#initialize' do
    it 'initializes a ChessRule' do
      expect(game.rule).to be_instance_of(ChessRule)
    end

    it 'initializes a ChessBoard' do
      expect(game.board).to be_instance_of(ChessBoard)
    end

    it 'initializes a ChessInput' do
      expect(game.input).to be_instance_of(ChessInput)
    end
  end

  describe '#play_game' do
    move = {origin_col: 0, origin_row: 1, dest_col: 0, dest_row: 3}
    display = '[] <- a chess board'

    before do
      allow(game.input).to receive(:turn).and_return(move)
      allow(game.board).to receive(:display).and_return(display)
      allow(game.rule).to receive(:check?).and_return(false)
      allow(game.rule).to receive(:stalemate?).and_return(false)
      allow(game.rule).to receive(:dead_position?).and_return(false)
      allow(game.rule).to receive(:checkmate?).and_return(false)
    end
    
    it 'gets player input for a turn' do
      expect(game.input).to receive(:turn)
      game.play_game
    end

    it 'updates the state of the board' do
      expect(game.board).to receive(:move_piece).with(move)
      game.play_game
    end

    it 'draws the board' do
      expect(game.board).to receive(:display)
      expect(game).to receive(:puts).with(display)
      game.play_game
    end

    it 'determines if a player is in check' do
      expect(game.rule).to receive(:check?).with(board, anything)
      game.play_game
    end

    it 'checks for stalemate' do
      expect(game.rule).to receive(:stalemate?).with(board, anything)
      game.play_game
    end

    it 'checks for dead position' do
      expect(game.rule).to receive(:dead_position?).with(board, anything)
      game.play_game
    end

    it 'checks for checkmate' do
      expect(game.rule).to receive(:checkmate?).with(board, anything)
      game.play_game
    end

    it 'ends the game if there is stalemate' do
      allow(game.rule).to receive(:stalemate?).and_return(true)
      expect(game).to receive(:end_game)
      game.play_game
    end

    it 'ends the game if there is dead_position' do
      allow(game.rule).to receive(:dead_position?).and_return(true)
      expect(game).to receive(:end_game)
      game.play_game
    end

    it 'ends the game if there is checkmate' do
      allow(game.rule).to receive(:checkmate?).and_return(true)
      expect(game).to receive(:end_game)
      game.play_game
    end

    it 'continues the game if there is not stalemate, dead position, or checkmate' do
      expect(game).not_to receive(:end_game)
      game.play_game
    end
  end
end