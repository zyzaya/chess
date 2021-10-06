# frozen_string_literal: true

require 'cell'
require 'chess_move'
require 'chess_input'
require 'chess_rule'
require 'chess_board'
require 'pieces/king'
require 'pieces/rook'

class CastlingBoard < ChessBoard
  def reset_board
    board = Array.new(8).map { Array.new(8, nil) }
    board[0][0] = Rook.new(:white, :left)
    board[4][0] = King.new(:white)
    board
  end
end

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
      # puts board.draw
    end
  end

  describe 'castling' do
    let(:board) { CastlingBoard.new }
    it 'moves the king from e1 to c1' do
      origin = Cell.new('e1')
      dest = Cell.new('c1')
      move.move_piece(input, board, rule, origin, dest)
      result = board.piece(dest)
      expect(result).to be_instance_of(King)
    end

    it 'moves the rook from a1 to d1' do
      origin = Cell.new('e1')
      dest = Cell.new('c1')
      move.move_piece(input, board, rule, origin, dest)
      result = board.piece(Cell.new('d1'))
      expect(result).to be_instance_of(Rook)
    end
  end

  describe 'pawn capture' do
    
  end

  describe 'en passant' do
    
  end

  describe 'promotion' do
    
  end
end