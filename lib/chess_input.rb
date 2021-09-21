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
    result = get("#{color}'s turn.") do |val|
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
    return false unless val.is_a?(String)

    match = val.match(/\A[abcdefgh][12345678] to [abcdefgh][12345678]\z/)
    return false if match.nil?

    match = match[0].split
    origin = match[0]
    dest = match[2]
    return false if
      [board.col(origin), board.row(origin), board.col(dest), board.row(dest)].any?(&:nil?)

    rule.valid?(board, color, origin, dest)
  end
end
