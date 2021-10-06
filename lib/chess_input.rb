# frozen_string_literal: true

require_relative 'input'
require_relative 'cell'

# Allows for the retrieval of Chess related input
class ChessInput
  include Input

  def turn(board, rule, color)
    result = get("#{color}'s turn.", 'Invalid input.') do |val|
      valid_turn_input?(board, rule, color, val)
    end
    result = result.split
    {
      origin: Cell.new(result[0]),
      dest: Cell.new(result[2])
    }
  end

  def replay
    result = get('play again?', 'Invalid input.', %w[y yes n no])
    %w[y yes].include?(result)
  end

  def valid_turn_input?(board, rule, color, val)
    return false unless val.is_a?(String)
    p 'is a string'
    match = val.match(/\A[abcdefgh][12345678] to [abcdefgh][12345678]\z/)
    return false if match.nil?
    p 'is a match'
    match = match[0].split
    origin = match[0]
    dest = match[2]
    return false if
      [board.col(origin), board.row(origin), board.col(dest), board.row(dest)].any?(&:nil?)
    p 'is on board'
    rule.valid?(board, color, origin, dest)
  end

  def promote
    get('Pawn promotion. Select bishop, knight, queen, or rook.',
        'Invalid. Select bishop, knight, queen, or rook.',
        %w[bishop knight queen rook])
  end
end
