# frozen_string_literal: true

require_relative 'input'
require_relative 'cell'
require 'yaml'

# Allows for the retrieval of Chess related input
class ChessInput
  include Input

  def initialize
    @filename = ''
  end

  def turn(board, rule, color)
    result = get("#{color}'s turn.", 'Invalid input.', %w[save exit]) do |val|
      valid_turn_input?(board, rule, color, val)
    end
    save(board, color) if result.eql?('save')
    return nil if %w[save exit].include?(result)

    result = result.split
    {
      origin: Cell.new(result[0]),
      dest: Cell.new(result[2])
    }
  end

  def save(board, current)
    Dir.mkdir('saves') unless Dir.exist?('saves')
    if @filename.eql?('')
      @filename = get('Enter save name', 'invalid') do |val|
        val.match(/[A-Za-z]*/)
      end
    end
    @filename = "saves/#{@filename}.ch"
    File.open(@filename, 'w') do |file|
      file.puts("turn: #{current}")
      file.puts(YAML.dump(board))
    end
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
    origin = Cell.new(match[0])
    dest = Cell.new(match[2])
    return false unless board.on_board?(origin) && board.on_board?(dest)

    p 'is on board'
    rule.valid?(board, color, origin, dest)
  end

  def promote
    get('Pawn promotion. Select bishop, knight, queen, or rook.',
        'Invalid. Select bishop, knight, queen, or rook.',
        %w[bishop knight queen rook])
  end
end
