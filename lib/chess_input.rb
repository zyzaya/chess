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
      return valid_turn_input?(board, rule, color, val)
    end
    result = result.split
    {
      origin_col: board.col(result[0]),
      origin_row: board.row(result[0]),
      dest_col: board.col(result[2]),
      dest_row: board.row(result[2])
    }
  end

  def valid_turn_input?(board, rule, color, val)
    return false unless 
      val.is_a?(String) &&
      val.length == 8
    val = val.split
    return false unless
      val.length == 3 &&
      val.all? { |v| v.length == 2 }
    return false if
      [board.col(val[0]), board.row(val[0]), board.col(val[2]), board.col(val[2])].any?(&:nil?)
    return rule.valid?(board, color, val[0], val[2])
  end
end
