# frozen_string_literal: true

# Receives input from the command line
module Input
  def get(info, valid_values = nil, &block)
    puts info
    valid = false
    valid_values = valid_values&.map(&:downcase)
    input = gets until block&.call(input) || valid_values&.include?(input.to_s&.downcase)
    input
  end
end
