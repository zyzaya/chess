# frozen_string_literal: true
require 'chess_input'

describe ChessInput do
  let(:input) { ChessInput.new }
  let(:board) { instance_double('ChessBoard') }
  let(:rule) { instance_double('ChessRule') }

  describe '#turn' do
    before do
      allow(rule).to receive(:valid?).and_return(false)
      allow(rule).to receive(:valid?).with(board, :white, anything, anything, anything).and_return(true)
      allow(input).to receive(:gets).and_return('asdf', 5, 'a1 to a3')
    end

    it 'calls input with a block' do
      allow(board).to receive(:col).and_return(0)
      allow(board).to receive(:row).and_return(0)
      allow(input).to receive(:get) do |info, &block|
        expect(block).not_to eq(nil)
        'a1 to a3'
      end
      input.turn(board, rule, :white)
    end

    it 'checks the inputs validity with valid_turn_input?' do
      expect(input).to receive(:valid_turn_input?)
      input.turn(board, rule, :white)
    end

    it 'returns a hash containing values for origin and destination' do
      allow(input).to receive(:get).and_return('a1 to a3')
      allow(board).to receive(:col).with('a1').and_return(0)
      allow(board).to receive(:col).with('a3').and_return(0)
      allow(board).to receive(:row).with('a1').and_return(0)
      allow(board).to receive(:row).with('a3').and_return(2)
      result = input.turn(board, rule, :white)
      expect(result[:origin_col]).to eql(0)
      expect(result[:origin_row]).to eql(0)
      expect(result[:dest_col]).to eql(0)
      expect(result[:dest_row]).to eql(2)
    end
  end

  describe '#valid_turn_input?' do
    xit 'checks the board for a valid move of the given color' do
      expect(rule).to receive(:valid?).with(board, :white, anything, anything, anything)
      input.turn(board, rule, :white)
    end

    xit 'accepts the format c# to c#' do
      allow(input).to receive(:gets).and_return('a1 to a3')
      result = input.turn(board, rule, :white)
      expect(result).not_to eql(nil)
    end
  end
end