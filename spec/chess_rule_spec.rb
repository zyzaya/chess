# frozen_string_literal: true

require 'chess_rule'
# require 'chess_board'

describe ChessRule do
  subject(:chess_rule) { ChessRule.new }

  describe '#valid?' do
    let(:origin) { instance_double('ChessPiece', color: :white) }
    let(:board) { instance_double('ChessBoard') }

    before do
      allow(board).to receive(:on_board?).and_return(true)
      allow(board).to receive(:piece).and_return(origin)
      allow(chess_rule).to receive(:taken_cell?).and_return(true)
      allow(chess_rule).to receive(:valid_piece_move?).and_return(true)
      allow(chess_rule).to receive(:obstructed?).and_return(false)
      allow(chess_rule).to receive(:removes_check?).and_return(true)
    end

    it 'returns false if the origin is a different color' do
      result = chess_rule.valid?(board, :black, 'a7', 'a5')
      expect(result).to be(false)
    end

    it 'returns false if origin is nil' do
      allow(chess_rule).to receive(:taken_cell?).and_return(false)
      result = chess_rule.valid?(board, :white, 'a5', 'a7')
      expect(result).to be(false)
    end

    it 'returns false if the destination is off of the board' do
      allow(board).to receive(:on_board?).and_return(false)
      result = chess_rule.valid?(board, :white, 'g1', 'e0')
      expect(result).to be(false)
    end

    it 'returns false if the king remains in check' do
      allow(chess_rule).to receive(:removes_check?).and_return(false)
      result = chess_rule.valid?(board, :white, 'c2', 'c3')
      expect(result).to be(false)
    end
  end

  describe '#removes_check?' do
    let(:board) { instance_double('ChessBoard') }
    let(:future) { instance_double('ChessBoard') }
    let(:piece) { instance_double('ChessPiece') }

    before do
      allow(chess_rule).to receive(:check?).and_return(true)
      allow(board).to receive(:clone).and_return(future)
      allow(board).to receive(:piece).and_return(piece)
      allow(future).to receive(:move_piece)
      allow(piece).to receive(:color).and_return(:white)
    end

    it 'clones the original board' do
      expect(board).to receive(:clone)
      chess_rule.removes_check?(board, 'b8', 'c6')
    end

    it 'moves piece from origin to dest on the future board' do
      origin = 'b8'
      dest = 'c6'
      expect(future).to receive(:move_piece).with(origin, dest)
      chess_rule.removes_check?(board, origin, dest)
    end

    it 'calls check? with a board as if the move has already happened' do
      expect(chess_rule).to receive(:check?).with(eql(future), anything)
      expect(chess_rule).not_to receive(:check?).with(eql(board), anything)
      chess_rule.removes_check?(board, 'b8', 'c6')
    end
  end

  describe '#check?' do
    let(:board) { instance_double('ChessBoard') }
    let(:piece) { instance_double('ChessPiece', color: :black) }

    before do
      allow(board).to receive(:piece).and_return(piece)
    end

    it 'calls capture_king once for each cell if capture_king? always returns false' do
      allow(chess_rule).to receive(:capture_king?).and_return(false)
      expect(chess_rule).to receive(:capture_king?).with(board, anything, anything).exactly(64).times
      result = chess_rule.check?(board, :white)
      expect(result).to eql(false)
    end

    it 'returns true as soon as capture_king? returns true' do
      allow(chess_rule).to receive(:capture_king?).and_return(false, false, false, true)
      expect(chess_rule).to receive(:capture_king?).with(board, anything, anything).exactly(4).times
      result = chess_rule.check?(board, :white)
      expect(result).to eql(true)
    end
  end

  describe '#obstructed?' do
    let(:board) { instance_double('ChessBoard') }
    let(:piece) { instance_double('ChessPiece') }

    it 'call cells between' do
      allow(chess_rule).to receive(:cells_between).and_return([nil])
      origin = 'h1'
      dest = 'h3'
      expect(chess_rule).to receive(:cells_between).with(board, origin, dest)
      chess_rule.obstructed?(board, origin, dest)
    end

    it 'returns true if there is a piece obstructing the move (except knights)' do
      allow(chess_rule).to receive(:cells_between).and_return([nil, piece])
      result = chess_rule.obstructed?(board, 'h1', 'h3')
      expect(result).to be(true)
    end

    it 'returns false if there are obstructions but the piece is a knight' do
      allow(chess_rule).to receive(:cells_between).and_return([nil, nil])
      result = chess_rule.obstructed?(board, 'b8', 'a6')
      expect(result).to be(false)
    end
  end

  describe '#valid_piece_move?' do
    let(:piece) { instance_double('ChessPiece') }
    let(:board) { instance_double('ChessBoard') }
    let(:origin) { 'a7' }
    let(:dest) { 'a4' }

    before do
      allow(board).to receive(:col).with(origin).and_return(0)
      allow(board).to receive(:row).with(origin).and_return(6)
      allow(board).to receive(:col).with(dest).and_return(0)
      allow(board).to receive(:row).with(dest).and_return(3)
    end

    it 'calls piece#valid? with the difference between the origin and destination column' do
      expect(piece).to receive(:valid?).with(0, anything)
      chess_rule.valid_piece_move?(board, piece, origin, dest)
    end

    it 'calls piece#valid? with the difference between the origin and destination column' do
      expect(piece).to receive(:valid?).with(anything, -3)
      chess_rule.valid_piece_move?(board, piece, origin, dest)
    end
  end

  describe '#cells_between' do
    let(:board) { instance_double('ChessBoard') }
    let(:piece) { instance_double('ChessPiece') }

    before do
      allow(board).to receive(:piece) do |col, row|
        col.eql?(3) && row.eql?(4) ? piece : nil
      end

      allow(board).to receive(:col) { |val| val[0].ord - 'a'.ord }
      allow(board).to receive(:row) { |val| val[1].to_i - 1 }
    end

    it 'returns an array of the cells between origin and dest when horizontal' do
      result = chess_rule.cells_between(board, 'a5', 'h5')
      expect(result.length).to eql(6)
      expect(result.one?(piece)).to eql(true)
      expect(result.reject { |r| r.eql?(piece) }.all?(&:nil?)).to eql(true)
    end

    it 'returns an array of the cells between origin and dest when vertical' do
      result = chess_rule.cells_between(board, 'd2', 'd7')
      expect(result.length).to eql(4)
      expect(result.one?(piece)).to eql(true)
      expect(result.reject { |r| r.eql?(piece) }.all?(&:nil?)).to eql(true)
    end

    it 'returns an array of the cells between origin and dest when diagonal' do
      result = chess_rule.cells_between(board, 'a2', 'g8')
      expect(result.length).to eql(5)
      expect(result.one?(piece)).to eql(true)
      expect(result.reject { |r| r.eql?(piece) }.all?(&:nil?)).to eql(true)
    end
  end

  describe '#capture_king?' do
    let(:board) { instance_double('ChessBoard') }
    let(:piece) { instance_double('ChessPiece', color: :white) }
    let(:col) { 3 }
    let(:row) { 5 }

    before do
      allow(board).to receive(:piece).and_return(piece)
      allow(board).to receive(:col).with('e8').and_return(4)
      allow(board).to receive(:row).with('e8').and_return(7)
      allow(chess_rule).to receive(:find_king).and_return('e8')
      allow(piece).to receive(:valid?).and_return(false)
      allow(piece).to receive(:valid?).with(4, 7).and_return(true)
    end

    it 'gets the piece at col, row' do
      expect(board).to receive(:piece).with(col, row)
      chess_rule.capture_king?(board, col, row)
    end

    it 'gets the location of the king of the opposite color to the piece at col, row' do
      expect(chess_rule).to receive(:find_king).with(board, :black)
      chess_rule.capture_king?(board, col, row)
    end

    it 'checks if the piece can move to the location of the king' do
      expect(piece).to receive(:valid?).with(4, 7)
      result = chess_rule.capture_king?(board, col, row)
      expect(result).to eql(true)
    end
  end
end
