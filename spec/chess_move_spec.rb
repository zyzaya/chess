# frozen_string_literal: true

require 'chess_move.rb'

describe ChessMove do
  let(:chess_move) { ChessMove.new }
  let(:rule) { instance_double('ChessRule', valid?: true) }
  let(:board) { instance_double('ChessBoard') }

  describe '#move_piece' do
    
    before do
      allow(chess_move).to receive(:move_castle).and_return(false)
      allow(chess_move).to receive(:)
    end

    it 'raises an error if the given move is not valid' do
      
    end

    it 'tries to castle' do
      expect
    end

    it 'tries to move a pawn' do
      
    end

    it 'calls force move if the move is legal, is not castling, and is not a pawn' do
      
    end
  end
end