require 'pieces/queen'

describe Queen do
  subject(:queen) { Queen.new(:black) }
  let(:size) { 8 }


  describe 'moveset' do
    it 'can move horizontally to any relative location' do
      1.upto(size) do |i|
        result = queen.valid?(0, i)
        expect(result).to be(true)
        result = queen.valid?(0, -i)
        expect(result).to be(true)
      end
    end

    it 'can move vertically to any relative location' do
      1.upto(size) do |i|
        result = queen.valid?(i, 0)
        expect(result).to be(true)
        result = queen.valid?(-i, 0)
        expect(result).to be(true)
      end
    end

    it 'can move diagonally to any relative location' do
      1.upto(size) do |i|
        result = queen.valid?(-i, i)
        expect(result).to be(true)
        result = queen.valid?(i, i)
        expect(result).to be(true)
        result = queen.valid?(-i, -i)
        expect(result).to be(true)
        result = queen.valid?(i, -i)
        expect(result).to be(true)    
      end
    end
  end
end