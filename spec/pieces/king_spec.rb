require 'pieces/king'

describe King do
  subject(:king) { King.new(:white) }

  describe 'moveset' do
    it 'can move one square diagonaly in any direction' do
      moveset = [[-1, 1], [1, 1], [-1, -1], [1, -1]]
      moveset.each do |move|
        result = king.valid?(move[0], move[1])
        expect(result).to be(true)
      end
    end

    it 'can move one square horizontaly in any direction' do
      moveset = [[-1, 0], [1, 0]]
      moveset.each do |move|
        result = king.valid?(move[0], move[1])
        expect(result).to be(true)
      end
    end

    it 'can move one square verticaly in any direction' do
      moveset = [[0, 1], [0, -1]]
      moveset.each do |move|
        result = king.valid?(move[0], move[1])
        expect(result).to be(true)
      end
    end

    it 'cannot move seven squares down' do
      result = king.valid?(0, -7)
      expect(result).to be(false)
    end
  end

  # describe 'castling' do
  #   it 'can castle if it has not moved' do
      
  #   end

  #   it 
  # end

  # it 'can track if it has moved' do
    
  # end
end