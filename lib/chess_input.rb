# frozen_string_literal: true
require_relative 'input'

class ChessInput
  include Input

  def initialize
    
  end

  def turn(board, rule, color)
    # result = get("#{color.to_s}'s turn.") do |val|
    #   false unless
    #     val.is_a?(String) &&
    #     val.length == 6
    #   val = val.split
    #   false unless
    #     val.length == 3 &&
    #     val.all? { |v| v.length == 2 }
    #   origin_col = board.col(v[0])
    #   origin_row = board.row(v[0])
    #   dest_col = board.col(v[2])
    #   dest_row = board.col(v[2])
    #   false if [origin_col, origin_row, dest_col, dest_row].any?(&:nil?)
    #   p val
    #   true
    # end
    result = get("#{color.to_s}'s turn.") do |val|
      return valid_turn_input?(val)
    end
    result = result.split
    {
      origin_col: board.col(result[0]),
      origin_row: board.row(result[0]),
      dest_col: board.col(result[2]),
      dest_row: board.row(result[2])
    }
    
    # p "r #{result}"
    # a1 to b3
    # is a valid move if
    #  in the format c# to c#
    #   where c is characters a to h
    #   and # is the numebers 1 to 8
    # the board defines the move as legal
    # returns the format 
    #   {origin_col: c#, origin_row: c#, dest_col: c#, dest_row: c#}
    # *additional information about the invalid movement is
    # handled by ChessGame
  end

  def valid_turn_input?(val)
    p 'avl'
    p val
    !val.nil?
  end
end
