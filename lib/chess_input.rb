# frozen_string_literal: true

require_relative 'input'

# Allows for the retrieval of Chess related input
class ChessInput
  include Input

  def turn(board, rule, color)
    result = get("#{color}'s turn.") do |val|
      valid_turn_input?(board, rule, color, val)
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
