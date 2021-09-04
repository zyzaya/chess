# frozen_string_literal: true

require 'chess_rule'
require 'chess_board'

describe ChessRule do
  subject(:chess_rule) { ChessRule.new }
  let(:board) { ChessBoard.new.reset_board}
  
  describe '#valid?' do
    it 'returns false if the origin is a different color' do
      color = :white
      origin = 'a7'
      dest = 'a5'
      result = chess_rule.valid?(board, color, origin, dest)
      expect(result).to be(false)
    end

    it 'returns false if origin is nil' do
      color = :white
      origin = 'a5'
      dest = 'b5'
      result = chess_rule.valid?(board, color, origin, dest)
      expect(result).to be(false)
    end

    it 'returns false if the destination is off of the board' do
      color = :white
      origin = 'g1'
      dest = 'e0'
      result = chess_rule.valid?(board, color, origin, dest)
      expect(result).to be(false)
    end

    it 'returns false if the king remains in check' do
      allow(chess_board).to receive(:check?).and_return(true)
      color = :white
      origin = 'c2'
      dest = 'c3'
      result = chess_rule.valid?(board, color, origin, dest)
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
