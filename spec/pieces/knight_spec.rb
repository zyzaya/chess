# frozen_string_literal: true

require 'pieces/knight'

describe Knight do
  subject(:knight) { Knight.new(:black) }
  
  describe 'moveset' do
    it 'can move horizontally two and up one' do
      result = knight.valid?(-2, 1)
      expect(result).to be(true)
      result = knight.valid?(2, 1)
      expect(result).to be(true)
    end

    it 'can move horizontally two and down one' do
      result = knight.valid?(-2, -1)
      expect(result).to be(true)
      result = knight.valid?(2, -1)
      expect(result).to be(true)
    end

    it 'can move vertically two and left one' do
      result = knight.valid?(-1, 2)
      expect(result).to be(true)
      result = knight.valid?(-1, -2)
      expect(result).to be(true)
    end

    it 'can move vertically two and right one' do
      result = knight.valid?(1, 2)
      expect(result).to be(true)
      result = knight.valid?(1, -2)
      expect(result).to be(true)
    end
  end
end