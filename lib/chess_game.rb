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
    finish = false
    until finish
      move = @input.turn(@board, @rule, :white)
      @board.move_piece(**move)
      puts @board.display
      if @rule.checkmate?(board, :black) then finish = :checkmate
      elsif @rule.stalemate?(board) then finish = :stalemate
      elsif @rule.dead_position?(board) then finish = :dead_position end
      break unless finish == false

      warn_check if @rule.check?(@board, :white)
    end
    end_game(finish)
  end

  def end_game(reason)
  end
end
