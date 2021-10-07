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
    current = :white
    until finish
      puts @board.draw
      move = @input.turn(@board, @rule, current)
      if move.instance_of?(Hash) && [move[:board], move[:turn]].none?(&:nil?)
        @board = move[:board]
        current = move[:turn]
        next
      end

      return if move.eql?('exit')
      next if move.eql?('save')

      @board.move_piece(move[:origin], move[:dest])
      if @rule.checkmate?(@board, current) then finish = :checkmate
      elsif @rule.stalemate?(@board, next_turn(current)) then finish = :stalemate
      elsif @rule.dead_position?(@board) then finish = :dead_position end
      break unless finish == false

      current = next_turn(current)
      warn_check(current) if @rule.check?(@board, current)
    end
    end_game(finish)
  end

  def end_game(reason)
    case reason
    when :stalemate
      puts 'stalemate. No legal moves are possible'
    when :dead_position
      puts 'dead position.'
    when :checkmate
      color = @rule.checkmate?(@board, :black)
      puts "checkmate. #{color.eql?(:black) ? :black : :white} wins"
    end
    play_game if @input.replay
  end

  def next_turn(current)
    current.eql?(:white) ? :black : :white
  end

  def warn_check(current)
    puts "#{current} is in check"
  end
end
