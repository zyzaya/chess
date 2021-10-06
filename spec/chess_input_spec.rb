# frozen_string_literal: true
require 'chess_input'

describe ChessInput do
  let(:input) { ChessInput.new }
  let(:board) { instance_double('ChessBoard') }
  let(:rule) { instance_double('ChessRule') }

  describe '#turn' do
    before do
      allow(input).to receive(:gets).and_return('asdf', '5', 'a1 to a3')
    end

    it 'calls input with a block' do
      allow(board).to receive(:col).and_return(0)
      allow(board).to receive(:row).and_return(0)
      allow(input).to receive(:get) do |_, &block|
        expect(block).not_to eq(nil)
        'a1 to a3'
      end
      input.turn(board, rule, :white)
    end

    it 'checks the inputs validity with valid_turn_input?' do
      allow(board).to receive(:col).with('a1').and_return(0)
      allow(board).to receive(:row).with('a1').and_return(0)
      allow(board).to receive(:col).with('a3').and_return(0)
      allow(board).to receive(:row).with('a3').and_return(2)
      allow(input).to receive(:valid_turn_input?).and_return(false, false, false, true)
      expect(input).to receive(:valid_turn_input?).with(board, rule, :white, anything)
      input.turn(board, rule, :white)
    end

    it 'returns a hash containing values for origin and destination' do
      allow(input).to receive(:get).and_return('a1 to a3')
      allow(board).to receive(:col).with('a1').and_return(0)
      allow(board).to receive(:row).with('a1').and_return(0)
      allow(board).to receive(:col).with('a3').and_return(0)
      allow(board).to receive(:row).with('a3').and_return(2)
      result = input.turn(board, rule, :white)
      expect(result[:origin].col).to eql(0)
      expect(result[:origin].row).to eql(0)
      expect(result[:dest].col).to eql(0)
      expect(result[:dest].row).to eql(2)
    end
  end

  describe '#valid_turn_input?' do
    it 'returns false if val is not a string' do
      result = input.valid_turn_input?(board, rule, :white, 5)
      expect(result).to be(false)
    end

    it 'returns false if val is not a set of three two character strings separated by a single space' do
      result = input.valid_turn_input?(board, rule, :white, 'a2 asdf a3')
      expect(result).to be(false)
    end

    it 'returns false if either value is not on the board' do
      allow(board).to receive(:col).and_return(nil)
      allow(board).to receive(:row).and_return(nil)
      result = input.valid_turn_input?(board, rule, :white, 'a9 to b1')
      expect(result).to be(false)
    end

    it 'checks the board for a valid move of the given color' do
      allow(board).to receive(:col).with('a1').and_return(0)
      allow(board).to receive(:row).with('a1').and_return(0)
      allow(board).to receive(:col).with('a3').and_return(0)
      allow(board).to receive(:row).with('a3').and_return(2)
      expect(rule).to receive(:valid?).with(board, :white, 'a1', 'a3')
      result = input.valid_turn_input?(board, rule, :white, 'a1 to a3')
      p result
    end

    it 'accepts the format c# to c#' do
      allow(rule).to receive(:valid?).and_return(true)
      allow(board).to receive(:col).with('a1').and_return(0)
      allow(board).to receive(:row).with('a1').and_return(0)
      allow(board).to receive(:col).with('a3').and_return(0)
      allow(board).to receive(:row).with('a3').and_return(2)
      result = input.valid_turn_input?(board, rule, :white, 'a1 to a3')
      expect(result).to be(true)
    end
  end

  describe '#replay' do
    it 'calls get with %[y yes n no] as valid values' do
      allow(input).to receive(:get)
      expect(input).to receive(:get).with(anything, anything, %w[y yes n no])
      input.replay
    end

    it 'returns true when given input is y or yes' do
      allow(input).to receive(:get).and_return('yes')
      result = input.replay
      expect(result).to eql(true)
    end

    it 'returns false when the given input is n or no' do
      allow(input).to receive(:get).and_return('n')
      result = input.replay
      expect(result).to eql(false)
    end
  end

  describe '#promote' do
    valid = %w[bishop knight queen rook]

    before do
      allow(input).to receive(:gets).and_return('asdfasd', 'queen')
    end

    it "uses #get to receive an input between #{valid}" do
      expect(input).to receive(:get).with(anything, anything, array_including('bishop', 'knight', 'queen', 'rook'))
      input.promote
    end

    it 'returns the name of the piece the user chose' do
      result = input.promote
      expect(valid.include?(result)).to eql(true)
    end
  end
end
