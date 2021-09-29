# frozen_string_literal: true

require 'chess_move.rb'

describe ChessMove do
  let(:chess_move) { ChessMove.new }
  let(:rule) { instance_double('ChessRule', valid?: true) }
  let(:board) { instance_double('ChessBoard') }
  let(:piece) { instance_double('ChessPiece', color: :white)}
  origin = 'a1'
  dest = 'b2'

  describe '#move_piece' do
    
    before do
      allow(chess_move).to receive(:move_castle).and_return(false)
      allow(chess_move).to receive(:move_pawn).and_return(false)
      allow(board).to receive(:piece).and_return(piece)
    end

    it 'raises an error if the given move is not valid' do
      allow(rule).to receive(:valid?).and_return(false)
      expect do
        chess_move.move_piece(board, rule, origin, dest)
      end.to raise_exception(ArgumentError)
    end

    it 'tries to castle' do
      expect(chess_move).to receive(:move_castle)
      chess_move.move_piece(board, rule, origin, dest)
    end

    it 'returns if it castled' do
      allow(chess_move).to receive(:move_castle).and_return(true)
      expect(chess_move).not_to receive(:generic_move)
      chess_move.move_piece(board, rule, origin, dest)
    end

    it 'tries to move a pawn' do
      expect(chess_move).to receive(:move_pawn)
      chess_move.move_piece(board, rule, origin, dest)
    end

    it 'returns if it moved a pawn' do
      allow(chess_move).to receive(:move_pawn).and_return(true)
      expect(chess_move).not_to receive(:generic_move)
      chess_move.move_piece(board, rule, origin, dest)
    end

    it 'calls generic move if the move is legal, is not castling, and is not a pawn' do
      expect(chess_move).to receive(:generic_move)
      chess_move.move_piece(board, rule, origin, dest)
    end
  end
end