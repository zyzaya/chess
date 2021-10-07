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

  describe '#add_capture' do
    it 'adds diagonal down if black' do
      black_pawn.add_capture(:left)
      black_pawn.add_capture(:right)
      left = black_pawn.valid?(-1, -1)
      right = black_pawn.valid?(1, -1)
      expect(left).to be(true)
      expect(right).to be(true)
    end

    it 'adds diagonal up if white' do
      white_pawn.add_capture(:left)
      white_pawn.add_capture(:right)
      left = white_pawn.valid?(-1, 1)
      right = white_pawn.valid?(1, 1)
      expect(right).to be(true)
      expect(left).to be(true)
    end
  end

  describe '#remove_capture' do
    before do
      black_pawn.add_capture(:left)
      black_pawn.add_capture(:right)
      white_pawn.add_capture(:left)
      white_pawn.add_capture(:right)
    end

    it 'removes diagonal down if black' do
      black_pawn.remove_capture(:left)
      black_pawn.remove_capture(:right)
      left = black_pawn.valid?(-1, -1)
      right = black_pawn.valid?(1, -1)
      expect(left).to be(false)
      expect(right).to be(false)
    end

    it 'removes diagonal up if white' do
      white_pawn.remove_capture(:left)
      white_pawn.remove_capture(:right)
      left = white_pawn.valid?(-1, 1)
      right = white_pawn.valid?(1, 1)
      expect(right).to be(false)
      expect(left).to be(false)
    end
  end

  describe '#en_passant' do
    it 'adds diagonal down if black' do
      black_pawn.en_passant(:left)
      black_pawn.en_passant(:right)
      left = black_pawn.valid?(-1, -1)
      right = black_pawn.valid?(1, -1)
      expect(left).to be(true)
      expect(right).to be(true)
    end

    it 'adds diagonal up if white' do
      white_pawn.en_passant(:left)
      white_pawn.en_passant(:right)
      left = white_pawn.valid?(-1, 1)
      right = white_pawn.valid?(1, 1)
      expect(right).to be(true)
      expect(left).to be(true)
    end
  end

  describe '#remove_en_passant' do
    before do
      black_pawn.en_passant(:left)
      black_pawn.en_passant(:right)
      white_pawn.en_passant(:left)
      white_pawn.en_passant(:right)
    end

    it 'removes diagonal down if black' do
      black_pawn.remove_en_passant
      left = black_pawn.valid?(-1, -1)
      right = black_pawn.valid?(1, -1)
      expect(left).to be(false)
      expect(right).to be(false)
    end

    it 'removes diagonal up if white' do
      white_pawn.remove_en_passant
      left = white_pawn.valid?(-1, 1)
      right = white_pawn.valid?(1, 1)
      expect(left).to be(false)
      expect(right).to be(false)
    end

    it 'does not remove a previously set capture' do
      white_pawn.add_capture(:left)
      white_pawn.remove_en_passant
      result = white_pawn.valid?(-1, 1)
      expect(result).to be(true)
    end
  end

  describe '#add_all_captures' do
    let(:board) { instance_double('ChessBoard') }
    let(:left) { instance_double('Cell') }
    let(:right) { instance_double('Cell') }
    let(:cell) { instance_double('Cell', col: 5, row: 6, input: 'f7') }

    before do
      allow(board).to receive(:on_board?).and_return(true)
      allow(white_pawn).to receive(:capture_cell).with(cell, :left).and_return(left)
      allow(white_pawn).to receive(:capture_cell).with(cell, :right).and_return(right)
      allow(board).to receive(:piece).and_return(black_pawn)
    end

    it 'does not add capture if target is off of the board' do
      allow(board).to receive(:on_board?).and_return(false)
      expect(white_pawn).not_to receive(:add_capture)
      white_pawn.add_all_captures(board, cell)
    end

    it 'does not add capture if the piece is the same color' do
      allow(board).to receive(:piece).and_return(white_pawn)
      expect(white_pawn).not_to receive(:add_capture)
      white_pawn.add_all_captures(board, cell)
    end

    it 'adds capture if target is on board and of the opposite color' do
      expect(white_pawn).to receive(:add_capture).with(:left)
      expect(white_pawn).to receive(:add_capture).with(:right)
      white_pawn.add_all_captures(board, cell)
    end
  end

  describe '#capture_cell' do
    let(:cell) { instance_double('Cell', col: 5, row: 5, input: 'f6') }

    it 'subtracts one from col if side is left' do
      result = white_pawn.capture_cell(cell, :left)
      expect(result.col).to eql(cell.col - 1)
    end

    it 'adds one to col if side is right' do
      result = white_pawn.capture_cell(cell, :right)
      expect(result.col).to eql(cell.col + 1)
    end

    it 'subtracts one from row if color is black' do
      result = black_pawn.capture_cell(cell, :right)
      expect(result.row).to eql(cell.row - 1)
    end

    it 'adds one to row if color is white' do
      result = white_pawn.capture_cell(cell, :left)
      expect(result.row).to eql(cell.row + 1)
    end
  end

  describe '#double_move?' do
    let(:origin) { instance_double('Cell', col: 2, row: 6) }
    let(:dest) { instance_double('Cell', col: 2, row: 4) }

    it 'returns true if the movement is two rows and zero columns' do
      result = white_pawn.double_move?(origin, dest)
      expect(result).to eql(true)
    end

    it 'returns false if the movement is not a double move' do
      wrong_dest = instance_double('Cell', col: 2, row: 5)
      result = white_pawn.double_move?(origin, wrong_dest)
      expect(result).to eql(false)
    end
  end

  describe '#promote?' do
    it 'returns true if the color is black and the row is 0' do
      dest = instance_double('Cell', col: 3, row: 0)
      result = black_pawn.promote?(dest)
      expect(result).to eql(true)
    end

    it 'returns true if the color is white and the row is 7' do
      dest = instance_double('Cell', col: 3, row: 7)
      result = white_pawn.promote?(dest)
      expect(result).to eql(true)
    end

    it 'returns false if the pawn is not at the opposite end' do
      dest = instance_double('Cell', col: 3, row: 2)
      result = black_pawn.promote?(dest)
      expect(result).to eql(false)
    end
  end

  describe '#en_passant?' do
    
  end
end
