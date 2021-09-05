# frozen_string_literal: true

require 'chess_rule'
# require 'chess_board'

describe ChessRule do
  subject(:chess_rule) { ChessRule.new }
  # let(:board) { ChessBoard.new.reset_board }

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

  describe 'removes_check?' do
    before do
      allow(chess_rule).to receive(:check?).and_return(true)
    end

    it 'does not modify the board' do
      current = board.map { |col| col.map { |cell| cell } }
      origin = 'b8'
      dest = 'c6'
      chess_rule.removes_check?(board, origin, dest)
      expect(board).to eql(current)
    end

    it 'calls check? with a board as if the move has already happened' do
      future = board.map { |col| col.map { |cell| cell } }
      origin = 'b8'
      dest = 'c6'
      future[2][5] = board[1][7]
      future[1][7] = nil
      expect(chess_rule).to receive(:check?).with(eql(future), anything)
      expect(chess_rule).not_to receive(:check?).with(eql(board), anything)
      chess_board.removes_check?(board, origin, dest)
    end
  end

  describe '#check?' do
    before do
      allow(chess_rule).to receive(:find_king).and_return('d8')
    end

    it 'returns false if no piece can capture the king' do
      result = chess_rule.check?(board, :black)
      expect(result).to be(false)
    end

    it 'returns true if any piece can capture the king' do
      board[4][6] = nil
      board[3][1] = nil
      board[6][4] = board[2][0]
      board[2][0] = nil
      result = chess_rule.check?(board, :black)
      expect(result).to be(true)
    end
  end

  describe '#obstructed?' do
    let(:board) { instance_double('ChessBoard') }

    it 'call cells between' do
      allow(chess_rule).to receive(:cells_between).and_return([nil])
      origin = 'h1'
      dest = 'h3'
      expect(chess_rule).to receive(:cells_between).with(board, origin, dest)
      chess_rule.obstructed?(board, origin, dest)
    end

    it 'returns true if there is a piece obstructing the move (except knights)' do
      result = chess_rule.obstructed?(board, 'h1', 'h3')
      expect(result).to be(true)
    end

    it 'returns false if there are obstructions but the piece is a knight' do
      result = chess_rule.obstructed?(board, 'b8', 'a6')
      expect(result).to be(false)
    end
  end

  describe '#valid_piece_move?' do
    let(:piece) { board[0][6] }

    it 'returns false if the move to dest is not a legal move by the piece at origin' do
      origin = 'a7'
      dest = 'a4'
      result = chess_rule.valid_piece_move?(piece, origin, dest)
      expect(result).to be(false)
    end

    it 'returns true if the move to dest is a legal move by the piece at origin' do
      origin = 'a7'
      dest = 'a5'
      result = chess_rule.valid_piece_move?(piece, origin, dest)
      expect(result).to be(true)
    end
  end
end
