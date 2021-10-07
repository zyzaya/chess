# frozen_string_literal: true

require 'chess_game'

describe ChessGame do
  let(:game) { ChessGame.new }

  before do
    allow(game.input).to receive(:replay).and_return(false)
  end

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
    let(:origin) { instance_double('Cell', col: 0, row: 1, input: 'a2') }
    let(:dest) { instance_double('Cell', col: 0, row: 3, input: 'a4') }
    let(:move) { { origin: origin, dest: dest } }
    draw = '[] <- a chess board'

    before do
      allow(game).to receive(:next_turn).with(:white).and_return(:black)
      allow(game).to receive(:next_turn).with(:black).and_return(:white)
      allow(game).to receive(:end_game)
      allow(game.input).to receive(:turn).and_return(move)
      allow(game.board).to receive(:draw).and_return(draw)
      allow(game.rule).to receive(:check?).and_return(false)
      allow(game.rule).to receive(:stalemate?).and_return(false)
      allow(game.rule).to receive(:dead_position?).and_return(false)
      allow(game.rule).to receive(:checkmate?).and_return(false, true)
    end

    it 'gets player input for a turn' do
      expect(game.input).to receive(:turn)
      game.play_game
    end

    it 'updates the state of the board' do
      expect(game.board).to receive(:move_piece).with(origin, dest).twice
      game.play_game
    end

    it 'draws the board' do
      expect(game.board).to receive(:draw).twice
      expect(game).to receive(:puts).with(draw).twice
      game.play_game
    end

    it 'determines if a player is in check' do
      expect(game.rule).to receive(:check?).with(game.board, anything)
      game.play_game
    end

    it 'checks for stalemate' do
      expect(game.rule).to receive(:stalemate?).with(game.board, anything)
      game.play_game
    end

    it 'checks for dead position' do
      expect(game.rule).to receive(:dead_position?).with(game.board)
      game.play_game
    end

    it 'checks for checkmate' do
      expect(game.rule).to receive(:checkmate?).with(game.board, anything)
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
      expect(game.rule).to receive(:checkmate?).twice
      expect(game.rule).to receive(:stalemate?).once
      expect(game.rule).to receive(:dead_position?).once
      game.play_game
    end

    it 'warns the player if in check' do
      allow(game.rule).to receive(:check?).and_return(true)
      expect(game).to receive(:warn_check)
      game.play_game
    end

    it 'switches turns' do
      expect(game).to receive(:next_turn).with(:white).at_least(1)
      game.play_game
    end

    it 'does not call end_game if exiting' do
      allow(game.input).to receive(:turn).and_return('exit')
      expect(game).not_to receive(:end_game)
      game.play_game
    end

    it 'does not move a piece after saving' do
      allow(game.input).to receive(:turn).and_return('save', 'exit')
      expect(game.board).not_to receive(:move_piece)
      game.play_game
    end
  end

  describe '#next_turn' do
    it 'returns white when black is given' do
      result = game.next_turn(:black)
      expect(result).to eql(:white)
    end

    it 'returns black when white is given' do
      result = game.next_turn(:white)
      expect(result).to eql(:black)
    end
  end

  describe '#end_game' do
    before do
      allow(game.rule).to receive(:checkmate?).and_return(false)
      allow(game.rule).to receive(:checkmate?).with(game.board, :black).and_return(true)
      allow(game.input).to receive(:replay).and_return(false)
    end

    it 'prints information about why the game ends' do
      expect(game).to receive(:puts)
      game.end_game(:checkmate)
    end

    it 'calls play game if replaying' do
      allow(game.input).to receive(:replay).and_return(true)
      expect(game).to receive(:play_game)
      game.end_game(:checkmate)
    end

    it 'does not call play when not replaying' do
      expect(game).not_to receive(:play_game)
      game.end_game(:stalemate)
    end
  end
end
