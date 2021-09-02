require 'chess_piece'

describe ChessPiece do
  subject(:piece) { ChessPiece.new(:white) }

  describe '#color' do
    it 'can access the color of the piece' do
      result = piece.color
      expect(result).to eql(:white)
    end
  end
end