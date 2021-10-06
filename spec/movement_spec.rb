# frozen_string_literal: true

require 'cell'
require 'chess_move'
require 'chess_input'
require 'chess_rule'
require 'chess_board'

describe 'movement' do
  let(:move) { ChessMove.new }
  let(:input) { ChessInput.new }
  let(:rule) { ChessRule.new }

  describe 'common move' do
    let(:board) { ChessBoard.new }
    
    it 'moves a pawn from d2 to d4' do
      origin = Cell.new('d2')
      dest = Cell.new('d4')
      move.move_piece(input, board, rule, origin, dest)
      result = board.piece(dest)
      expect(result).not_to eql(nil)  
    end
  end

  describe 'castling' do
    
  end

  describe 'pawn capture' do
    
  end

  describe 'en passant' do
    
  end

  describe 'promotion' do
    
  end
end