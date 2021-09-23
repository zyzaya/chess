# frozen_string_literal: true

# Receives input from the command line
module Input
  def get(info, invalid, valid_values = nil, &block)
    puts info
    valid_values = valid_values&.map(&:downcase)
    input = ''
    valid = false
    until valid
      input = gets.chomp
      valid = block&.call(input) || valid_values&.include?(input.to_s&.downcase)
      puts invalid unless valid
    end
    input
  end
end
