# frozen_string_literal: true

require_relative 'chess_rule'
require_relative 'chess_board'
require_relative 'chess_input'

# Runs a game of chess
class ChessGame
  attr_reader :rule, :board, :input

  def initialize
    @rule = ChessRule.new
    @board = ChessBoard.new
    @input = ChessInput.new
  end

  def play_game
    move = @input.turn(@board, @rule, :white)
    p move
    @board.move_piece(**move)
    puts @board.display
    warn_check if @rule.check?(@board, :white)
    end_game(:stalemate) if @rule.stalemate?(board)
    end_game(:dead_position) if @rule.dead_position?(board)
    end_game(:checkmate) if @rule.checkmate?(board, :black)
    # get input
    # update state of board
    # display board
    # check if in check
    # display check info
    # check for end of game
    #   stalemate, dead position, checkmate?
    # next round or win state
  end

  def end_game(reason)
  end
end
