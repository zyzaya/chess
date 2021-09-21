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
    # get input
    # update state of board
    # display board
    # check if in check
    # display check info
    # check for end of game
    #   stalemate, dead position, checkmate?
    # next round or win state
  end
end
