# frozen_string_literal: true

require 'chess_game'
require 'chess_rule'
require 'pieces/bishop'
require 'pieces/king'
require 'pieces/knight'
require 'pieces/pawn'
require 'pieces/queen'
require 'pieces/rook'

class StalemateBoard < ChessBoard
  def reset_board
    board = Array.new(8).map { Array.new(8, nil) }
    board[0][0] = King.new(:black)
    board[0][0].moved = true
    board[0][1] = Pawn.new(:black)
    board[0][1].moved = true
    board[1][3] = Queen.new(:white)
    board[6][4] = King.new(:white)
    board[6][4].moved = true
    board
  end
end

class DeadPositionBoard < ChessBoard
  def reset_board
    board = Array.new(8).map { Array.new(8, nil) }
    board[0][0] = King.new(:black)
    board[0][0].moved = true
    board[3][4] = King.new(:white)
    board[3][4].moved = true
    board[2][7] = Bishop.new(:white)
    board
  end
end

class CheckmateBoard < ChessBoard

end

describe 'end of game conditions' do
  let(:rule) { ChessRule.new }

  describe 'stalemate' do
    let(:stalemate) { StalemateBoard.new }
    it 'is in stalemate' do
      puts stalemate.draw
      result = rule.stalemate?(stalemate, :black)
      expect(result).to eql(true)
    end
  end

  describe 'dead_position' do
    let(:dead) { DeadPositionBoard.new }
    it 'is in dead position' do
      puts dead.draw
      result = rule.dead_position?(dead)
      expect(result).to eql(true)
    end
  end
end
